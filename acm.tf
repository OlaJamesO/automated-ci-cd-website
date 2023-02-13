resource "aws_acm_certificate" "certificate" {
  # Remove the domain_name and validation_method attributes, since the certificate has already been created
  domain_name = var.domain
  # validation_method = "DNS"

  # Use the ARN of the existing certificate
  # arn = "arn:aws:acm:us-east-1:802607305497:certificate/37d56928-12e3-4e46-9b49-601b8b0ebbca"

  tags = {
    Name = "${var.bucket_name}"
  }
}
