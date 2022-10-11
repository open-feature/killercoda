DEBUG_VERSION=8

###############################################
# Step [1/3]: Install docker compose plugin
###############################################
sudo apt update  < "/dev/null"
sudo apt install -y ca-certificates curl gnupg lsb-release  < "/dev/null"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update  < "/dev/null"
sudo apt install -y docker-compose-plugin  < "/dev/null"

###############################################
# Step [2/3]: Clone Repo and check out PR
###############################################
git clone https://github.com/open-feature/playground
cd playground
git pull origin pull/59/head
sed -i 's#image: jaegertracing/all-in-one:1.38#image: docker.io/jaegertracing/all-in-one:1.38#g' ./docker-compose.yaml
sed -i 's#image: thomaspoignant/go-feature-flag-relay-proxy:v0.3.0#image: docker.io/thomaspoignant/go-feature-flag-relay-proxy:v0.3.0#g' ./docker-compose.yaml

###############################################
# Step [3/3]: Start things up!
###############################################
docker compose up --detach

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#