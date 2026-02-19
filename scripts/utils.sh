#!/bin/bash

reset_color=$(tput sgr0 2>/dev/null || true)

info() {
  printf "%s💡 %s%s\n" "$(tput setaf 4 2>/dev/null || echo '')" "$1" "$reset_color"
}

success() {
  printf "%s✅ %s%s\n" "$(tput setaf 2 2>/dev/null || echo '')" "$1" "$reset_color"
}

err() {
  printf "%s❌ %s%s\n" "$(tput setaf 1 2>/dev/null || echo '')" "$1" "$reset_color"
}

warn() {
  printf "%s⚠️ %s%s\n" "$(tput setaf 3 2>/dev/null || echo '')" "$1" "$reset_color"
}

yes_no_input() {
  read -p "$1 (y/n): " answer
  if [ "$answer" != "y" ]; then
    if [ "${2:-}" == "exit" ]; then
      err "Aborting..."
      exit 1
    fi
    return 1
  fi
  return 0
}

go_home() {
  cd ~
}

install_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    warn "Xcode CLT already installed"
  else
    info "Installing Xcode CLT..."
    xcode-select --install
    sudo xcodebuild -license accept
    success "Xcode CLT installed successfully"
  fi
}

update_system() {
  sudo softwareupdate -i -a
}

stow_files() {
  info "Stowing files..."
  stow .
  success "Files stowed"
}
