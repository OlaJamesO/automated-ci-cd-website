variable "domain" {
  default = "terramino.jameso.tech"
}

variable "bucket_name" {
  default = "terramino.jameso.tech"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "hosted_zone_id" {
  default = "Z073651441IJIESKK9V3"
}
variable "aws_codebuild_project_name" {
    default = "web-game"
}
variable "acm_certificate_arn" {
  type = string
  default = "arn:aws:acm:us-east-1:802607305497:certificate/37d56928-12e3-4e46-9b49-601b8b0ebbca"
}

variable "cloudfront_identifier" {
  type = string
}
