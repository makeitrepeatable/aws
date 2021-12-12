
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.s3_bucket_name}-${random_string.random.result}"
  acl    = var.s3_acl
  tags   = var.tags
}

resource "aws_s3_bucket_object" "checkout" {
  bucket = aws_s3_bucket.demo_bucket.bucket
  key    = "checkout.png"
  source = "images/checkout.png"
  acl    = var.s3_acl
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.demo_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.demo_bucket.id

    custom_origin_config {
      http_port              = var.cf_custom_origin_config.http_port
      https_port             = var.cf_custom_origin_config.https_port
      origin_protocol_policy = var.cf_custom_origin_config.origin_protocol_policy
      origin_ssl_protocols   = var.cf_protocols
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  default_cache_behavior {
    allowed_methods  = var.cf_allowed_methods
    cached_methods   = var.cf_cached_methods
    target_origin_id = aws_s3_bucket.demo_bucket.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  depends_on = [aws_s3_bucket.demo_bucket]
}
