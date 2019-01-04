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

# Enable press and hold key repeat
defaults delete -g ApplePressAndHoldEnabled

# Make key repeat way fast
defaults write -g InitialKeyRepeat -int 20
defaults write -g InitialKeyRepeat -int 4

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

# Turn on SSH
sudo systemsetup -setremotelogin on

# Hostname
sudo networksetup -setcomputername Pondermatic
sudo scutil --set HostName pondermatic

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew bundle --file=- <<_EOT
tap "thoughtbot/formulae"

brew "zsh"
brew "git"
brew "rcm"
cask "alacritty"
_EOT

ZSH_PATH=$(brew --prefix)/bin/zsh
echo $ZSH_PATH | sudo tee -a /etc/shells
chsh -s $ZSH_PATH

DOTFILES_REPO=https://github.com/taavitani/dotfiles
DOTFILES_PATH=~/src/${DOTFILES_REPO##https://}

git clone $DOTFILES_REPO $DOTFILES_PATH

env RCRC=$DOTFILES_PATH/rcrc rcup -f -v

# Make SF Mono available for Alacritty
cp /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/*.otf ~/Library/Fonts/

# Brewfile was updated from dotfiles
brew bundle
