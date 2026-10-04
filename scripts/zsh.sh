install_oh_my_zsh() {
  install_if_missing "Oh My Zsh" '[[ -d "${HOME}/.oh-my-zsh" ]]' \
    'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && install_oh_my_zsh_plugins'
}

install_oh_my_zsh_plugins() {
  info "Installing Oh My Zsh plugins..."

  ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

  clone_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
  clone_zsh_plugin "https://github.com/zsh-users/zsh-completions" "zsh-completions"
  clone_zsh_plugin "https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete" "zsh-npm-scripts-autocomplete"

  success "Oh My Zsh plugins installed"
}

clone_zsh_plugin() {
  local url="$1"
  local name="$2"

  install_if_missing "${name} plugin" \
    "[[ -d \"${ZSH_CUSTOM}/plugins/${name}\" ]]" \
    "git clone \"${url}\" \"${ZSH_CUSTOM}/plugins/${name}\""
}