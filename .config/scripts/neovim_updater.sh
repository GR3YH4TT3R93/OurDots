#!/usr/bin/env zsh
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
ENDCOLOR=$'\e[0m'

usage() {
  echo "Usage: $0 [-s | -n]"
  echo "Options:"
  echo "  -s    Install stable version of Neovim"
  echo "  -n    Install nightly version of Neovim (default)"
  exit 0
}

error_exit() {
  echo -e "${RED}Error: ${ENDCOLOR}$1" >&2
  exit 1
}

# Default to nightly version
VERSION="nightly"

# Parse command line options
while getopts ":sn" opt; do
  case ${opt} in
    s )
      VERSION="stable"
      ;;
    n )
      VERSION="nightly"
      ;;
    \? )
      echo -e "${RED}Invalid option: $OPTARG${ENDCOLOR}" >&2
      usage
      ;;
  esac
done

install_neovim() {
  echo -e "${GREEN}Installing latest Neovim ${VERSION} version${ENDCOLOR}."
  sleep 2

  # Set download URL based on version
  if [[ "$VERSION" == "stable" ]]; then
    echo -e "${YELLOW}Downloading ${VERSION} version${ENDCOLOR}."
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
  else
    echo -e "${YELLOW}Downloading ${VERSION} version${ENDCOLOR}."
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
  fi

  sudo rm -rf /opt/nvim*
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
  echo -e "${GREEN}Neovim ${VERSION} version installed successfully${ENDCOLOR}."
}

install_neovim || error_exit "${YELLOW}Failed to install Neovim${ENDCOLOR}."
