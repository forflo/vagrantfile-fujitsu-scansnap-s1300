#!/usr/bin/env bash

HOMEBREW_INSTALLED="$(which brew)"

[ "$HOMEBREW_INSTALLED" == "" ] && {
    echo "Homebrew in not installed"
    echo "This script relies on the 'brew' command"
    exit 1
}

OSX_VERSION="$(sw_vers -productVersion)"

case "$OSX_VERSION" in
    "10.15.2" | "12.0.1")
    ;;
    *)
    echo "This script was developed precisely for mac os x 10.15.2"
    echo "edit this script and remove this output in order to install nonetheless"
    exit 1
    ;;
esac

# first we try to upgrade the software.
# If it hasn't been installed yet, we install it.
brew upgrade --cask vagrant \
    || brew install --cask vagrant
brew upgrade --cask virtualbox \
    || brew install --cask virtualbox
brew upgrade --cask virtualbox-extension-pack \
    || brew install --cask virtualbox-extension-pack

vagrant up
vagrant halt && vagrant up
