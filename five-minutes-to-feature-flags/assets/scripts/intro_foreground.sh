# -----------------------------------
# Step 1/6: APT Update
# ----------------------------------- 
apt update

# -----------------------------------
# Step 2/6: Installing bat
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
# Step 3/6: Installing Node
# -----------------------------------
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - &&\
apt install -y nodejs < /dev/null

# -----------------------------------
# Step 4/6: Installing jq
# -----------------------------------
apt install -y jq < /dev/null

# -----------------------------------
# Step 5/6: Installing NPM packages
# -----------------------------------
npm install express --save
npm install express-promise-router --save
npm install cowsay --save
npm install @openfeature/js-sdk --save
npm install --force @moredip/openfeature-minimalist-provider

# -----------------------------------
# Step 6/6: Initialising NPM package
# -----------------------------------
cd app
npm init -y
mv package.json package.BAK.json
cat package.BAK.json | jq '. += { "type": "module" }' > package.json
rm package.BAK.json

# ---------------------------------------------#
#       🎉 Installation Complete 🎉           #
#           Please proceed now...              #
# ---------------------------------------------#