link_cursor_settings() {
  info "Linking Cursor settings..."

  local cursor_settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"

  if [ -L "$cursor_settings_file" ]; then
    warn "Cursor settings file is a symbolic link; skipping"
    return 0
  fi

  mv "$cursor_settings_file" "$cursor_settings_file.backup"

  ln -s "$DOTFILES_ROOT/.cursor_settings.json" "$cursor_settings_file"

  success "Cursor settings linked successfully"
}