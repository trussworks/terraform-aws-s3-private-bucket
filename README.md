Creates an S3 bucket with good default policies.

Usage:

    module "aws-s3-bucket" {
      source = "github.com/trussworks/terraform-aws-s3-bucket"
      bucket = "my-versioning-bucket"
    }


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acl | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply. | string | `private` | no |
| bucket | The name of the bucket. If omitted, Terraform will assign a random, unique name. | string | - | yes |
| tags | A mapping of tags to assign to the bucket. | string | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket | The name of the bucket. |

