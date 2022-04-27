Creates a private S3 bucket with good defaults:

- Private only objects
- Encryption
- Versioning
- Access logging
- Storage analytics

The following policy rules are set:

- Deny uploading public objects.
- Deny updating policy to allow public objects.

The following ACL rules are set:

- Retroactively remove public access granted through public ACLs
- Deny updating ACL to public

The following lifecycle rules are set:

- Incomplete multipart uploads are deleted after 14 days.
- Expired object delete markers are deleted.
- Noncurrent object versions transition to the Standard - Infrequent Access storage class after 30 days.
- Noncurrent object versions expire after 365 days.

## Terraform Versions

Terraform 0.13 and newer. Pin module version to ~> 3.X. Submit pull-requests to master branch.

Terraform 0.12. Pin module version to ~> 2.X.  Submit pull-requests to terraform012 branch.

## Usage

```hcl
module "aws-s3-bucket" {
  source         = "trussworks/s3-private-bucket/aws"
  bucket         = "my-bucket-name"
  logging_bucket = "my-aws-logs"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_analytics_configuration.private_analytics_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_analytics_configuration) | resource |
| [aws_s3_bucket_cors_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_inventory.inventory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_inventory) | resource |
| [aws_s3_bucket_lifecycle_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.supplemental_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_incomplete_multipart_upload_days"></a> [abort\_incomplete\_multipart\_upload\_days](#input\_abort\_incomplete\_multipart\_upload\_days) | Number of days until aborting incomplete multipart uploads | `number` | `14` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the bucket. | `string` | n/a | yes |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `false` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | List of maps containing rules for Cross-Origin Resource Sharing. | `list(any)` | `[]` | no |
| <a name="input_custom_bucket_policy"></a> [custom\_bucket\_policy](#input\_custom\_bucket\_policy) | JSON formatted bucket policy to attach to the bucket. | `string` | `""` | no |
| <a name="input_enable_analytics"></a> [enable\_analytics](#input\_enable\_analytics) | Enables storage class analytics on the bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_force_destroy"></a> [enable\_bucket\_force\_destroy](#input\_enable\_bucket\_force\_destroy) | If set to true, Bucket will be emptied and destroyed when terraform destroy is run. | `bool` | `false` | no |
| <a name="input_enable_bucket_inventory"></a> [enable\_bucket\_inventory](#input\_enable\_bucket\_inventory) | If set to true, Bucket Inventory will be enabled. | `bool` | `false` | no |
| <a name="input_enable_s3_public_access_block"></a> [enable\_s3\_public\_access\_block](#input\_enable\_s3\_public\_access\_block) | Bool for toggling whether the s3 public access block resource should be enabled. | `bool` | `true` | no |
| <a name="input_expiration"></a> [expiration](#input\_expiration) | expiration blocks | `list(any)` | <pre>[<br>  {<br>    "expired_object_delete_marker": true<br>  }<br>]</pre> | no |
| <a name="input_inventory_bucket_format"></a> [inventory\_bucket\_format](#input\_inventory\_bucket\_format) | The format for the inventory file. Default is ORC. Options are ORC or CSV. | `string` | `"ORC"` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The AWS KMS master key ID used for the SSE-KMS encryption. | `string` | `""` | no |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | The S3 bucket to send S3 access logs. | `string` | `""` | no |
| <a name="input_noncurrent_version_expiration"></a> [noncurrent\_version\_expiration](#input\_noncurrent\_version\_expiration) | Number of days until non-current version of object expires | `number` | `365` | no |
| <a name="input_noncurrent_version_transitions"></a> [noncurrent\_version\_transitions](#input\_noncurrent\_version\_transitions) | Non-current version transition blocks | `list(any)` | <pre>[<br>  {<br>    "days": 30,<br>    "storage_class": "STANDARD_IA"<br>  }<br>]</pre> | no |
| <a name="input_schedule_frequency"></a> [schedule\_frequency](#input\_schedule\_frequency) | The S3 bucket inventory frequency. Defaults to Weekly. Options are 'Weekly' or 'Daily'. | `string` | `"Weekly"` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| <a name="input_transitions"></a> [transitions](#input\_transitions) | Current version transition blocks | `list(any)` | `[]` | no |
| <a name="input_use_account_alias_prefix"></a> [use\_account\_alias\_prefix](#input\_use\_account\_alias\_prefix) | Whether to prefix the bucket name with the AWS account alias. | `string` | `true` | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | A string that indicates the versioning status for the log bucket. | `string` | `"Enabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. |
| <a name="output_id"></a> [id](#output\_id) | The name of the bucket. |
| <a name="output_name"></a> [name](#output\_name) | The Name of the bucket. Will be of format bucketprefix-bucketname. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```shell
make test
```

Or with aws-vault:

```shell
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```

## CHANGELOG

This terraform module is undergoing an experiment where we keep a CHANGELOG for it. We're still trying to figure out how to automate this process and, for now, are manually running the command.

The changelog should be updated every time a new GitHub release is cut.

To do so, you should have a Github token with "repo" scope that can be loaded in as an environment variable. You can find more info [here](https://github.com/github-changelog-generator/github-changelog-generator#github-token).

```sh
export CHANGELOG_GITHUB_TOKEN="«your-40-digit-github-token»"
```

The command to run on your terminal:

```sh
docker run --env CHANGELOG_GITHUB_TOKEN="$CHANGELOG_GITHUB_TOKEN" --rm -v "$(pwd)":/usr/local/src/your-app ferrarimarco/github-changelog-generator -u trussworks -p terraform-aws-s3-private-bucket
```
