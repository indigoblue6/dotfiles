# dotfiles

Ubuntu / WSL と zsh 向けの開発環境。vi キーバインドを使います。

## 導入

リポジトリ内で次を実行してください。sudo の認証が必要です。

```bash
bash scripts/setup-ubuntu.sh
```

スクリプトは apt でツールを導入し、`~/.zshrc` が未作成ならこのリポジトリへの
シンボリックリンクを作ります。既存の別の `.zshrc` は上書きしません。
繰り返し実行できます。言語別のランタイムはプロジェクトに合わせて別途導入します。

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
この環境では公式インストーラーで `~/.local/bin/starship` に導入済みです。
再構築時は Ubuntu のセットアップスクリプトで apt 版を導入します。
両方ある場合は PATH の順序によりユーザー領域の版が優先されます。

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
既存の pyenv / rbenv はインストール済みの場合のみ初期化します。
Git のユーザー情報・グローバル設定は変更しません。

## 確認

```bash
bash -n scripts/setup-ubuntu.sh
zsh -n .zshrc
zsh -ic 'print -r -- "zsh startup OK: $ZSH_VERSION"'
```

## 参照

- [Starship の公式設定リファレンス](https://starship.rs/config/)
- [fzf のシェル連携](https://github.com/junegunn/fzf#setting-up-shell-integration)
- [zoxide の設定](https://github.com/ajeetdsouza/zoxide#installation)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting の読み込み順](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)
