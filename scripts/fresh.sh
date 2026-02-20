#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/utils.sh
. scripts/brew.sh
. scripts/zsh.sh
. scripts/asdf.sh
. scripts/macos.sh

print_logo

yes_no_input "Are you sure you want to continue?" "exit"

install_xcode_clt
install_brew
install_stow
stow_files
go_home
install_oh_my_zsh

info "Print HOME directory: $HOME"
ls -la "$HOME"

install_brew_bundle
install_asdf_tools

if yes_no_input "Do you want to setup macOS?"; then
  setup_macos
fi

if [ "$IS_CI" == "false" ] && yes_no_input "Do you want to run cleanup?"; then
  clean_up
fi

if [ "$IS_CI" == "false" ] && yes_no_input "Do you want to update the system?"; then
  update_system
fi

success "Fresh setup completed successfully"