#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/utils.sh
. scripts/brew.sh
. scripts/zsh.sh
. scripts/asdf.sh

info "Starting fresh setup..."

yes_no_input "Are you sure you want to continue?" "exit"

install_xcode_clt
install_brew
stow_files
go_home
install_oh_my_zsh
install_brew_bundle
install_asdf_tools

if yes_no_input "Do you want to update the system?"; then
  update_system
fi

success "Fresh setup completed successfully"