# StartTech Infrastructure Runbook

## Overview

This runbook documents the operational procedures for deploying, monitoring, troubleshooting, and maintaining the StartTech infrastructure environment.

---

# Infrastructure Components

The infrastructure includes:

- VPC
- Public and private subnets
- NAT Gateway
- Application Load Balancer
- EC2 Auto Scaling Group
- Dockerized backend API
- S3 frontend hosting
- CloudFront CDN
- ElastiCache Redis
- CloudWatch monitoring
- GitHub Actions CI/CD

---

# Backend Deployment Procedure

Backend deployments are automated using GitHub Actions.

## Deployment Steps

1. Developer pushes code to `main`
2. GitHub Actions pipeline triggers
3. Tests are executed
4. Docker image is built
5. Docker image pushed to Docker Hub
6. Auto Scaling Group instance refresh triggered
7. New EC2 instances launch automatically
8. New instances pull latest Docker image
9. Old instances are drained gracefully

---

# Frontend Deployment Procedure

Frontend deployment steps:

1. Developer pushes frontend changes
2. GitHub Actions workflow runs
3. React app builds
4. Build files uploaded to S3
5. CloudFront invalidation triggered

---

# Terraform Operations

## Initialize Terraform

```bash
terraform init
```

## Validate Configuration

```bash
terraform validate
```

## Format Terraform Files

```bash
terraform fmt
```

## Preview Infrastructure Changes

```bash
terraform plan
```

## Apply Infrastructure Changes

```bash
terraform apply
```

---

# Docker Operations

## Build Backend Image

```bash
docker build -t starttech-backend .
```

## Run Backend Container Locally

```bash
docker run -p 8080:8080 starttech-backend
```

## View Running Containers

```bash
docker ps
```

## View Container Logs

```bash
docker logs <container-id>
```

---

# Monitoring

## CloudWatch

CloudWatch is used for:

- Log collection
- CPU monitoring
- Dashboard metrics
- Auto scaling alarms

## CloudWatch Alarm

High CPU alarm:

- Alarm Name: `starttech-high-cpu`
- Trigger Threshold: `70% CPU`

---

# Auto Scaling

The backend infrastructure scales automatically using:

- Auto Scaling Group
- Launch Template
- CloudWatch alarm
- Scaling policy

## Scaling Trigger

If average CPU utilization exceeds 70%, the Auto Scaling Group launches additional EC2 instances.

---

# Health Checks

Backend health endpoint:

```bash
/health
```

Application Load Balancer target groups use this endpoint to determine instance health.

---

# Troubleshooting

## ALB Returning 502 Error

Possible causes:

- Backend container not running
- Incorrect backend port
- Failed health checks
- Docker container crash

### Troubleshooting Steps

SSH into EC2 instance:

```bash
docker ps
docker logs starttech-backend
sudo ss -tulpn | grep 8080
```

---

## Failed Health Checks

Verify:

- Backend running on port 8080
- Security group allows port 8080
- `/health` endpoint returns HTTP 200

---

## GitHub Actions Failure

Verify:

- GitHub secrets configured correctly
- Docker Hub credentials valid
- AWS credentials valid
- Workflow YAML syntax correct

---

# Useful AWS Console Locations

## EC2

```text
EC2 → Auto Scaling Groups
```

## Load Balancer

```text
EC2 → Load Balancers
```

## Target Groups

```text
EC2 → Target Groups
```

## CloudWatch

```text
CloudWatch → Dashboards
CloudWatch → Log Groups
CloudWatch → Alarms
```

---

# Redis

Redis is provisioned using Amazon ElastiCache.

Purpose:

- Session storage
- Caching layer
- Performance optimization

---

# Security Practices

Implemented security measures include:

- IAM roles for EC2
- Security groups
- Environment variables
- GitHub encrypted secrets
- Controlled inbound access

---

# Recovery Procedures

## Rebuild Backend Instances

Trigger ASG refresh:

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name starttech-backend-asg
```

## Redeploy Backend

Push changes to `main` branch to trigger GitHub Actions deployment pipeline.

---

# Maintenance

Recommended maintenance tasks:

- Rotate credentials
- Update Docker base images
- Patch EC2 AMIs
- Review CloudWatch alarms
- Monitor scaling activity
- Clean unused Docker images

---

# Operational Status

Current operational capabilities:

- High availability backend
- Rolling deployments
- Automated CI/CD
- Infrastructure as Code
- Auto scaling
- Centralized monitoring
- CDN-enabled frontend delivery