package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func GetPublicAccessBlockConfiguration(t *testing.T, terraformOptions *terraform.Options) *s3.PublicAccessBlockConfiguration {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return nil
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetPublicAccessBlockInput{
		Bucket: awssdk.String(bucketName),
	}

	var publicAccessBlockConfiguration *s3.PublicAccessBlockConfiguration
	maxRetries := 3

	retryDuration := time.Duration(30)
	_, err = retry.DoWithRetryE(t, "Get public access block configuration", maxRetries, retryDuration,
		func() (string, error) {
			publicAccessBlock, err := s3Client.GetPublicAccessBlock(params)

			if err != nil {
				assert.FailNow(t, "Error Getting public access block for client")
				return "", nil
			}

			publicAccessBlockConfiguration = publicAccessBlock.PublicAccessBlockConfiguration
			return "Retrieved public access block configuration", nil
		},
	)

	if err != nil {
		assert.FailNow(t, "Error on retry")
		return nil
	}

	return publicAccessBlockConfiguration
}

func AssertS3BucketEncryptionEnabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketEncryptionInput{
		Bucket: awssdk.String(bucketName),
	}

	maxRetries := 3
	retryDuration := time.Duration(30)
	_, retryErr := retry.DoWithRetryE(t, "Get bucket encryption", maxRetries, retryDuration,
		func() (string, error) {
			encryption, err := s3Client.GetBucketEncryption(params)

			if err != nil {
				assert.FailNow(t, "Error getting bucket encryption")
				return "", nil
			}

			expectedEncryption := "AES256"
			for _, element := range encryption.ServerSideEncryptionConfiguration.Rules {
				actualEncryption := element.ApplyServerSideEncryptionByDefault.SSEAlgorithm
				if *actualEncryption != expectedEncryption {
					return "", fmt.Errorf("server side encryption test failed. got: %v, expected: %v", actualEncryption, expectedEncryption)
				}
			}
			return "Retrieved bucket encryption", nil
		},
	)
	if retryErr != nil {
		assert.FailNow(t, "Error on retry")
		return
	}
}

func AssertS3BucketPublicAccessBlockConfigurationEnabled(t *testing.T, terraformOptions *terraform.Options) {
	config := GetPublicAccessBlockConfiguration(t, terraformOptions)

	if !*config.BlockPublicAcls {
		assert.FailNowf(t, "Block public ACLs not enabled", "%s\n")
		return
	}
	if !*config.BlockPublicPolicy {
		assert.FailNowf(t, "Block public policy not enabled", "%s\n")
		return
	}
	if !*config.IgnorePublicAcls {
		assert.FailNowf(t, "Ignore public ACLs not enabled", "%s\n")
		return
	}
	if !*config.RestrictPublicBuckets {
		assert.FailNowf(t, "Restrict public buckets not enabled", "%s\n")
		return
	}
}

func AssertS3BucketPublicAccessBlockConfigurationDisabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetPublicAccessBlockInput{
		Bucket: awssdk.String(bucketName),
	}

	_, err = s3Client.GetPublicAccessBlock(params)

	if err != nil {
		return
	}
	assert.Equal(t, "NoSuchPublicAccessBlockConfiguration", err)
}

func AssertS3BucketLoggingEnabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketLoggingInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketLogging, err := s3Client.GetBucketLogging(params)
	if err != nil {
		assert.FailNow(t, "Error getting bucket Logging")
		return
	}

	loggingEnabled := bucketLogging.LoggingEnabled
	if loggingEnabled == nil {
		assert.FailNow(t, "Logging not enabled")
		return
	}

	actual := *loggingEnabled.TargetBucket
	loggingBucketName := terraformOptions.Vars["logging_bucket"].(string)
	expected := loggingBucketName
	if actual != expected {
		assert.FailNowf(t, ("Logging target bucket does not match expected. Got: %v, Expected: %v"), actual, expected)
	}
}

func AssertS3BucketLoggingNotEnabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketLoggingInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketLogging, err := s3Client.GetBucketLogging(params)
	if err != nil {
		assert.FailNow(t, "Error getting bucket logging")
		return
	}

	loggingEnabled := bucketLogging.LoggingEnabled
	if loggingEnabled != nil {
		assert.FailNow(t, "Logging is enabled")
		return
	}
}

func AssertS3BucketPolicyContainsNonTLSDeny(t *testing.T, terraformOptions *terraform.Options) {
	bucketName := terraformOptions.Vars["test_name"].(string)
	pattern := fmt.Sprintf(`{"Sid":"enforce-tls-requests-only","Effect":"Deny","Principal":{"AWS":"*"},"Action":"s3:*","Resource":"arn:aws:s3:::%s/*","Condition":{"Bool":{"aws:SecureTransport":"false"}}}`, bucketName)
	AssertS3BucketPolicyContains(t, terraformOptions, pattern)
}

func AssertS3BucketPolicyContains(t *testing.T, terraformOptions *terraform.Options, pattern string) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	bucketName := terraformOptions.Vars["test_name"].(string)
	policy, err := aws.GetS3BucketPolicyE(t, region, bucketName)
	require.NoError(t, err)

	if !strings.Contains(policy, pattern) {
		assert.FailNowf(t, "could not find pattern: %s in policy: %s", pattern, policy)
		return
	}
}

func AssertS3BucketAnalyticsEnabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.ListBucketAnalyticsConfigurationsInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketAnalytics, err := s3client.ListBucketAnalyticsConfigurations(params)
	if err != nil {
		assert.FailNow(t, "Error listing bucket analytics configurations")
		return
	}

	analytics := bucketAnalytics.AnalyticsConfigurationList
	if len(analytics) < 1 {
		assert.FailNow(t, "Analytics is not enabled")
		return
	}
}

func AssertS3BucketCorsEnabled(t *testing.T, terraformOptions *terraform.Options) {
	region := terraformOptions.EnvVars["AWS_DEFAULT_REGION"]
	s3Client, err := aws.NewS3ClientE(t, region)
	if err != nil {
		assert.FailNow(t, "Error creating s3client")
		return
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketCorsInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketCors, err := s3Client.GetBucketCors(params)

	if err != nil {
		assert.FailNow(t, "Error getting bucket cors configurations")
		return
	}

	cors := bucketCors.CORSRules
	if cors == nil {
		assert.FailNow(t, "cors subresources not enabled")
		return
	}

}
