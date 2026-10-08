#!/usr/bin/env bash
# ==============================================================================
# Build macOS Installer Package (.pkg) for praat-scripts-ja
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PKG_IDENTIFIER="com.okawawaka.praat-japanese-tools"
VERSION="1.1.0"
OUTPUT_DIR="$REPO_ROOT/dist"
OUTPUT_PKG="$OUTPUT_DIR/Praat-JapaneseTools-Setup.pkg"

WORK_DIR="$(mktemp -d /tmp/praat-pkg-build.XXXXXX)"
PAYLOAD_DIR="$WORK_DIR/payload"
SCRIPTS_DIR="$WORK_DIR/scripts"
RESOURCES_DIR="$WORK_DIR/resources"

echo "=== macOS インストーラー (.pkg) のビルドを開始します ==="
echo "リポジトリルート: $REPO_ROOT"
echo "作業用一時ディレクトリ: $WORK_DIR"

# クリーンアップハンドラ
cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# 1. 出力ディレクトリ作成
mkdir -p "$OUTPUT_DIR"
mkdir -p "$PAYLOAD_DIR"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$RESOURCES_DIR"

# 2. プラグインペイロードの配置
echo "[1/4] プラグイン構成ファイルをステージング中..."
cp "$REPO_ROOT/setup.praat" "$PAYLOAD_DIR/"
cp "$REPO_ROOT/README.md" "$PAYLOAD_DIR/"
cp "$REPO_ROOT/LICENSE" "$PAYLOAD_DIR/"
cp -R "$REPO_ROOT/scripts" "$PAYLOAD_DIR/"
cp "$SCRIPT_DIR/uninstall.sh" "$PAYLOAD_DIR/"
cp "$SCRIPT_DIR/uninstall.command" "$PAYLOAD_DIR/"
chmod +x "$PAYLOAD_DIR/uninstall.sh" "$PAYLOAD_DIR/uninstall.command"

# 3. インストーラースクリプト・リソースの配置
echo "[2/4] インストーラースクリプトおよびメタデータを準備中..."
cp "$SCRIPT_DIR/mac/postinstall" "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/postinstall"

cp "$SCRIPT_DIR/mac/welcome.html" "$RESOURCES_DIR/"
cp "$SCRIPT_DIR/mac/conclusion.html" "$RESOURCES_DIR/"

# 4. コンポーネントパッケージのビルド
echo "[3/4] pkgbuild でコンポーネントパッケージを作成中..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --identifier "$PKG_IDENTIFIER" \
    --version "$VERSION" \
    --install-location "/tmp/.praat_japanese_tools_payload" \
    --scripts "$SCRIPTS_DIR" \
    "$WORK_DIR/component.pkg"

# 5. 製品パッケージ (Product Archive) の生成
echo "[4/4] productbuild で最終 .pkg パッケージを生成中..."
productbuild \
    --distribution "$SCRIPT_DIR/mac/distribution.xml" \
    --resources "$RESOURCES_DIR" \
    --package-path "$WORK_DIR" \
    "$OUTPUT_PKG"

if [ -f "$OUTPUT_PKG" ]; then
    PKG_SIZE=$(du -h "$OUTPUT_PKG" | cut -f1)
    echo "========================================================"
    echo "  [成功] パッケージ生成完了!"
    echo "  ファイル: $OUTPUT_PKG ($PKG_SIZE)"
    echo "========================================================"
else
    echo "エラー: パッケージの生成に失敗しました。" >&2
    exit 1
fi
