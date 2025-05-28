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
until docker exec gitea curl -s http://localhost:3000/api/v1/version | grep -q "version"; do
  echo "Gitea not ready yet..."
  sleep 2
done

# First gitea is the container and the next is the call
user_list=$(docker exec -u git gitea gitea admin user list 2>/dev/null)

# Check if openfeature user exists
if ! echo "$user_list" | grep -qw "openfeature"; then
  # Using the gitea service started with docker
  echo "Creating openfeature admin gitea user..."
  docker exec -u git gitea gitea admin user create \
    --username=openfeature \
    --password=openfeature \
    --email=me@faas.com \
    --must-change-password=false
    # -c /etc/gitea
else
  echo "User already exists. Continuing..."
fi

echo "Checking for existing token ..."
user_tokens=$(docker exec gitea curl -s -H "Authorization: Basic $(echo -n "openfeature:openfeature" | base64)" \
  http://localhost:3000/api/v1/users/openfeature/tokens)

# Output the token check into JSON array & looping to get id of tea_token
token_id=$(echo "$user_tokens" | jq -r '.[] | select(.name == "tea_token") | .id') > /dev/null

# When the token ID exists delete to regenerate to adhere to gitea usage
# non-empty && not null
if [ -n "$token_id" ] && [ "$token_id" != "null" ]; then
  echo "Deleting existing token..."
  docker exec gitea curl -s -X DELETE \
    http://localhost:3000/api/v1/users/openfeature/tokens/$token_id \
    -H "Authorization: Basic $(echo -n "openfeature:openfeature" | base64)"
  echo "Re-generating gitea access token for tea CLI..."
else
  echo "No existing tea_token."
  echo "Generating gitea access token for tea CLI..."
fi

# Generate access token for tea CLI set up
docker exec -u git gitea gitea admin user generate-access-token \
  --username=openfeature \
  --token-name=tea_token \
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
