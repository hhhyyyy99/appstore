#!/bin/bash

# Generated from official installation evidence:
# - https://github.com/Wei-Shaw/sub2api/blob/main/deploy/.env.example
# - https://github.com/Wei-Shaw/sub2api/blob/main/backend/internal/config/config.go
# - https://github.com/Wei-Shaw/sub2api/blob/main/backend/internal/repository/aes_encryptor.go

set -e

ENV_FILE="./.env"
if [ ! -f "$ENV_FILE" ]; then
    exit 0
fi

generate_hex_32_bytes() {
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n'
}

get_env_value() {
    grep -E "^$1=" "$ENV_FILE" | tail -n 1 | cut -d '=' -f 2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//"
}

set_env_value() {
    key="$1"
    value="$2"
    if grep -qE "^${key}=" "$ENV_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        printf '\n%s=%s\n' "$key" "$value" >> "$ENV_FILE"
    fi
}

jwt_secret="$(get_env_value JWT_SECRET)"
if [ "${#jwt_secret}" -lt 32 ]; then
    set_env_value JWT_SECRET "$(generate_hex_32_bytes)"
fi

totp_key="$(get_env_value TOTP_ENCRYPTION_KEY)"
if ! printf '%s' "$totp_key" | grep -Eq '^[0-9a-fA-F]{64}$'; then
    set_env_value TOTP_ENCRYPTION_KEY "$(generate_hex_32_bytes)"
fi
