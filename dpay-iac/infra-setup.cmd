@echo off
setlocal ENABLEDELAYEDEXPANSION

set BUCKET_NAME=explore-adhoc
set REGION=ap-southeast-3
set STATE_KEY=adhoc/statefile.tfstate
set PLAN_FILE=infra-plan.txt

where terraform >nul 2>nul
if errorlevel 1 (
    echo ❌ Terraform is not installed.
    echo 👉 Please install Terraform from https://www.terraform.io/downloads
    exit /b 1
)
echo ✅ Terraform is installed.
terraform version

echo 🔍 Checking if S3 bucket "%BUCKET_NAME%" exists...
aws s3api head-bucket --bucket %BUCKET_NAME% >nul 2>nul
if errorlevel 1 (
    echo 🚀 Creating bucket "%BUCKET_NAME%"...
    aws s3api create-bucket ^
        --bucket %BUCKET_NAME% ^
        --region %REGION% ^
        --create-bucket-configuration LocationConstraint=%REGION%

    echo ✅ Enabling versioning...
    aws s3api put-bucket-versioning ^
        --bucket %BUCKET_NAME% ^
        --versioning-configuration Status=Enabled

    aws s3api put-public-access-block \
      --bucket "$BUCKET_NAME" \
      --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
      }'
) else (
    echo ✅ Bucket "%BUCKET_NAME%" already exists.
)

echo 📝 Creating backend.tf...
(
echo terraform {
echo   backend "s3" {
echo     bucket = "%BUCKET_NAME%"
echo     key    = "%STATE_KEY%"
echo     region = "%REGION%"
echo   }
echo }
) > backend.tf

if "%1"=="init" (
    echo 🔧 Running terraform init...
    terraform init
    echo 📋 Running terraform plan...
    terraform plan -out=%PLAN_FILE%
    if errorlevel 1 (
        echo ❌ Plan failed. Check above logs.
        exit /b 1
    )
    echo ✅ Plan saved to %PLAN_FILE%
    exit /b 0
)

if "%1"=="deploy" (
    if not exist %PLAN_FILE% (
        echo ❌ Plan file "%PLAN_FILE%" not found. Run "deploy-infra.cmd init" first.
        exit /b 1
    )
    echo 🚀 Applying infrastructure from plan...
    terraform apply %PLAN_FILE%
    exit /b 0
)

echo.
echo Usage:
echo   deploy-infra.cmd init      ^<-- Generate plan file
echo   deploy-infra.cmd deploy    ^<-- Apply plan file
echo.

endlocal
