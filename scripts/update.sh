#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

. "$DOTFILES_ROOT/scripts/utils.sh"
. "$DOTFILES_ROOT/scripts/skills.sh"
. "$DOTFILES_ROOT/scripts/graphify.sh"

info "Brew upgrade..."
brew upgrade --greedy

info "Brew bundle..."
brew bundle --verbose

info "Skills sync (install missing from .skills.json)..."
sync_skills

info "Skills update (pull latest versions)..."
npx skills update -g -y

info "npm global update..."
npm update -g

info "Graphify upgrade..."
update_graphify

success "dotup complete"
