#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"


if grep -Fxq "/opt/homebrew/bin/zsh" /etc/shells; then
    echo "/opt/homebrew/bin/zsh already exists in /etc/shells"
else
    echo "/opt/homebrew/bin/zsh not found in /etc/shells, adding it now..."
    echo "/opt/homebrew/bin/zsh" | sudo tee -a /etc/shells >/dev/null
fi


if [ "$SHELL" = "/opt/homebrew/bin/zsh" ]; then
    echo "Default shell is already set to /opt/homebrew/bin/zsh"
else
    echo "Changing default shell to /opt/homebrew/bin/zsh..."
    chsh -s '/opt/homebrew/bin/zsh'
fi


if sh --version | grep -q zsh; then
    echo '/private/var/select/sh is already linked to zsh'
else
    sudo ln -fsv /bin/zsh /private/var/select/sh
fi

echo "\n<<< ZSH Setup Complete >>>\n"

