FROM node:18-bullseye-slim

# Install PostgreSQL client for pg_dump/psql and other utilities
RUN apt-get update && apt-get install -y postgresql-client procps && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (production only or all? build needs devDeps usually)
RUN npm install

# Copy source
COPY . .

# Build the app
RUN npm run build

# Expose port
EXPOSE 4321

# Make entrypoint executable
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entrypoint
ENTRYPOINT ["entrypoint.sh"]
