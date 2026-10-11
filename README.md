# AWS Infrastructure Provisioning with Terraform

## Project Overview

This project demonstrates Infrastructure as Code (IaC) using **Terraform and AWS**. It provisions a custom VPC, creates two public subnets across different Availability Zones, configures internet connectivity, and deploys two EC2 instances running Apache web servers.

The EC2 instances are configured automatically using Bash user-data scripts, which install Apache and create a simple webpage displaying the instance ID and subnet information.

The goal of this project is to understand how AWS networking resources connect and how Terraform automates infrastructure provisioning.

![AWS Terraform architecture] 

## AWS Resources Created

- **VPC:** Provides an isolated virtual network for the infrastructure.
- **Subnets:** Two public subnets in separate Availability Zones.
- **Internet Gateway:** Enables internet connectivity for the VPC.
- **Route Table:** Routes internet-bound traffic through the Internet Gateway.
- **Route Table Associations:** Associate both subnets with the route table.
- **Security Group:** Defines inbound SSH and HTTP access and allows outbound traffic.
- **EC2 Instances:** Two `t3.micro` instances, one in each subnet.
- **S3 Bucket:** An AWS S3 bucket provisioned from AWS Console.

### 1. Apache website running

The page shows the custom HTML content served by Apache on the first EC2 instance.

![Website running on EC2] 
### 2. EC2 instance details

AWS Console evidence of the running instance, including its public and private IP addresses, VPC, and subnet.

![EC2 instance details] 

### 3. VPC resource map

The resource map shows the VPC, both subnets, route tables, and Internet Gateway.

![VPC resource map] 

## S3 remote state

Terraform uses an S3 backend configured with the state key `demo/terraform.tfstate` in `ap-south-1`. The `use_lockfile = true` setting enables S3-native state locking using a `.tflock` object.

![S3 remote state object] 

The S3 backend bucket must exist before Terraform initializes the backend. Keep the backend bucket separate from the infrastructure resources managed by this configuration to avoid a bootstrap dependency.



## How It Works

1. Terraform creates the VPC and networking resources.
2. Two public subnets are created in different Availability Zones.
3. An Internet Gateway and route table provide a path for internet traffic.
4. A security group defines the permitted network traffic.
5. Terraform launches an EC2 instance in each subnet.
6. Each instance executes its user-data script during initialization.
7. The scripts install Apache, retrieve the instance ID from EC2 instance metadata, and generate an HTML webpage.
8. The webpages can be accessed over HTTP using the instances' public IP addresses, provided the instances have public IPs and the network configuration is correct.

## Run the project

Prerequisites: Terraform installed, AWS CLI configured with credentials for the target account, and permissions (not needed fro root user) to manage the required AWS resources and access the S3 backend.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying it. When finished with the learning environment, remove the infrastructure you no longer need:

```bash
terraform destroy
```

Do not delete the S3 backend bucket while Terraform still needs its remote state. If you intend to remove the backend bucket too, first ensure the infrastructure has been destroyed and the state is no longer needed.


After deployment, obtain the EC2 public IP addresses from the AWS Console or terraform state, then open the URLs in a browser:

```text
http://<instance-1-public-ip>
http://<instance-2-public-ip>
```

## Cleanup

Destroy the resources when they are no longer needed:

```bash
terraform destroy
```
## Learning Outcomes

- Understanding Infrastructure as Code with Terraform.
- Provisioning AWS networking resources and EC2 instances.
- Understanding VPCs, subnets, route tables, Internet Gateways, and security groups.
- Using Terraform variables and resource references.
- Automating EC2 configuration with Bash user-data scripts.
- Deploying a basic Apache web server on AWS.
- Managing infrastructure through Terraform's plan, apply, and destroy workflow.


