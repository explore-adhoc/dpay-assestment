#!/bin/bash

BUCKET_NAME="terraform-state"
REGION="ap-southeast-3"
STATE_KEY="iac/s3/terraform.tfstate"
PLAN_FILE="infra.plan"

check_terraform() {
  if ! command -v terraform >/dev/null 2>&1; then
    echo "❌ Terraform is not installed."
    echo "👉 Please install Terraform from https://www.terraform.io/downloads"
    exit 1
  fi
  echo "✅ Terraform is installed."
  terraform version
}

create_s3_bucket() {
  echo "🔍 Checking if bucket '$BUCKET_NAME' exists..."
  if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket '$BUCKET_NAME' already exists."
  else
    echo "🚀 Creating S3 bucket '$BUCKET_NAME' in region '$REGION'..."
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"

    echo "✅ Enabling versioning..."
    aws s3api put-bucket-versioning \
      --bucket "$BUCKET_NAME" \
      --versioning-configuration Status=Enabled

    echo "✅ Blocking public access..."
    aws s3api put-public-access-block \
      --bucket "$BUCKET_NAME" \
      --public-access-block-configuration \
        BlockPublicAcls=true \
        IgnorePublicAcls=true \
        BlockPublicPolicy=true \
        RestrictPublicBuckets=true
  fi
}

generate_backend_tf() {
  echo "📝 Generating backend.tf..."
  cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "$BUCKET_NAME"
    key    = "$STATE_KEY"
    region = "$REGION"
  }
}
EOF
}

terraform_init() {
  echo "🔧 Running 'terraform init'..."
  terraform init
}

terraform_plan() {
  echo "📋 Running 'terraform plan'..."
  terraform plan -out="$PLAN_FILE"
  if [[ $? -eq 0 ]]; then
    echo "✅ Plan saved to $PLAN_FILE"
  else
    echo "❌ Plan failed. Exiting."
    exit 1
  fi
}


terraform_apply() {
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "❌ Plan file '$PLAN_FILE' not found. Run the plan step first."
    exit 1
  fi
  echo "🚀 Applying infrastructure from plan..."
  terraform apply "$PLAN_FILE"
}

print_help() {
  echo ""
  echo "Usage: $0 [init|deploy|help]"
  echo ""
  echo "  init      Initialize Terraform and generate plan"
  echo "  deploy    Apply changes using existing plan"
  echo "  help      Show this help message"
  echo ""
}

main() {
  ACTION=$1

  check_terraform
  create_s3_bucket
  generate_backend_tf

  case "$ACTION" in
    init)
      terraform_init
      terraform_plan
      ;;
    deploy)
      terraform_apply
      ;;
    help|*)
      print_help
      ;;
  esac
}

main "$1"
