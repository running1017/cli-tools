# Directory Output Tool 仕様書

## 概要

ディレクトリの内容を LLM のプロンプト用にマークダウン形式で出力するツール。

## 機能要件

### 1. 基本機能

- ディレクトリ構造をツリー形式で出力
  - 除外パターンにマッチするもの以外はすべて（バイナリファイル含む）を表示
- ファイル内容の出力
  - 出力条件に合致するファイルの内容を言語に応じたシンタックスハイライト付きで出力

### 2. ファイル出力条件

以下のいずれかの条件に合致するファイルを出力対象とする：

#### 2.1 通常条件（以下のすべてを満たす）

1. MIME タイプ条件
   - text/\*
   - application/json
   - application/xml
   - application/x-yaml
2. フィルターパターン非該当
   - デフォルトフィルターパターンにマッチしない
   - オプションフィルターパターンにマッチしない
3. サイズ条件
   - 指定されたサイズ閾値以下

#### 2.2 強制包含条件

- 否定パターン（!で始まるパターン）にマッチする
  - この条件に合致する場合、他の条件（MIME タイプ、サイズ）に関わらず出力

### 3. 入力

#### 3.1 必須パラメータ

なし（デフォルトはカレントディレクトリ）

#### 3.2 オプショナルパラメータ

- 対象ディレクトリパス
  - 相対パスまたは絶対パス
  - チルダ(~)によるホームディレクトリ指定をサポート
- フィルターパターン（複数指定可）
  - .gitignore 形式のパターンをサポート
  - 除外/包含両方のパターンを指定可能
  - デフォルトパターンに追加して適用
- 出力ファイル名
- ファイルサイズ閾値
  - デフォルト: 1MB
- 探索深度
  - デフォルト: 無制限
  - 指定時は指定された深さまでを探索

### 4. パターンマッチング仕様

#### 4.1 パターン記法

.gitignore と同様の記法をサポート：

- 基本パターン
  - `*`: 0 個以上の任意の文字（ディレクトリ区切り文字を除く）
  - `?`: 任意の 1 文字（ディレクトリ区切り文字を除く）
  - `**`: 0 個以上のディレクトリ階層
- 特殊記法

  - `/` で始まるパターン: ルートディレクトリからの相対パス
  - `/` で終わるパターン: ディレクトリを指定
  - `!` で始まるパターン: 否定パターン（除外対象から除外）

- マッチング規則
  - デフォルトフィルターパターン、コマンドライン指定パターンの順に評価
  - 後に記述されたパターンが優先
  - より具体的なパターンが優先

#### 4.2 デフォルトフィルターパターン

```gitignore
# ビルド・依存関係
node_modules/
target/
dist/
build/
.next/
.nuxt/
vendor/
.gradle/
.idea/
.vscode/
coverage/

# パッケージマネージャーファイル
package-lock.json
yarn.lock
Cargo.lock
composer.lock
poetry.lock

# キャッシュ・一時ファイル
.cache/
.temp/
.tmp/
__pycache__/
*.pyc
.DS_Store
Thumbs.db

# ログ・デバッグファイル
*.log
*.debug

# バイナリ・メディアファイル
*.exe
*.dll
*.so
*.dylib
*.bin
*.dat
*.db
*.sqlite
*.sqlite3
*.ico
*.jpg
*.jpeg
*.png
*.gif
*.bmp
*.mp3
*.mp4
*.avi
*.mov
*.pdf

# バージョン管理システム
.git/
.svn/
.hg/

# 設定・メタデータ
.env.*
!.env.example
!.env.template
*.local
tsconfig.tsbuildinfo
.eslintcache
.stylelintcache
```

### 5. 出力

#### 5.1 出力形式

マークダウンファイル（UTF-8 エンコーディング）

#### 5.2 出力内容

1. ヘッダー（"# Directory Contents"）
2. ディレクトリ構造セクション

   - "## Directory Structure" というサブヘッダー
   - ツリー形式のディレクトリ構造（バイナリファイル含む）
   - バッククォート 4 つで囲まれたテキストブロック

3. ファイル内容セクション
   - "## File Contents" というサブヘッダー
   - バッククォート 4 つで囲まれたテキストブロック
   - 出力条件に合致するファイルについて：
     - ファイルパスをヘッダーとして表示
     - テキストファイルの場合：
       - ファイル内容をバッククォート 4 つで囲まれたコードブロックとして表示
       - 言語に応じたシンタックスハイライト指定
     - サイズ制限超過の場合：
       - "File is too large to display (X.XX MB > Y.YY MB size limit)" という
         メッセージを表示（X.XX は実際のサイズ、Y.YY は制限サイズ）

### 6. 言語判定

拡張子に基づく言語判定：

- Shell scripts: sh, bash, zsh
- Web: js, jsx, ts, tsx, html, htm, css, scss, sass
- Programming: py, rb, php, java, c, cpp, cc, cxx, cs, go, rs, swift, kt, kts
- Data formats: json, yml, yaml, xml, md, markdown, toml
- Config: conf, cfg, ini, env
- Database: sql
- Docker: dockerfile
- 特殊ファイル：
  - Dockerfile → dockerfile
  - Makefile → makefile
- その他 → text

### 7. エラー処理

#### 7.1 検証項目

- 出力先ディレクトリの存在確認
- 出力先ディレクトリの書き込み権限確認
- 必須オプション値の存在確認
- フィルターパターンの文法確認

#### 7.2 警告

- 既存の出力ファイルが存在する場合の上書き警告

### 8. コマンドライン引数

```text
dir_output [オプション] [ディレクトリ]

オプション：
    -h, --help                     ヘルプを表示（デフォルトフィルターパターンも表示）
    -f, --filter PATTERN           .gitignore形式のフィルターパターンを指定（複数指定可）
    -o, --output FILE             出力ファイル名を指定（デフォルト: ./directory_contents.md）
    -s, --max-size SIZE           出力対象とする最大ファイルサイズを指定（デフォルト: 1MB）
    -d, --max-depth DEPTH         探索する最大階層を指定（デフォルト: 無制限）
    -v, --version                 バージョンを表示

サイズ指定例：
    100K, 1M, 2G など（単位: K=キロバイト、M=メガバイト、G=ギガバイト）

フィルターパターン例：
    # 除外パターン
    dir_output -f "*.tmp"          # すべての.tmpファイルを除外
    dir_output -f "/logs/"         # ルートディレクトリ直下のlogsディレクトリを除外
    dir_output -f "**/test/"       # すべての階層のtestディレクトリを除外

    # 包含パターン（!で始まるパターン）
    dir_output -f "*.log" -f "!important.log"    # important.log以外のすべての.logファイルを除外
    dir_output -f "**/tmp/" -f "!tmp/keep.txt"   # tmp配下でkeep.txt以外を除外

    # 複数パターンの組み合わせ
    dir_output -f "*.log" -f "!important.log" -f "**/temp/" ~/project
```

### 9. パターン評価順序

1. デフォルトフィルターパターンの評価
2. コマンドライン指定のフィルターパターン（-f, --filter）の評価
   - パターンは指定順に評価
   - 後に指定されたパターンが優先
   - 否定パターン（!で始まるパターン）は、前のパターンの結果を修正

#### 9.1 評価例

```bash
# 基本的な使用例
dir_output -f "*.log"                    # すべての.logファイルを除外
dir_output -f "*.log" -f "!important.log" # important.log以外の.logファイルを除外

# デフォルトパターンとの組み合わせ
# デフォルト: .env.*を除外
dir_output -f "!.env.example"            # デフォルトの.env.*除外から.env.exampleのみ除外解除

# 複雑なパターンの例
dir_output \
    -f "*.log" \                         # すべての.logファイルを除外
    -f "!logs/*.log" \                   # logs/ディレクトリ内の.logファイルは含める
    -f "logs/temp/*.log" \               # ただしlogs/temp/内の.logファイルは除外
    ~/project

# ディレクトリ指定の例
dir_output \
    -f "/node_modules/" \                # ルートの/node_modules/を除外
    -f "**/test/" \                      # すべての階層のtestディレクトリを除外
    -f "!tests/fixtures/" \              # ただしtests/fixturesは残す
    .
```
