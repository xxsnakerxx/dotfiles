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

sync_skills() {
  info "Syncing skills from .skills.json..."
  local skills_file="$DOTFILES_ROOT/.skills.json"
  local agents parsed row package desired installed to_add to_remove skill
  local add_flags=()
  local remove_flags=()

  agents=$(jq -r '.agents | join(",")' "$skills_file")

  parsed=$(mktemp)
  npx skills list -g 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | \
    awk '/^  [^ ]/ {name=$1} /Source: / {print name, $NF}' > "$parsed"

  for row in $(jq -c '.sources[]' "$skills_file"); do
    package=$(echo "$row" | jq -r '.package')

    desired=$(echo "$row" | jq -r '.skills[]' | sort)
    installed=$(awk -v p="$package" '$2==p {print $1}' "$parsed" | sort)

    to_add=$(comm -23 <(echo "$desired") <(echo "$installed"))
    to_remove=$(comm -13 <(echo "$desired") <(echo "$installed"))

    if [[ -n "$to_add" ]]; then
      add_flags=()
      while IFS= read -r skill; do
        [[ -n "$skill" ]] && add_flags+=(-s "$skill")
      done <<< "$to_add"
      npx skills add "$package" -g "${add_flags[@]}" -a "$agents" -y
    fi

    if [[ -n "$to_remove" ]]; then
      remove_flags=()
      while IFS= read -r skill; do
        [[ -n "$skill" ]] && remove_flags+=(-s "$skill")
      done <<< "$to_remove"
      npx skills remove -g "${remove_flags[@]}" -y
    fi
  done

  rm -f "$parsed"
  success "Skills synced"
}
