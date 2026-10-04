install_graphify() {
  install_if_missing "uv" "command -v uv" "brew install uv"
  install_if_missing "graphify" "command -v graphify" 'uv tool install "graphifyy[leiden]"'
}

update_graphify() {
  info "Upgrading graphify..."
  uv tool upgrade graphifyy
  success "graphify upgraded"
}
