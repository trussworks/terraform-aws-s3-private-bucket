Creates a private, versioned S3 bucket with good defaults.

The following policy rules are set:

* Deny uploading public objects.

The following lifecycle rules are set:

* Incomplete multipart uploads are deleted after 14 days.
* Expired object delete markers are deleted.
* Noncurrent object versions transition to the Standard - Infrequent Access storage class after 30 days.
* Noncurrent object versions expire after 365 days.

Usage:

    module "aws-s3-bucket" {
      source = "github.com/trussworks/terraform-aws-s3-bucket"
      bucket = "my-versioning-bucket"
    }


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket | The name of the bucket. If omitted, Terraform will assign a random, unique name. | string | - | yes |
| tags | A mapping of tags to assign to the bucket. | string | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket | The name of the bucket. |

