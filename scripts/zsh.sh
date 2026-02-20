install_oh_my_zsh() {
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed"

    install_oh_my_zsh_plugins
  else
    warn "Oh My Zsh already installed"
  fi
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

  if [[ ! -d "${ZSH_CUSTOM}/${name}" ]]; then
    info "Cloning ${name} plugin..."
    git clone "${url}" "${ZSH_CUSTOM}/${name}"
    success "${name} plugin cloned"
  else
    warn "${name} plugin already cloned"
  fi
}