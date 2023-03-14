#!/bin/bash

DEBUG_VERSION=2
GITEA_VERSION=1.19
TEA_CLI_VERSION=0.9.2
FLAGD_VERSION=0.4.0

# Download and install flagd
wget -O flagd.tar.gz https://github.com/open-feature/flagd/releases/download/v${FLAGD_VERSION}/flagd_${FLAGD_VERSION}_Linux_x86_64.tar.gz
tar -xf flagd.tar.gz
chmod +x flagd
mv flagd /usr/local/bin

# Download and install 'gitea' CLI: 'tea'
wget -O tea https://dl.gitea.com/tea/${TEA_CLI_VERSION}/tea-${TEA_CLI_VERSION}-linux-amd64
chmod +x tea
mv tea /usr/local/bin

#################
# Install postgresql for Gitea
###################
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql < /dev/null

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

# Download 'gitea'
wget -O gitea https://dl.gitea.com/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64
chmod +x gitea
mv gitea /usr/local/bin
chown git:git /usr/local/bin/gitea

# Set up directory structure for 'gitea'
mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown git:git /etc/gitea
chmod 770 /etc/gitea

# Create systemd service for 'gitea'
# Ref: https://github.com/go-gitea/gitea/blob/main/contrib/systemd/gitea.service
mv ~/gitea.service /etc/systemd/system/gitea.service
# cat <<EOF > /etc/systemd/system/gitea.service
# [Unit]
# Description=Gitea (Git with a cup of tea)
# After=syslog.target
# After=network.target

# Wants=postgresql.service
# After=postgresql.service

# [Service]
# RestartSec=2s
# Type=simple
# User=git
# Group=git
# WorkingDirectory=/var/lib/gitea/
# ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
# Restart=always
# Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

# [Install]
# WantedBy=multi-user.target
# EOF

mv ~/gitea.app.ini /etc/gitea/app.ini
# cat <<EOF > /etc/gitea/app.ini
# APP_NAME = "Gitea: Git with a cup of tea"
# RUN_USER = "git"
# [server]
# PROTOCOL = "http"
# DOMAIN = "http://0.0.0.0:3000"
# ROOT_URL = "http://0.0.0.0:3000"
# HTTP_ADDR = "0.0.0.0"
# HTTP_PORT = "3000"
# [database]
# DB_TYPE = "postgres"
# HOST = "0.0.0.0:5432"
# NAME = "giteadb"
# USER = "gitea"
# PASSWD = "gitea"
# [repository]
# ENABLE_PUSH_CREATE_USER = true
# DEFAULT_PUSH_CREATE_PRIVATE = false
# [security]
# INSTALL_LOCK = true
# EOF
chown -R git:git /etc/gitea

# Set up gitea DB
sudo -u postgres -H -- psql --command "CREATE ROLE gitea WITH LOGIN PASSWORD 'gitea';" > /dev/null 2>&1
sudo -u postgres -H -- psql --command "CREATE DATABASE giteadb WITH OWNER gitea TEMPLATE template0 ENCODING UTF8 LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';" > /dev/null 2>&1

# Start gitea
systemctl start gitea
# Migrate the DB to create all required tables and config
sudo -u git gitea migrate -c=/etc/gitea/app.ini 

# Create a user called 'openfeature'
# With password 'openfeature'
sudo -u git gitea admin user create \
   --username=openfeature \
   --password=openfeature \
   --email=me@faas.com \
   --must-change-password=false \
   -c=/etc/gitea/app.ini

sudo -u git gitea admin user generate-access-token \
  --username=openfeature \
  --scopes=repo \
  -c=/etc/gitea/app.ini \
  --raw > /tmp/output.log

ACCESS_TOKEN=$(tail -n 1 /tmp/output.log)

# Authenticate the 'tea' CLI
tea login add \
   --name=openfeature \
   --user=openfeature \
   --password=openfeature \
   --url=http://0.0.0.0:3000 \
   --token=$ACCESS_TOKEN > /dev/null 2>&1

# Create an empty repo called 'flags'
# Clone the template repo
tea repo create --name=flags --init=false
git clone https://0.0.0.0:3000/flags
wget -O ~/flags/example_flags.flagd.json https://github.com/open-feature/flagd/blob/main/config/samples/example_flags.flagd.json

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#