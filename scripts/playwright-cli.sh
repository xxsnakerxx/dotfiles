# shellcheck shell=bash
install_playwright_cli() {
  install_if_missing "playwright-cli" "command -v playwright-cli" "npm install -g @playwright/cli"
  playwright-cli install --skills claude --global
  playwright-cli install --skills agents --global
}

update_playwright_cli() {
  info "Upgrading playwright-cli..."
  npm update -g @playwright/cli
  playwright-cli install --skills claude --global
  playwright-cli install --skills agents --global
  success "playwright-cli upgraded"
}
