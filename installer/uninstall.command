#!/usr/bin/env bash
# ==============================================================================
# Praat 日本語音声ツール アンインストーラー (macOS ダブルクリック実行用)
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/uninstall.sh" ]; then
    bash "$DIR/uninstall.sh"
else
    # プラグインフォルダ自身を削除
    PRAAT_DIR="$HOME/Library/Preferences/Praat Prefs"
    PLUGIN_DIR="$PRAAT_DIR/plugin_JapaneseTools"
    echo "プラグインを削除中: $PLUGIN_DIR"
    rm -rf "$PLUGIN_DIR"
    echo "削除が完了しました。"
fi

echo ""
echo "キーボードの任意のキー（または Enter）を押すとこのウィンドウは閉じます。"
read -n 1 -s -r
exit 0
