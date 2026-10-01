#!/usr/bin/env bash
# ==============================================================================
# Praat 日本語音声ツール プラグイン インストーラー (macOS / Linux)
# ==============================================================================

set -e

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OS_TYPE="$(uname -s)"
if [ "$OS_TYPE" = "Darwin" ]; then
    PRAAT_DIR="$HOME/Library/Preferences/Praat Prefs"
else
    if [ -d "$HOME/.config/praat" ]; then
        PRAAT_DIR="$HOME/.config/praat"
    else
        PRAAT_DIR="$HOME/.praat-dir"
    fi
fi

PLUGIN_DIR="$PRAAT_DIR/plugin_JapaneseTools"

echo "========================================================"
echo "  Praat 日本語音声ツール プラグイン インストーラー"
echo "  (macOS / Linux)"
echo "========================================================"
echo ""
echo "検出された Praat 設定ディレクトリ: $PRAAT_DIR"

mkdir -p "$PRAAT_DIR"

if [ -L "$PLUGIN_DIR" ] || [ -d "$PLUGIN_DIR" ]; then
    echo "[クリーンアップ] 既存のプラグイン登録を更新します..."
    rm -rf "$PLUGIN_DIR"
fi

echo "[登録中] プラグインを Praat にリンクしています..."
if ln -s "$SRC_DIR" "$PLUGIN_DIR" 2>/dev/null; then
    echo ""
    echo "========================================================"
    echo "  【成功】プラグインのインストールが正常に完了しました！"
    echo "========================================================"
else
    echo "[フォールバック] シンボリックリンク作成に失敗したためコピーします..."
    cp -R "$SRC_DIR" "$PLUGIN_DIR"
    echo ""
    echo "========================================================"
    echo "  【完了】フォルダコピーによる導入が完了しました！"
    echo "========================================================"
fi

echo ""
echo "【利用できるメニュー】"
echo "  1. メニューバー: [Praat] -> [日本語音声ツール (JA)]"
echo "  2. 右側アクションボタン: Sound や TextGrid 選択時に [日本語ツール (JA)]"
echo ""

if pgrep -x "Praat" > /dev/null 2>&1 || pgrep -f "Praat" > /dev/null 2>&1; then
    echo "--------------------------------------------------------"
    echo "【重要なお知らせ】"
    echo "現在 Praat が起動しています。"
    echo "新しいメニューを Praat に反映させるため、"
    echo "一度 Praat を終了してから再起動してください。"
    echo "--------------------------------------------------------"
else
    echo "Praat を起動して新しいメニューをご確認ください。"
fi
echo ""
