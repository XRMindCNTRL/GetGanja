#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <resource-group> <location>"
  exit 1
fi

RG=$1
LOCATION=$2

az deployment group create \
  --resource-group "$RG" \
  --template-file infra/appservice/main.bicep \
  --parameters location="$LOCATION" \
    postgresPassword="$(openssl rand -base64 16)" \
    createPostgres=true \
    createRedis=true

echo "Deployment finished. Use the outputs to get frontend/backend URLs." 
