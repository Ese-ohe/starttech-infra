# StartTech Infrastructure

## Overview

This repository contains Terraform Infrastructure as Code (IaC) for the StartTech platform.

## Infrastructure Components

- VPC networking
- Security groups
- EC2 compute resources
- Application Load Balancer
- Auto Scaling Group
- S3 bucket for frontend hosting
- CloudFront distribution
- CloudWatch monitoring
- Redis caching layer
- MongoDB connectivity

## Terraform Structure

```text
terraform/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── storage/
│   └── monitoring/
## CI/CD

GitHub Actions workflow automates Terraform validation and planning.

## Monitoring

Monitoring configurations are located in:

```text
monitoring/
## Deployment

Run:

```bash
terraform init
terraform validate
terraform plan