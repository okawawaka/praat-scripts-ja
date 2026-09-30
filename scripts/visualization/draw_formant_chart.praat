# ==============================================================================
# スクリプト名: draw_formant_chart.praat (F1-F2 母音図の自動描画)
# 
# 【概要】
# 本スクリプトで抽出したフォルマントデータ（TSVファイル）を読み込み、
# Praat Picture ウィンドウ上に F1-F2 母音図（音響母音散布図）をプロットします。
# 従来の音声学の慣例に従い、軸は逆方向（F1: 下から上へ減少、F2: 左から右へ減少）
# で描画され、舌の位置（高低・前後）に対応した直感的な母音空間を可視化できます。
# 画像（PNGやPDF/EPS）として保存可能です。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: draw_formant_chart.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form F1-F2 母音図の自動描画 (Draw Formant Chart)
    comment === 【データファイル指定】 ===
    text tsv_file C:\SpeechData\formant_results.tsv
    comment collect_formant_data.praat で作成したTSVファイルを指定

    comment === 【軸の周波数範囲（Hz）】 ===
    positive min_f1 200
    positive max_f1 1000
    positive min_f2 500
    positive max_f2 3000

    comment === 【描画・デザイン設定】 ===
    sentence title 日本語母音 F1-F2 母音図
    positive font_size 12
    boolean save_image_file 0
    text output_image C:\SpeechData\vowel_chart.png
endform

clearinfo
echo === 母音図の描画を開始します ===

if not fileReadable(tsv_file$)
    exitScript: "【エラー】指定されたTSVファイルが見つかりません: " + tsv_file$
endif

# TSVファイルを Table として読み込み
table = Read Table from tab-separated file: tsv_file$
num_rows = Get number of rows

if num_rows = 0
    removeObject: table
    exitScript: "【エラー】データ行が存在しません。"
endif

# 描画画面（Praat Picture）のクリアと初期化
Erase all
Select inner viewport: 1.5, 6.5, 1.5, 6.5
Font size: font_size
Helvetica

# 母音空間の軸を描画（F1, F2とも音声学の慣例で反転）
# 横軸: F2 (右へ行くほど小さくなる: max_f2 -> min_f2)
# 縦軸: F1 (上へ行くほど小さくなる: max_f1 -> min_f1)
Axes: max_f2, min_f2, max_f1, min_f1

Draw inner box
Marks bottom every: 1, 500, "yes", "yes", "no"
Marks left every: 1, 100, "yes", "yes", "no"

Text bottom: "yes", "第2フォルマント F2 (Hz) ← 前舌性"
Text left: "yes", "第1フォルマント F1 (Hz) ← 舌の高さ"
Text top: "yes", title$

# 各点をプロット
selectObject: table
num_plotted = 0

for i to num_rows
    selectObject: table
    label$ = Get value: i, "Label"
    f1_val = Get value: i, "F1_Hz"
    f2_val = Get value: i, "F2_Hz"
    
    if f1_val <> undefined and f2_val <> undefined
        if f1_val >= min_f1 and f1_val <= max_f1 and f2_val >= min_f2 and f2_val <= max_f2
            # プロット点または母音記号を描画
            Paint circle (mm): "Grey", f2_val, f1_val, 1.5
            Text: f2_val, "centre", f1_val, "half", label$
            num_plotted = num_plotted + 1
        endif
    endif
endfor

removeObject: table

echo プロット完了: 'num_plotted' / 'num_rows' 件を描画しました。

# 画像保存オプション
if save_image_file
    Save as 300-dpi PNG file: output_image$
    echo 画像を保存しました: 'output_image$'
endif

echo Praat Picture ウィンドウをご確認ください。
