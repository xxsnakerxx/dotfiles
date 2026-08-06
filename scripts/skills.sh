install_skills() {
  info "Installing skills from .skills.json..."
  local skills_file="$DOTFILES_ROOT/.skills.json"

  for row in $(jq -c '.sources[]' "$skills_file"); do
    local package
    local agents
    local skill_flags=()

    package=$(echo "$row" | jq -r '.package')
    agents=$(jq -r '.agents | join(",")' "$skills_file")

    while IFS= read -r skill; do
      skill_flags+=(-s "$skill")
    done <<< "$(echo "$row" | jq -r '.skills[]')"

    npx skills add "$package" -g "${skill_flags[@]}" -a "$agents" -y
  done

  success "Skills installed"
}
