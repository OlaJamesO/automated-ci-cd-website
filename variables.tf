variable "domain" {
  default = "tictactoe.olajames.com"
}

variable "bucket_name" {
  default = "tictactoe.olajames.com"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "hosted_zone_id" {
}
variable "aws_codebuild_project_name" {
    default = "web-game"
}
variable "acm_certificate_arn" {
  type = string
}

variable "cloudfront_identifier" {
  type = string
}
