DEBUG_VERSION=11
PLAYGROUND_APP_VERSION=v0.9.0
JAEGER_VERSION=1.42
FLAGD_VERSION=v0.4.5
GO_FEATURE_FLAG_VERSION=v1.4.0

#################################################################
# Step [1/4]: Install docker compose plugin
#################################################################
sudo apt update  < "/dev/null"
sudo apt install -y ca-certificates curl gnupg lsb-release  < "/dev/null"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update  < "/dev/null"
sudo apt install -y docker-compose-plugin  < "/dev/null"

###################################################################
# Step [2/4]: Clone Repo and checkout correct tag
###################################################################
git clone https://github.com/open-feature/playground
cd playground
git fetch --all --tags
git checkout tags/${PLAYGROUND_APP_VERSION}

###################################################################
# Step [3/4]: Setup
###################################################################
trimmedURL=$(sed -e 's/PORT/8013/g' -e 's#^https://*##' /etc/killercoda/host)
cat <<EOF > .env
###############################################
##
## Feature Flag Environment Variables
##
###############################################

# Options: recursive, memo, loop, binet, default
FIB_ALGO=default

###############################################
##
## Feature Flag SDK keys (server)
##
###############################################

# Split IO server-side API key
SPLIT_KEY=

# CloudBees App Key
CLOUDBEES_APP_KEY=

# LaunchDarkly SDK Key
LD_KEY=

# Flagsmith Environment key (v2)
FLAGSMITH_ENV_KEY=

# Harness SDK Key
HARNESS_KEY=

###############################################
##
## Feature Flag SDK keys (web)
##
###############################################

# Split IO server-side API key
SPLIT_KEY_WEB=

# CloudBees App Key
CLOUDBEES_APP_KEY_WEB=

# LaunchDarkly SDK Key
LD_KEY_WEB=

# Flagsmith Environment key (v2)
FLAGSMITH_ENV_KEY_WEB=

# Harness SDK Key
HARNESS_KEY_WEB=

# The domain name or IP address of flagd
# @default localhost
FLAGD_HOST_WEB=${trimmedURL}
FLAGD_PORT_WEB=443 
FLAGD_TLS_WEB=true
EOF

###################################################################
# Step [4/4]: Starting the application
###################################################################
docker compose up --detach

# Waiting for application to start
timeout 60 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' {{TRAFFIC_HOST1_30000}})" != "200" ]]; do sleep 5; done' || false

# Application is running and available: {{TRAFFIC_HOST1_30000}}
# ---------------------------------------------#
#       🎉 Preparation Complete 🎉            #
#           Please proceed now...              #
# ---------------------------------------------#