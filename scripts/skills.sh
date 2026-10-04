manifest_agents()  { jq -r '.agents | join(",")' "$DOTFILES_ROOT/.skills.json"; }
manifest_sources() { jq -c '.sources[]'       "$DOTFILES_ROOT/.skills.json"; }

install_skills() {
  info "Installing skills from .skills.json..."
  export PATH="$HOME/.asdf/shims:$PATH"
  local agents row package skill
  local skill_flags=()

  agents=$(manifest_agents)

  while IFS= read -r row; do
    skill_flags=()

    package=$(jq -r '.package' <<< "$row")

    while IFS= read -r skill; do
      skill_flags+=(-s "$skill")
    done < <(jq -r '.skills[]' <<< "$row")

    npx skills add "$package" -g "${skill_flags[@]}" -a "$agents" -y
  done < <(manifest_sources)

  success "Skills installed"
}

skill_lock_file() {
  if [[ -n "${XDG_STATE_HOME:-}" ]]; then
    printf '%s/skills/.skill-lock.json\n' "$XDG_STATE_HOME"
  else
    printf '%s/.agents/.skill-lock.json\n' "$HOME"
  fi
}

sync_skills() {
  info "Syncing skills from .skills.json..."
  local lock_file agents row package skill
  local missing_flags=()

  agents=$(manifest_agents)
  lock_file="$(skill_lock_file)"

  if [[ ! -f "$lock_file" ]]; then
    warn "No skill lockfile at $lock_file; installing all from manifest"
    install_skills
    return
  fi

  while IFS= read -r row; do
    package=$(jq -r '.package' <<< "$row")
    missing_flags=()

    while IFS= read -r skill; do
      missing_flags+=(-s "$skill")
    done < <(comm -23 \
      <(jq -r '.skills[]' <<< "$row" | sort) \
      <(jq -r --arg p "$package" '.skills | to_entries[] | select(.value.source == $p) | .key' "$lock_file" | sort))

    if [[ ${#missing_flags[@]} -gt 0 ]]; then
      info "Installing missing skills from $package"
      npx skills add "$package" -g "${missing_flags[@]}" -a "$agents" -y
    fi
  done < <(manifest_sources)

  success "Skills synced"
}
