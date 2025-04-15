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
- `OPENAI_API_KEY` or another LLM API key for the R2R application to function

### Coolify Magic Variables
The compose file takes advantage of Coolify's magic environment variables for automatic generation of secure values:

- `SERVICE_PASSWORD_POSTGRES`: Generated password for PostgreSQL
- `SERVICE_PASSWORD_HATCHET_DB`: Generated password for Hatchet's PostgreSQL database
- `SERVICE_USER_RABBITMQ`: Generated username for RabbitMQ
- `SERVICE_PASSWORD_RABBITMQ`: Generated password for RabbitMQ
- `SERVICE_BASE64_64_R2R_SECRET`: Generated 64-character secret key for R2R
- `SERVICE_PASSWORD_ADMIN`: Generated password for the admin user

You don't need to set these variables manually - Coolify will generate them automatically when you deploy the application.

### Custom Domains
The compose file also uses Coolify's FQDN feature for automatic domain routing:

- `SERVICE_FQDN_R2R_7272`: Creates an accessible URL for the R2R API
- `SERVICE_FQDN_R2R_DASHBOARD_3000`: Creates an accessible URL for the R2R dashboard

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
