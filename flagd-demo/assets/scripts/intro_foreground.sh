#!/bin/bash

DEBUG_VERSION=13
GITEA_VERSION=1.23.8
TEA_CLI_VERSION=0.9.2
FLAGD_VERSION=0.11.5

if [[ -n "${TRAFFIC_HOST1_3000:-}" ]]; then
  GITEA_URL="http://${TRAFFIC_HOST1_3000}"
elif [[ -n "${GITEA_URL:-}" ]]; then
  # Use passed-in GITEA_URL environment variable (e.g. host.docker.internal on Mac/Windows)
  GITEA_URL="${GITEA_URL}"
else
  # Fallback default
  GITEA_URL="http://gitea:3000"
fi

echo "Using Gitea URL: $GITEA_URL"

echo "Starting Gitea & flagd docker containers..."
docker compose -f ~/docker-compose.yaml up -d

# Confirm gitea is functional before making calls
until docker exec gitea curl -s "$GITEA_URL/api/v1/version" | grep -q "version"; do
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
else
  echo "User already exists. Continuing..."
fi

echo "Checking for existing token ..."
user_tokens=$(docker exec gitea curl -s -H "Authorization: Basic $(echo -n "openfeature:openfeature" | base64)" \
  "$GITEA_URL/api/v1/users/openfeature/tokens")

# Output the token check into JSON array & looping to get id of tea_token
token_id=$(echo "$user_tokens" | jq -r '.[] | select(.name == "tea_token") | .id') > /dev/null

# When the token ID exists delete to regenerate to adhere to gitea usage
# non-empty && not null
if [ -n "$token_id" ] && [ "$token_id" != "null" ]; then
  echo "Deleting existing token..."
  docker exec gitea curl -s -X DELETE \
    "$GITEA_URL/api/v1/users/openfeature/tokens/$token_id" \
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

ACCESS_TOKEN=$(tail -n 1 /tmp/output.log)

if ! type -P tea &> /dev/null; then 
  echo "Installing tea CLI..."
  # Download and install 'gitea' CLI: 'tea'
  wget -O tea https://dl.gitea.com/tea/${TEA_CLI_VERSION}/tea-${TEA_CLI_VERSION}-linux-amd64
  chmod +x tea
  mv tea /usr/local/bin
fi

# Authenticate the 'tea' CLI
echo "Authenticate tea CLI..."
tea login add \
  --name=local \
  --url="$GITEA_URL" \
  --token="$ACCESS_TOKEN" # > /dev/null 2>&1

# Check if repo 'flags' exists
echo "Checking if repo 'flags' exists..."
repo_exists=$(tea repo list --json | jq -e '.[] | select(.name=="flags")' >/dev/null 2>&1 && echo "yes" || echo "no")

if [[ "$repo_exists" == "yes" ]]; then
  echo "Repo 'flags' already exists. Skipping creation."
else
  echo "Creating repo 'flags'..."
  tea repo create --login=local --name=flags --branch=main --init=true >/dev/null
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
git config --system user.email "me@faas.com"
git config --system user.name "OpenFeature"

git clone http://openfeature:openfeature@${GITEA_URL#http://}/openfeature/flags

cd flags
wget -O example_flags.flagd.json https://raw.githubusercontent.com/open-feature/flagd/main/samples/example_flags.flagd.json

git config credential.helper cache
git add -A
git commit -m "seed flags from flagd json"
git push origin main

echo  🎉 Installation Complete 🎉 Please proceed now...   

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
