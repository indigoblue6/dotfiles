#!/usr/bin/env bash
# sudo 不要の mise と開発 CLI の導入。
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v mise >/dev/null 2>&1; then
  installer="$(mktemp)"
  trap 'rm -f -- "$installer"' EXIT
  curl -fsSL https://mise.run -o "$installer"
  sh "$installer"
fi

mkdir -p "$config_dir/mise"
if [[ ! -e "$config_dir/mise/config.toml" && ! -L "$config_dir/mise/config.toml" ]]; then
  ln -s "$repo_dir/mise.toml" "$config_dir/mise/config.toml"
elif [[ ! "$config_dir/mise/config.toml" -ef "$repo_dir/mise.toml" ]]; then
  printf '%s\n' '既存の mise/config.toml があります。dotfiles/mise.toml の tools を統合してから再実行してください。' >&2
  exit 1
fi

mise trust "$repo_dir/mise.toml"
# 呼び出し元プロジェクトのツールはインストールしない。
(cd "$HOME" && mise install)
printf '%s\n' 'mise と開発 CLI の導入完了。exec zsh で反映してください。'
