#!/bin/bash

# デフォルトの設定
DEFAULT_CONFIG=(
    'node_modules'
    '.git'
    '.cache'
    'vendor'
    'dist'
    'build'
)

# 設定ファイルのパス
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dir_output"
CONFIG_FILE="${CONFIG_DIR}/config"

# 設定を読み込む
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        EXCLUDE_PATTERNS=("${DEFAULT_CONFIG[@]}")
    fi
}

# 設定を保存する
save_config() {
    mkdir -p "$CONFIG_DIR"

    echo "# dir_output exclude patterns" > "$CONFIG_FILE"
    echo "EXCLUDE_PATTERNS=(" >> "$CONFIG_FILE"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        echo "    '$pattern'" >> "$CONFIG_FILE"
    done
    echo ")" >> "$CONFIG_FILE"
}

# 設定を編集する
edit_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        save_config
    fi

    ${EDITOR:-vim} "$CONFIG_FILE"
    echo "設定を更新しました。"
}
