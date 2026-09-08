install_skills() {
  info "Installing skills from .skills.json..."
  local skills_file="$DOTFILES_ROOT/.skills.json"
  local row package agents skill
  local skill_flags=()

  for row in $(jq -c '.sources[]' "$skills_file"); do
    skill_flags=()

    package=$(echo "$row" | jq -r '.package')
    agents=$(jq -r '.agents | join(",")' "$skills_file")

    while IFS= read -r skill; do
      skill_flags+=(-s "$skill")
    done <<< "$(echo "$row" | jq -r '.skills[]')"

    npx skills add "$package" -g "${skill_flags[@]}" -a "$agents" -y
  done

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
  local skills_file="$DOTFILES_ROOT/.skills.json"
  local lock_file agents row package skill
  local missing_flags=()

  agents=$(jq -r '.agents | join(",")' "$skills_file")
  lock_file="$(skill_lock_file)"

  if [[ ! -f "$lock_file" ]]; then
    warn "No skill lockfile at $lock_file; installing all from manifest"
    install_skills
    return
  fi

  for row in $(jq -c '.sources[]' "$skills_file"); do
    package=$(echo "$row" | jq -r '.package')
    missing_flags=()

    while IFS= read -r skill; do
      missing_flags+=(-s "$skill")
    done < <(comm -23 \
      <(echo "$row" | jq -r '.skills[]' | sort) \
      <(jq -r --arg p "$package" '.skills | to_entries[] | select(.value.source == $p) | .key' "$lock_file" | sort))

    if [[ ${#missing_flags[@]} -gt 0 ]]; then
      info "Installing missing skills from $package"
      npx skills add "$package" -g "${missing_flags[@]}" -a "$agents" -y
    fi
  done

  success "Skills synced"
}
