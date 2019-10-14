package test

import (
	"fmt"
	"strings"
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func AssertS3BucketEncryptionEnabled(t *testing.T, region string, bucketName string) {
	err := AssertS3BucketEncryptionEnabledE(t, region, bucketName)
	require.NoError(t, err)
}

func AssertS3BucketEncryptionEnabledE(t *testing.T, region string, bucketName string) error {
	s3Client, err := aws.NewS3ClientE(t, region)

	if err != nil {
		return err
	}

	params := &s3.GetBucketEncryptionInput{
		Bucket: awssdk.String(bucketName),
	}

	encryption, err := s3Client.GetBucketEncryption(params)

	if err != nil {
		return err
	}

	expectedEncryption := "AES256"
	for _, element := range encryption.ServerSideEncryptionConfiguration.Rules {
		actualEncryption := element.ApplyServerSideEncryptionByDefault.SSEAlgorithm
		if *actualEncryption != expectedEncryption {
			return fmt.Errorf("server side encyption test failed. got: %v, expected: %v", actualEncryption, expectedEncryption)
		}
	}

	return nil
}

// An example of how to test the Terraform module in examples/terraform-aws-s3-example using Terratest.
func TestTerraformAwsS3Example(t *testing.T) {
	t.Parallel()

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	expectedName := fmt.Sprintf("terratest-aws-s3-private-bucket-%s", strings.ToLower(random.UniqueId()))

	expectedLoggingBucket := fmt.Sprintf("terratest-aws-s3-logging-%s", strings.ToLower(random.UniqueId()))

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket":         expectedName,
			"logging_bucket": expectedLoggingBucket,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// Create temporary logging bucket for s3 bucket module
	s3Client, err := aws.NewS3ClientE(t, awsRegion)
	if err != nil {
		fmt.Println(err)
		return
	}

	params := &s3.CreateBucketInput{
		Bucket: awssdk.String(expectedLoggingBucket),
		ACL:    awssdk.String("log-delivery-write"),
	}

	_, err = s3Client.CreateBucket(params)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Clean up tempoary logging bucket at end of test
	defer aws.DeleteS3Bucket(t, awsRegion, expectedLoggingBucket)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "id")

	AssertS3BucketEncryptionEnabled(t, awsRegion, bucketID)
}
