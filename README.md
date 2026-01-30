# Tulip MCP Server Docker Container

This repository contains a Docker container for running the [Tulip MCP Server](https://github.com/tulip/mcp-server-tulip), which provides Model Context Protocol (MCP) integration with Tulip manufacturing execution systems.

## Purpose

The Tulip MCP Server enables AI assistants and applications to interact with Tulip manufacturing data through a standardized protocol. This Docker container provides a secure, isolated environment for running the server with proper configuration management and security practices.

**Key capabilities:**
- Connect AI assistants to Tulip manufacturing data
- Query tables, machines, and operational data
- Execute read-only and write operations (configurable)
- Support for manufacturing workflows and station data
- Rate limiting and retry mechanisms for production stability

## Prerequisites

- Docker installed on your system
- Valid Tulip API credentials (API key and secret)
- Access to a Tulip SaaS instance

## Configuration (.env File)

Create a `.env` file in the same directory as the Dockerfile with the following variables:

### Required (Sensitive) Variables
These **MUST** be provided and should never be committed to version control:

```bash
# Tulip API credentials - REQUIRED
TULIP_API_KEY=your-actual-tulip-api-key
TULIP_API_SECRET=your-actual-tulip-api-secret
TULIP_BASE_URL=https://your-tulip-instance.tulip.co
```
- `TULIP_API_KEY`: Your Tulip API key (from Tulip Settings > API Keys)
- `TULIP_API_SECRET`: Your Tulip API secret (generated with the API key)
- `TULIP_BASE_URL`: Your Tulip SaaS instance URL (format: https://[instance].tulip.co)

### Optional Variables
These have sensible defaults but can be overridden in your .env file:
```bash
# Authentication & Workspace
TULIP_WORKSPACE_ID=DEFAULT              # Workspace ID (only needed for Account API keys)

# Rate Limiting & Retries
MCP_MAX_RETRIES=3                       # Maximum retry attempts for failed requests
MCP_BASE_DELAY=1000                     # Base delay between retries (milliseconds)

# Tool Configuration
ENABLED_TOOLS=machine,read-only         # Comma-separated list of enabled tools/categories

# MCP Server Metadata
MCP_SERVER_NAME=tulip-mcp               # Server name for MCP identification
MCP_SERVER_VERSION=1.0.0                # Server version

# Debugging
MCP_DEBUG=false                         # Enable debug logging (true/false)
```

### Tool Configuration Details
The `ENABLED_TOOLS` variable controls which APIs and operations are available:

#### Available Categories:
- read-only: Safe operations (queries, lists, gets)
- write: Data modification operations
- admin: Administrative functions

#### Available Types:
- table: Table operations (create records, query data)
- machine: Machine status and operations
- user: User management
- app: Application interactions
- interface: Interface operations
- station: Station data and controls
- station-group: Station group management
- utility: Utility functions

### Examples:
```bash
# Enable only read operations
ENABLED_TOOLS=read-only

# Enable specific tools
ENABLED_TOOLS=listTables,getTable,createTableRecord

# Mixed approach (recommended for manufacturing)
ENABLED_TOOLS=table,machine,read-only
```

## Building the Docker Image
```bash
# Build the image
docker build -t tulip-mcp-runner:latest .
```
The Dockerfile includes sensible defaults for all optional configuration. Only the sensitive API credentials need to be provided at runtime.

## Running the Container
### Option 1: Using docker run with .env file (Recommended)
```bash
# Run with .env file (recommended)
docker run -d \
  --name tulip-mcp-runner \
  --env-file .env \
  -p 3350:3350 \
  tulip-mcp-runner:latest
```

## Option 2: Using docker-compose (a Production alternative)
```yaml
version: '3.8'

services:
  tulip-mcp-runner:
    build: .
    container_name: tulip-mcp-runner
    ports:
      - "3350:3350"
    env_file:
      - .env
    restart: unless-stopped
    
    # Optional: Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3350/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Optional: Resource limits for production
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### Run With `docker-compose`
```bash
# Start the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

##  Option 3: Direct Environment Variables
```bash
# Run with explicit environment variables (less secure)
docker run -d \
  --name tulip-mcp-runner \
  -e TULIP_API_KEY="your-api-key" \
  -e TULIP_API_SECRET="your-api-secret" \
  -e TULIP_BASE_URL="https://your-instance.tulip.co" \
  -p 3350:3350 \
  tulip-mcp-runner:latest
```

# Security Considerations
## 🔒 Critical Security Guidelines
### 1. Protect Your Credentials

NEVER commit .env files with real credentials to version control
Add .env to your .gitignore file immediately
Use different API keys for development, staging, and production environments
Rotate API keys regularly according to your security policy
### 2. Environment File Security
```bash
# Set proper file permissions
chmod 600 .env

# Add to .gitignore
echo ".env" >> .gitignore
echo ".env.*" >> .gitignore
```
### 3. Production Deployment
For production environments, consider these security enhancements:

Secrets Management: Use Docker secrets, Kubernetes secrets, or cloud-native secret stores (AWS Secrets Manager, Azure Key Vault)
Network Security: Run containers in isolated networks with firewall rules
RBAC: Use least-privilege Tulip API keys (workspace-level vs account-level)
Monitoring: Enable audit logging for API access
Container Security: Scan images for vulnerabilities, use non-root users
### 4. Network Isolation Example
```yaml
# docker-compose.yml with network isolation
version: '3.8'

networks:
  tulip-internal:
    driver: bridge
    internal: true

services:
  tulip-mcp-runner:
    build: .
    env_file: .env
    networks:
      - tulip-internal
    ports:
      - "127.0.0.1:3350:3350"  # Bind to localhost only
```
### Manufacturing Environment Considerations
- **Export Control**: Ensure Tulip instance and container deployment comply with ITAR/EAR requirements
- **Data Residency**: Keep containers and data in appropriate geographic regions
- **Compliance**: Document API access patterns for ISO 9001, AS9100, or ISO 13485 audits
- **Change Control**: Version control your configurations and follow change management procedures

## Troubleshooting
### Common Issues
- `Container starts but no response`: Check if all required environment variables are set
- `Authentication errors`: Verify API key/secret and workspace ID
- `Network connectivity`: Ensure container can reach your Tulip instance
- `Permission denied`: Check API key permissions and enabled tools configuration

### Debug Mode
Enable debug logging by setting `MCP_DEBUG=true` in your `.env` file, then check container logs:
```bash
# View container logs
docker logs tulip-mcp-runner

# Follow logs in real-time
docker logs -f tulip-mcp-runner
```
### Health Checks
Test if the server is running:
```bash
# Check if server is responding (adjust port if needed)
curl http://localhost:3350/health

# Check container status
docker ps
docker inspect tulip-mcp-runner
```

## Example `.env` Template
Create your `.env` file using this template:
```bash
# ==================================================
# Tulip MCP Server Configuration
# ==================================================
# 
# 🔒 SECURITY WARNING:
# This file contains sensitive credentials.
# - DO NOT commit this file to version control
# - Set file permissions: chmod 600 .env
# - Add .env to .gitignore
#
# ==================================================

# REQUIRED: Tulip API Credentials
TULIP_API_KEY=your-tulip-api-key-here
TULIP_API_SECRET=your-tulip-api-secret-here
TULIP_BASE_URL=https://your-instance.tulip.co

# OPTIONAL: Uncomment and modify as needed
# TULIP_WORKSPACE_ID=your-workspace-id
# MCP_MAX_RETRIES=3
# MCP_BASE_DELAY=1000
# ENABLED_TOOLS=machine,read-only,table
# MCP_SERVER_NAME=tulip-mcp-production
# MCP_SERVER_VERSION=1.0.0
# MCP_DEBUG=false
```

# License
[MIT License](./LICENSE)

# Support
For issues related to:

Docker container: Create an issue in this repository
Tulip MCP Server: See the official [Tulip MCP Server info](https://tulip.co/blog/introducing-tulip-mcp/) or [Tulip MCP Server repository](https://github.com/tulip/tulip-mcp)
Tulip API: Contact Tulip support or consult [Tulip API documentation](https://support.tulip.co/docs/work-with-apis)