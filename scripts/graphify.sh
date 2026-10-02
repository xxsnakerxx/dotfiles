install_graphify() {
  if ! command -v uv >/dev/null 2>&1; then
    info "Installing uv..."
    brew install uv
    success "uv installed"
  fi

  if ! command -v graphify >/dev/null 2>&1; then
    info "Installing graphify..."
    uv tool install "graphifyy[leiden]"
    success "graphify installed"
  else
    warn "graphify already installed"
  fi
}

update_graphify() {
  info "Upgrading graphify..."
  uv tool upgrade graphifyy
  success "graphify upgraded"
}
