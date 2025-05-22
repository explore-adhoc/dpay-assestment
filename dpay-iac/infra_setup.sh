#!/bin/bash

set -euo pipefail

BUCKET_NAME="explore-adhoc"
REGION="ap-southeast-3"
STATE_KEY="adhoc/statefile.tfstate"
PLAN_FILE="infra-plan.txt"

command -v terraform >/dev/null 2>&1 || {
  echo "❌ Terraform is not installed."
  echo "👉 Please install Terraform from https://www.terraform.io/downloads"
  exit 1
}
echo "✅ Terraform is installed."
terraform version

echo "🔍 Checking if S3 bucket \"$BUCKET_NAME\" exists..."
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "🚀 Creating bucket \"$BUCKET_NAME\"..."
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

  echo "✅ Enabling versioning..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

  echo "🔒 Blocking public access..."
  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'
else
  echo "✅ Bucket \"$BUCKET_NAME\" already exists."
fi

ACTION="${1:-}"

if [[ "$ACTION" == "init" ]]; then
  echo "🔧 Running terraform init..."
  terraform init
  echo "📋 Running terraform plan..."
  if terraform plan -out="$PLAN_FILE"; then
    echo "✅ Plan saved to $PLAN_FILE"
    exit 0
  else
    echo "❌ Plan failed. Check above logs."
    exit 1
  fi
fi

if [[ "$ACTION" == "deploy" ]]; then
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "❌ Plan file \"$PLAN_FILE\" not found. Run \"deploy-infra.sh init\" first."
    exit 1
  fi
  echo "🚀 Applying infrastructure from plan..."
  terraform apply "$PLAN_FILE"
  exit 0
fi

echo
echo "Usage:"
echo "  ./deploy-infra.sh init      <-- Generate plan file"
echo "  ./deploy-infra.sh deploy    <-- Apply plan file"
echo
