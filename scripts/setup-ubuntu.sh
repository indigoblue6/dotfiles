#!/usr/bin/env bash
# Ubuntu 用。既存の設定は置き換えず、必要なツールと .zshrc を準備する。
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  zsh git curl ca-certificates build-essential \
  ripgrep fd-find fzf zoxide jq git-delta \
  eza bat hexyl procs tmux starship \
  zsh-autosuggestions zsh-syntax-highlighting

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  ln -s "$repo_dir/.zshrc" "$HOME/.zshrc"
elif [[ "$HOME/.zshrc" -ef "$repo_dir/.zshrc" ]]; then
  printf '%s\n' '.zshrc は接続済みです。'
else
  printf '%s\n' '既存の ~/.zshrc を保持しました。dotfiles/.zshrc の設定を手動で取り込んでください。'
fi

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$config_dir"
if [[ ! -e "$config_dir/starship.toml" && ! -L "$config_dir/starship.toml" ]]; then
  ln -s "$repo_dir/starship.toml" "$config_dir/starship.toml"
fi

zsh -n "$repo_dir/.zshrc"
printf '%s\n' '導入完了。新しい zsh を開いてください。'
