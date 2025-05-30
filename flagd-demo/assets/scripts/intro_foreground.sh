#!/bin/bash

# set -euo pipefail

DEBUG_VERSION=13
GITEA_VERSION=1.23.8
TEA_CLI_VERSION=0.9.2
FLAGD_VERSION=0.11.5
USER_NAME="openfeature"
USER_PASSWORD="openfeature"
USER_EMAIL=me@faas.com
TOKEN_NAME="tea_token"
REPO_NAME="flags"

echo "Starting Gitea docker container..."
# Killercoda doesn't use the `docker compose` syntax as of now
if type -P docker-compose &>/dev/null; then
  docker-compose -f ~/docker-compose.yaml up -d
else
  docker compose -f ~/docker-compose.yaml up -d
fi

if [[ -n "${BASE_URL:-}" ]]; then
  # Use passed-in BASE_URL environment variable (e.g. host.docker.internal:3000 on Mac/Windows)
  # Makes it easier to run locally with mock killercoda env dockerfile
  BASE_URL="${BASE_URL}"
else
  BASE_URL="http://${TRAFFIC_HOST1_3000:-0.0.0.0:3000}"
  # Fallback default
  # BASE_URL="http://localhost:3000"
  # BASE_URL="http://${TRAFFIC_HOST1_3000}"
fi

echo "Waiting for Gitea API to be ready..."
until curl -sf "$BASE_URL/api/v1/version" > /dev/null; do
  echo "Gitea API not ready yet..."
  sleep 5
done

echo "Using base URL: $BASE_URL"

# First gitea is the container and the next is the call
user_list=$(docker exec -u git gitea gitea admin user list 2>/dev/null)

# Check if openfeature user exists
if ! echo "$user_list" | grep -qw "$USER_NAME"; then
  # Using the gitea service started with docker
  echo "Creating openfeature admin gitea user..."
  docker exec -u git gitea gitea admin user create \
    --username=$USER_NAME \
    --password=$USER_PASSWORD \
    --email=$USER_EMAIL \
    --must-change-password=false
else
  echo "User already exists. Continuing..."
fi

echo "Checking for existing token ..."
user_tokens=$(docker exec gitea curl -s -H "Authorization: Basic $(echo -n "$USER_NAME:$USER_PASSWORD" | base64)" \
  "$BASE_URL/api/v1/users/$USER_NAME/tokens")

# Output the token check into JSON array & looping to get id of tea_token
token_id=$(echo "$user_tokens" | jq -r --arg TOKEN_NAME "$TOKEN_NAME" '.[] | select(.name == $TOKEN_NAME) | .id') 

# When the token ID exists delete to regenerate to adhere to gitea usage
# non-empty && not null
if [ -n "$token_id" ] && [ "$token_id" != "null" ]; then
  echo "Deleting existing token..."
  docker exec gitea curl -s -X DELETE \
    "$BASE_URL/api/v1/users/$USER_NAME/tokens/$token_id" \
    -H "Authorization: Basic $(echo -n "$USER_NAME:$USER_PASSWORD" | base64)"
  echo "Re-generating gitea access token for tea CLI..."
else
  echo "No existing tea_token."
  echo "Generating gitea access token for tea CLI..."
fi

# Generate access token for tea CLI set up
docker exec -u git gitea gitea admin user generate-access-token \
  --username=$USER_NAME \
  --token-name=$TOKEN_NAME \
  --scopes=all \
  --raw > /tmp/output.log 

ACCESS_TOKEN=$(tail -n 1 /tmp/output.log)


if ! type -P tea &> /dev/null; then 
  echo "Installing tea CLI..."
  # Download and install 'gitea' CLI: 'tea'
  wget -O tea https://dl.gitea.com/tea/${TEA_CLI_VERSION}/tea-${TEA_CLI_VERSION}-linux-amd64
  chmod +x tea
  mv tea /usr/local/bin
else 
  # Remove existing 'local' login if it exists
  tea login rm local 2>/dev/null || true
fi

# Authenticate the 'tea' CLI
echo "Authenticate tea CLI..."
tea login add \
  --name=local \
  --url="$BASE_URL" \
  --token="$ACCESS_TOKEN" # > /dev/null 2>&1

# Check if repo 'flags' exists
echo "Checking if repo 'flags' exists..."
# count the lines of the json response know how many repos
repo_exists=$(tea repo list --login local --output simple | grep -w "$REPO_NAME" | wc -l)

if [[ "$repo_exists" -gt 0 ]]; then
  echo "Repo 'flags' already exists. Skipping creation."
else
  echo "Creating repo 'flags'..."
  tea repo create --login=local --name=$REPO_NAME --branch=main --init=true >/dev/null
fi

if ! type -P flagd &> /dev/null; then
  echo "Installing flagd..."
  wget -O flagd.tar.gz https://github.com/open-feature/flagd/releases/download/flagd%2Fv${FLAGD_VERSION}/flagd_${FLAGD_VERSION}_Linux_x86_64.tar.gz
  tar -xf flagd.tar.gz
  mv flagd_linux_x86_64 flagd
  chmod +x flagd
  mv flagd /usr/local/bin
fi 

# Add 'git' user
adduser \
  --system \
  --shell /bin/bash \
  --gecos 'Git Version Control' \
  --group \
  --disabled-password \
  --home /home/git \
  git

# Configure git for 'ubuntu' and 'git' users
git config --system user.email $USER_EMAIL
git config --system user.name $USER_NAME

git clone http://$USER_NAME:$USER_PASSWORD@${BASE_URL#http://}/$USER_NAME/$REPO_NAME ~/$REPO_NAME

wget -P ~/$REPO_NAME https://raw.githubusercontent.com/open-feature/flagd/main/samples/example_flags.flagd.json
cd ~/$REPO_NAME

git config credential.helper cache
git add -A
git commit -m "seed flags from flagd json"
git push origin main

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
