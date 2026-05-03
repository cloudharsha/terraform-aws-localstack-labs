# terraform-aws-localstack-labs

A hands-on practice repository for learning **Terraform** with **AWS** locally using [LocalStack](https://localstack.cloud/) — no real AWS account required.

---

## 📁 Repository Structure

```
terraform-aws-localstack-labs/
├── documentation/          # Guides, notes, and reference docs
├── localstack/             # LocalStack Docker setup
│   ├── docker-compose.yml  # Docker Compose file to run LocalStack
│   ├── .env.example        # Environment variable template
│   ├── .gitignore          # Ignores runtime volume & .env
│   └── scripts/
│       └── init-localstack.sh  # Bootstrap script (health check + seed resources)
└── terraform/              # Terraform configurations (labs)
```

---

## 🚀 Getting Started with LocalStack

### Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | ≥ 24 | Runs LocalStack container |
| [Docker Compose](https://docs.docker.com/compose/) | ≥ 2.x | Orchestrates the container |
| [AWS CLI](https://aws.amazon.com/cli/) | ≥ 2 | Interact with LocalStack endpoints |
| [Terraform](https://developer.hashicorp.com/terraform/install) | ≥ 1.6 | Infrastructure-as-code tool |

> **Optional but recommended:** Install [awslocal](https://github.com/localstack/awscli-local) (`pip install awscli-local`) — a thin wrapper around the AWS CLI pre-configured to talk to LocalStack.

---

> [!IMPORTANT]
> `localstack/localstack:latest` now resolves to a **Pro** build and exits with code 55 if no auth token is set.
> The `docker-compose.yml` in this repo is pinned to `localstack/localstack:3` (Community edition — free, no sign-up needed).

### 1 · Configure environment variables

```bash
# From the localstack/ directory
cd localstack
cp .env.example .env
```

Edit `.env` if you want to change the AWS region, enabled services, or debug level. The defaults work out of the box.

---

### 2 · Start LocalStack

```bash
# From the localstack/ directory
docker compose up -d
```

This pulls the `localstack/localstack:latest` image (first run only) and starts the container in the background.

**Verify it is running:**

```bash
# Should return JSON with service statuses
curl http://localhost:4566/_localstack/health
```

Or with the AWS CLI:

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

---

### 3 · Run the bootstrap script *(optional)*

The script waits for LocalStack to be healthy, then seeds an initial S3 bucket (`terraform-state-local`) that can be used as a Terraform remote-state backend.

```bash
# Make executable (first time only)
chmod +x localstack/scripts/init-localstack.sh

# Run
bash localstack/scripts/init-localstack.sh
```

---

### 4 · Stop LocalStack

```bash
# From the localstack/ directory
docker compose down
```

Add `-v` to also remove the persisted volume:

```bash
docker compose down -v
```

---

## 🔧 Configuring the AWS CLI for LocalStack

Add a dedicated profile to avoid mixing LocalStack with real AWS credentials:

```bash
aws configure --profile localstack
# AWS Access Key ID:     test
# AWS Secret Access Key: test
# Default region name:   us-east-1
# Default output format: json
```

Use the profile for every command:

```bash
aws --profile localstack --endpoint-url=http://localhost:4566 s3 ls
```

Or export for the current session:

```bash
export AWS_PROFILE=localstack
export AWS_ENDPOINT_URL=http://localhost:4566
```

---

## 🌐 LocalStack Service Endpoints

All AWS services are available through a single gateway endpoint:

| Endpoint | Description |
|---|---|
| `http://localhost:4566` | Main LocalStack gateway (all services) |
| `http://localhost:4566/_localstack/health` | Health check |
| `http://localhost:4566/_localstack/info` | Version & feature info |

---

## 🔗 Useful Links

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Terraform LocalStack Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/custom-service-endpoints)
- [awslocal CLI](https://github.com/localstack/awscli-local)
- [tflocal CLI](https://github.com/localstack/terraform-local) — Terraform wrapper for LocalStack
