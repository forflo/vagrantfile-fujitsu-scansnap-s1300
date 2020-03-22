#!/usr/bin/env bash

HOMEBREW_INSTALLED="$(which brew)"

[ "$HOMEBREW_INSTALLED" == "" ] && {
    echo "Homebrew in not installed"
    echo "This script relies on the 'brew' command"
    exit 1
}

OSX_VERSION="$(sw_vers -productVersion)"

[ "$OSX_VERSION" != "10.15.2" ] && {
    echo "This script was developed precisely for mac os x 10.15.2"
    echo "edit this script and remove this output in order to install nonetheless"
    exit 1
}

# first we try to upgrade the software.
# If it hasn't been installed yet, we install it.
brew cask upgrade vagrant \
    || brew cask install vagrant
brew cask upgrade virtualbox \
    || brew cask install virtualbox
brew cask upgrade virtualbox-extension-pack \
    || brew cask install virtualbox-extension-pack

vagrant up
vagrant halt && vagrant up
