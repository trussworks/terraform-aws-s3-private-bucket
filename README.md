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

Terraform 0.12. Pin module version to ~> 2.X. Submit pull-requests to terraform012 branch.

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_analytics_configuration.private_analytics_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_analytics_configuration) | resource |
| [aws_s3_bucket_cors_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_inventory.inventory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_inventory) | resource |
| [aws_s3_bucket_lifecycle_configuration.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.private_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
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
| abort\_incomplete\_multipart\_upload\_days | Number of days until aborting incomplete multipart uploads | `number` | `14` | no |
| additional\_lifecycle\_rules | List of additional lifecycle rules to specify | `list(any)` | `[]` | no |
| bucket | The name of the bucket. | `string` | n/a | yes |
| bucket\_key\_enabled | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `false` | no |
| control\_object\_ownership | Whether to manage S3 Bucket Ownership Controls on this bucket. | `bool` | `true` | no |
| cors\_rules | List of maps containing rules for Cross-Origin Resource Sharing. | `list(any)` | `[]` | no |
| custom\_bucket\_policy | JSON formatted bucket policy to attach to the bucket. | `string` | `""` | no |
| enable\_analytics | Enables storage class analytics on the bucket. | `bool` | `true` | no |
| enable\_bucket\_force\_destroy | If set to true, Bucket will be emptied and destroyed when terraform destroy is run. | `bool` | `false` | no |
| enable\_bucket\_inventory | If set to true, Bucket Inventory will be enabled. | `bool` | `false` | no |
| enable\_s3\_public\_access\_block | Bool for toggling whether the s3 public access block resource should be enabled. | `bool` | `true` | no |
| expiration | expiration blocks | `list(any)` | ```[ { "expired_object_delete_marker": true } ]``` | no |
| inventory\_bucket\_format | The format for the inventory file. Default is ORC. Options are ORC or CSV. | `string` | `"ORC"` | no |
| kms\_master\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. If blank, bucket encryption configuration defaults to AES256. | `string` | `""` | no |
| logging\_bucket | The S3 bucket to send S3 access logs. | `string` | `""` | no |
| noncurrent\_version\_expiration | Number of days until non-current version of object expires | `number` | `365` | no |
| noncurrent\_version\_transitions | Non-current version transition blocks | `list(any)` | ```[ { "days": 30, "storage_class": "STANDARD_IA" } ]``` | no |
| object\_ownership | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. | `string` | `"BucketOwnerEnforced"` | no |
| s3\_bucket\_acl | Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list. | `string` | `null` | no |
| schedule\_frequency | The S3 bucket inventory frequency. Defaults to Weekly. Options are 'Weekly' or 'Daily'. | `string` | `"Weekly"` | no |
| tags | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| transfer\_acceleration | Whether or not to enable bucket acceleration. | `bool` | `null` | no |
| transitions | Current version transition blocks | `list(any)` | `[]` | no |
| use\_account\_alias\_prefix | Whether to prefix the bucket name with the AWS account alias. | `string` | `true` | no |
| use\_random\_suffix | Whether to add a random suffix to the bucket name. | `bool` | `false` | no |
| versioning\_status | A string that indicates the versioning status for the log bucket. | `string` | `"Enabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. |
| bucket\_regional\_domain\_name | The bucket region-specific domain name. |
| id | The name of the bucket. |
| name | The Name of the bucket. Will be of format bucketprefix-bucketname. |
<!-- END_TF_DOCS -->

## Upgrade Paths

### Upgrading from 5.x.x to 6.x.x

Version 6.x.x updates the module to account for changes made by AWS in April
2023 to the default security settings of new S3 buckets.

Version 6.x.x of this module adds the following resource and variables. How to
use the new variables will depend on your use case.

New resource:

- `aws_s3_bucket_ownership_controls.private_bucket`

New variables:

- `control_object_ownership`
- `object_ownership`
- `s3_bucket_acl`

Steps for updating existing buckets managed by this module:

- **Option 1: Disable ACLs.** In order to update an existing bucket to use the
  new AWS recommended defaults, use this module's default values for the new
  input variables. Using those settings will disable S3 access control lists for
  the bucket and set object ownership to `BucketOwnerEnforced`.

- **Option 2: Continue using ACLs.** To continue using ACLs, set `s3_bucket_acl`
  to `"private"` and `object_ownership` to `"ObjectWriter"` or
  `"BucketOwnerPreferred"`.

See [Controlling ownership of objects and disabling ACLs for your
bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html)
for further details and migration considerations.

### Upgrading from 4.x.x to 5.x.x

Removed variables:

- `sse_algorithm`. If `kms_master_key_id` is not passed, the module will fall
  back to AES256 for the bucket encryption configuration.

### Upgrading from 3.x.x to 4.x.x

Version 4.x.x enables the use of version 4 of the AWS provider. Terraform provided [an upgrade path](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade) for this. To support the upgrade path, this module now includes the following additional resources:

- `aws_s3_bucket_policy.private_bucket`
- `aws_s3_bucket_acl.private_bucket`
- `aws_s3_bucket_versioning.private_bucket`
- `aws_s3_bucket_lifecycle_configuration.private_bucket`
- `aws_s3_bucket_logging.private_bucket`
- `aws_s3_bucket_server_side_encryption_configuration.private_bucket`
- `aws_s3_bucket_cors_configuration.private_bucket`

This module version removes the `enable_versioning` variable (boolean) and replaces it with the `versioning_status` variable (string). There are three possible values for this variable: `Enabled`, `Disabled`, and `Suspended`. If at one point versioning was enabled on your bucket, but has since been turned off, you will need to set `versioning_status` to `Suspended` rather than `Disabled`.

Additionally, this version of the module requires a minimum AWS provider version of 3.75, so that you can remain on the 3.x AWS provider while still gaining the ability to utilize the new S3 resources introduced in the 4.x AWS provider.

There are two general approaches to performing this upgrade:

1. Upgrade the module version and run `terraform plan` followed by `terraform apply`, which will create the new Terraform resources.
1. Perform `terraform import` commands, which accomplishes the same thing without running `terraform apply`. This is the more cautious route.

If you choose to take the route of running `terraform import`, you will need to perform the following imports. Replace `example` with the name you're using when calling this module and replace `your-bucket-name-here` with the name of your bucket (as opposed to an S3 bucket ARN). Also note the inclusion of `,private` when importing the new `aws_s3_bucket_acl` Terraform resource; if you are setting the `s3_bucket_acl` input variable, use that value instead of `private`. If you have not configured a target bucket using the `logging_bucket` input variable, then you don't need to import the `aws_s3_bucket_logging` Terraform resource.

```sh
terraform import module.example.aws_s3_bucket_policy.private_bucket your-bucket-name-here
terraform import module.example.aws_s3_bucket_acl.private_bucket your-bucket-name-here,private
terraform import module.example.aws_s3_bucket_versioning.private_bucket your-bucket-name-here
terraform import module.example.aws_s3_bucket_lifecycle_configuration.private_bucket your-bucket-name-here
terraform import module.example.aws_s3_bucket_server_side_encryption_configuration.private_bucket your-bucket-name-here
terraform import module.example.aws_s3_bucket_cors_configuration.private_bucket your-bucket-name-here
# Optionally run these two commands if you have configured the logging_bucket input variable.
terraform import module.example.aws_s3_bucket_logging.private_bucket your-bucket-name-here
terraform state mv 'module.example.aws_s3_bucket_logging.private_bucket' 'module.example.aws_s3_bucket_logging.private_bucket[0]'
```

After this, you will need to run a `terraform plan` and `terraform apply` to apply some non-functional changes to lifecycle rule IDs.

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
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
