module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["tictactoe.olajames.com"]

  comment             = "My CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true

  origin_access_identities = {
    s3_bucket_one = "CloudFront access"
  }

  origin = {
    s3_one = {
      domain_name = "${var.bucket_name}.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    path_pattern           = "/*"
    target_origin_id       = "s3_one"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  viewer_certificate = {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method = "sni-only"
  }
}
