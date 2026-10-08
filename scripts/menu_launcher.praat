# ==============================================================================
# スクリプト名: menu_launcher.praat (日本語音声分析ツール ランチャー)
# 
# 【概要】
# Praatのメニューから直接起動できる総合ランチャーです。
# 実行したいツールを一覧から選択してワンクリックで呼び出すことができます。
# ==============================================================================

beginPause: "日本語音声分析スクリプト一覧"
    comment: "【実行したいツールを選択してください】"
    choice: "tool", 1
        option: "1. 音声区間の一括切り出し"
        option: "2. 無音・ポーズの自動検出"
        option: "3. フォルマントデータの一括測定"
        option: "4. ピッチ (F0) データの一括測定"
        option: "5. 区間継続時間の集計"
        option: "6. F1-F2 母音図の自動描画"
        option: "7. サンプリングレートの一括変更"
        option: "8. ステレオ→モノラル一括変換"
        option: "9. バージョン情報 (About)"
clicked = endPause: "キャンセル", "起動", 2, 1

if clicked = 1
    exitScript: "処理がキャンセルされました。"
endif

if tool = 1
    runScript: "segmentation/extract_intervals_to_wav.praat"
elsif tool = 2
    runScript: "segmentation/mark_pauses.praat"
elsif tool = 3
    runScript: "acoustic-analysis/collect_formant_data.praat"
elsif tool = 4
    runScript: "acoustic-analysis/collect_pitch_data.praat"
elsif tool = 5
    runScript: "acoustic-analysis/calculate_segment_durations.praat"
elsif tool = 6
    runScript: "visualization/draw_formant_chart.praat"
elsif tool = 7
    runScript: "batch-processing/change_sample_rate.praat"
elsif tool = 8
    runScript: "batch-processing/convert_stereo_to_mono.praat"
elsif tool = 9
    runScript: "about.praat"
endif
