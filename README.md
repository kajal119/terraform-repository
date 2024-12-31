# HTTP Service and Terraform Deployment

## Overview

This project consists of two parts:

1. **HTTP Service**: A Flask-based HTTP service that connects to an S3 bucket and returns the content (or a specific path) as a JSON response.
2. **Terraform Deployment**: Terraform configuration to provision AWS infrastructure (EC2) and deploy the HTTP service.

## Prerequisites

- Python 3.x
- Flask
- Boto3
- Terraform
- AWS account with credentials configured

## Part 1: HTTP Service

The HTTP service exposes the endpoint `/list-bucket-content/<path>` that lists the content of an S3 bucket. If no path is specified, it returns the top-level content.

### Example Usage

- `GET /list-bucket-content`: Returns a list of files and directories in the S3 bucket.
- `GET /list-bucket-content/dir1`: Returns the content within `dir1`.

## Part 2: Terraform Deployment

The Terraform configuration provisions an EC2 instance and deploys the HTTP service on it.

### Steps to Deploy

1. Clone the repository.
2. Navigate to the `terraform` directory.
3. Run `terraform init` to initialize Terraform.
4. Run `terraform apply` to create the EC2 instance and deploy the service.
5. Access the service at `http://<instance_ip>:8000/list-bucket-content`.
