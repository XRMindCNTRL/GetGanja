#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <subscription-id> <resource-group>"
  exit 1
fi

SUBSCRIPTION=$1
RESOURCE_GROUP=$2

az account set --subscription "$SUBSCRIPTION"

az ad sp create-for-rbac \
  --name "cannabis-delivery-deployer" \
  --role Contributor \
  --scopes "/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}" \
  --sdk-auth

echo "Copy the returned JSON and add it to GitHub Actions secrets as AZURE_CREDENTIALS."
