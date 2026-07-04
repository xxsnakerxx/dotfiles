#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

. "$DOTFILES_ROOT/scripts/utils.sh"
. "$DOTFILES_ROOT/scripts/brew.sh"
. "$DOTFILES_ROOT/scripts/zsh.sh"
. "$DOTFILES_ROOT/scripts/asdf.sh"
. "$DOTFILES_ROOT/scripts/skills.sh"
. "$DOTFILES_ROOT/scripts/macos.sh"

print_logo

yes_no_input "Are you sure you want to continue?" "exit"

install_xcode_clt
setup_touch_id_for_sudo
install_brew
install_stow
stow_files
go_home
fix_permissions
install_oh_my_zsh
install_brew_bundle
install_skills
reload_zsh
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