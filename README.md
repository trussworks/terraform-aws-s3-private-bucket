Creates a private S3 bucket with good defaults:

* Private only objects
* Encryption
* Versioning
* Access logging

The following policy rules are set:

* Deny uploading public objects.
* Deny updating policy to allow public objects.

The following ACL rules are set:

* Retroactively remove public access granted through public ACLs
* Deny updating ACL to public

The following lifecycle rules are set:

* Incomplete multipart uploads are deleted after 14 days.
* Expired object delete markers are deleted.
* Noncurrent object versions transition to the Standard - Infrequent Access storage class after 30 days.
* Noncurrent object versions expire after 365 days.

## Usage

    module "aws-s3-bucket" {
      source         = "trussworks/s3-private-bucket/aws"
      bucket         = "my-bucket-name"
      logging_bucket = "my-aws-logs"

      tags {
        Name        = "My bucket"
        Environment = "Dev"
      }
    }

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket | The name of the bucket. | string | n/a | yes |
| custom\_bucket\_policy | JSON formatted bucket policy to attach to the bucket. | string | `""` | no |
| logging\_bucket | The S3 bucket to send S3 access logs. | string | n/a | yes |
| tags | A mapping of tags to assign to the bucket. | map(string) | `{}` | no |
| use\_account\_alias\_prefix | Whether to prefix the bucket name with the AWS account alias. | string | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. |
| bucket\_regional\_domain\_name | The bucket region-specific domain name. |
| id | The name of the bucket. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

    go test -v ./test/...

Or with aws-vault:

    AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- go test -v ./test/...

By default, terratest will attempt to create the test buckets in a random AWS
region. To use a specific region, set the `TERRATEST_REGION` environment
variable.

Example:

    export TERRATEST_REGION=us-west-2
