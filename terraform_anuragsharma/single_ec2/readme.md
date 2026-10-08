# Single EC2 Terraform Deployment

This repository contains a Terraform configuration to provision a single Amazon EC2 instance on AWS.

## Overview

The deployment creates:
- One VPC
- One public subnet
- One EC2 instance
- Security group allowing SSH access
- Key pair support for secure login

This is a simple starting point for launching a basic Linux server in AWS using Infrastructure as Code.

## Prerequisites

Before running this deployment, ensure you have:
- An AWS account
- AWS CLI installed and configured
- Terraform installed (version 1.0 or later recommended)
- An SSH key pair created in AWS or locally

## File Structure

- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `provider.tf` - AWS provider configuration
- `terraform.tfvars.example` - Example values for required variables

## Configuration

Update the variables in `terraform.tfvars` or set environment variables before running Terraform.

Typical values include:
- AWS region
- Instance AMI ID
- Instance type
- Key name
- Security group CIDR
- Tag values

Example:

```hcl
region = "us-east-1"
ami_id = "ami-0c02fb55956c7d316"
instance_type = "t3.micro"
key_name = "my-keypair"
project_name = "single-ec2"
```

## Initialize Terraform

```bash
terraform init
```

## Validate the Configuration

```bash
terraform validate
```

## Review the Execution Plan

```bash
terraform plan
```

## Deploy the Infrastructure

```bash
terraform apply
```

When prompted, confirm the apply by typing `yes`.

## Connect to the Instance

After deployment completes, use the public IP or DNS name from Terraform outputs to connect:

```bash
ssh -i /path/to/private-key.pem ec2-user@<public-ip>
```

Note: The default username may vary by AMI (for example, `ec2-user` for Amazon Linux or `ubuntu` for Ubuntu AMIs).

## Destroy the Infrastructure

To remove the deployed resources:

```bash
terraform destroy
```

## Notes

- Review AWS costs before provisioning resources.
- Ensure your IAM user or role has permission to create EC2 resources.
- Keep your SSH private key secure and do not commit it to source control.

## Security Considerations

- Restrict ingress rules to trusted IP ranges.
- Prefer using a least-privilege IAM role.
- Regularly rotate your SSH keys and review security group rules.
