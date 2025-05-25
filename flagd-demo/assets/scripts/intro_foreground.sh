#!/bin/bash

DEBUG_VERSION=13
GITEA_VERSION=1.23.8
TEA_CLI_VERSION=0.9.2
FLAGD_VERSION=0.11.5

# Download and install flagd
wget -O flagd.tar.gz https://github.com/open-feature/flagd/releases/download/flagd%2Fv${FLAGD_VERSION}/flagd_${FLAGD_VERSION}_Linux_x86_64.tar.gz
tar -xf flagd.tar.gz
mv flagd_linux_x86_64 flagd
chmod +x flagd
mv flagd /usr/local/bin

rm flagd.tar.gz

docker compose -f ~/docker-compose.yaml up -d

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

# Wait for Gitea to be available
# Timeout after 2mins
timeout 120 bash -c 'while [[ "$(curl --insecure -s -o /dev/null -w "%{http_code}" http://localhost:3000)" != "200" ]]; do sleep 5; done'
# timeout 120 bash -c 'until curl -s -o /dev/null -w "%{http_code}" http://0.0.0.0:3000)

# Create a user called 'openfeature'
# With password 'openfeature'
# Using the gitea service started with docker
docker exec -u git gitea gitea admin user create \
   --username=openfeature \
   --password=openfeature \
   --email=me@faas.com \
   --must-change-password=false \
   -c data/gitea/conf/app.ini

# sudo -u git gitea admin user generate-access-token \
#   --username=openfeature \
#   --scopes=repo \
#   -c=/etc/gitea/app.ini \
#   --raw > /tmp/output.log

# ACCESS_TOKEN=$(tail -n 1 /tmp/output.log)

ACCESS_TOKEN=$(docker exec -u git gitea gitea admin user generate-access-token \
  --username=openfeature \
  --scopes=repo \
-c data/gitea/conf/app.ini \
  --raw > /tmp/output.log
)

# Download and install 'gitea' CLI: 'tea'
wget -O tea https://dl.gitea.com/tea/${TEA_CLI_VERSION}/tea-${TEA_CLI_VERSION}-linux-amd64
chmod +x tea
mv tea /usr/local/bin

# Authenticate the 'tea' CLI
tea login add \
   --name=openfeature \
   --user=openfeature \
   --password=openfeature \
   --url=http://0.0.0.0:3000 \
   --token=$ACCESS_TOKEN > /dev/null 2>&1

# Create an empty repo called 'flags'
# Clone the template repo
tea repo create --name=flags --branch=main --init=true > /dev/null 2>&1
git clone http://openfeature:openfeature@0.0.0.0:3000/openfeature/flags
wget -O ~/flags/example_flags.flagd.json https://raw.githubusercontent.com/open-feature/flagd/refs/tags/flagd/v${FLAGD_VERSION}/samples/example_flags.flagd.json
cd ~/flags
git config credential.helper cache
git add -A
git commit -m "add flags"
git push

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
