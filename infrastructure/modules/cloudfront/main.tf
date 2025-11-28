resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "${var.name}-cloudfront-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "AllowCloudFrontOACRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${var.bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = "${var.bucket_id}.s3.amazonaws.com"
    origin_id                = "s3_origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3_origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}