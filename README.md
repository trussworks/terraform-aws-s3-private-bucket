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

Terraform 0.13. Pin module version to ~> 3.X. Submit pull-requests to master branch.

Terraform 0.12. Pin module version to ~> 2.X.  Submit pull-requests to terraform012 branch.

Terraform 0.11. Pin module version to ~> 1.7.3. Submit pull-requests to terraform011 branch.

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
| terraform | ~> 0.13.0 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket | The name of the bucket. | `string` | n/a | yes |
| cors\_rules | List of maps containing rules for Cross-Origin Resource Sharing. | `list(any)` | `[]` | no |
| custom\_bucket\_policy | JSON formatted bucket policy to attach to the bucket. | `string` | `""` | no |
| enable\_analytics | Enables storage class analytics on the bucket. | `bool` | `true` | no |
| enable\_bucket\_force\_destroy | If set to true, Bucket will be emptied and destroyed when terraform destroy is run. | `bool` | `false` | no |
| enable\_bucket\_inventory | If set to true, Bucket Inventory will be enabled. | `bool` | `false` | no |
| enable\_versioning | Enables versioning on the bucket. | `string` | `true` | no |
| inventory\_bucket\_format | The format for the inventory file. Default is ORC. Options are ORC or CSV. | `string` | `"ORC"` | no |
| logging\_bucket | The S3 bucket to send S3 access logs. | `string` | `""` | no |
| schedule\_frequency | The S3 bucket inventory frequency. Defaults to Weekly. Options are 'Weekly' or 'Daily'. | `string` | `"Weekly"` | no |
| tags | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| use\_account\_alias\_prefix | Whether to prefix the bucket name with the AWS account alias. | `string` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. |
| bucket\_regional\_domain\_name | The bucket region-specific domain name. |
| id | The name of the bucket. |
| name | The Name of the bucket. Will be of format bucketprefix-bucketname. |

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
