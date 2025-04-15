# R2R Deployment with Coolify

This directory contains Docker Compose configuration for deploying R2R using Coolify.

## Deployment Instructions

1. In Coolify, create a new service using "Build Pack: Docker Compose"
2. Set the Base Directory to `/docker`
3. Choose `compose.coolify.yaml` as your compose file
4. Make sure to configure the necessary environment variables in Coolify

## Environment Variables

The compose file is set up to work with Coolify's single .env file approach. All necessary environment variables have default values, but you should configure at least the following:

### Required Variables
- `R2R_SECRET_KEY`: A secure secret key for the R2R application
- `POSTGRES_PASSWORD`: Password for the PostgreSQL database
- `HATCHET_POSTGRES_PASSWORD`: Password for the Hatchet PostgreSQL database
- `RABBITMQ_DEFAULT_PASS`: Password for RabbitMQ

### Optional but Recommended
- At least one LLM API key (e.g., `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, etc.)
- `NEXT_PUBLIC_R2R_DEFAULT_PASSWORD`: Default password for the R2R dashboard

## Volumes

The following volumes are used:
- `postgres_data`: PostgreSQL data
- `hatchet_postgres_data`: Hatchet PostgreSQL data
- `hatchet_rabbitmq_data`: RabbitMQ data
- `hatchet_certs`: Hatchet certificates
- `hatchet_config`: Hatchet configuration
- `hatchet_api_key`: Hatchet API key

## Services

- R2R API service runs on port 7272
- R2R Dashboard runs on port 7273
- Hatchet Dashboard runs on port 7274
- Monitoring is available through Grafana on port 3001
