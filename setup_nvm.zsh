#!/usr/bin/env zsh

echo "\n<<< Starting NVM Setup >>>\n"

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Check if NVM is already installed
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "NVM is already installed at $NVM_DIR"
else
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Load NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if Node v22 is already installed
if nvm list | grep -q "v22"; then
    echo "Node v22 is already installed"
else
    echo "Installing Node v22..."
    nvm install 22
fi

# Set Node v22 as default
echo "Setting Node v22 as default..."
nvm alias default 22
nvm use 22

# Verify installation
echo "\nNode version: $(node --version)"
echo "NPM version: $(npm --version)"

echo "\n<<< NVM Setup Complete >>>\n"
