# DEBUG_VERSION=2

set -e
# -----------------------------------
# APT Update
# ----------------------------------- 
apt update

# -----------------------------------
# Installing bat
# -----------------------------------
apt install -y bat < /dev/null
# Symlink: Make 'batcat' available as 'bat' command
ln -s /usr/bin/batcat /usr/sbin/bat
# Alias 'cat' to 'bat' so running: 'cat ~/myfile.txt' uses 'bat' instead
# Bonus points for using 'bat' to do this :)
bat <<EOF >> ~/.bashrc
alias cat=bat
EOF
# Refresh source
source ~/.bashrc

# -----------------------------------
# Installing Node
# -----------------------------------
# curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
# apt install -y nodejs < /dev/null
curl -fsSL https://deb.nodesource.com/setup_23.x | sudo -E bash - &&\
sudo apt-get install -y nodejs


# -----------------------------------
# Setup the project
# -----------------------------------
git clone https://github.com/open-feature/five-minutes-to-feature-flags
mkdir app
mv five-minutes-to-feature-flags/* app/
cd app

# -----------------------------------
#  npm install
# -----------------------------------
npm ci

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#
