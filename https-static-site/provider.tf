provider "aws" {
  # ACM が発行した証明書を CloudFront に割り当てるためには、米国東部リージョン ( us-east-1 ) に証明書をリクエストまたはインポートする必要がある
  region = "us-east-1"
}

