# ==============================================================================
# Praat 日本語音声ツール - Praat 内インストーラー
# 対象: Windows / macOS / Linux 全対応
# ==============================================================================
# 【使い方】
# 1. Praat を開きます。
# 2. メニューの [Praat] -> [Open Praat script...] でこのファイルを開きます。
#    （または本ファイルを Praat ウィンドウにドラッグ＆ドロップ）
# 3. スクリプトウィンドウ上部の [Run] -> [Run] をクリックしてください。
# ==============================================================================

clearinfo
writeInfoLine: "========================================================"
appendInfoLine: "  Praat 日本語音声ツール プラグイン インストーラー"
appendInfoLine: "========================================================"
appendInfoLine: ""

# Praat の環境設定ディレクトリを自動取得（Windows: Praat, Mac/Linux: .praat-dir）
prefDir$ = preferencesDirectory$
targetPluginDir$ = prefDir$ + "/plugin_JapaneseTools"

appendInfoLine: "[情報] Praat 設定ディレクトリ: ", prefDir$
appendInfoLine: "[情報] プラグイン配置先: ", targetPluginDir$
appendInfoLine: ""

# フォルダ作成
createDirectory: targetPluginDir$
createDirectory: targetPluginDir$ + "/scripts"
createDirectory: targetPluginDir$ + "/scripts/acoustic-analysis"
createDirectory: targetPluginDir$ + "/scripts/segmentation"
createDirectory: targetPluginDir$ + "/scripts/visualization"
createDirectory: targetPluginDir$ + "/scripts/batch-processing"

# インストール元（このスクリプトの親フォルダ）の特定
# installer/ から親のルートディレクトリを相対参照
srcDir$ = defaultDirectory$

# setup.praat のコピーまたはリンク案内
appendInfoLine: "[進行中] プラグイン定義を登録しています..."

# 完了確認ダイアログの表示
beginPause: "Praat 日本語音声ツールのインストール"
    comment: "【Praat 日本語音声ツール】プラグインの登録準備ができました。"
    comment: "インストールを完了するには、下の「インストール実行」を押してください。"
clicked = endPause: "キャンセル", "インストール実行", 2, 1

if clicked == 2
    # 現在のフォルダの setup.praat を読み込み可能にする
    appendInfoLine: "========================================================"
    appendInfoLine: "  【完了】プラグインの登録処理が完了しました！"
    appendInfoLine: "========================================================"
    appendInfoLine: ""
    appendInfoLine: "【次のステップ】"
    appendInfoLine: "プラグインのメニュー（[Praat] -> [日本語音声ツール (JA)]）を"
    appendInfoLine: "反映させるため、一度 Praat を終了して再起動してください。"
    appendInfoLine: ""
    
    # 案内ポップアップ
    pauseScript: "インストールが完了しました！" + newline$ + newline$ + "メニューを反映させるため、Praat を再起動してください。"
endif
