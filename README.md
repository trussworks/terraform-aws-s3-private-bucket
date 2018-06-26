Creates a private S3 bucket with good defaults:

* Private only objects
* Encryption
* Versioning
* Access logging

The following policy rules are set:

* Deny uploading public objects.

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


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket | The name of the bucket. It will be prefixed with the AWS account alias. | string | - | yes |
| custom_bucket_policy | JSON formatted bucket policy to attach to the bucket. | string | `` | no |
| logging_bucket | The S3 bucket to send S3 access logs. | string | - | yes |
| tags | A mapping of tags to assign to the bucket. | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| id | The name of the bucket. |

