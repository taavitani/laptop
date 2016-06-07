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

# Disable character viewer so holding down a key simply repeats
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set key repeat to a pretty fast rate
defaults write NSGlobalDomain KeyRepeat -int 6

# Reduce the delay before a held key starts to repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Use dark style for menu bar and Dock
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Do not create .DS_Store on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Unhide library
chflags nohidden ~/Library

# Create some standard folders. And hide those in Finder
mkdir -p ~/bin ~/src
chflags hidden ~/bin ~/src

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
brew "zsh"
_EOT

ZSH_PATH=$(brew --prefix)/bin/zsh
echo $ZSH_PATH | sudo tee -a /etc/shells
chsh -s $ZSH_PATH
