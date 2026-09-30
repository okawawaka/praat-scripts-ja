# ==============================================================================
# スクリプト名: collect_formant_data.praat (フォルマントデータの一括抽出)
# 
# 【概要】
# フォルダ内の音声ファイル（WAV）と TextGrid を読み込み、
# 指定した段（Tier）の各ラベル区間の中央点（50%地点）における
# フォルマント周波数（F1〜F5）および帯域幅（B1〜B3）を自動測定します。
# 結果はタブ区切りテキストファイル（TSV）として保存され、ExcelやRで即座に分析可能です。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: collect_formant_data_from_files.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form フォルマントデータの一括抽出 (Collect Formant Data)
    comment === 【フォルダ・出力指定】 ===
    text sound_dir C:\SpeechData\wav\
    sentence sound_ext .wav
    text textgrid_dir C:\SpeechData\tg\
    sentence textgrid_ext .TextGrid
    text result_file C:\SpeechData\formant_results.tsv

    comment === 【抽出条件】 ===
    positive tier_number 1
    comment 分析対象のTier番号
    boolean skip_empty_labels 1
    comment 空白ラベル（無音など）を除外するかどうか

    comment === 【フォルマント分析パラメータ】 ===
    positive time_step 0.01
    comment 分析時間ステップ（秒）
    integer max_num_formants 5
    comment 抽出する最大フォルマント数
    positive max_formant_hz 5500
    comment 最大フォルマント周波数（女性: 5500 Hz, 男性: 5000 Hz, 子供: 8000 Hz）
    positive window_length 0.025
    comment 分析窓長（秒）
    real preemphasis_from 50
    comment プリエンファシス開始周波数（Hz）
endform

# パス末尾の補正
if right$(sound_dir$, 1) <> "/" and right$(sound_dir$, 1) <> "\"
    sound_dir$ = sound_dir$ + "/"
endif
if right$(textgrid_dir$, 1) <> "/" and right$(textgrid_dir$, 1) <> "\"
    textgrid_dir$ = textgrid_dir$ + "/"
endif

clearinfo
echo === フォルマント一括抽出を開始します ===
echo 入力音声フォルダ: 'sound_dir$'
echo 入力TextGridフォルダ: 'textgrid_dir$'
echo 結果出力ファイル: 'result_file$'
echo 最大フォルマント設定: 'max_formant_hz' Hz

# 既存結果ファイルが存在する場合は上書き確認
if fileReadable(result_file$)
    deleteFile: result_file$
endif

# ヘッダー行を出力
title_line$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MidTime_s" + tab$ + "F1_Hz" + tab$ + "F2_Hz" + tab$ + "F3_Hz" + tab$ + "F4_Hz" + tab$ + "F5_Hz" + tab$ + "B1_Hz" + tab$ + "B2_Hz" + tab$ + "B3_Hz" + newline$
writeFile: result_file$, title_line$

file_list = Create Strings as file list: "fileList", sound_dir$ + "*" + sound_ext$
num_files = Get number of strings

if num_files = 0
    removeObject: file_list
    exitScript: "【エラー】対象フォルダに対象の音声ファイル（*" + sound_ext$ + "）が見つかりませんでした。"
endif

total_measurements = 0

for i to num_files
    selectObject: file_list
    filename$ = Get string: i
    basename$ = filename$ - sound_ext$
    
    tg_path$ = textgrid_dir$ + basename$ + textgrid_ext$
    sound_path$ = sound_dir$ + filename$
    
    if fileReadable(tg_path$)
        sound = Read from file: sound_path$
        tg = Read from file: tg_path$
        
        # フォルマントオブジェクトの作成 (To Formant (burg))
        selectObject: sound
        formant = To Formant (burg): time_step, max_num_formants, max_formant_hz, window_length, preemphasis_from
        
        selectObject: tg
        num_tiers = Get number of tiers
        
        if tier_number <= num_tiers
            is_interval = Is interval tier: tier_number
            if is_interval
                num_intervals = Get number of intervals: tier_number
                
                for j to num_intervals
                    selectObject: tg
                    label$ = Get label of interval: tier_number, j
                    start_t = Get start time of interval: tier_number, j
                    end_t = Get end time of interval: tier_number, j
                    duration = end_t - start_t
                    mid_t = start_t + (duration / 2)
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    
                    if not (skip_empty_labels and clean_label$ == "")
                        # フォルマント値と帯域幅を取得
                        selectObject: formant
                        f1 = Get value at time: 1, mid_t, "Hertz", "Linear"
                        f2 = Get value at time: 2, mid_t, "Hertz", "Linear"
                        f3 = Get value at time: 3, mid_t, "Hertz", "Linear"
                        f4 = Get value at time: 4, mid_t, "Hertz", "Linear"
                        f5 = Get value at time: 5, mid_t, "Hertz", "Linear"
                        b1 = Get bandwidth at time: 1, mid_t, "Hertz", "Linear"
                        b2 = Get bandwidth at time: 2, mid_t, "Hertz", "Linear"
                        b3 = Get bandwidth at time: 3, mid_t, "Hertz", "Linear"
                        
                        # 未定義値 (undefined) のフォーマット
                        f1$ = if f1 = undefined then "NA" else fixed$(f1, 2) fi
                        f2$ = if f2 = undefined then "NA" else fixed$(f2, 2) fi
                        f3$ = if f3 = undefined then "NA" else fixed$(f3, 2) fi
                        f4$ = if f4 = undefined then "NA" else fixed$(f4, 2) fi
                        f5$ = if f5 = undefined then "NA" else fixed$(f5, 2) fi
                        b1$ = if b1 = undefined then "NA" else fixed$(b1, 2) fi
                        b2$ = if b2 = undefined then "NA" else fixed$(b2, 2) fi
                        b3$ = if b3 = undefined then "NA" else fixed$(b3, 2) fi
                        
                        dur_ms = duration * 1000
                        
                        # TSV行の生成
                        row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + fixed$(mid_t, 4) + tab$ + f1$ + tab$ + f2$ + tab$ + f3$ + tab$ + f4$ + tab$ + f5$ + tab$ + b1$ + tab$ + b2$ + tab$ + b3$ + newline$
                        
                        appendFile: result_file$, row$
                        total_measurements = total_measurements + 1
                    endif
                endfor
            endif
        endif
        
        removeObject: sound
        removeObject: tg
        removeObject: formant
        echo ['i'/'num_files'] 'basename$': 分析完了
    endif
endfor

removeObject: file_list

echo ==============================================
echo 完了: 合計 'total_measurements' 件のデータを抽出しました。
echo 出力先: 'result_file$'
