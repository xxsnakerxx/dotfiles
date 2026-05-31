#!/bin/bash

_color_blue=$(tput setaf 4 2>/dev/null || true)
_color_green=$(tput setaf 2 2>/dev/null || true)
_color_red=$(tput setaf 1 2>/dev/null || true)
_color_yellow=$(tput setaf 3 2>/dev/null || true)
reset_color=$(tput sgr0 2>/dev/null || true)
IS_CI=${CI:-${IS_CI:-false}}

_print() { printf "%s%s %s%s\n" "$1" "$2" "$3" "$reset_color"; }

info()    { _print "$_color_blue"   "💡" "$1"; }
success() { _print "$_color_green"  "✅" "$1"; printf "\n"; }
err()     { _print "$_color_red"    "❌" "$1"; }
warn()    { _print "$_color_yellow" "⚠️" "$1"; }

yes_no_input() {
  if [ "$IS_CI" == "true" ]; then
    return 0
  fi

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

# Keep sudo timestamp fresh until the current script exits. Runs in background;
# when the parent process is gone the loop ends and the job exits (main script continues).
sudo_keepalive() {
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || break
  done 2>/dev/null &
}

setup_touch_id_for_sudo() {
  info "Setting up Touch ID for sudo..."

  if ! ls /usr/lib/pam/pam_tid.so* >/dev/null 2>&1; then
    warn "Touch ID not available on this machine; skipping Touch ID for sudo setup"
    return 0
  fi

  local template="/etc/pam.d/sudo_local.template"
  local sudo_local="/etc/pam.d/sudo_local"

  if [[ -f "$sudo_local" ]]; then
    warn "sudo_local already exists; skipping Touch ID for sudo setup"
    return 0
  fi

  sudo cp "$template" "$sudo_local"
  # Uncomment Touch ID line and fix pam_tid.s -> pam_tid.so if present
  sudo sed -i '' -e '/pam_tid/s/^# *//' -e 's/pam_tid\.s$/pam_tid.so/' "$sudo_local"

  success "Touch ID for sudo setup completed"
}

fix_permissions() {
  info "Fixing user home directory permissions..."
  chmod 700 ~
  success "User home directory permissions fixed"
}

stow_files() {
  info "Removing existing dotfiles that would conflict with stow..."
  ignore_list=$(grep -v '^#' .stow-local-ignore 2>/dev/null | grep -v '^[[:space:]]*$' || true)
  for name in * .[!.]* ..?*; do
    [ -e "$name" ] || continue
    [ "$name" = "." ] || [ "$name" = ".." ] && continue
    echo "$ignore_list" | grep -qFx "$name" && continue
    [ -e "$HOME/$name" ] && rm -rf "$HOME/$name"
  done

  info "Stowing files..."
  stow .
  success "Files stowed"
}

clean_up() {
  info "Cleaning up..."
  mo clean
  success "Cleanup completed"
}

reload_zsh() {
  info "Reloading Zsh..."

  zsh -i -c "source ~/.zshrc"

  success "Zsh reloaded"
}

print_logo() {
  echo "
 ######
 #     #  ####  ##### ###### # #      ######  ####
 #     # #    #   #   #      # #      #      #
 #     # #    #   #   #####  # #      #####   ####
 #     # #    #   #   #      # #      #           #
 #     # #    #   #   #      # #      #      #    #
 ######   ####    #   #      # ###### ######  ####

  "
}
