link_cursor_settings() {
  info "Linking Cursor settings..."

  local cursor_settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"

  if [ ! -f "$cursor_settings_file" ]; then
    warn "Cursor settings file does not exist; skipping"
    return 0
  fi

  if [ -L "$cursor_settings_file" ]; then
    warn "Cursor settings file is a symbolic link; skipping"
    return 0
  fi

  mv "$cursor_settings_file" "$cursor_settings_file.backup"

  ln -s "$DOTFILES_ROOT/cursor.json" "$cursor_settings_file"

  success "Cursor settings linked successfully"
}