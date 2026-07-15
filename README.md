# terraform-ec2-infra

Terraform configuration to provision a public **Amazon EC2** instance on AWS, complete with a security group, an IAM role for AWS Systems Manager (SSM) access, and Docker pre-installed via user data. Terraform state is stored remotely in an S3 backend.

## Overview

This project provisions the following AWS resources:

- **EC2 instance** (`t2.micro`) running the latest Amazon Linux 2023 AMI, launched in a public subnet with a public IP.
- **Security group** allowing all outbound traffic (IPv4).
- **IAM role & instance profile** attaching the `AmazonSSMManagedInstanceCore` policy so you can connect via SSM Session Manager (no SSH keys required).
- **User data** bootstrap script that installs `git`, `docker`, and `docker-compose`, then starts the Docker service.
- **Remote state** stored in an S3 bucket.

## Architecture

| Resource | Description |
| --- | --- |
| `aws_instance.public` | Amazon Linux 2023 EC2 instance in a public subnet |
| `aws_security_group.sg` | Security group attached to the instance |
| `aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4` | Allows all outbound IPv4 traffic |
| `aws_iam_role.example` | IAM role assumed by EC2 |
| `aws_iam_instance_profile.example` | Instance profile linking the role to the instance |
| `aws_iam_role_policy_attachment.example-attach` | Attaches the SSM managed policy |

Data sources (`data.tf`) look up the default VPC, its public subnets, the available AZs, and the most recent Amazon Linux 2023 AMI.

## File structure

| File | Purpose |
| --- | --- |
| `provider.tf` | AWS provider configuration (region) |
| `backend.tf` | S3 remote state backend configuration |
| `data.tf` | Data sources (AMI, VPC, subnets, AZs) |
| `main.tf` | EC2 instance and security group resources |
| `iam.tf` | IAM role, instance profile, and policy attachment |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with valid credentials
- An existing S3 bucket for remote state
- A default VPC with public subnets in the target region

## Configuration

Before applying, review and update the following values to match your environment:

- **`backend.tf`** — set `bucket`, `key`, and `region` for your remote state:
  ```hcl
  terraform {
    backend "s3" {
      bucket = "sctp-ce6-tfstate"
      key    = "jaz-ec2.tfstate" # change to a unique key
      region = "ap-southeast-1"  # region of your backend bucket
    }
  }
  ```
- **`provider.tf`** — set the AWS `region` (default: `ap-southeast-1`).
- **`main.tf`** — update the instance `Name` tag (`jazeel-ec2`) as desired.
- **`iam.tf`** — the IAM role/profile names (`jaz-ec2-ssm-role`, `jaz-ec2-ssm-profile`) must be unique within your account.

## Usage

```bash
# Initialize Terraform and configure the backend
terraform init

# Preview the changes
terraform plan

# Apply the configuration
terraform apply

# Tear everything down
terraform destroy
```

## Connecting to the instance

Because the instance has an SSM instance profile attached, you can connect without SSH keys:

```bash
aws ssm start-session --target <instance-id>
```

## Notes

- `user_data_replace_on_change = true` forces the instance to be **recreated** whenever the user data changes.
- The security group only defines egress rules. Add ingress rules if you need inbound access (e.g., SSH or HTTP).
