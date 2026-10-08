# ==============================================================================
# スクリプト名: about.praat (バージョン情報・実行環境の表示)
# 
# 【概要】
# プラグインのバージョンおよび実行中のPraatバージョン、OS環境を表示します。
# ==============================================================================

pluginName$ = "Praat日本語版スクリプト (praat-scripts-ja)"
pluginVersion$ = "1.1.0"

# OS環境の判定
if windows
    osName$ = "Windows"
elsif macintosh
    osName$ = "macOS"
else
    osName$ = "Linux / Unix"
endif

# バージョン情報ダイアログの表示
beginPause: "バージョン情報 - Praat日本語版スクリプト"
    comment: "【プラグイン情報】"
    comment: "  プラグイン名: " + pluginName$
    comment: "  バージョン: v" + pluginVersion$
    comment: ""
    comment: "【実行環境】"
    comment: "  Praat バージョン: " + praatVersion$
    comment: "  OS 環境: " + osName$
    comment: ""
    comment: "GitHub: https://github.com/okawawaka/praat-scripts-ja"
clicked = endPause: "Infoに出力", "閉じる", 2, 1

# 「Infoに出力」が押された場合はPraat Infoウィンドウにも出力
if clicked = 1
    writeInfoLine: "=========================================="
    appendInfoLine: " プラグイン・環境情報"
    appendInfoLine: "=========================================="
    appendInfoLine: "プラグイン名: ", pluginName$
    appendInfoLine: "プラグインバージョン: v", pluginVersion$
    appendInfoLine: "Praat バージョン: ", praatVersion$
    appendInfoLine: "OS: ", osName$
    appendInfoLine: "リポジトリ: https://github.com/okawawaka/praat-scripts-ja"
endif
