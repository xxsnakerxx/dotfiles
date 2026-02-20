install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed successfully"
  else
    warn "Homebrew already installed"
  fi
}

install_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    info "Installing Stow..."
    brew install stow
    success "Stow installed successfully"
  else
    warn "Stow already installed"
  fi
}

install_brew_bundle() {
  info "Installing Homebrew bundle..."
  brew bundle
  success "Homebrew bundle installed successfully"
}