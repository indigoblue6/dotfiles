#!/usr/bin/env bash
# Omarchy は CLI を pacman、言語ランタイムを既存の mise で管理する。
set -euo pipefail
# shellcheck disable=SC1091
source /etc/os-release
[[ "$ID" == omarchy ]] || { echo 'Omarchy 専用です。' >&2; exit 1; }
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${1:-}" != --config-only ]]; then
  omarchy pkg add zsh git curl mise zsh-autosuggestions zsh-syntax-highlighting \
    bat git-delta eza fd fzf github-cli hexyl jq procs ripgrep shellcheck starship tmux zoxide
fi
for cmd in zsh mise starship; do command -v "$cmd" >/dev/null; done
zsh -n "$repo_dir/.zshrc"
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
link_config() {
  local source_file="$1" target="$2"
  [[ "$target" -ef "$source_file" ]] && return 0
  mkdir -p "$(dirname -- "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_dir"
    cp -a -- "$target" "$backup_dir/$(basename -- "$target")"
    rm -- "$target"
  fi
  ln -s -- "$source_file" "$target"
}
link_config "$repo_dir/.zshrc" "$HOME/.zshrc"
printf '設定完了。バックアップ（変更前のファイルがある場合）: %s\n' "$backup_dir"
printf '%s\n' 'exec zsh で起動。標準シェルも変更する場合: chsh -s /usr/bin/zsh'
