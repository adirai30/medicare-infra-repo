# ☁️ MediCare Infrastructure Repository

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-purple)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![EKS](https://img.shields.io/badge/Amazon-EKS-blue)
![VPC](https://img.shields.io/badge/AWS-VPC-green)
![IaC](https://img.shields.io/badge/IaC-Terraform-blue)

## 📌 Project Overview

This repository contains the **Terraform Infrastructure as Code (IaC)** used to provision the AWS infrastructure for the MediCare DevSecOps/GitOps platform.

The infrastructure is designed to provide a secure and scalable foundation for:

* ☸️ Amazon EKS
* 🌐 VPC networking
* 🔒 Private subnets
* 🌍 Public subnets
* 🚪 Internet Gateway
* 🔄 NAT Gateways
* 📦 EKS worker nodes
* ⚖️ AWS Load Balancer integration
* 🚀 Kubernetes application deployment

---

# 🏗️ Infrastructure Architecture

```text
                         ☁️ AWS
                          │
                          ▼
                    ┌───────────┐
                    │    VPC    │
                    │10.0.0.0/16│
                    └─────┬─────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
       Public Subnets            Private Subnets
       10.0.0.0/24               10.0.10.0/24
       10.0.1.0/24               10.0.11.0/24
             │                         │
             │                         ▼
             │                  EKS Worker Nodes
             │                         │
             ▼                         ▼
       Internet Gateway            Amazon EKS
             │                         │
             ▼                         ▼
          Internet              MediCare Application
```

---

# 🧰 Technology Stack

| Component                  | Technology           |
| -------------------------- | -------------------- |
| ☁️ Cloud                   | AWS                  |
| 🏗️ Infrastructure as Code | Terraform            |
| ☸️ Kubernetes              | Amazon EKS           |
| 🌐 Networking              | Amazon VPC           |
| 🚪 Internet Gateway        | AWS IGW              |
| 🔄 Private Internet Access | NAT Gateway          |
| 🖥️ Worker Nodes           | EC2                  |
| 📦 Registry                | Amazon ECR           |
| ⚖️ Load Balancing          | AWS Load Balancer    |
| 🔐 Identity                | AWS IAM              |
| 📊 Monitoring              | Prometheus + Grafana |

---

# 📁 Repository Structure

```text
medicare-infra-repo/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── .terraform.lock.hcl
├── .gitignore
└── README.md
```

Terraform state files are intentionally excluded from Git using `.gitignore`.

---

# 🌎 AWS Region

The infrastructure is deployed in:

```text
us-east-1
```

---

# 🌐 VPC Configuration

VPC CIDR:

```text
10.0.0.0/16
```

The network is divided into public and private subnets.

### Public Subnets

```text
10.0.0.0/24
10.0.1.0/24
```

### Private Subnets

```text
10.0.10.0/24
10.0.11.0/24
```

---

# 🌍 Public Network

Public resources use:

```text
Internet Gateway
```

Traffic flow:

```text
Internet
   ↓
Internet Gateway
   ↓
Public Route Table
   ↓
Public Subnet
```

---

# 🔒 Private Network

Private resources use NAT gateways for outbound internet connectivity.

```text
Private Subnet
      ↓
Private Route Table
      ↓
NAT Gateway
      ↓
Internet Gateway
      ↓
Internet
```

This allows private resources to access external services without making them directly internet-facing.

---

# ☸️ Amazon EKS

The infrastructure provisions the Kubernetes foundation for the MediCare platform.

Cluster:

```text
medicare-eks
```

Worker node group:

```text
medicare-workers
```

Worker node instance type:

```text
t3.small
```

The cluster uses private subnets for worker nodes.

---

# 🖥️ Worker Nodes

The EKS worker nodes run inside private subnets.

Benefits:

* 🔒 Reduced direct internet exposure
* 🛡️ Better network isolation
* 📈 Scalable Kubernetes workloads
* ☸️ Suitable for production-style architecture

---

# ⚖️ AWS Load Balancer

The EKS environment integrates with the AWS Load Balancer Controller.

The Kubernetes application can create an:

```text
AWS Application Load Balancer
```

Traffic is routed to Kubernetes services using the ingress configuration stored in the GitOps repository.

---

# 🔐 Infrastructure Security

The project follows several security practices:

### 🔒 Private Worker Nodes

EKS worker nodes are placed in private subnets.

### 🌐 Public Access

Only resources that require public connectivity are exposed through public networking.

### 🛡️ IAM

AWS permissions are controlled using IAM roles and policies.

### 🔑 GitHub OIDC

GitHub Actions authenticates with AWS using OIDC instead of storing long-lived AWS access keys.

---

# 🚀 Terraform Workflow

The infrastructure follows:

```text
Terraform Code
      │
      ▼
terraform init
      │
      ▼
terraform validate
      │
      ▼
terraform plan
      │
      ▼
terraform apply
      │
      ▼
AWS Infrastructure
```

---

# 🛠️ Prerequisites

Install:

* Terraform
* AWS CLI
* kubectl
* Helm
* Git

Configure AWS CLI:

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

# 🚀 Getting Started

## 1️⃣ Clone Repository

```bash
git clone https://github.com/adirai30/medicare-infra-repo.git
cd medicare-infra-repo
```

---

## 2️⃣ Initialize Terraform

```bash
terraform init
```

This downloads the required Terraform providers and initializes the working directory.

---

## 3️⃣ Validate Configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

## 4️⃣ Format Terraform

```bash
terraform fmt
```

---

## 5️⃣ Review Infrastructure Plan

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

---

## 6️⃣ Apply Infrastructure

```bash
terraform apply
```

Review the proposed resources and confirm when prompted.

---

# 🔍 Verify AWS Infrastructure

Check the VPC:

```bash
aws ec2 describe-vpcs
```

Check EKS:

```bash
aws eks describe-cluster \
  --region us-east-1 \
  --name medicare-eks
```

Update Kubernetes configuration:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name medicare-eks
```

Verify nodes:

```bash
kubectl get nodes
```

---

# 🧹 Terraform Cleanup

To remove Terraform-managed resources:

```bash
terraform destroy
```

⚠️ **Important:** Never run `terraform destroy` on the shared/demo environment unless you intentionally want to remove the infrastructure.

---

# 🔄 Relationship With Other Repositories

The MediCare platform is divided into three repositories.

```text
┌───────────────────────────────┐
│     medicare-app-repo         │
│                               │
│ Application + CI/CD           │
└───────────────┬───────────────┘
                │
                ▼
        Amazon ECR Images
                │
                ▼
┌───────────────────────────────┐
│     medicare-gitops-repo      │
│                               │
│ Kubernetes + Argo CD manifests│
└───────────────┬───────────────┘
                │
                ▼
             Argo CD
                │
                ▼
┌───────────────────────────────┐
│        Amazon EKS             │
│                               │
│ MediCare Application          │
└───────────────────────────────┘

        ▲
        │
        │ Infrastructure
        │
┌───────┴───────────────────────┐
│      medicare-infra-repo      │
│                               │
│ Terraform + AWS Infrastructure│
└───────────────────────────────┘
```

---

# 🎯 Infrastructure Objectives

This repository demonstrates practical experience with:

* ☁️ AWS
* 🏗️ Terraform
* 🌐 VPC
* 🔒 Public/private subnet architecture
* 🔄 NAT Gateway
* 🚪 Internet Gateway
* ☸️ Amazon EKS
* 🖥️ EC2 worker nodes
* ⚖️ AWS Load Balancer
* 🔐 IAM
* 🔑 OIDC
* 📦 ECR
* 🚀 GitOps architecture

---

# 📊 Current Platform Architecture

```text
                         👨‍💻 Developer
                              │
                              ▼
                     ┌─────────────────┐
                     │ GitHub App Repo │
                     └────────┬────────┘
                              │
                              ▼
                     GitHub Actions
                              │
                 ┌────────────┼────────────┐
                 ▼            ▼            ▼
               Test        Trivy       Docker
                                           │
                                           ▼
                                      Amazon ECR
                                           │
                                           ▼
                                   GitOps Repository
                                           │
                                           ▼
                                        Argo CD
                                           │
                                           ▼
                                      Amazon EKS
                                           │
                       ┌───────────────────┴───────────────────┐
                       │                                       │
                       ▼                                       ▼
                MediCare App                            Monitoring
                ├── Frontend                            ├── Prometheus
                └── Backend                             ├── Grafana
                                                        └── Alertmanager

                         ▲
                         │
                  Terraform Infrastructure
                         │
                  AWS VPC + EKS + Networking
```

---

# 🛡️ Infrastructure as Code Benefits

### 🔁 Reproducibility

Infrastructure can be recreated from Terraform code.

### 📝 Version Control

Infrastructure changes are tracked using Git.

### 🔍 Reviewability

Terraform plans allow changes to be reviewed before deployment.

### 🤖 Automation

Infrastructure provisioning becomes repeatable and less dependent on manual AWS Console operations.

### 📦 Standardization

The same architecture can be recreated consistently.

---

# 👨‍💻 Author

**Aditya Rai**

Cloud / DevOps Engineer

GitHub:

https://github.com/adirai30

---

# ⭐ Infrastructure Highlights

```text
✅ Terraform IaC
✅ AWS VPC
✅ Public + Private Subnets
✅ Internet Gateway
✅ NAT Gateways
✅ Amazon EKS
✅ EC2 Worker Nodes
✅ AWS Load Balancer integration
✅ IAM
✅ GitHub OIDC
✅ ECR
✅ GitOps-ready architecture
```

---

# 📜 License

This project is created for learning, portfolio, demonstration, and DevOps practice purposes.
