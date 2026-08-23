provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  # reads CLOUDFLARE_API_TOKEN from your shell env automatically
}