#!/bin/bash

# ヘルプの表示
show_help() {
    cat << EOF
使用方法: dir_output [オプション]

オプション:
    -h, --help          このヘルプを表示
    -e, --edit-config   除外パターンの設定を編集
    -v, --version       バージョンを表示

説明:
    現在のディレクトリ構成をMarkdownファイルとして出力します。
    除外パターンは ~/.config/dir_output/config で設定できます。
EOF
}

# 言語の判定
get_language() {
    local filename="$1"
    local ext="${filename##*.}"

    # 拡張子を小文字に変換
    ext="${ext,,}"

    case "$ext" in
        # Shell scripts
        sh|bash|zsh) echo "bash" ;;

        # Web development
        js|jsx) echo "javascript" ;;
        ts|tsx) echo "typescript" ;;
        html|htm) echo "html" ;;
        css) echo "css" ;;
        scss|sass) echo "scss" ;;

        # Programming languages
        py) echo "python" ;;
        rb) echo "ruby" ;;
        php) echo "php" ;;
        java) echo "java" ;;
        c) echo "c" ;;
        cpp|cc|cxx) echo "cpp" ;;
        cs) echo "csharp" ;;
        go) echo "go" ;;
        rs) echo "rust" ;;
        swift) echo "swift" ;;
        kt|kts) echo "kotlin" ;;

        # Data formats
        json) echo "json" ;;
        yml|yaml) echo "yaml" ;;
        xml) echo "xml" ;;
        md|markdown) echo "markdown" ;;
        toml) echo "toml" ;;

        # Configuration files
        conf|cfg) echo "config" ;;
        ini) echo "ini" ;;
        env) echo "env" ;;

        # Database
        sql) echo "sql" ;;

        # Docker
        dockerfile) echo "dockerfile" ;;

        # Default case
        *)
            if [[ "$filename" == "Dockerfile" ]]; then
                echo "dockerfile"
            elif [[ "$filename" == "Makefile" ]]; then
                echo "makefile"
            else
                echo "text"
            fi
            ;;
    esac
}

# Markdownファイルの生成
generate_markdown() {
    local output_file="$1"

    # eza用の除外パターン文字列を作成
    local eza_exclude=$(IFS='|'; echo "${EXCLUDE_PATTERNS[*]}")

    # find用の除外パターンを作成
    local find_exclude=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        find_exclude+=(-not -path "*/$pattern/*")
    done

    # Markdownファイルの作成開始
    echo "# Directory Contents" > "$output_file"

    # ディレクトリ構造の追加
    echo -e "\n## Directory Structure\n" >> "$output_file"
    echo '````text' >> "$output_file"
    eza -T -a -I "$eza_exclude" >> "$output_file"
    echo '````' >> "$output_file"

    # ファイル内容セクションの追加
    echo -e "\n## File Contents" >> "$output_file"

    # すべてのファイルを処理
    find . -type f "${find_exclude[@]}" -not -path "$output_file" | while read -r file; do
        if [[ -f "$file" && -s "$file" ]]; then
            local rel_path="$(realpath --relative-to=. "$file")"
            local lang=$(get_language "$file")
            echo -e "\n### $rel_path\n" >> "$output_file"
            echo -e "\`\`\`\`$lang" >> "$output_file"
            cat "$file" >> "$output_file"
            echo -e "\n\`\`\`\`" >> "$output_file"
        fi
    done
}
