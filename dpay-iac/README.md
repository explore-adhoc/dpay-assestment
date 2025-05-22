

# Problem #1
Write Terraform HCL config to generate AWS infra in the following form:
A. 1 VPC
B. 1 public subnet
C. 1 private subnet connected to 1 NAT Gateway
D. 1 autoscaling group with config:
    a. minimum 2 EC2 t2.medium instances and max 5 instances,
    b. where scaling policy is CPU >= 45%.
    c. instances must be placed on the 1 private subnet created in point C above.
E. Automatically creates CloudWatch monitoring for instance and resource created:
    a. CPU monitoring
    b. memory usage
    c. status check failure
    d. network usage
    F. Terraform backend should be stored on S3 bucket.

## 📦 To Solve problem #1:

- **VPC Module**
  - 1 VPC with public and private subnets
  - Internet Gateway and NAT Gateway
  - Route tables

- **NAT Gateway Module**
  - NAT Gateway in the public subnet
  - Private subnet internet access via NAT

- **EC2 Auto Scaling Module**
  - Launch Template with Amazon CloudWatch Agent
  - Auto Scaling Group in private subnet (min: 2, max: 5)
  - CPU ≥ 45% triggers scale-out policy

- **CloudWatch Monitoring Module**
  - Alarms for:
    - CPU usage
    - Memory usage
    - EC2 status check failures
    - Network In/Out

- **Remote State via S3**
  - S3 backend with native state locking to s3 bucket

## 🛠 How to Use

### 1. Prepare S3 to save terraform state

change dir ```cd dpay-iac/```

then run this command to create s3 bucket to store terraform state
```hcl
terraform init -backend=false
```

Then Run this command
```hcl
terraform apply -target=s3_bucket.tf_state -auto-approve
```

### 1.1 To make it easier for you, I have prepared 2 executable files.

with this options all settings will automatically creates

MAC | Linux | WSL
```bash
chmod +x ./infra-setup.sh && ./infra-setup.sh
```

WINDOWS
open with powershell
```cmd
infra-setup.cmd
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Apply Infrastructure

```bash
terraform apply
```

## 🔐 Notes

- Ensure you have your AWS credentials configured via `~/.aws/credentials` or environment variables.
- Replace AMI ID and region to match your use case.
- Review IAM permissions before applying.

## 📁 Modules

- `modules/vpc`
- `modules/nat_gateway`
- `modules/ec2_autoscaling`
- `modules/cloudwatch`

---

Maintained by: **Indra Buchori Ruiswara**
