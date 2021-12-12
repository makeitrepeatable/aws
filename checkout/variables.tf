variable "pk_algo" {
  type    = string
  default = "RSA"
}

variable "pk_bits" {
  type    = number
  default = 4096
}


variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [443, 22, 80]
}

variable "asg_min" {
  type    = number
  default = 2
}

variable "asg_max" {
  type    = number
  default = 5
}

variable "cert_name" {
  type    = string
  default = "webserver.pem"
}

variable "key_pair_name" {
  type    = string
  default = "webserver"
}

variable "tags" {
  default = {
    purpose     = "checkout"
    environment = "dev"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "asg_health_check_type" {
  type    = string
  default = "ELB"
}

variable "ami" {
  type    = string
  default = "ami-0cef61fd3eb8cfb72"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "elb_name" {
  type    = string
  default = "checkout-elb"
}

variable "s3_bucket_name" {
  type    = string
  default = "makeitrepeatable"
}

variable "s3_acl" {
  type    = string
  default = "public-read"
}

variable "cf_protocols" {
  type        = list(string)
  description = "list of ingress ports"
  default = [
    "TLSv1",
    "TLSv1.1",
    "TLSv1.2"
  ]
}

variable "cf_allowed_methods" {
  type        = list(string)
  description = "list of ingress ports"
  default = [
    "DELETE",
    "GET",
    "HEAD",
    "OPTIONS",
    "PATCH",
    "POST",
    "PUT"
  ]
}

variable "cf_cached_methods" {
  type        = list(string)
  description = "list of ingress ports"
  default = [
    "GET",
    "HEAD"
  ]
}

variable "elb_health_check" {
  type = map(any)
  default = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
}

variable "elb_listener" {
  type = map(any)
  default = {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"

  }
}

variable "cf_custom_origin_config" {
  type = map(any)
  default = {
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "match-viewer"

  }
}

variable "asg_name" {
  type    = string
  default = "checkout-asg"
}