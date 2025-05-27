#!/bin/bash

set -euo pipefail

DEBUG_VERSION=13
GITEA_VERSION=1.23.8
TEA_CLI_VERSION=0.9.2
FLAGD_VERSION=0.11.5

# if [[ -n "${TRAFFIC_HOST1_3000:-}" ]]; then
#   GITEA_URL="https://${TRAFFIC_HOST1_3000}"
# else
#   GITEA_URL="http://localhost:3000"
# fi

echo "Starting Gitea & flagd docker containers..."
docker compose -f ~/docker-compose.yaml up -d

# Confirm gitea is functional before making calls
until docker exec gitea curl -s http://localhost:3000/api/v1/version | tee /tmp/version_output.txt | grep -q "version"; do
  echo "Gitea not ready yet..."
  sleep 2
done

# Create a user called 'openfeature' with password 'openfeature'
# Using the gitea service started with docker
echo "Creating openfeature admin gitea user..."
docker exec -u git gitea gitea admin user create \
  --username=openfeature \
  --password=openfeature \
  --email=me@faas.com \
  --must-change-password=false || echo "User already exits."
  # -c /etc/gitea

# Setup access token for tea CLI set up
echo "Generating gitea access token for tea CLI..."
docker exec -u git gitea gitea admin user generate-access-token \
  --username=openfeature \
  --scopes=all \
  --raw > /tmp/output.log 
  # -c /etc/gitea \

ACCESS_TOKEN=$(tail -n 1 /tmp/output.log)

if ! type -P tea &> /dev/null; then 
  echo "Installing tea CLI..."
  curl -sL https://dl.gitea.com/tea/${TEA_CLI_VERSION}/tea-${TEA_CLI_VERSION}-linux-amd64 -o /usr/local/bin/tea
  chmod +x /usr/local/bin/tea
fi

# Authenticate the 'tea' CLI
tea login add \
  --name local \
  --url=http://localhost:3000 \
  --token=$ACCESS_TOKEN > /dev/null 2>&1

# Create an empty repo called 'flags'
# Clone the template repo
tea repo create \
  --name=flags \
  --branch=main \
  --init=true >/dev/null

git clone http://openfeature:openfeature@localhost:3000/openfeature/flags

wget -O ~/flags/example_flags.flagd.json https://raw.githubusercontent.com/open-feature/flagd/refs/tags/flagd/v${FLAGD_VERSION}/samples/example_flags.flagd.json

git config credential.helper cache

cd ~/flags
git add -A
git commit -m "seed flags from flagd json"
git push origin main

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
