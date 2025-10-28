# Dotfiles

## Clone the repository

```shell
# Dotfiles
git clone git@github.com/fpirim/.dotfiles.git ~/.dotfiles
```

## Create symlinks

```shell
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
```

## Install dependencies

```shell
# Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then pass in the brewfile location...
brew bundle --file ~/.dotfiles/Brewfile

# ...or move to the directory and run it there
cd ~/.dotfiles && brew bundle
```

## TODO List

- [ ] Learn how to use defaults to record and restore System Preferences and other macOS configurations.
- [ ] Organize these growing steps into multiple script files.
- [ ] Automate symlinking and run script files with a bootstrapping tool like Dotbot.
- [ ] Revisit the list <b>.zshrc</b> to customize the shell.
- [ ] Make a checklist of steps to decommission your computer before wiping your hard drive.
- [ ] Create a bootable USB installer for macOS.
- [ ] Integrate other cloud services into your Dotfiles repositories at dotfiles.github.io.

- [ ] Add .tmux.conf syntax highlighting to bat config (custom language syntaxes under the `config/bat/syntaxes` folder).
    Hint:
    ```bash
    mkdir -p "$(bat --config-dir)/syntaxes"
    cd "$(bat --config-dir)/syntaxes"
    git clone https://github.com/tmux-plugins/tmux-syntax-highlighting.git
    bat cache --build
    ```