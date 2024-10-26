terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56"
    }
  }
}

provider "aws" {
  region = var.aws_region
}






resource "aws_s3_bucket" "devbucket-pod4" {
  bucket = "pod4-12121212"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}






resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.devbucket-pod4.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.devbucket-pod4.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.devbucket-pod4.id
  acl    = "public-read"
}


resource "aws_s3_object" "bucket1" {
   bucket = aws_s3_bucket.devbucket-pod4.bucket
   key = "index.html"
   acl = "public-read"
   source="./website/index.html"
   etag = filemd5("./website/index.html")
   content_type = "text/html"
tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_website_configuration" "dev_s3_website_configuration" {
  bucket = aws_s3_bucket.devbucket-pod4.id
 
  index_document {
    suffix = "index.html"
  }
 
  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
origin {
    domain_name = "${aws_s3_bucket.devbucket-pod4.bucket_regional_domain_name}"
    origin_id   = "my_first_origin"
}
enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"
default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my_first_origin"
forwarded_values {
      query_string = false
cookies {
        forward = "none"
      }
    }
viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
# Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "my_first_origin"
forwarded_values {
      query_string = false
      headers      = ["Origin"]
cookies {
        forward = "none"
      }
    }
min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
# Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id  = "my_first_origin"
forwarded_values {
      query_string = false
cookies {
        forward = "none"
      }
    }
min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress             = true
    viewer_protocol_policy = "redirect-to-https"
  }
price_class = "PriceClass_200"
restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }
tags = {
    Environment = "production"
  }
viewer_certificate {
    cloudfront_default_certificate = true
  }

}