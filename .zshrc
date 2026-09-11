# 対話シェル専用。明示的に source された場合も非対話シェルには適用しない。
[[ -o interactive ]] || return

# Omarchy のセッション・ツール用 PATH を継承する。
if [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]]; then
  source /usr/share/omarchy/default/bash/env-bootstrap
fi

# 基本設定
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
bindkey -v

# PATH は zsh の配列で管理し、再読み込み時の重複を防ぐ。
typeset -U path
path=(
  "$HOME/.local/bin"
  $path
)
export PATH

# CLI の存在判定や Starship 初期化より前に mise の PATH を適用する。
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# プロンプト（zsh 標準の色指定を使用）
PROMPT='%F{green}%n@%m %F{yellow}%~ %F{red}%# %f'
PROMPT2='%F{red} %_ > %f'
RPROMPT='%T'
SPROMPT='%F{yellow}correct: %R -> %r ? [n,y,a,e] %f'
setopt transient_rprompt

# ディレクトリ移動・補完表示
setopt auto_cd auto_pushd pushd_ignore_dups
setopt list_packed list_types
# 新しい CLI 名を誤訂正しない。
unsetopt correct

# Omarchy ではセッションの色を継承し、未設定ならシステムの dircolors を使う。
if [[ -n ${OMARCHY_PATH:-} ]]; then
  if [[ -z ${LS_COLORS:-} ]] && (( $+commands[dircolors] )); then
    eval "$(dircolors -b)"
  fi
else
  export LSCOLORS=gxfxcxdxbxegedabagacag
  export LS_COLORS='di=36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;46'
fi
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# 代替ツールがある場合のみエイリアスを設定する。
# eza を優先し、従来の exa も利用可能。
if (( $+commands[eza] )); then
  alias ls='eza -lh'
elif (( $+commands[exa] )); then
  alias ls='exa -lh'
else
  case $OSTYPE in
    darwin*|freebsd*) alias ls='ls -lhG' ;;
    linux*) alias ls='ls -lh --color=auto' ;;
  esac
fi
if (( $+commands[bat] )); then
  alias cat='bat'
elif (( $+commands[batcat] )); then
  alias cat='batcat'
fi
(( $+commands[hexyl] )) && alias od='hexyl'
(( $+commands[procs] )) && alias ps='procs'
if (( ! $+commands[fd] && $+commands[fdfind] )); then
  alias fd='fdfind'
fi
alias ll='ls -a'
alias gs='git status --short --branch'
alias gl='git log --oneline --graph --decorate -20'
if (( $+commands[delta] )); then
  alias gd='git -c core.pager=delta diff'
else
  alias gd='git diff'
fi

# 履歴（既存の保存先と保存件数を維持）
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1100000
SAVEHIST=1000000
setopt hist_ignore_dups hist_reduce_blanks share_history extended_history
setopt hist_expire_dups_first hist_find_no_dups hist_save_no_dups

# vi 挿入モードで、入力済みの文字列から履歴を検索する。
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey -M viins '^P' history-beginning-search-backward-end
bindkey -M viins '^N' history-beginning-search-forward-end
bindkey -M viins '^R' history-incremental-search-backward

# 補完初期化。不適切な権限の補完ファイルは読み込まない。
autoload -Uz compinit
compinit -i

# 履歴・ファイルをあいまい検索（Ctrl-R / Ctrl-T / Alt-C）。
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border}"
  if (( $+commands[fd] || $+commands[fdfind] )); then
    if (( $+commands[fd] )); then
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
      export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
    else
      export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
      export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
    fi
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  # --zsh は fzf 0.48 以降。旧版は配布パッケージのスクリプトを使用。
  if _dotfiles_fzf_init=$(fzf --zsh 2>/dev/null); then
    eval "$_dotfiles_fzf_init"
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
  unset _dotfiles_fzf_init
fi

# よく使うディレクトリに z <名前>、対話選択は zi <名前>。
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

for _dotfiles_plugin in /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -r $_dotfiles_plugin ]] || continue
  source "$_dotfiles_plugin"
  # vi 挿入モードの Ctrl-F で履歴からの候補を採用。
  bindkey -M viins '^F' autosuggest-accept
  break
done
unset _dotfiles_plugin

# Starship があればプロンプトを切り替える。
# Omarchy が管理する既存の Starship 設定・配色を使用する。
if [[ -n ${OMARCHY_PATH:-} ]]; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
fi
if (( $+commands[starship] )); then
  # 元のプロンプトの %# と同じく、特権ユーザーでは # を表示する。
  export STARSHIP_PROMPT_CHARACTER="${(%):-%#}"
  eval "$(starship init zsh)"
fi

# マシン固有の設定。
if [[ -r "$HOME/.zshrc.include" ]]; then
  source "$HOME/.zshrc.include"
fi

# ウィジェットの定義後、最後に構文ハイライトを読み込む。
for _dotfiles_plugin in /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r $_dotfiles_plugin ]] || continue
  source "$_dotfiles_plugin"
  break
done
unset _dotfiles_plugin
