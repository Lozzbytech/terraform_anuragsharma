# Separate EC2 Instance Deployment

This document explains how to deploy a standalone EC2 instance using Terraform in this folder.

## Prerequisites

Before running the deployment, make sure you have:

- Terraform installed (v1.0 or later)
- AWS CLI installed and configured
- An AWS account with permission to create EC2 resources
- Access to a valid AWS profile or environment variables for credentials

## Folder Contents

This folder contains the Terraform configuration for creating a separate EC2 instance, including the required provider, networking, security group, and instance resource configuration.

## AWS Configuration

Configure your AWS credentials before deployment:

```bash
aws configure
```

Or export your credentials:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Update Variables

Review the Terraform variables in the configuration and update values such as:

- AMI ID
- instance type
- key pair name
- subnet or VPC settings
- security group rules
- tagging values

If a `terraform.tfvars` file is used, populate it with the required values.

Example:

```hcl
region = "us-east-1"
instance_type = "t3.micro"
ami = "ami-0c02fb55956c7d316"
key_name = "your-key-pair"
```

## Initialize Terraform

From this directory, run:

```bash
terraform init
```

This downloads the required providers and initializes the working directory.

## Review the Deployment Plan

```bash
terraform plan
```

Check the resources that will be created before applying them.

## Deploy the EC2 Instance

Run:

```bash
terraform apply
```

If prompted, confirm the deployment by typing `yes`.

Terraform will create the EC2 instance and any related resources defined in the configuration.

## Verify Deployment

After the apply finishes, confirm the instance is running in the AWS Console or by running:

```bash
aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId,State:State.Name,PublicIpAddress:PublicIpAddress}"
```

If you configured SSH access, connect using the instance's public IP and your key pair:

```bash
ssh -i your-key.pem ec2-user@<public-ip>
```

## Destroy the Environment

To remove the deployed resources:

```bash
terraform destroy
```

Confirm the destruction by typing `yes`.

## Notes

- Always review the Terraform plan before applying changes.
- Keep AWS credentials secure.
- Use a dedicated IAM user or role with the minimum permissions required.
- Make sure the selected AMI matches the desired OS and region.

## Troubleshooting

Common issues:

- Invalid AWS credentials or missing region configuration
- AMI not available in the selected region
- Insufficient IAM permissions
- Key pair mismatch or missing SSH key
- Security group blocking inbound traffic

If deployment fails, check the Terraform error output and verify your AWS configuration.
