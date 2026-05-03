#!/usr/bin/env bash
# -----------------------------------------------------------------------
# init-localstack.sh
# Waits for LocalStack to be healthy, then runs optional bootstrap tasks
# (e.g. creating S3 buckets, DynamoDB tables, etc.)
# -----------------------------------------------------------------------
set -euo pipefail

LOCALSTACK_URL="http://localhost:4566"
MAX_RETRIES=30
SLEEP_INTERVAL=2

echo "⏳  Waiting for LocalStack to be ready at ${LOCALSTACK_URL} ..."

for i in $(seq 1 "$MAX_RETRIES"); do
  if curl -sf "${LOCALSTACK_URL}/_localstack/health" | grep -q '"s3": "available"'; then
    echo "✅  LocalStack is ready!"
    break
  fi
  echo "   Attempt ${i}/${MAX_RETRIES} — not ready yet, retrying in ${SLEEP_INTERVAL}s ..."
  sleep "$SLEEP_INTERVAL"
  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "❌  LocalStack did not become healthy in time. Exiting."
    exit 1
  fi
done

# -----------------------------------------------------------------------
# Bootstrap: create sample S3 bucket
# Add your own awslocal / aws --endpoint-url commands below
# -----------------------------------------------------------------------
echo "🪣  Creating sample S3 bucket: terraform-state-local ..."
aws --endpoint-url="${LOCALSTACK_URL}" \
    s3 mb s3://terraform-state-local \
    --region us-east-1 2>/dev/null || echo "   Bucket already exists, skipping."

echo "🎉  LocalStack bootstrap complete."
