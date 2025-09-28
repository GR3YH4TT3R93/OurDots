#!/usr/bin/env bash

###############################################################################
#                                                                             #
#                       Install script for OurDots                            #
#                                                                             #
###############################################################################


###############################################################################
#                                                                             #
#                            Custom variables                                 #
#                                                                             #
###############################################################################
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}
FILE_PATH="$HOME/GitHub"
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
ENDCOLOR=$'\e[0m'
ARCH_PACKAGES=(
  autotiling
  bitwarden
  blueman
  btop
  btrfs-assistant
  chromium
  cliphist
  curl
  discord
  difftastic
  fastfetch
  git
  github-cli
  godot
  grub-btrfs
  gvfs
  inotify-tools
  lazygit
  libretro-mupen64plus-next
  retroarch-assets-ozone
  retroarch-assets-xmb
  linux-firmware-qlogic
  lutris
  neovim
  nwg-look
  openssh
  playerctl
  python-pynvim
  retroarch
  rofi
  ripgrep
  slurp
  snap-pac
  snapper
  steam
  swaybg
  swayidle
  swaylock
  swaync
  swayosd
  task
  thefuck
  thunar
  thunar-archive-plugin
  thunderbird
  timew
  tmux
  wf-recorder
  wl-clipboard
  wayland-protocols
  xdg-desktop-portal-wlr
  yazi
  yq
  yt-dlp
  zoxide
  wget
  wtype
  zsh
  # AUR Packages
  aic94xx-firmware
  ast-firmware
  # bindfs
  bottles
  dotnet-sdk-8.0-bin
  easyeffects
  ff2mpv-native-messaging-host-librewolf-git
  getnf
  lib32-obs-vkcapture
  librewolf-bin
  librewolf-extension-tridactyl-bin
  librewolf-sync
  localsend-bin
  lsfg-vk
  obs-vkcapture
  mpv-thumbfast-git
  pixieditor-bin
  proton-ge-custom-bin
  rofi-rbw-git
  snap-pac-grub
  swaddle
  # wlroots-git
  sway
  swaynagmode
  swaync-widgets-git
  swaysettings-git
  sway-screenshot-git
  swayfx
  typioca
  upd72020x-fw
  waypaper
  wd719x-firmware
  wezterm-nightly-bin
  wlrobs
  xdg-desktop-portal-termfilechooser-hunkyburrito-git
)
DEBIAN_PACKAGES=(
  git
  curl
  wget
  zsh
  openssh-client
  openssh-server
  gnupg
  lsb-release
  software-properties-common
  ca-certificates
  apt-transport-https
  unzip
  fonts-firacode
)
FEDORA_PACKAGES=(
  git
  curl
  wget
  zsh
  openssh-clients
  openssh-server
  gnupg2
  redhat-lsb-core
  dnf-plugins-core
  ca-certificates
  unzip
  fira-code-fonts
)

###############################################################################
#                                                                             #
#                          Function defininitions                             #
#                                                                             #
###############################################################################
# Error handling function
error_exit() {
  echo -e "${RED}Error: ${ENDCOLOR}$1" >&2
  exit 1
}

# System detection function
detect_system() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
  else
    error_exit "Cannot detect Linux distribution"
  fi

  if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt update -y"
    UPGRADE_CMD="sudo apt upgrade -y"
    INSTALL_CMD="sudo apt install -y"
    PACKAGES=("${DEBIAN_PACKAGES[@]}")
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf check-update -y || true"
    UPGRADE_CMD="sudo dnf upgrade -y"
    INSTALL_CMD="sudo dnf install -y"
    PACKAGES=("${FEDORA_PACKAGES[@]}")
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="sudo pacman -Sy"
    UPGRADE_CMD="sudo pacman -Su --noconfirm"
    INSTALL_CMD="yay -S --noconfirm"
    PACKAGES=("${ARCH_PACKAGES[@]}")
  else
    error_exit "No supported package manager found"
  fi

  echo -e "${GREEN}Detected: $DISTRO $VERSION with $PKG_MANAGER${ENDCOLOR}"
}

# Update package repositories
update_repos() {
  echo -e "${GREEN}Updating package repositories...${ENDCOLOR}"
  eval "$UPDATE_CMD" || error_exit "Failed to update package repositories"
}

# Upgrade packages
upgrade_packages() {
  echo -e "${GREEN}Upgrading packages...${ENDCOLOR}"
  eval "$UPGRADE_CMD" || error_exit "Failed to upgrade packages"
}

setup_dotfiles() {
  echo -e "${GREEN}Setting up dotfiles...${ENDCOLOR}"
  # Create GitHub directory if it doesn't exist
  mkdir -p "$FILE_PATH"

  # Clone the repository if it doesn't exist
  if [ ! -d "$FILE_PATH/dotfiles" ]; then
    ## REPLACE THIS URL ⬇️
    git clone --bare https://github.com/GR3YH4TT3R93/OurDots.git ~/GitHub/dotfiles
    ## REPLACE THIS URL ⬆️
    git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" checkout
    git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" config --local status.showUntrackedFiles no
    # Initialize and update submodules
    git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" submodule update --init --recursive
  fi
}

# Helper function to check if a package is installed
package_installed() {
  local package="$1"
  case "$PKG_MANAGER" in
    apt)
      dpkg -l "$package" 2>/dev/null | grep -q "^ii"
      ;;
    dnf)
      rpm -q "$package" >/dev/null 2>&1
      ;;
    pacman)
      yay -Qi "$package" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

# Package installation function
install_package_list() {
  # Prompt the user to choose if they want to install recommended packages
  read -rp "${GREEN}Would you like to install recommended packages? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
  if [[ "$choice" == [Yy]* ]]; then
    local packages

    if [ $# -gt 0 ]; then
      # Properly receive the array
      packages=("$@")
      echo -e "${GREEN}Installing provided package list...${ENDCOLOR}"
    else
      read -rp "Enter path to package list file: " package_file < /dev/tty
      if [ -f "$package_file" ]; then
        # Read into array
        mapfile -t packages < "$package_file"
        echo -e "${GREEN}Reading packages from $package_file...${ENDCOLOR}"
      else
        error_exit "File not found: $package_file"
      fi
    fi

    if [ ${#packages[@]} -gt 0 ]; then
      echo -e "${GREEN}Installing ${#packages[@]} packages: ${packages[*]}${ENDCOLOR}"

      # Try batch install first
      if eval "$INSTALL_CMD" "${packages[@]}"; then
        echo -e "${GREEN}Successfully installed all packages${ENDCOLOR}"
      else
        echo -e "${YELLOW}Batch install failed. Identifying failed packages...${ENDCOLOR}"

        # Identify which packages failed
        local failed_packages=()
        for package in "${packages[@]}"; do
          if ! package_installed "$package"; then
            failed_packages+=("$package")
          fi
        done

        # Only retry the failed ones
        if [ ${#failed_packages[@]} -gt 0 ]; then
          echo -e "${YELLOW}Retrying ${#failed_packages[@]} failed packages: ${failed_packages[*]}${ENDCOLOR}"

          for package in "${failed_packages[@]}"; do
            echo -e "${GREEN}Installing $package...${ENDCOLOR}"
            if ! eval "$INSTALL_CMD" "$package"; then
              echo -e "${RED}Failed to install $package${ENDCOLOR}"
            fi
          done
        fi
      fi
    else
      echo -e "${YELLOW}No packages to install${ENDCOLOR}"
    fi
  else
    echo -e "${YELLOW}Skipping installation of recommended packages${ENDCOLOR}."
  fi
}

# Install mise packages
install_mise() {
  if command -v mise >/dev/null 2>&1; then
    echo -e "${GREEN}mise already installed${ENDCOLOR}"
    return 0
  fi

  echo -e "${GREEN}Installing mise...${ENDCOLOR}"
  # Get mise latest version
  MISE_VERSION=$(curl -s "https://api.github.com/repos/jdx/mise/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  # Install mise to /usr/local/bin
  curl -fsSL "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-x64" \
    | sudo tee /usr/local/bin/mise > /dev/null || error_exit "${YELLOW}Failed to download mise${ENDCOLOR}."
  sudo chmod +x /usr/local/bin/mise || error_exit "${YELLOW}Failed to install mise${ENDCOLOR}."

  # Activate mise in current shell
  echo -e "${GREEN}Activating mise in current shell...${ENDCOLOR}"
  export PATH="/usr/local/bin:$PATH"

  # Initialize mise for the current shell session
  eval "$(mise activate bash)"

  echo -e "${GREEN}mise installed and activated successfully${ENDCOLOR}"
}

# Activate mise if installed
ensure_mise_activated() {
  if command -v mise >/dev/null 2>&1; then
    export PATH="/usr/local/bin:$PATH"
    eval "$(mise activate bash)"
  fi
}
install_mise_packages() {
  echo -e "${GREEN}Installing mise packages...${ENDCOLOR}"
  mise use -g usage || error_exit "${YELLOW}Failed to install usage${ENDCOLOR}."
  mise use -g rust || error_exit "${YELLOW}Failed to install Rust${ENDCOLOR}."
  mise use -g nodejs || error_exit "${YELLOW}Failed to install Node.js${ENDCOLOR}."
  mise use -g ruby || error_exit "${YELLOW}Failed to install Ruby${ENDCOLOR}."
  mise use -g go || error_exit "${YELLOW}Failed to install Go${ENDCOLOR}."
  echo -e "${GREEN}mise packages installed successfully${ENDCOLOR}"
}

install_wezterm() {
  if command -v wezterm >/dev/null 2>&1; then
    echo -e "${GREEN}WezTerm already installed${ENDCOLOR}"
    return 0
  fi

  # Prompt the user to choose if they want to install WezTerm
  read -rp "${GREEN}Would you like to install WezTerm? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
  if [[ "$choice" == [Yy]* ]]; then
    # Install WezTerm
    echo -e "${GREEN}Installing WezTerm${ENDCOLOR}."
    sleep 2
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg \
      && echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list \
      && sudo nala update \
      && sudo nala install --update wezterm -y \
      && echo -e "${GREEN}WezTerm installed successfully${ENDCOLOR}."
  else
    echo -e "${YELLOW}Skipping installation of WezTerm${ENDCOLOR}."
  fi

}

# Install logo-ls
install_logo-ls() {
  if command -v logo-ls >/dev/null 2>&1; then
    echo -e "${GREEN}logo-ls already installed${ENDCOLOR}"
    return 0
  fi

  # Prompt the user to choose if they want to install Logo-ls
  read -rp "${GREEN}Would you like to install logo-ls? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
  if [[ "$choice" == [Yy]* ]]; then
    # Install logo-ls
    echo -e "${GREEN}Installing logo-ls...${ENDCOLOR}"
    # Install Logo-ls
    cd /tmp \
      && git clone https://github.com/canta2899/logo-ls.git \
      && cd logo-ls \
      && go build -o logo-ls ./cmd/logo-ls \
      && sudo mv logo-ls /usr/bin/ \
      && cd ~/ \
      && sudo rm -rf ~/go \
      && echo -e "${GREEN}logo-ls installed successfully${ENDCOLOR}."
  else
    echo -e "${YELLOW}Skipping installation of logo-ls${ENDCOLOR}."
  fi
}

# Install Neovim Nightly
install_neovim_nightly() {
  if command -v nvim >/dev/null 2>&1; then
    echo -e "${GREEN}Neovim already installed${ENDCOLOR}"
    return 0
  fi

  echo -e "${GREEN}Installing Neovim Nightly...${ENDCOLOR}"

  case $PKG_MANAGER in
    dnf)
      sudo dnf install 'dnf-command(config-manager)' -y \
        && sudo dnf config-manager --add-repo https://copr.fedorainfracloud.org/coprs/neovim/neovim-nightly/repo/fedora-"$(rpm -E %fedora)"/neovim-neovim-nightly-fedora-"$(rpm -E %fedora)".repo \
        && sudo dnf install neovim-nightly -y
      ;;
    pacman)
      yay -S --noconfirm neovim-nightly-bin
      ;;
    apt)
      sudo add-apt-repository ppa:neovim-ppa/unstable -y \
        && sudo apt update \
        && sudo apt install neovim -y
      ;;
    *)
      error_exit "Unsupported package manager for Neovim installation"
  ;; esac

  echo -e "${GREEN}Neovim Nightly installed successfully${ENDCOLOR}"
}

# Install neovim extreas
install_neovim_extras() {
  echo -e "${GREEN}Installing Neovim extras...${ENDCOLOR}"
  # Install pynvim for Python support
  #pip install --user pynvim || error_exit "${YELLOW}Failed to install pynvim${ENDCOLOR}."
  # Install neovim gem for Ruby support
  # gem install neovim || error_exit "${YELLOW}Failed to install neovim gem${ENDCOLOR}."
  # Install luajit and luarocks for Lua support
  # Check if luajit and luarocks need to be installed
  needs_luajit=false
  needs_luarocks=false

  if ! command -v luajit &> /dev/null; then
    needs_luajit=true
  fi

  if ! command -v luarocks &> /dev/null; then
    needs_luarocks=true
  fi

  # Only install if needed
  if [ "$needs_luajit" = true ] || [ "$needs_luarocks" = true ]; then
    packages_to_install=""
    [ "$needs_luajit" = true ] && packages_to_install="luajit"
    [ "$needs_luarocks" = true ] && packages_to_install="$packages_to_install luarocks"

    echo -e "${GREEN}Installing $packages_to_install${ENDCOLOR}."

    if [ "$PKG_MANAGER" = "pacman" ]; then
      if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm "$packages_to_install" || error_exit "${YELLOW}Failed to install $packages_to_install${ENDCOLOR}."
      else
        sudo pacman -S --noconfirm "$packages_to_install" || error_exit "${YELLOW}Failed to install $packages_to_install${ENDCOLOR}."
      fi
    else
      eval "$INSTALL_CMD $packages_to_install" || error_exit "${YELLOW}Failed to install $packages_to_install${ENDCOLOR}."
    fi
  else
    echo -e "${GREEN}luajit and luarocks are already installed${ENDCOLOR}."
  fi

  # # Install neovim rock for Lua support
  # luarocks install --local --tree=$HOME/.luarocks neovim || error_exit "${YELLOW}Failed to install neovim rock${ENDCOLOR}."
  # Install cpanm and Neovim module for Perl support
  cpan App::cpanminus || error_exit "${YELLOW}Failed to install cpanminus${ENDCOLOR}."
  export PATH="$HOME/perl5/bin:$PATH"
  cpanm -n Neovim::Ext || error_exit "${YELLOW}Failed to install neovim perl module${ENDCOLOR}."
  # Install rubygems and neovim gem for Ruby support
  # gem install neovim || error_exit "${YELLOW}Failed to install neovim gem package${ENDCOLOR}."
  # gem update --system || error_exit "${YELLOW}Failed to update gem${ENDCOLOR}."
  echo -e "${GREEN}Neovim extras installed successfully${ENDCOLOR}"
}

# Install LazyGit
install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    echo -e "${GREEN}Lazygit already installed${ENDCOLOR}"
    return 0
  fi

  echo -e "${GREEN}Installing LazyGit...${ENDCOLOR}"

  case $PKG_MANAGER in
    dnf)
      sudo dnf install epel-release -y \
        && sudo dnf install lazygit -y
      ;;
    pacman)
      sudo pacman -S --noconfirm lazygit
      ;;
    apt)
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
        && tar xf /tmp/lazygit.tar.gz -c /tmp \
        && sudo install /tmp/lazygit /usr/local/bin \
        && echo -e "${GREEN}Lazygit installed successfully${ENDCOLOR}."
      ;;
    *)
      error_exit "Unsupported package manager for LazyGit installation"
  ;; esac
}

# Install GitHub CLI
install_gh() {
  if command -v gh >/dev/null 2>&1; then
    echo -e "${GREEN}GitHub CLI already installed${ENDCOLOR}"
    return 0
  fi

  echo -e "${GREEN}Installing GitHub CLI...${ENDCOLOR}"

  case $PKG_MANAGER in
    dnf)
      sudo dnf install dnf5-plugins \
        && sudo dnf config-manager --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo \
        && sudo dnf install gh --repo gh-cli
      ;;
    pacman)
      sudo pacman -S --noconfirm github-cli
      ;;
    apt)
      sudo mkdir -p -m 755 /etc/apt/keyrings
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update && sudo apt install gh -y
      ;;
    *)
      error_exit "Unsupported package manager for GitHub CLI installation"
      ;;
  esac

  echo -e "${GREEN}GitHub CLI installed successfully${ENDCOLOR}"
}

# Git Credentials Setup
git_config() {
  # Check if Git credentials are already configured
  git_username=$(git config --get user.name 2>/dev/null || git config --system --get user.name 2>/dev/null)
  git_email=$(git config --get user.email 2>/dev/null || git config --system --get user.email 2>/dev/null)

  if [ "$git_username" != "" ] && [ "$git_email" != "" ]; then
    echo -e "${GREEN}Git credentials already configured${ENDCOLOR}."
    echo -e "${GREEN}Username: $git_username${ENDCOLOR}."
    echo -e "${GREEN}Email: $git_email${ENDCOLOR}."
    read -rp "${YELLOW}Would you like to reconfigure? (Yes/No)${ENDCOLOR}: " reconfigure < /dev/tty
    if [[ ! "$reconfigure" == [Yy]* ]]; then
      echo -e "${GREEN}Keeping existing Git configuration${ENDCOLOR}."
      # Still need key_title for SSH key operations later
      read -rp "${GREEN}Enter the name of your existing SSH signing key (without .pub extension)${ENDCOLOR}: " key_title < /dev/tty
      username="$git_username"
      email="$git_email"
    else
      # Proceed with reconfiguration
      setup_git_credentials=true
    fi
  else
    setup_git_credentials=true
  fi

  if [ "$setup_git_credentials" = true ]; then
    echo -e "${YELLOW}Time to set up your Git credentials${ENDCOLOR}."
    # Prompt the user for their Git username
    read -rp "${GREEN}Enter your Git username${ENDCOLOR}: " username < /dev/tty
    # Prompt the user for their Git email
    read -rp "${GREEN}Enter your Git email${ENDCOLOR}: " email < /dev/tty
    # Prompt the user for the name associated with the SSH key
    read -rp "${GREEN}Enter a name you would like associated with the new SSH key for easy recognition on GitHub${ENDCOLOR}: " key_title < /dev/tty
    # Git System Config
    read -rp "${GREEN}Would you like to set your Git configuration system-wide? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Set the Git username and email system-wide
      sudo git config --system user.name "$username"
      sudo git config --system user.email "$email"
      sudo git config --system gpg.format ssh
      sudo git config --system user.signingkey ~/.ssh/"$key_title".pub
      sudo git config --system gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
      sudo git config --system diff.submodule log
      sudo git config --system log.showSignature true
      sudo git config --system submodule.recurse true
      sudo git config --system commit.gpgsign true
      sudo git config --system tag.gpgsign true
      sudo git config --system push.autoSetupRemote true
      sudo git config --system fetch.prune true
      sudo git config --system core.editor nvim
      sudo git config --system core.autocrlf input
      sudo git config --system init.defaultBranch main
      sudo git config --system color.status auto
      sudo git config --system color.branch auto
      sudo git config --system color.interactive auto
      sudo git config --system color.diff auto
      sudo git config --system status.short true
      sudo git config --system alias.assume-unchanged 'update-index --assume-unchanged'
      sudo git config --system alias.assume-changed 'update-index --no-assume-unchanged'
      gh auth setup-git
      # Transfer gh helper config to system config
      cat "$HOME/.gitconfig" >> "/usr/etc/gitconfig"
      # Clean up unnecessary file
      rm "$HOME/.gitconfig"
      echo -e "${GREEN}Git credentials configured system-wide${ENDCOLOR}."
    elif [[ "$choice" == [Nn]* ]]; then
      # Set the Git username and email globally
      git config --global user.name "$username"
      git config --global user.email "$email"
      git config --global gpg.format ssh
      git config --global user.signingkey ~/.ssh/"$key_title".pub
      git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
      git config --global diff.submodule log
      git config --global submodule.recurse true
      git config --global log.showSignature true
      git config --global commit.gpgsign true
      git config --global tag.gpgsign true
      git config --global push.autoSetupRemote true
      git config --global fetch.prune true
      git config --global core.editor nvim
      git config --global core.autocrlf input
      git config --global init.defaultBranch main
      git config --global color.status auto
      git config --global color.branch auto
      git config --global color.interactive auto
      git config --global color.diff auto
      git config --global status.short true
      git config --global alias.assume-unchanged 'update-index --assume-unchanged'
      git config --global alias.assume-changed 'update-index --no-assume-unchanged'
      gh auth setup-git
      echo -e "${GREEN}Git credentials configured globally${ENDCOLOR}."
      sleep 2
    else
      echo -e "${YELLOW}Skipping Git configuration${ENDCOLOR}."
      sleep 2
    fi
  fi

  # Set up GitHub auth if not already authenticated
  if ! gh auth status 2>&1 | grep -q "Logged in to github.com"; then
    gh auth login || error_exit "${RED}Failed to set up GitHub auth.${ENDCOLOR}"
  else
    echo -e "${GREEN}Already authenticated with GitHub CLI${ENDCOLOR}"
    sleep 2
  fi

  # Check if SSH key already exists on GitHub (only if key_title is set)
  if [ "$key_title" != "" ] && gh ssh-key list 2>/dev/null | grep -q "$key_title"; then
    echo -e "${GREEN}SSH key '$key_title' already exists on GitHub. Skipping SSH setup.${ENDCOLOR}"
    sleep 2
  else
    # Set Up SSH Key
    if [ ! -f ~/.ssh/"$key_title" ]; then
      # Generate an Ed25519 SSH key pair
      echo -e "${GREEN}Generating SSH key${ENDCOLOR}"
      ssh-keygen -f ~/.ssh/"$key_title" -t ed25519 -C "$email" || error_exit "${RED}Failed to generate SSH key${ENDCOLOR}"
      # Start SSH agent and add key
      eval "$(ssh-agent -s)"
      ssh-add ~/.ssh/"$key_title" || error_exit "${RED}Failed to add SSH key to agent${ENDCOLOR}"
    else
      echo -e "${YELLOW}SSH key already exists. Skipping SSH key generation. Adding SSH key to SSH-agent${ENDCOLOR}"
      eval "$(ssh-agent -s)"
      ssh-add ~/.ssh/"$key_title" || error_exit "${RED}Failed to add SSH key to agent${ENDCOLOR}"
    fi

    # Check if we have the required scope before refreshing
    if ! gh auth status 2>&1 | grep -q "admin:ssh_signing_key"; then
      echo -e "${GREEN}Refreshing GH CLI permissions for SSH key management${ENDCOLOR}"
      gh auth refresh -h github.com -s admin:ssh_signing_key || error_exit "${RED}Failed to give GH CLI permissions to add SSH key to GitHub for Signature Verification.${ENDCOLOR}"
    else
      echo -e "${GREEN}Already have SSH signing key permissions${ENDCOLOR}"
    fi

    echo -e "${GREEN}Adding SSH key to GitHub${ENDCOLOR}"
    # Add SSH key to GitHub using gh cli
    gh ssh-key add ~/.ssh/"$key_title".pub --title "$key_title" --type "signing" || error_exit "${RED}Failed to add SSH key to GitHub.${ENDCOLOR}"

    # Create file containing SSH public key for verifying signers
    if [ ! -f ~/.ssh/allowed_signers ] || ! grep -q "$key_title" ~/.ssh/allowed_signers; then
      awk '{ print $3 " " $1 " " $2 }' ~/.ssh/"$key_title".pub >> ~/.ssh/allowed_signers
    fi
  fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}Oh My Zsh already installed${ENDCOLOR}"
    return 0
  fi

  # Prompt the user to choose if they want to install oh-my-zsh
  read -rp "${GREEN}Would you like to install Oh-My-Zsh? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
  if [[ "$choice" == [Yy]* ]]; then
    # Install Oh My Zsh
    echo -e "${GREEN}Installing Oh-My-Zsh${ENDCOLOR}."
    sleep 2
    export ZSH="$HOME/.config/oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/GR3YH4TT3R93/ohmyzsh/master/tools/install.sh)"
    # Clean up excess files
    rm ".zshrc.pre-oh-my-zsh"

    # Prompt the user to choose if they want to install Powerlevel10k
    read -rp "${GREEN}Would you like to install Powerlevel10k? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Powerlevel10k
      echo -e "${GREEN}Installing Powerlevel10k${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" || error_exit "${YELLOW}Failed to install Powerlevel10k${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Powerlevel10k${ENDCOLOR}."
      sed -i '/if \[\[ -r "\${XDG_CACHE_HOME:-\$HOME\/.cache}\/p10k-instant-prompt-\${(%):-%n}.zsh" \]\]; then/,/fi/{/fi/{N;d;};d;}' ~/.zshrc
      # Replace with default theme
      sed -i 's/ZSH_THEME="powerlevel10k\/powerlevel10k"/ZSH_THEME="robbyrussell"/' ~/.zshrc
      rm -rf ~/.p10k.zsh
      rm -rf "$ZSH_CUSTOM/themes/powerlevel10k"
    fi

    # Pronpt the user to choose if they want to install Zsh-Auto-Suggestions
    read -rp "${GREEN}Would you like to install Zsh-Auto-Suggestions? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Auto-Suggestions
      echo -e "${GREEN}Installing Zsh-Auto-Suggestions${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || error_exit "${YELLOW}Failed to install zsh-autosuggestions${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Zsh-Auto-Suggestions${ENDCOLOR}."
      # Remove the line Zsh-Auto-Suggestions from .zshrc
      sed -i '/zsh-autosuggestions/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-Completions
    read -rp "${GREEN}Would you like to install Zsh-Completions? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Completions
      echo -e "${GREEN}Installing Zsh-Completions${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" || error_exit "${YELLOW}Failed to install zsh-completions${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Zsh-Completions${ENDCOLOR}."
      sed -i '/zsh-completions/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-History-Substring-Search
    read -rp "${GREEN}Would you like to install Zsh-History-Substring-Search? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-History-Substring-Search
      echo -e "${GREEN}Installing Zsh-History-Substring-Search${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" || error_exit "${YELLOW}Failed to install zsh-history-substring-search${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Zsh-History-Substring-Search${ENDCOLOR}."
      sed -i '/zsh-history-substring-search/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-Syntax-Highlighting
    read -rp "${GREEN}Would you like to install Zsh-Syntax-Highlighting? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Syntax-Highlighting
      echo -e "${GREEN}Installing Zsh-Syntax-Highlighting${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || error_exit "${YELLOW}Failed to install zsh-syntax-highlighting${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Zsh-Syntax-Highlighting${ENDCOLOR}."
      sed -i '/zsh-syntax-highlighting/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Git-Flow-Completions
    read -rp "${GREEN}Would you like to install Git-Flow-Completions? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Git-Flow-Completions
      echo -e "${GREEN}Installing Git-Flow-Completions${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/bobthecow/git-flow-completion "$ZSH_CUSTOM/plugins/git-flow-completion" || error_exit "${YELLOW}Failed to install git-flow-completion${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Git-Flow-Completions${ENDCOLOR}."
      sed -i '/git-flow-completion/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-Vi-Mode
    read -rp "${GREEN}Would you like to install Zsh-Vi-Mode? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Vi-Mode
      echo -e "${GREEN}Installing Zsh-Vi-Mode${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode" || error_exit "${YELLOW}Failed to install Zsh-Vi-Mode${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Zsh-Vi-Mode${ENDCOLOR}."
      sed -i '/zsh-vi-mode/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-Interactive-Cd
    read -rp "${GREEN}Would you like to install Magic-Enter? (Yes/No)${ENDCOLOR}: " choice < /dev/tty

    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Interactive-Cd
      echo -e "${GREEN}Installing Magic-Enter${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/GR3YH4TT3R93/magic-enter "$ZSH_CUSTOM/plugins/magic-enter" || error_exit "${YELLOW}Failed to install Magic-Enter${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of Magic-Enter${ENDCOLOR}."
      sed -i '/magic-enter/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to install Zsh-Interactive-Cd
    read -rp "${GREEN}Would you like to install fzf-tab? (Yes/No)${ENDCOLOR}: " choice < /dev/tty

    if [[ "$choice" == [Yy]* ]]; then
      # Install Zsh-Interactive-Cd
      echo -e "${GREEN}Installing fzf-tab${ENDCOLOR}."
      sleep 2
      git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab" || error_exit "${YELLOW}Failed to install fzf-tab${ENDCOLOR}."
    else
      echo -e "${YELLOW}Skipping installation of fzf-tab${ENDCOLOR}."
      sed -i '/fzf-tab/d' ~/.zshrc
    fi

    # Prompt the user to choose if they want to keep the included .zsh_aliases file
    read -rp "${GREEN}Would you like to keep the included .zsh_aliases file? (Yes/No)${ENDCOLOR}: " choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      # Keep the included .zsh_aliases file
      echo -e "${GREEN}Keeping .zsh_aliases file${ENDCOLOR}."
      sleep 2
    else
      # Remove the included .zsh_aliases file and inclided if statement in .zshrc
      echo -e "${YELLOW}Removing .zsh_aliases file${ENDCOLOR}."
      rm ~/.zsh_aliases
      sed -i '/if \[\[ -r "\$HOME\/.zsh_aliases" \]\]; then/,/fi/{/fi/{N;d;};d;}' ~/.zshrc
    fi
  fi
}

# Install FiraCode Nerd Font
install_firacode_nerd_font() {
  if fc-list | grep -qi "FiraCode Nerd Font" >/dev/null 2>&1; then
    echo -e "${GREEN}FiraCode Nerd Font already installed${ENDCOLOR}"
    return 0
  fi

  # Prompt the user to choose if they want to install Fira Code Nerd Font
  read -rp "${GREEN}Would you like to install Fira Code Nerd Font? (Yes/No)${ENDCOLOR}: " choice < /dev/tty

  if [[ "$choice" == [Yy]* ]]; then
    # If using Arch use getnf to install Fira Code Nerd Font
    if [[ "$PKG_MANAGER" == "pacman" ]] && command -v getnf >/dev/null 2>&1; then
      echo -e "${GREEN}Installing Fira Code Nerd Font using getnf${ENDCOLOR}."
      sleep 2
      getnf -i FiraCode || error_exit "${YELLOW}Failed to install Fira Code Nerd Font using getnf${ENDCOLOR}."
      echo -e "${GREEN}Fira Code Nerd Font installed successfully using getnf${ENDCOLOR}."
      return 0
    else
      echo -e "${YELLOW}getnf not found, proceeding with manual installation of Fira Code Nerd Font${ENDCOLOR}."
      sleep 2
    fi
    # Install Fira Code Nerd Font
    echo -e "${GREEN}Installing Fira Code Nerd Font${ENDCOLOR}."
    sleep 2
    # Define variables
    local FIRACODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    local FONT_DIR="/usr/share/fonts/truetype/fira-code"
    local TEMP_FILE="/tmp/FiraCode.zip"
    # Create the directory for the FiraCode Nerd Fonts
    sudo mkdir -p "$FONT_DIR"
    # Download and extract the FiraCode Nerd Fonts zip file
    echo -e "${YELLOW}Downloading FiraCode Nerd Fonts...${ENDCOLOR}"
    curl -fsSL "$FIRACODE_URL" -o "$TEMP_FILE"
    echo -e "${YELLOW}Extracting FiraCode Nerd Fonts...${ENDCOLOR}"
    sudo unzip -q "$TEMP_FILE" -d "$FONT_DIR"

    # Refresh the font cache
    echo -e "${YELLOW}Refreshing font cache...${ENDCOLOR}"
    sudo fc-cache -fv >/dev/null 2>&1

    # Clean up
    echo -e "${YELLOW}Cleaning up...${ENDCOLOR}"
    rm -f "$TEMP_FILE"

    # Check if the fonts were installed successfully
    if fc-list | grep -q "FiraCode Nerd Font"; then
      echo -e "${GREEN}FiraCode Nerd Fonts installed successfully.${ENDCOLOR}"
    else
      echo -e "${RED}Failed to install FiraCode Nerd Fonts.${ENDCOLOR}"
    fi
  else
    echo -e "${YELLOW}Skipping installation of Fira Code Nerd Font${ENDCOLOR}."
  fi
}

# Set up btrfs config
create_btrfs_subvolumes() {
  echo -e "${GREEN}=== Btrfs Subvolume Creator ===${ENDCOLOR}"
  echo
  sleep 2

  # Find the Btrfs root partition
  echo -e "${GREEN}Detecting Btrfs root partition...${ENDCOLOR}"
  ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')

  if [[ -z "$ROOT_DEVICE" ]]; then
    echo -e "${RED}Error: Could not detect root device${ENDCOLOR}"
    return 1
  fi

  echo -e "${GREEN}Root device: $ROOT_DEVICE"

  # Verify it's a Btrfs filesystem
  FS_TYPE=$(findmnt -n -o FSTYPE /)
  if [[ "$FS_TYPE" != "btrfs" ]]; then
    echo -e "${RED}Error: Root filesystem is not Btrfs (detected: $FS_TYPE)${ENDCOLOR}"
    return 1
  fi

  echo -e "${GREEN}Confirmed Btrfs filesystem${ENDCOLOR}"
  echo

  # Create temporary mount point
  TEMP_MOUNT="/mnt/btrfs-root-temp"
  echo -e "${GREEN}Creating temporary mount point at $TEMP_MOUNT...${ENDCOLOR}"
  sudo mkdir -p "$TEMP_MOUNT"

  # Mount top-level subvolume
  echo -e "${GREEN}Mounting top-level Btrfs subvolume...${ENDCOLOR}"
  sudo mount -o subvolid=5 "$ROOT_DEVICE" "$TEMP_MOUNT"

  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Failed to mount top-level subvolume${ENDCOLOR}"
    sudo rmdir "$TEMP_MOUNT"
    return 1
  fi

  echo -e "${GREEN}Successfully mounted at $TEMP_MOUNT${ENDCOLOR}"
  echo

  # List existing subvolumes
  echo -e "${GREEN}Current subvolumes:${ENDCOLOR}"
  sudo btrfs subvolume list / | grep -E "path @"
  echo

  # Create @snapshots subvolume
  if [[ -d "$TEMP_MOUNT/@snapshots" ]]; then
    echo -e "${RED}Warning: @snapshots subvolume already exists, skipping...${ENDCOLOR}"
  else
    echo -e "${GREEN}Creating @snapshots subvolume...${ENDCOLOR}"
    sudo btrfs subvolume create "$TEMP_MOUNT/@snapshots"
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}✓ Created @snapshots subvolume${ENDCOLOR}"
    else
      echo -e "${RED}✗ Failed to create @snapshots subvolume${ENDCOLOR}"
    fi
  fi
  echo

  # Create @games subvolume
  if [[ -d "$TEMP_MOUNT/@games" ]]; then
    echo -e "${YELLOW}Warning: @games subvolume already exists, skipping...${ENDCOLOR}"
  else
    echo -e "${GREEN}Creating @games subvolume...${ENDCOLOR}"
    sudo btrfs subvolume create "$TEMP_MOUNT/@games"
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}✓ Created @games subvolume${ENDCOLOR}"
    else
      echo -e "${RED}✗ Failed to create @games subvolume${ENDCOLOR}"
    fi
  fi
  echo

  # Move existing data if needed
  if [[ -d "/opt/games" ]] && [[ -n "$(ls -A /opt/games 2>/dev/null)" ]]; then
    echo -e "${GREEN}Found existing data in /opt/games${ENDCOLOR}"
    read -rp "${GREEN}Copy existing data to new @games subvolume? (y/N): ${ENDCOLOR}" choice < /dev/tty
    if [[ "$choice" == [Yy]* ]]; then
      echo -e "${GREEN}Copying data...${ENDCOLOR}"
      sudo cp -a /opt/games/* "$TEMP_MOUNT/@games/"
      echo -e "${GREEN}✓ Data copied${ENDCOLOR}"
    fi
  fi
  echo

  # Get UUID for fstab
  UUID=$(sudo blkid -s UUID -o value "$ROOT_DEVICE")
  echo -e "${GREEN}Partition UUID: $UUID${ENDCOLOR}"
  echo

  # Check if UUID is set
  if [[ -z "$UUID" ]]; then
    echo -e "${RED}Error: Still could not retrieve UUID. Please check the device.${ENDCOLOR}"
    sudo umount "$TEMP_MOUNT"
    sudo rmdir "$TEMP_MOUNT"
    return 1
  fi

  # Create mount points
  echo -e "${GREEN}Creating mount points...${ENDCOLOR}"
  sudo mkdir -p /.snapshots
  sudo mkdir -p /opt/games
  echo -e "${GREEN}✓ Mount points created${ENDCOLOR}"
  echo

  # Generate fstab entries
  echo "${GREEN}=== Add these lines to /etc/fstab ===${ENDCOLOR}"
  echo
  echo -e "${GREEN}UUID=$UUID  /.snapshots  btrfs  subvol=@snapshots,defaults,compress=zstd  0  0${ENDCOLOR}"
  echo -e "${GREEN}UUID=$UUID  /opt/games   btrfs  subvol=@games,defaults,compress=zstd  0  0${ENDCOLOR}"
  echo

  # Ask if user wants to automatically add to fstab
  # Ask if user wants to automatically add to fstab
  read -rp "${GREEN}Automatically add these entries to /etc/fstab? (y/N): ${ENDCOLOR}" choice < /dev/tty
  if [[ "$choice" == [Yy]* ]]; then
    # Backup fstab
    sudo cp /etc/fstab /etc/fstab.backup-"$(date +%Y%m%d-%H%M%S)"
    echo -e "${GREEN}✓ Backed up /etc/fstab${ENDCOLOR}"

    # Add entries if they don't exist
    if ! grep -q "@snapshots" /etc/fstab; then
      echo "UUID=$UUID  /.snapshots  btrfs  subvol=@snapshots,defaults,compress=zstd  0  0" | sudo tee -a /etc/fstab > /dev/null
      echo -e "${GREEN}✓ Added @snapshots to fstab${ENDCOLOR}"
    else
      echo -e "${YELLOW}⚠ @snapshots entry already in fstab${ENDCOLOR}"
    fi

    if ! grep -q "@games" /etc/fstab; then
      echo "UUID=$UUID  /opt/games   btrfs  subvol=@games,defaults,compress=zstd  0  0" | sudo tee -a /etc/fstab > /dev/null
      echo -e "${GREEN}✓ Added @games to fstab${ENDCOLOR}"
    else
      echo -e "${YELLOW}⚠ @games entry already in fstab${ENDCOLOR}"
    fi

    echo
    echo -e "${GREEN}Mounting new subvolumes...${ENDCOLOR}"
    sudo mount /.snapshots
    sudo mount /opt/games

    if mountpoint -q /.snapshots && mountpoint -q /opt/games; then
      echo -e "${GREEN}✓ Subvolumes mounted successfully${ENDCOLOR}"
    else
      echo -e "${YELLOW}⚠ Warning: Some subvolumes may not have mounted correctly${ENDCOLOR}"
      echo -e "${GREEN}Checking mount status:${ENDCOLOR}"
      mountpoint /.snapshots && echo -e "  ${GREEN}✓ /.snapshots is mounted${ENDCOLOR}" || echo -e "  ${RED}✗ /.snapshots failed to mount${ENDCOLOR}"
      mountpoint /opt/games && echo -e "  ${GREEN}✓ /opt/games is mounted${ENDCOLOR}" || echo -e "  ${RED}✗ /opt/games failed to mount${ENDCOLOR}"
    fi
  else
    echo -e "${YELLOW}Skipped automatic fstab modification${ENDCOLOR}"
    echo -e "${YELLOW}Please add the entries manually and then run:${ENDCOLOR}"
    echo -e "${YELLOW}  sudo mount /.snapshots${ENDCOLOR}"
    echo -e "${YELLOW}  sudo mount /opt/games${ENDCOLOR}"
  fi

  # Unmount temporary mount
  echo -e "Cleaning up...${ENDCOLOR}"
  sudo umount "$TEMP_MOUNT"
  sudo rmdir "$TEMP_MOUNT"
  echo -e "${GREEN}✓ Cleanup complete${ENDCOLOR}"
  echo

  # Verify
  echo "${GREEN}=== Verification ===${ENDCOLOR}"
  echo -e "${GREEN}Current subvolumes:${ENDCOLOR}"
  sudo btrfs subvolume list / | grep -E "path @"
  echo
  echo -e "${GREEN}Mounted subvolumes:${ENDCOLOR}"
  sudo mount | grep btrfs
  echo
  echo "${GREEN}=== Setup Complete! ===${ENDCOLOR}"
}

# Setup Snapper
setup_snapper() {
  echo "${GREEN}=== Setting up Snapper (Arch Wiki method) ===${ENDCOLOR}"
  sleep 2

  # Get root device
  ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
  UUID=$(sudo blkid -s UUID -o value "$ROOT_DEVICE")

  echo -e "${GREEN}1. Cleaning up existing Snapper configuration...${ENDCOLOR}"
  # Remove existing snapper config if it exists
  if snapper list-configs 2>/dev/null | grep -q "root"; then
    echo -e "   ${YELLOW} - Removing existing root config...${ENDCOLOR}"
    sudo snapper -c root delete-config 2>/dev/null || true
  fi

  echo -e "${GREEN}2. Ensuring /.snapshots is not mounted and doesn't exist as folder...${ENDCOLOR}"
  # Unmount /.snapshots if mounted
  if mountpoint -q /.snapshots; then
    sudo umount /.snapshots
  fi

  # Remove /.snapshots directory
  sudo rm -rf /.snapshots

  echo -e "${GREEN}3. Creating snapper config for /...${ENDCOLOR}"
  # This will create a nested .snapshots subvolume inside @
  sudo snapper -c root create-config / 2>/dev/null || echo -e "   ${YELLOW} - Config already exists (this is OK)${ENDCOLOR}"

  echo -e "${GREEN}4. Deleting any nested .snapshots subvolume that snapper created...${ENDCOLOR}"
  # Delete the nested subvolume that snapper created (if it exists)
  if [[ -d /.snapshots ]] && sudo btrfs subvolume show /.snapshots &>/dev/null; then
    sudo btrfs subvolume delete /.snapshots
    echo -e "   ${GREEN} - Removed nested subvolume${ENDCOLOR}"
  else
    echo -e "   ${YELLOW} - No nested subvolume to delete${ENDCOLOR}"
  fi

  echo -e "${GREEN}5. Recreating /.snapshots as directory...${ENDCOLOR}"
  # Recreate as regular directory
  sudo mkdir /.snapshots

  echo -e "${GREEN}6. Reloading systemd for fstab changes...${ENDCOLOR}"
  sudo systemctl daemon-reload

  echo -e "${GREEN}7. Mounting separate @snapshots subvolume to /.snapshots...${ENDCOLOR}"
  # Mount the separate @snapshots subvolume
  sudo mount -o subvol=@snapshots,defaults,compress=zstd "$ROOT_DEVICE" /.snapshots

  echo -e "${GREEN}8. Adding fstab entry for persistence...${ENDCOLOR}"
  # Add to fstab for persistence
  if ! grep -q "@snapshots" /etc/fstab; then
    echo "UUID=$UUID  /.snapshots  btrfs  subvol=@snapshots,defaults,compress=zstd  0  0" | sudo tee -a /etc/fstab
    echo -e "   ${GREEN} - Added to fstab${ENDCOLOR}"
  else
    echo -e "   ${YELLOW} - Fstab entry already exists${ENDCOLOR}"
  fi

  echo -e "${GREEN}9. Setting permissions...${ENDCOLOR}"
  sudo chmod 750 /.snapshots

  echo -e "${GREEN}10. Enabling snapper services...${ENDCOLOR}"
  sudo systemctl enable --now snapper-timeline.timer
  sudo systemctl enable --now snapper-cleanup.timer

  # GRUB-BTRFS SETUP
  echo -e "${GREEN}11. Setting up grub-btrfs integration...${ENDCOLOR}"
  # Check if grub-btrfs is installed by looking for the package or files
  if pacman -Q grub-btrfs 2>/dev/null || [[ -f /usr/bin/grub-btrfsd || -f /usr/bin/grub-btrfs || -f /etc/grub.d/41_snapshots-btrfs ]]; then
    echo -e "   ${GREEN} - grub-btrfs is installed, configuring...${ENDCOLOR}"

    # Configure grub-btrfs for dracut if config file exists
    if [[ -f /etc/default/grub-btrfs/config ]]; then
      echo -e "   ${GREEN} - Configuring grub-btrfs kernel parameters...${ENDCOLOR}"
      sudo cp /etc/default/grub-btrfs/config /etc/default/grub-btrfs/config.backup-"$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true

      if grep -q "^#*GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=" /etc/default/grub-btrfs/config; then
        sudo sed -i 's/^#*GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=.*/GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="rd.live.overlay.overlayfs=1"/' /etc/default/grub-btrfs/config
      else
        echo 'GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="rd.live.overlay.overlayfs=1"' | sudo tee -a /etc/default/grub-btrfs/config > /dev/null
      fi
    fi

    # Regenerate grub-btrfs snapshot submenu if the script exists
    if [[ -x /etc/grub.d/41_snapshots-btrfs ]]; then
      echo -e "   ${GREEN} - Regenerating grub-btrfs snapshot submenu...${ENDCOLOR}"
      sudo /etc/grub.d/41_snapshots-btrfs > /dev/null 2>&1 || echo -e "   ${YELLOW}⚠ grub-btrfs submenu generation had issues${ENDCOLOR}"
    fi

    # Enable grub-btrfsd service if it exists
    if systemctl list-unit-files | grep -q grub-btrfsd.service; then
      echo -e "   ${GREEN} - Enabling grub-btrfsd service...${ENDCOLOR}"
      sudo systemctl enable --now grub-btrfsd.service
    else
      echo -e "   ${YELLOW}⚠ grub-btrfsd.service not found${ENDCOLOR}"
    fi
  else
    echo -e "   ${YELLOW}⚠ grub-btrfs is not installed, skipping grub integration${ENDCOLOR}"
    echo -e "   ${YELLOW}To install: sudo pacman -S grub-btrfs${ENDCOLOR}"
  fi

  # UPDATE GRUB
  echo -e "12. Updating GRUB configuration...${ENDCOLOR}"
  if command -v grub-mkconfig >/dev/null 2>&1; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1 && echo -e "   ${GREEN}✓ GRUB updated successfully${ENDCOLOR}" || echo -e "   ${YELLOW}⚠ GRUB update had issues${ENDCOLOR}"
  else
    echo -e "   ${YELLOW}⚠ grub-mkconfig not found${ENDCOLOR}"
  fi

  # VERIFICATION
  echo
  echo "${GREEN}=== Verification ===${ENDCOLOR}"
  if mountpoint -q /.snapshots; then
    echo -e "${GREEN}✓ /.snapshots is properly mounted${ENDCOLOR}"
    MOUNT_SOURCE=$(findmnt -n -o SOURCE /.snapshots)
    if echo "$MOUNT_SOURCE" | grep -q "subvol=@snapshots"; then
      echo -e "${GREEN}✓ Using separate @snapshots subvolume (not nested in @)${ENDCOLOR}"
    fi
  else
    echo -e "${RED}✗ /.snapshots is not mounted${ENDCOLOR}"
  fi

  if snapper -c root list-configs 2>/dev/null | grep -q "root"; then
    echo -e "${GREEN}✓ Snapper config created successfully${ENDCOLOR}"
  else
    echo -e "${RED}✗ Snapper config missing${ENDCOLOR}"
  fi

  if systemctl is-active snapper-timeline.timer >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Snapper timeline timer is active${ENDCOLOR}"
  else
    echo -e "${RED}✗ Snapper timeline timer is not active${ENDCOLOR}"
  fi

  # Check grub-btrfs properly (without trying to run the daemon as user)
  if pacman -Q grub-btrfs 2>/dev/null && systemctl is-active grub-btrfsd.service >/dev/null 2>&1; then
    echo -e "${GREEN}✓ grub-btrfsd service is active${ENDCOLOR}"
  elif pacman -Q grub-btrfs 2>/dev/null; then
    echo -e "${YELLOW}⚠ grub-btrfs installed but service not active${ENDCOLOR}"
  else
    echo -e "${YELLOW}⚠ grub-btrfs not installed${ENDCOLOR}"
  fi

  echo
  echo -e "${GREEN}✓ Snapper setup complete - following Arch Wiki layout${ENDCOLOR}"
  echo -e "${GREEN}✓ Snapshots are stored in separate @snapshots subvolume (not nested in @)${ENDCOLOR}"
}

# Setup /opt/games permissions
setup_opt_games_permissions() {
  echo -e "Setting up /opt/games permissions...${ENDCOLOR}"
  sleep 2

  # Create a 'games' group if it doesn't exist
  if ! getent group games >/dev/null; then
    sudo groupadd games
    echo -e "${GREEN}✓ Created 'games' group${ENDCOLOR}"
  else
    echo -e "${YELLOW}⚠ 'games' group already exists${ENDCOLOR}"
  fi

  # Add the current user to the 'games' group
  sudo usermod -aG games "$USER"
  # Change ownership of /opt/games to root:games
  sudo chown root:games /opt/games
  echo -e "${GREEN}✓ Changed ownership of /opt/games to root:games${ENDCOLOR}"

  # Set permissions to 2775 (rwxrwsr-x)
  sudo chmod 2775 /opt/games
  echo -e "${GREEN}✓ Set permissions of /opt/games to 2775${ENDCOLOR}"

  echo -e "${GREEN}✓ /opt/games permissions setup complete${ENDCOLOR}"
}

# Silence grub boot messages
silence_grub() {
  echo -e "${GREEN}Silencing GRUB boot messages...${ENDCOLOR}"
  sleep 2

  if [[ -f /etc/default/grub ]]; then
    # Backup grub config
    sudo cp /etc/default/grub /etc/default/grub.backup-"$(date +%Y%m%d-%H%M%S)"
    echo -e "${GREEN}✓ Backed up /etc/default/grub${ENDCOLOR}"

    # Modify GRUB timeout
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub

    # Modify GRUB timeout menu
    sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub

    # Function to prepend parameter if missing
    prepend_param_if_missing() {
      local param="$1"
      if ! grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | grep -q "$param"; then
        sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/=\"\(.*\)\"/=\"$param \1\"/" /etc/default/grub
      fi
    }

    # Prepend rd.systemd.show_status=false first (so it ends up last in the final order)
    if grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | grep -q "rd\.systemd\.show_status"; then
      sudo sed -i 's/rd\.systemd\.show_status=[^ "]*/rd.systemd.show_status=false/' /etc/default/grub
    else
      prepend_param_if_missing "rd.systemd.show_status=false"
    fi

    # Prepend splash
    prepend_param_if_missing "splash"

    # Prepend quiet (will be first)
    prepend_param_if_missing "quiet"

    # Update GRUB
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "${GREEN}✓ Updated GRUB configuration${ENDCOLOR}"
    echo -e "${GREEN}✓ GRUB boot messages silenced${ENDCOLOR}"
  else
    echo -e "${RED}✗ Warning: /etc/default/grub not found${ENDCOLOR}"
  fi
}

# Set up wayland sddm
setup_sddm_wayland() {
  echo -e "${GREEN}Setting up SDDM Wayland configuration...${ENDCOLOR}"

  # Create the directory if it doesn't exist
  sudo mkdir -p /etc/sddm.conf.d

  # Write the configuration to the file
  sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null << 'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
EOF

  echo -e "${GREEN}SDDM Wayland configuration written to /etc/sddm.conf.d/10-wayland.conf${ENDCOLOR}"
}

# Clean up
clean_up() {
  # Hide or delete README.md based on whether installed as bare repository or not
  # Check if the bare repository exists and is readable
  if [ -e "$FILE_PATH/dotfiles" ]; then
    echo -e "${GREEN}Hiding README.md and Installers in ~/.config/scripts${ENDCOLOR}."
    echo -e "${GREEN}moving...${ENDCOLOR}"
    mv README.md ~/.config/scripts/README.md || error_exit "${YELLOW}Failed to hide README.md${ENDCOLOR}."
    git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" assume-unchanged README.md || error_exit "${YELLOW}Failed to ignore changes to README.md and Installers${ENDCOLOR}."
  else
    echo -e "${YELLOW}Deletinging README.md Installers and .git folder${ENDCOLOR}."
    echo -e "${GREEN}Removing...${ENDCOLOR}"
    rm -rf README.md install.sh .git || error_exit "${YELLOW}Failed to remove README.md Installers and .git folder${ENDCOLOR}."
  fi
  # Add fastfetch to profile.d for all users
  echo 'fastfetch' | sudo tee /etc/profile.d/fastfetch.sh >/dev/null
}

exit_script() {
  echo -e "${GREEN}Setup Complete! Press Ctrl+D or wait 5 seconds for changes to take effect${ENDCOLOR}."

  sleep 5

  exec zsh -l
}

###############################################################################
#                                                                             #
#                              Main Function                                  #
#                                                                             #
###############################################################################
main() {
  echo -e "${GREEN}Starting OurDots installation...${ENDCOLOR}"

  #############################################################################
  #                                                                           #
  #                           Detect system                                   #
  #                                                                           #
  #############################################################################
  detect_system

  #############################################################################
  #                                                                           #
  #                 Update and upgrade system packages                        #
  #                                                                           #
  #############################################################################
  update_repos
  upgrade_packages

  # Install basic packages
  install_package_list "${PACKAGES[@]}"

  # Set up dotfiles
  setup_dotfiles

  # Install mise and mise packages
  install_mise
  install_mise_packages

  # Install WezTerm
  install_wezterm

  # Install logo-ls
  install_logo-ls

  # Install Neovim Nightly
  install_neovim_nightly
  install_neovim_extras

  # Install LazyGit
  install_lazygit

  # Install GitHub CLI
  install_gh

  # Set up Git configuration
  git_config

  # Set up Oh My Zsh
  install_oh_my_zsh

  # Install FiraCode Nerd Font
  install_firacode_nerd_font

  # Set uop btrfs config
  create_btrfs_subvolumes

  # Set up Snapper
  setup_snapper

  # Set up /opt/games permissions
  setup_opt_games_permissions

  # Silence grub boot messages
  silence_grub

  # Set up SDDM for Wayland
  setup_sddm_wayland

  # Clean up setup files
  clean_up

  # Finish Setup
  exit_script
}

# Run main function
main "$@"
