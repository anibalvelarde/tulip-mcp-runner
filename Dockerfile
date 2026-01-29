FROM node:20-slim

# Install Python and required packages
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment and install mcpo
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install --upgrade pip && pip3 install mcpo

# Create app directory
WORKDIR /app

# Expose port
EXPOSE 3350

# Run the application with mcpo
CMD ["/opt/venv/bin/mcpo", "--port", "3350", "--", "npx", "-y", "@tulip/mcp-server"] 