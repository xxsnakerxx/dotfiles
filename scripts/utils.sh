#!/bin/bash

reset_color=$(tput sgr0 2>/dev/null || true)
IS_CI=${CI:-${IS_CI:-false}}

info() {
  printf "%s💡 %s%s\n" "$(tput setaf 4 2>/dev/null || echo '')" "$1" "$reset_color"
}

success() {
  printf "%s✅ %s%s\n" "$(tput setaf 2 2>/dev/null || echo '')" "$1" "$reset_color"
  printf "\n"
}

err() {
  printf "%s❌ %s%s\n" "$(tput setaf 1 2>/dev/null || echo '')" "$1" "$reset_color"
}

warn() {
  printf "%s⚠️ %s%s\n" "$(tput setaf 3 2>/dev/null || echo '')" "$1" "$reset_color"
}

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

stow_files() {

  info "Removing existing dotfiles that would conflict with stow..."
  ignore_list=""
  [ -f .stow-local-ignore ] && ignore_list=$(grep -v '^#' .stow-local-ignore | grep -v '^[[:space:]]*$' || true)
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
