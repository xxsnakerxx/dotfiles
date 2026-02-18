
# If you come from bash you might have to change your $PATH.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-completions zsh-npm-scripts-autocomplete brew asdf)

fpath+=$HOME/.zsh/pure

autoload -U compinit && compinit
autoload -U promptinit; promptinit

source $ZSH/oh-my-zsh.sh

prompt pure

export ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export REACT_EDITOR=code
export EDITOR=nano

export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"

alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NODE_OPTIONS=--max-old-space-size=4096

# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# go
export PATH=$PATH:$(go env GOPATH)/bin

if [ -f .zshrc.local.sh ]; then
    source .zshrc.local.sh
fi
