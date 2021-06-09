#!/bin/bash

set -o errexit
set -o xtrace

# Hide the Dock
defaults write com.apple.dock autohide -bool true

# Show only running apps in the Dock
defaults write com.apple.dock static-only -bool true

# Indicators useless if only showin running apps
defaults write com.apple.dock show-process-indicators -bool false

# Tab moves focus between all window/dialog elements
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show full path in Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Make Finder quittable
defaults write com.apple.finder QuitMenuItem -bool true

# Starting a search in Finder defaults to the current directory
defaults write com.apple.finder FXDefaultSearchScope -string SCcf

# Disable file extension change warning dialog.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Vanilla function keys
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Make key repeat way fast
defaults write -g InitialKeyRepeat -int 20
defaults write -g KeyRepeat -int 4

# Disable MacOS default key hold character selection popup
defaults write -g ApplePressAndHoldEnabled -bool false

# Use dark style for menu bar and Dock
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Do not create .DS_Store on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Unhide library
chflags nohidden ~/Library

# Create some standard folders
mkdir -p ~/bin ~/src

# Get our sudo ticket ready
sudo -v -p "Password for sudo: "

# Hostname
sudo networksetup -setcomputername Pondermatic
sudo scutil --set HostName pondermatic

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew update
brew bundle --file=- <<_EOT
tap "thoughtbot/formulae"

brew "zsh"
brew "git"
brew "rcm"
_EOT

ZSH_PATH=$(brew --prefix)/bin/zsh
echo $ZSH_PATH | sudo tee -a /etc/shells
chsh -s $ZSH_PATH

DOTFILES_REPO=https://github.com/taavitani/dotfiles
DOTFILES_PATH=~/src/${DOTFILES_REPO##https://}

git clone $DOTFILES_REPO $DOTFILES_PATH

env RCRC=$DOTFILES_PATH/rcrc rcup -f -v

# Make SF Mono available for Alacritty
cp /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/*.otf ~/Library/Fonts/

# Brewfile was updated from dotfiles
brew bundle

# SSH remote URL
git -C $DOTFILES_PATH remote set-url origin git@github.com:taavitani/dotfiles.git

# Clone laptop repo
LAPTOP_REPO=https://github.com/taavitani/laptop
LAPTOP_PATH=~/src/${LAPTOP_REPO##https://}

git clone $LAPTOP_REPO $LAPTOP_PATH

cat <<_EOT
To set up OpenSSH agent and tmux launchd services after software and dotfiles are installed.

Run w/ SIP disabled to stop the MacOS packaged agent from running:
$ launchctl unload -w /System/Library/LaunchAgents/com.openssh.ssh-agent.plist

And start OpenSSH agent and tmux services:
$ launchctl load -wF ~/Library/LaunchAgents/org.homebrew.ssh-agent.plist
$ launchctl load -wF ~/Library/LaunchAgents/org.homebrew.ssh-agent-env.plist
$ launchctl load -wF ~/Library/LaunchAgents/org.homebrew.tmux.plist

To check status/debug:
$ launchctl list | fgrep homebrew
$ syslog -w
$ ssh-add -l # in tmux
_EOT
