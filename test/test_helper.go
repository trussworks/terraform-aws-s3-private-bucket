package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func GetPublicAccessBlockConfiguration(t *testing.T, terraformOptions *terraform.Options) *s3.PublicAccessBlockConfiguration {
	config, err := GetPublicAccessBlockConfigurationE(t, terraformOptions)
	require.NoError(t, err)
	return config

}

func GetPublicAccessBlockConfigurationE(t *testing.T, terraformOptions *terraform.Options) (*s3.PublicAccessBlockConfiguration, error) {
	region := terraformOptions.Vars["region"].(string)
	s3Client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return nil, err
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetPublicAccessBlockInput{
		Bucket: awssdk.String(bucketName),
	}

	var publicAccessBlockConfiguration *s3.PublicAccessBlockConfiguration
	maxRetries := 3
	retryDuration := 3 * time.Second
	_, err = retry.DoWithRetryE(t, "Get public access block configuration", maxRetries, retryDuration,
		func() (string, error) {
			publicAccessBlock, err := s3Client.GetPublicAccessBlock(params)
			if err != nil {
				return "", err
			}
			publicAccessBlockConfiguration = publicAccessBlock.PublicAccessBlockConfiguration
			return "Retrieved public access block configuration", nil
		},
	)

	if err != nil {
		return nil, err
	}

	return publicAccessBlockConfiguration, nil
}

func AssertS3BucketEncryptionEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketEncryptionEnabledE(t, terraformOptions)
	require.NoError(t, err)
}

func AssertS3BucketEncryptionEnabledE(t *testing.T, terraformOptions *terraform.Options) error {
	region := terraformOptions.Vars["region"].(string)
	s3Client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return err
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketEncryptionInput{
		Bucket: awssdk.String(bucketName),
	}

	maxRetries := 3
	retryDuration := 3 * time.Second
	_, err = retry.DoWithRetryE(t, "Get bucket encryption", maxRetries, retryDuration,
		func() (string, error) {
			encryption, err := s3Client.GetBucketEncryption(params)

			if err != nil {
				return "", err
			}

			expectedEncryption := "AES256"
			for _, element := range encryption.ServerSideEncryptionConfiguration.Rules {
				actualEncryption := element.ApplyServerSideEncryptionByDefault.SSEAlgorithm
				if *actualEncryption != expectedEncryption {
					return "", fmt.Errorf("server side encyption test failed. got: %v, expected: %v", actualEncryption, expectedEncryption)
				}
			}

			return "Retrieved bucket encryption", nil
		},
	)

	return err
}

func AssertS3BucketBlockPublicACLEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketPublicAccessBlockConfigurationEnabledE(t, terraformOptions, "BlockPublicAcls")
	require.NoError(t, err)
}

func AssertS3BucketBlockPublicPolicyEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketPublicAccessBlockConfigurationEnabledE(t, terraformOptions, "BlockPublicPolicy")
	require.NoError(t, err)
}

func AssertS3BucketIgnorePublicACLEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketPublicAccessBlockConfigurationEnabledE(t, terraformOptions, "IgnorePublicAcls")
	require.NoError(t, err)
}

func AssertS3BucketRestrictPublicBucketsEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketPublicAccessBlockConfigurationEnabledE(t, terraformOptions, "RestrictPublicBuckets")
	require.NoError(t, err)
}

func AssertS3BucketPublicAccessBlockConfigurationEnabledE(t *testing.T, terraformOptions *terraform.Options, configType string) error {
	config := GetPublicAccessBlockConfiguration(t, terraformOptions)

	expected := true
	switch configType {
	case "BlockPublicAcls":
		if *config.BlockPublicAcls != expected {
			return fmt.Errorf("Block public ACLs not enabled")
		}
	case "BlockPublicPolicy":
		if *config.BlockPublicPolicy != expected {
			return fmt.Errorf("Block public policy not enabled")
		}
	case "IgnorePublicAcls":
		if *config.IgnorePublicAcls != expected {
			return fmt.Errorf("Ignore public ACLs not enabled")
		}
	case "RestrictPublicBuckets":
		if *config.RestrictPublicBuckets != expected {
			return fmt.Errorf("Restrict public buckets not enabled")
		}
	default:
		return fmt.Errorf("Unrecognized public access block configuration type")
	}

	return nil
}

func AssertS3BucketLoggingEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketLoggingEnabledE(t, terraformOptions)
	require.NoError(t, err)
}

func AssertS3BucketLoggingEnabledE(t *testing.T, terraformOptions *terraform.Options) error {
	region := terraformOptions.Vars["region"].(string)
	s3Client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return err
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketLoggingInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketLogging, err := s3Client.GetBucketLogging(params)

	if err != nil {
		return err
	}

	loggingEnabled := bucketLogging.LoggingEnabled

	if loggingEnabled == nil {
		return fmt.Errorf("Logging not enabled")
	}

	actual := *loggingEnabled.TargetBucket
	loggingBucketName := terraformOptions.Vars["logging_bucket"].(string)
	expected := loggingBucketName
	if actual != expected {
		return fmt.Errorf("Logging target bucket does not match expected. Got: %v, Expected: %v", actual, expected)
	}

	return nil
}

func AssertS3BucketLoggingNotEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketLoggingNotEnabledE(t, terraformOptions)
	require.NoError(t, err)
}

func AssertS3BucketLoggingNotEnabledE(t *testing.T, terraformOptions *terraform.Options) error {
	region := terraformOptions.Vars["region"].(string)
	s3Client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return err
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.GetBucketLoggingInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketLogging, err := s3Client.GetBucketLogging(params)

	if err != nil {
		return err
	}

	loggingEnabled := bucketLogging.LoggingEnabled

	if loggingEnabled != nil {
		return fmt.Errorf("Logging is enabled")
	}

	return nil
}

func AssertS3BucketPolicyContainsNonTLSDeny(t *testing.T, region string, bucketName string) {
	pattern := fmt.Sprintf(`{"Sid":"enforce-tls-requests-only","Effect":"Deny","Principal":{"AWS":"*"},"Action":"s3:*","Resource":"arn:aws:s3:::%s/*","Condition":{"Bool":{"aws:SecureTransport":"false"}}}`, bucketName)
	err := AssertS3BucketPolicyContains(t, region, bucketName, pattern)
	require.NoError(t, err)

}

func AssertS3BucketPolicyContains(t *testing.T, region string, bucketName string, pattern string) error {
	policy, err := aws.GetS3BucketPolicyE(t, region, bucketName)
	require.NoError(t, err)

	if !strings.Contains(policy, pattern) {
		return fmt.Errorf("could not find pattern: %s in policy: %s", pattern, policy)
	}

	return nil
}

func AssertS3BucketAnalyticsEnabled(t *testing.T, terraformOptions *terraform.Options) {
	err := AssertS3BucketAnalyticsEnabledE(t, terraformOptions)
	require.NoError(t, err)
}

func AssertS3BucketAnalyticsEnabledE(t *testing.T, terraformOptions *terraform.Options) error {
	region := terraformOptions.Vars["region"].(string)
	s3client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return err
	}

	bucketName := terraformOptions.Vars["test_name"].(string)
	params := &s3.ListBucketAnalyticsConfigurationsInput{
		Bucket: awssdk.String(bucketName),
	}

	bucketAnalytics, err := s3client.ListBucketAnalyticsConfigurations(params)

	if err != nil {
		return err
	}

	analytics := bucketAnalytics.AnalyticsConfigurationList

	if len(analytics) < 1 {
		return fmt.Errorf("Analytics is not enabled")
	}

	return nil
}
