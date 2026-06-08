#!/bin/bash

# Generated from official installation evidence:
# - https://github.com/router-for-me/CLIProxyAPI/blob/v7.1.50/docker-compose.yml
# - https://github.com/router-for-me/CLIProxyAPI/blob/v7.1.50/config.example.yaml
# - https://github.com/router-for-me/CLIProxyAPI/blob/v7.1.50/internal/safemode/example_api_keys.go

ENV_FILE="./.env"
if [ ! -f "$ENV_FILE" ]; then
    echo ".env file not found" >&2
    exit 1
fi
CLIENT_API_KEY=$(grep -E '^CLIENT_API_KEY=' "$ENV_FILE" | tail -n 1 | cut -d '=' -f 2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
if [ -z "$CLIENT_API_KEY" ]; then
    echo "CLIENT_API_KEY is required" >&2
    exit 1
fi
escape_yaml() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}
CLIENT_API_KEY_ESC=$(escape_yaml "$CLIENT_API_KEY")
cat > ./config.yaml <<EOF
host: ""
port: 8317
remote-management:
  allow-remote: false
  secret-key: ""
auth-dir: "~/.cli-proxy-api"
api-keys:
  - "$CLIENT_API_KEY_ESC"
debug: false
logging-to-file: true
logs-max-total-size-mb: 0
error-logs-max-files: 10
usage-statistics-enabled: false
redis-usage-queue-retention-seconds: 60
request-retry: 3
max-retry-credentials: 0
max-retry-interval: 30
ws-auth: true
enable-gemini-cli-endpoint: false
EOF
