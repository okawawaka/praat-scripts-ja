#!/usr/bin/env bash
# ==============================================================================
# Praat 日本語音声ツール プラグイン アンインストーラー (macOS / Linux)
# ==============================================================================

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
BUTTONS_FILE="$PRAAT_DIR/Buttons5.ini"

echo "========================================================"
echo "  Praat 日本語音声ツール プラグイン アンインストーラー"
echo "  (macOS / Linux)"
echo "========================================================"
echo ""

# 1. 起動中 Praat プロセスの確認
if pgrep -x "Praat" > /dev/null 2>&1 || pgrep -f "Praat" > /dev/null 2>&1; then
    echo "--------------------------------------------------------"
    echo "【重要】現在 Praat が起動しています！"
    echo "Praat が開いたままだと、メモリ上にメニューが保持されたままになり、"
    echo "画面からメニューが消去されません。"
    echo "--------------------------------------------------------"
    echo ""
    read -p "Praat を今すぐ自動終了してアンインストールを続行しますか？ (y/n) [y]: " reply
    reply=${reply:-y}
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        pkill -x "Praat" 2>/dev/null || pkill -f "Praat" 2>/dev/null || true
        sleep 1
        echo "[完了] Praat を終了しました。"
    else
        echo "[案内] アンインストール後、必ず手動で Praat を再起動してください。"
    fi
    echo ""
fi

# 2. プラグインの削除
echo "[削除中] プラグイン登録を解除しています..."
if [ -L "$PLUGIN_DIR" ] || [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
    echo "  -> プラグインフォルダ (plugin_JapaneseTools) を正常に削除しました。"
else
    echo "  -> プラグインフォルダは既に登録解除されています。"
fi

# 過去の古い名前もクリーンアップ
for legacy in plugin_ja plugin_scripts_ja plugin_japanese_tools; do
    if [ -e "$PRAAT_DIR/$legacy" ]; then
        rm -rf "$PRAAT_DIR/$legacy"
        echo "  -> 過去の旧プラグイン ($legacy) もクリーンアップしました。"
    fi
done

# 3. Buttons5.ini のクリーンアップ
if [ -f "$BUTTONS_FILE" ]; then
    grep -v -E "JapaneseTools|日本語音声ツール|日本語ツール" "$BUTTONS_FILE" > "$BUTTONS_FILE.tmp" 2>/dev/null && mv "$BUTTONS_FILE.tmp" "$BUTTONS_FILE"
    echo "  -> Praat 設定 (Buttons5.ini) からプラグインの痕跡をクリーンアップしました。"
fi

echo ""
echo "========================================================"
echo "  【成功】アンインストールが正常に完了しました！"
echo "========================================================"
echo "Praat を起動した際、メニューからプラグインが完全に消去されています。"
echo ""
