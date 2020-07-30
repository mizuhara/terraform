# SSL 証明書を紐付けるドメインを指定する
data "aws_route53_zone" "route53_zone" {
  name         = "<your-domain>"
  private_zone = false
}

# 上で指定したドメイン用の SSL 証明書を取得する
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "www.${var.root_domain}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# ホストゾーンに CNAME を登録する
resource "aws_route53_record" "acm_cert" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = lookup(aws_acm_certificate.acm_cert.domain_validation_options[0], "resource_record_name")
  type    = lookup(aws_acm_certificate.acm_cert.domain_validation_options[0], "resource_record_type")
  records = [lookup(aws_acm_certificate.acm_cert.domain_validation_options[0], "resource_record_value")]
  ttl     = 60
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "www.${var.root_domain}"
  type    = "CNAME"
  records = [aws_cloudfront_distribution.site.domain_name]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "acm_cert" {
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [aws_route53_record.acm_cert.fqdn]
}

