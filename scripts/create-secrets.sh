#!/bin/bash
set -e

source .env.secrets

kubectl create secret generic alertmanager-telegram \
  --from-literal=token=$TELEGRAM_TOKEN \
  --from-literal=chat_id=$TELEGRAM_CHAT_ID \
  -n monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret created successfully"
