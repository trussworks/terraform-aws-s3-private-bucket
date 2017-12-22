{
  "Version": "2012-10-17",
  "Id": "trussworks-aws-s3-private-bucket",
  "Statement": [
    {
      "Sid": "ensure-private-read-write",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::${bucket}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": [
            "public-read",
            "public-read-write"
          ]
        }
      }
    }
  ]
}
