# Dotfiles

## Clone the repository

```shell
git clone git@github.com/fpirim/.dotfiles.git ~/.dotfiles
```

## Install dependencies

```shell
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
cd ~/.dotfiles && brew bundle
```

## TODO List

- [ ] Learn how to use defaults to record and restore System Preferences and other macOS configurations.
- [ ] Add .tmux.conf syntax highlighting to bat config (custom language syntaxes under the `config/bat/syntaxes` folder).
    Hint:
    ```bash
    mkdir -p "$(bat --config-dir)/syntaxes"
    cd "$(bat --config-dir)/syntaxes"
    git clone https://github.com/tmux-plugins/tmux-syntax-highlighting.git
    bat cache --build
    ```
