# ==============================================================================
# スクリプト名: draw_formant_chart.praat (F1-F2 母音図の自動描画)
# 
# 【概要】
# フォルマントデータ（TSVファイルまたは選択中のTable）を読み込み、
# Praat Picture ウィンドウ上に F1-F2 母音図（音響母音散布図）をプロットします。
# 音声学の慣例に従い、軸は逆方向（F1: 下から上へ減少、F2: 左から右へ減少）
# で描画され、舌の位置（高低・前後）に対応した直感的な母音空間を可視化できます。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクトモード】
#    Praat上で Table オブジェクトを選択している場合、パス指定なしで即座にプロットします。
# 2. 【ファイル選択ダイアログモード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「ファイル選択ダイアログ」
#    が起動します。TSVファイルを手動パス入力なしで開いてプロットします。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: draw_formant_chart.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

num_table = numberOfSelected("Table")
is_temp_table = 0

if num_table > 0
    table_id = selected("Table", 1)
else
    tsv_path$ = chooseReadFile$: "フォルマントデータ(TSV)を選択してください"
    if tsv_path$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    table_id = Read Table from tab-separated file: tsv_path$
    is_temp_table = 1
endif

beginPause: "F1-F2 母音図の描画設定"
    comment: "【軸の周波数範囲（Hz）】"
    positive: "min_f1", 200
    positive: "max_f1", 1000
    positive: "min_f2", 500
    positive: "max_f2", 3000
    comment: "【描画デザイン】"
    sentence: "chart_title", "F1-F2 母音散布図"
    positive: "chart_font_size", 12
    comment: "画像ファイル(PNG)としても保存する:"
    boolean: "save_png_image", 0
clicked = endPause: "キャンセル", "描画を実行", 2, 1

if clicked = 1
    if is_temp_table
        removeObject: table_id
    endif
    exitScript: "処理がキャンセルされました。"
endif

f1_min = min_f1
f1_max = max_f1
f2_min = min_f2
f2_max = max_f2
title$ = chart_title$
f_size = chart_font_size
do_save_png = save_png_image

png_out_file$ = ""
if do_save_png
    png_out_file$ = chooseWriteFile$: "保存先PNG画像名を指定してください", "vowel_chart.png"
    if png_out_file$ == ""
        do_save_png = 0
    endif
endif

clearinfo
appendInfoLine: "=== 母音図の描画を開始します ==="

selectObject: table_id
num_rows = Get number of rows

if num_rows == 0
    if is_temp_table
        removeObject: table_id
    endif
    exitScript: "【エラー】データ行が存在しません。"
endif

# 描画画面（Praat Picture）の初期化
Erase all
Select outer viewport: 0, 8, 0, 8
Select inner viewport: 1.5, 6.5, 1.5, 6.5
Font size: f_size
Helvetica

# 母音空間の軸を描画（F1, F2とも音声学の慣例で反転）
# 横軸: F2 (右へ行くほど小さくなる: f2_max -> f2_min)
# 縦軸: F1 (上へ行くほど小さくなる: f1_max -> f1_min)
Axes: f2_max, f2_min, f1_max, f1_min

Draw inner box
Marks bottom every: 1, 500, "yes", "yes", "no"
Marks left every: 1, 100, "yes", "yes", "no"

Text bottom: "yes", "第2フォルマント F2 (Hz) ← 前舌性"
Text left: "yes", "第1フォルマント F1 (Hz) ← 舌の高さ"
Text top: "yes", title$

selectObject: table_id
num_plotted = 0

for i to num_rows
    selectObject: table_id
    label$ = Get value: i, "Label"
    f1_val = Get value: i, "F1_Hz"
    f2_val = Get value: i, "F2_Hz"
    
    if f1_val <> undefined and f2_val <> undefined
        if f1_val >= f1_min and f1_val <= f1_max and f2_val >= f2_min and f2_val <= f2_max
            Paint circle (mm): "Grey", f2_val, f1_val, 1.5
            Text: f2_val, "centre", f1_val, "half", label$
            num_plotted = num_plotted + 1
        endif
    endif
endfor

if is_temp_table
    removeObject: table_id
endif

appendInfoLine: "描画完了: 合計 ", num_plotted, " / ", num_rows, " 件をプロットしました。"

if do_save_png and png_out_file$ <> ""
    Save as 300-dpi PNG file: png_out_file$
    appendInfoLine: "画像ファイルを保存しました: ", png_out_file$
endif

appendInfoLine: "Praat Picture ウィンドウをご確認ください。"
