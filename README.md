# AWS ECS Fargate CI/CD Pipeline

A production-style cloud deployment project that demonstrates how to provision AWS infrastructure with Terraform and deploy a containerized application to Amazon ECS Fargate using GitHub Actions.

## Project Overview

This project demonstrates an end-to-end cloud delivery workflow:

1. Provision AWS infrastructure with Terraform.
2. Containerize a Node.js application with Docker.
3. Push the container image to Amazon ECR.
4. Deploy the application to Amazon ECS Fargate.
5. Trigger the deployment workflow manually from GitHub Actions.
6. Use GitHub Actions OIDC authentication instead of storing long-lived AWS access keys in GitHub.

The application exposes:

- `/` - sample application response
- `/health` - health-check endpoint

## Architecture

```text
Developer
   |
   | push code
   v
GitHub Repository
   |
   | manual GitHub Actions trigger
   v
GitHub Actions
   |
   | OIDC / AssumeRoleWithWebIdentity
   v
AWS IAM
   |
   +----------------------+
   |                      |
   v                      v
Amazon ECR           Amazon ECS Fargate
(Container Image)         |
                          v
                 Application Load Balancer
                          |
                          v
                    Node.js Service
                          |
                          v
                  CloudWatch Logs
```

Infrastructure is provisioned with Terraform and includes:

```text
VPC
|-- Public Subnets
|   |-- Internet Gateway
|   |-- NAT Gateway
|   `-- Application Load Balancer
|
`-- Private Subnets
    `-- ECS Fargate Tasks
```

## Technologies Used

- **AWS:** ECS Fargate, ECR, IAM, VPC, CloudWatch
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions
- **Containers:** Docker
- **Application:** Node.js / Express
- **Security:** GitHub Actions OIDC and least-privilege IAM permissions

## Infrastructure Design

The Terraform configuration provisions a dedicated VPC with public and private subnets.

Public subnets provide internet-facing infrastructure, while ECS tasks run in private subnets without public IP addresses. A NAT Gateway provides controlled outbound internet access for private resources.

The ECS service runs on AWS Fargate and sends application logs to CloudWatch.

## CI/CD Workflow

The deployment workflow is currently configured with `workflow_dispatch`, so it runs only when manually triggered from the GitHub Actions interface.

```text
Manual Run
    |
    v
GitHub Actions
    |
    v
Authenticate to AWS using OIDC
    |
    v
Authenticate to Amazon ECR
    |
    v
Build Docker image
    |
    v
Push image to ECR
    |
    v
Force new ECS service deployment
```

The workflow uses GitHub's OpenID Connect integration with AWS. This avoids storing permanent AWS access keys in the repository or in GitHub Actions secrets.

## Security Decisions

A key goal of this project was to avoid unnecessary credential exposure.

The deployment workflow uses:

- GitHub Actions OIDC for temporary AWS credentials
- An IAM role restricted to this repository
- IAM permissions scoped to ECR image publishing and ECS deployment actions
- ECS workloads deployed into private subnets
- Security groups to control network access
- Local Terraform variable files excluded from source control

## Repository Structure

```text
.
|-- .github/
|   `-- workflows/
|       `-- deploy.yml
|-- app/
|   |-- package.json
|   |-- package-lock.json
|   `-- server.js
|-- infra/
|   |-- .terraform.lock.hcl
|   |-- ecr.tf
|   |-- ecs.tf
|   |-- github-actions-oidc.tf
|   |-- iam.tf
|   |-- main.tf
|   |-- networking.tf
|   |-- outputs.tf
|   |-- providers.tf
|   |-- security.tf
|   |-- terraform.tfvars.example
|   `-- variables.tf
|-- Dockerfile
|-- .gitignore
`-- README.md
```

## Application

The sample Express application listens on port `3000` and provides a dedicated health endpoint.

```text
GET /
GET /health
```

## Deployment Process

### 1. Create a local Terraform variables file

Copy the example file:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Update the values if needed. The real `terraform.tfvars` file is intentionally ignored by Git.

### 2. Provision the AWS infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Configure GitHub Actions

Configure the repository values required by `.github/workflows/deploy.yml`, including:

- AWS Region
- ECR repository name
- ECS cluster name
- ECS service name
- IAM role ARN used by GitHub Actions

### 4. Deploy

Open the repository's **Actions** tab, select **Deploy to ECS (Fargate)**, and choose **Run workflow**.

The workflow will:

1. Check out the repository.
2. Assume the AWS deployment role through OIDC.
3. Log in to Amazon ECR.
4. Build the Docker image.
5. Push the image to ECR.
6. Trigger a new ECS service deployment.

## Engineering Concepts Demonstrated

This project demonstrates practical experience with:

- Infrastructure as Code
- VPC networking
- Public/private subnet design
- Container orchestration
- CI/CD automation
- IAM and temporary cloud credentials
- Least-privilege access
- Load-balanced container workloads
- Cloud logging
- Deployment automation

## Current Environment Note

The GitHub Actions workflow is configured for manual execution. The AWS deployment environment must be active and the required repository variables and secrets must be configured before a deployment run can succeed.

## Future Improvements

Potential next steps include:

- HTTPS with AWS Certificate Manager
- Route 53 DNS
- ECS service auto scaling
- CloudWatch alarms and dashboards
- Blue/green or canary deployments
- Automated Terraform validation in CI
- Container vulnerability scanning
- Remote Terraform state with S3 and DynamoDB locking
- Multiple deployment environments such as dev, staging, and production

## Author

**Timothy Charles Nnabuchi**

Cloud / DevOps Engineer focused on AWS infrastructure, automation, containerized systems, and reliable cloud deployments.
