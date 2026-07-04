install_skills() {
  info "Installing skills from .skills.json..."
  local skills_file="$DOTFILES_ROOT/.skills.json"

  for row in $(jq -c '.sources[]' "$skills_file"); do
    local package
    local skill_list
    local agents

    package=$(echo "$row" | jq -r '.package')
    skill_list=$(echo "$row" | jq -r '.skills | join(",")')
    agents=$(jq -r '.agents | join(",")' "$skills_file")

    npx skills add "$package" -g --skill "$skill_list" -a "$agents" -y
  done

  success "Skills installed"
}
