install_asdf_tools() {
  info "Installing ASDF tools..."

  asdf plugin add nodejs
  asdf plugin add ruby
  asdf plugin add python

  asdf install

  success "ASDF tools installed"
}