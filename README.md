# dotfiles

## Omarchy / Arch Linux での導入

`WSL2-on-Ubuntu` から派生した `omarchy` ブランチです。

```bash
bash scripts/setup-omarchy.sh
exec zsh
```

CLI は Omarchy の `omarchy pkg add`（pacman）で導入し、既存の mise 設定・
Node/Codex を維持します。この OS では `setup-ubuntu.sh` / `setup-mise.sh` を実行しません。
zsh の vi 操作、補完、履歴検索、候補表示と構文強調を利用できます。
Omarchy の環境初期化も読み込みます。
プロンプト・配色は Omarchy の既存の `~/.config/starship.toml` を継承します。
ls の色もセッション設定またはシステムの dircolors を使用します。
既存の `.zshrc` を変更する場合は、
`~/.local/state/dotfiles/backups/` に退避します。
`--config-only` はパッケージ導入済みの環境用です。

ログインシェルを変える場合は `chsh -s /usr/bin/zsh` 後に再ログインします。
デスクトップと既存の tmux / Neovim 設定は維持します。
旧 `.tmux.conf` は古い tmux 構文を含むため自動適用しません。
検証: `bash mise-tasks/check`、`zsh -ic 'bash mise-tasks/doctor'`。

以下は元の Ubuntu / WSL 向け手順です。

Ubuntu / WSL と zsh 向けの開発環境。vi キーバインドを使います。

## 導入

リポジトリ内で次を実行してください。sudo の認証が必要です。

```bash
bash scripts/setup-ubuntu.sh
```

apt は zsh・Git・curl・証明書・ビルドツールと zsh 補助プラグインに使用します。
開発 CLI（bat・delta・eza・fd・fzf・gh・hexyl・jq・procs・ripgrep・ShellCheck・Starship・tmux・zoxide）は
mise で管理します。`~/.zshrc` が未作成ならこのリポジトリへのリンクを作ります。
既存の別の `.zshrc` は上書きしません。繰り返し実行できます。

既に Ubuntu 側の準備が済んでいる場合、sudo 不要で mise への移行だけ実行できます。

```bash
bash scripts/setup-mise.sh
exec zsh
```

`mise.toml` を `~/.config/mise/config.toml` にリンクします（`XDG_CONFIG_HOME` に対応）。
既存の別の mise 設定がある場合は停止するので、内容を統合してください。
旧 apt 版や単体インストール版は削除せず、mise が管理する実行ファイルを優先します。
既に起動している tmux サーバーは旧バイナリのままなので、セッション終了後に再起動してください。

言語ランタイムも mise に統一します。プロジェクトのディレクトリで必要なものを指定します。

```bash
mise use node@24       # プロジェクトの mise.toml に記録
mise use python@3.14   # Python を使うプロジェクトで実行
mise use ruby@3.4      # Ruby を使うプロジェクトで実行
mise install          # 設定されたバージョンを導入
mise ls               # 使用バージョンと設定元を確認
mise upgrade          # 設定のバージョン指定に従って更新
```

全プロジェクト共通のランタイムは `mise use --global` で指定できます。
グローバル設定はリポジトリにリンクしているため、その変更も dotfiles の差分になります。
Ruby などソースビルドするランタイムは追加のシステムライブラリが必要な場合があります。

標準シェルの登録は `getent passwd "$USER"` で確認できます。
zsh 以外なら `chsh -s /usr/bin/zsh` を実行して再ログインしてください。
VS Code で bash が開く場合は「Terminal: Select Default Profile」で zsh を選択し、
新しいターミナルを開いてください。

## 操作

Starship の表示は元の `.zshrc` を踏襲した 1 行形式です。
`ユーザー名@ホスト名` は緑、現在のパスは黄色、入力記号は赤で表示します。
入力記号は一般ユーザーで `%`、特権ユーザーで `#`、右側は時刻です。
パスはホームを `~` とし、途中のディレクトリは省略しません。
パスの後ろに Git ブランチ・変更状態と、プロジェクトに応じた言語バージョン
（Node.js・Python・Rust・Go・Ruby）を表示します。
専用フォントは不要です。表示は `starship.toml` で調整できます。

セットアップは `~/.config/starship.toml`（`XDG_CONFIG_HOME` 設定時はその配下）に
リンクを作ります。既存の設定は保持します。
Starship も mise 管理です。元の配色・1 行表示・Git と言語情報を維持しています。

| 操作・コマンド | 用途 |
| --- | --- |
| Tab | 補完候補の選択、大文字・小文字を無視した補完 |
| Ctrl-R | fzf で履歴検索 |
| Ctrl-T | fzf でファイルを選択して入力 |
| Alt-C | fzf でディレクトリを選んで移動 |
| Ctrl-F（vi 挿入モード） | 薄く表示された入力候補を採用 |
| Ctrl-P / Ctrl-N（vi 挿入モード） | 入力した接頭辞から履歴検索 |
| `z 名前` / `zi 名前` | 訪問履歴を使った移動 / 対話的な移動 |
| `rg パターン` | ファイル内容の検索 |
| `fd 名前` | ファイル名の検索（Ubuntu の fdfind にも対応） |
| `ls` / `ll` | eza による一覧 / 隠しファイルを含む一覧 |
| `cat ファイル` | bat による色付き表示。通常の cat は `command cat` |
| `gs` / `gl` / `gd` | Git 状態 / 履歴 / delta による差分表示 |
| `jq . ファイル.json` | JSON の整形 |

fzf のファイル検索は隠しファイルを含み、`.git` と ignore 対象を除外します。
任意ツールがない場合も zsh は起動できます。補助プラグインの自動読み込みは
Ubuntu パッケージの配置を前提とします。

`~/.zshrc.include` にマシン固有の設定を置けます。PATH に `~/.local/bin` を含めています。
pyenv・rbenv・anyenv・hsenv・Roswell 用の PATH 追加と初期化は廃止し、
`mise activate zsh` でプロジェクトごとの環境を適用します。
Git のユーザー情報・グローバル設定は変更しません。

## 確認

このリポジトリ内で、次のコマンドを実行してください。

```bash
mise run check
```

`mise-tasks/check` が Bash スクリプトの構文と ShellCheck、`.zshrc` の構文、
未ステージ・ステージ済み差分の空白エラーを検証します。
ShellCheck は zsh 非対応のため `.zshrc` には実行しません。

実際の開発環境が正しくセットアップされているかは自己診断できます。

```bash
mise run doctor
```

`doctor` は WSL / Ubuntu、必須コマンド、mise 管理の開発 CLI、dotfiles への設定リンク、
ログインシェル、`.zshrc` の構文、GitHub CLI の認証、SSH agent などを確認します。
必須項目の欠落はエラー、推奨項目は警告として表示します。

## GitHub CLI の認証

WSL のターミナルで一度実行してください。ログインにはブラウザでの操作が必要です。

```bash
mise exec -- gh auth login --hostname github.com --git-protocol https --web
mise exec -- gh auth setup-git --hostname github.com
mise exec -- gh auth status
```

`gh auth setup-git` は Git の認証ヘルパーを設定します。
以後は `git push`、`gh pr create`、`gh pr checks` などを利用できます。
コミットの名前・メールアドレスは GitHub のログインとは別の設定です。

## 参照

- [mise の使い方](https://mise.jdx.dev/getting-started)

- [Starship の公式設定リファレンス](https://starship.rs/config/)
- [fzf のシェル連携](https://github.com/junegunn/fzf#setting-up-shell-integration)
- [zoxide の設定](https://github.com/ajeetdsouza/zoxide#installation)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting の読み込み順](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)
