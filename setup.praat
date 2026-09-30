# ==============================================================================
# Praat プラグイン定義ファイル: setup.praat
# プラグイン名: Japanese Tools for Praat (日本語音声分析スクリプト集)
# リポジトリ: okawawaka/praat-scripts-ja
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 常設メニュー（Objects ウィンドウのメニューバー: Praat メニュー内）
# ------------------------------------------------------------------------------
Add menu command: "Objects", "Praat", "日本語音声ツール (JA)", "", 0, ""
Add menu command: "Objects", "Praat", "ツール一覧・ランチャー...", "日本語音声ツール (JA)", 1, "scripts/menu_launcher.praat"
Add menu command: "Objects", "Praat", "フォルマントデータ一括測定...", "日本語音声ツール (JA)", 1, "scripts/acoustic-analysis/collect_formant_data.praat"
Add menu command: "Objects", "Praat", "ピッチ (F0) データ一括測定...", "日本語音声ツール (JA)", 1, "scripts/acoustic-analysis/collect_pitch_data.praat"
Add menu command: "Objects", "Praat", "区間継続時間の集計...", "日本語音声ツール (JA)", 1, "scripts/acoustic-analysis/calculate_segment_durations.praat"
Add menu command: "Objects", "Praat", "音声区間の一括切り出し...", "日本語音声ツール (JA)", 1, "scripts/segmentation/extract_intervals_to_wav.praat"
Add menu command: "Objects", "Praat", "無音・ポーズの自動検出...", "日本語音声ツール (JA)", 1, "scripts/segmentation/mark_pauses.praat"
Add menu command: "Objects", "Praat", "F1-F2 母音図の自動描画...", "日本語音声ツール (JA)", 1, "scripts/visualization/draw_formant_chart.praat"
Add menu command: "Objects", "Praat", "サンプリングレートの一括変更...", "日本語音声ツール (JA)", 1, "scripts/batch-processing/change_sample_rate.praat"
Add menu command: "Objects", "Praat", "ステレオ→モノラル一括変換...", "日本語音声ツール (JA)", 1, "scripts/batch-processing/convert_stereo_to_mono.praat"

# ------------------------------------------------------------------------------
# 2. 動的アクションメニュー（Sound 単独選択時）
# ------------------------------------------------------------------------------
Add action command: "Sound", 1, "", 0, "", 0, "日本語ツール (JA)", "", 0, ""
Add action command: "Sound", 1, "", 0, "", 0, "無音・ポーズ自動検出...", "日本語ツール (JA)", 1, "scripts/segmentation/mark_pauses.praat"
Add action command: "Sound", 1, "", 0, "", 0, "ピッチデータ抽出...", "日本語ツール (JA)", 1, "scripts/acoustic-analysis/collect_pitch_data.praat"
Add action command: "Sound", 1, "", 0, "", 0, "サンプリングレート変更...", "日本語ツール (JA)", 1, "scripts/batch-processing/change_sample_rate.praat"
Add action command: "Sound", 1, "", 0, "", 0, "ステレオをモノラル変換...", "日本語ツール (JA)", 1, "scripts/batch-processing/convert_stereo_to_mono.praat"

# ------------------------------------------------------------------------------
# 3. 動的アクションメニュー（Sound と TextGrid が両方選択されている時）
# ------------------------------------------------------------------------------
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "日本語ツール (JA)", "", 0, ""
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "音声区間を一括切り出し...", "日本語ツール (JA)", 1, "scripts/segmentation/extract_intervals_to_wav.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "フォルマント一括測定...", "日本語ツール (JA)", 1, "scripts/acoustic-analysis/collect_formant_data.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "ピッチ一括集計...", "日本語ツール (JA)", 1, "scripts/acoustic-analysis/collect_pitch_data.praat"
Add action command: "Sound", 1, "TextGrid", 1, "", 0, "区間継続時間の測定...", "日本語ツール (JA)", 1, "scripts/acoustic-analysis/calculate_segment_durations.praat"

# ------------------------------------------------------------------------------
# 4. 動的アクションメニュー（TextGrid 単独選択時）
# ------------------------------------------------------------------------------
Add action command: "TextGrid", 1, "", 0, "", 0, "日本語ツール (JA)", "", 0, ""
Add action command: "TextGrid", 1, "", 0, "", 0, "区間継続時間の測定...", "日本語ツール (JA)", 1, "scripts/acoustic-analysis/calculate_segment_durations.praat"

# ------------------------------------------------------------------------------
# 5. 動的アクションメニュー（Table 単独選択時）
# ------------------------------------------------------------------------------
Add action command: "Table", 1, "", 0, "", 0, "日本語ツール (JA)", "", 0, ""
Add action command: "Table", 1, "", 0, "", 0, "F1-F2 母音図を描画...", "日本語ツール (JA)", 1, "scripts/visualization/draw_formant_chart.praat"
