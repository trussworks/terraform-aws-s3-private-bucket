package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsS3PrivateBucket(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	testName := fmt.Sprintf("terratest-aws-s3-private-bucket-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-logs", testName)
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name":        testName,
			"logging_bucket":   loggingBucket,
			"region":           awsRegion,
			"enable_analytics": true,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	AssertS3BucketEncryptionEnabled(t, awsRegion, testName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, testName)
	AssertS3BucketBlockPublicACLEnabled(t, terraformOptions)
	AssertS3BucketBlockPublicPolicyEnabled(t, awsRegion, testName)
	AssertS3BucketIgnorePublicACLEnabled(t, awsRegion, testName)
	AssertS3BucketRestrictPublicBucketsEnabled(t, awsRegion, testName)
	AssertS3BucketLoggingEnabled(t, awsRegion, testName, loggingBucket)
	AssertS3BucketPolicyContainsNonTLSDeny(t, awsRegion, testName)
	AssertS3BucketAnalyticsEnabled(t, awsRegion, testName)
}

func TestTerraformAwsS3PrivateBucketWithoutAnalytics(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	testName := fmt.Sprintf("terratest-aws-s3-private-bucket-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-logs", testName)
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name":        testName,
			"logging_bucket":   loggingBucket,
			"region":           awsRegion,
			"enable_analytics": false,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	AssertS3BucketEncryptionEnabled(t, awsRegion, testName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, testName)
	AssertS3BucketBlockPublicACLEnabled(t, terraformOptions)
	AssertS3BucketBlockPublicPolicyEnabled(t, awsRegion, testName)
	AssertS3BucketIgnorePublicACLEnabled(t, awsRegion, testName)
	AssertS3BucketRestrictPublicBucketsEnabled(t, awsRegion, testName)
	AssertS3BucketLoggingEnabled(t, awsRegion, testName, loggingBucket)
	AssertS3BucketPolicyContainsNonTLSDeny(t, awsRegion, testName)
}
func TestTerraformAwsS3PrivateBucketCustomPolicy(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/custom-bucket-policy")
	testName := fmt.Sprintf("terratest-aws-s3-private-bucket-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-logs", testName)
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"test_name":      testName,
			"logging_bucket": loggingBucket,
			"region":         awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	aws.AssertS3BucketPolicyExists(t, awsRegion, testName)
	AssertS3BucketPolicyContainsNonTLSDeny(t, awsRegion, testName)
}

func TestTerraformAwsInventory(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/bucket-inventory")
	testName := fmt.Sprintf("terratest-aws-s3-private-bucket-inventory-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-inventory-logs", testName)
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"test_name":               testName,
			"logging_bucket":          loggingBucket,
			"region":                  awsRegion,
			"enable_bucket_inventory": true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	aws.AssertS3BucketExists(t, awsRegion, testName)
	AssertS3BucketPolicyContainsNonTLSDeny(t, awsRegion, testName)

}

func TestTerraformAwsS3PrivateBucketNoLoggingBucket(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple-no-logging")

	// Give this S3 Bucket a unique ID for a name tag so we can distinguish it from any other Buckets provisioned
	// in your AWS account
	testName := fmt.Sprintf("terratest-aws-s3-private-bucket-no-logging-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name": testName,
			"region":    awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	aws.AssertS3BucketExists(t, awsRegion, testName)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	AssertS3BucketLoggingNotEnabled(t, awsRegion, testName)
	AssertS3BucketPolicyContainsNonTLSDeny(t, awsRegion, testName)
}
