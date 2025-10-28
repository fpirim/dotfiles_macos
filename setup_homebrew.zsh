#!/usr/bin/env zsh

echo "\n<<< Starting Homebrew Setup >>>\n"

if exists brew; then
    echo "Homebrew is already installed"
else
    echo "Homebrew not found, installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# TODO: Currently --no-quarantine is not supported in Homebrew Bundle
# so, export HOMEBREW_CASK_OPTS="--no-quarantine" is using workaround.

brew bundle --verbose

# echo "Accept Xcode license agreement..."
# sudo xcodebuild -license accept
# sudo xcodebuild -runFirstLaunch

