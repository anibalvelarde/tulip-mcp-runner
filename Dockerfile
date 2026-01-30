FROM node:20-slim

# Install Python and required packages
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment and install mcpo
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install --upgrade pip && pip3 install mcpo

# Set non-sensitive defaults (can be overridden by .env file)
ENV TULIP_WORKSPACE_ID=DEFAULT
ENV MCP_MAX_RETRIES=3
ENV MCP_BASE_DELAY=1000
ENV ENABLED_TOOLS=machine,read-only
ENV MCP_SERVER_NAME=tulip-mcp-runner
ENV MCP_SERVER_VERSION=1.0.0
ENV MCP_DEBUG=false

# Sensitive environment variables (MUST be provided via .env file or runtime)
# ENV TULIP_API_KEY - Required: Set via .env file
# ENV TULIP_API_SECRET - Required: Set via .env file
# ENV TULIP_BASE_URL - Required: Set via .env file

# Create app directory
WORKDIR /app

# Expose port
EXPOSE 3351

# Verify
RUN ls /*

# Run the application with mcpo
CMD ["/opt/venv/bin/mcpo", "--port", "3351", "--", "npx", "-y", "@tulip/mcp-server"] 