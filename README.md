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
| id | The name of the bucket. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

