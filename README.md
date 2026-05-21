# StartTech Full-Stack Cloud Infrastructure

## Overview

This project implements a production-style cloud infrastructure and CI/CD pipeline for the StartTech full-stack application using AWS, Terraform, Docker, GitHub Actions, and Cloud-native services.

The infrastructure provisions:

- React frontend hosting
- Golang backend API deployment
- Auto Scaling backend infrastructure
- Application Load Balancer
- Redis caching layer
- Monitoring and logging
- CI/CD automation
- Rolling deployments

---

# Technologies Used

## Infrastructure

- Terraform
- AWS VPC
- EC2
- Auto Scaling Group
- Application Load Balancer
- CloudFront
- S3
- ElastiCache Redis
- CloudWatch
- IAM

## Backend

- Golang
- Docker
- MongoDB Atlas
- Redis

## Frontend

- React
- Vite

## CI/CD

- GitHub Actions
- Docker Hub

---

# Architecture

Detailed architecture documentation is available in:

```bash
ARCHITECTURE.md
```

---

# Infrastructure Provisioned

Terraform provisions the following resources:

## Networking

- VPC
- Public subnets
- Private subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Security groups

## Compute

- EC2 Launch Template
- Auto Scaling Group
- Application Load Balancer
- Target Groups

## Storage and CDN

- S3 frontend bucket
- CloudFront distribution

## Monitoring

- CloudWatch Log Groups
- CloudWatch Dashboard
- CPU Alarm
- Auto Scaling Policy

## Caching

- ElastiCache Redis Cluster

---

# Backend Deployment

The backend application is containerized using Docker.

Deployment process:

1. GitHub Actions builds Docker image
2. Docker image pushed to Docker Hub
3. Auto Scaling Group instance refresh triggered
4. New EC2 instances launch
5. EC2 instances pull latest Docker image
6. Old instances drained automatically

---

# Frontend Deployment

The frontend deployment pipeline:

1. React application builds
2. Static files uploaded to S3
3. CloudFront cache invalidated
4. Updated frontend served globally

---

# Auto Scaling

The backend infrastructure uses:

- Auto Scaling Group
- Launch Template
- CloudWatch CPU Alarm
- Scaling Policy

Scaling triggers when CPU utilization exceeds configured thresholds.

---

# Health Checks

Backend health checks are configured using:

```bash
/health
```

The Application Load Balancer validates backend health before routing traffic.

---

# CI/CD Pipelines

## Backend CI/CD

Workflow includes:

- Dependency installation
- Unit testing
- Integration testing
- Vulnerability scanning
- Docker image build
- Docker image push
- Rolling deployment trigger

## Frontend CI/CD

Workflow includes:

- Dependency installation
- Frontend build
- S3 deployment
- CloudFront invalidation

---

# Monitoring and Logging

CloudWatch provides:

- Application log groups
- CPU monitoring
- Dashboard metrics
- Auto scaling alarms

---

# Security

Security implementation includes:

- IAM roles
- Security groups
- GitHub Secrets
- Controlled ingress rules
- Environment variable management

---

# Repository Structure

```bash
terraform/
├── main.tf
├── outputs.tf
├── variables.tf
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── storage/
│   └── monitoring/

.github/
└── workflows/
    ├── backend-ci-cd.yml
    └── frontend-ci-cd.yml
```

---

# Deployment Commands

## Terraform

```bash
terraform init
terraform plan
terraform apply
```

## Backend

```bash
docker build -t starttech-backend .
docker run -p 8080:8080 starttech-backend
```

---

# Future Improvements

Potential future improvements include:

- ECS or EKS migration
- HTTPS with ACM
- Route53 custom domain
- Blue/Green deployment
- WAF integration
- Secrets Manager integration
- Centralized observability stack

---

# Author

StartTech Assessment 3 Infrastructure Project