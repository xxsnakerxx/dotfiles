# shellcheck shell=bash
install_brew() {
  # shellcheck disable=SC2016 # defer expansion to eval
  install_if_missing "Homebrew" \
    "command -v brew" \
    '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && eval "$(/opt/homebrew/bin/brew shellenv)"'
}

install_stow() {
  install_if_missing "Stow" "command -v stow" "brew install stow"
}

install_brew_bundle() {
  info "Installing Homebrew bundle..."

  brew bundle install --file="~/.brewfile"

  success "Homebrew bundle installed successfully"
}