#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

_dim=$(tput dim 2>/dev/null || true)
_yellow=$(tput setaf 3 2>/dev/null || true)
_green=$(tput setaf 2 2>/dev/null || true)
_reset=$(tput sgr0 2>/dev/null || true)

_info()  { printf "\n%s🟡 %s%s\n" "$_yellow" "$*" "$_reset"; }
_done()  { printf "\n%s✅ %s%s\n" "$_green"  "$*" "$_reset"; }
_info "Brew upgrade..."
brew upgrade --greedy

_info "Brew bundle..."
brew bundle --file="$DOTFILES_ROOT/.brewfile"

_info "Skills update..."
npx skills update -g -y

_info "npm global update..."
npm update -g

_done "dotup complete"
