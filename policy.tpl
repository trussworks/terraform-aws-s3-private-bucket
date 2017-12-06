{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
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
    },
    {
      "Sid": "ensure-encrypted",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${bucket}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
