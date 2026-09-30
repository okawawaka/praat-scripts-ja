# ==============================================================================
# スクリプト名: collect_pitch_data.praat (ピッチ・F0統計量の一括抽出)
# 
# 【概要】
# フォルダ内の音声ファイルと TextGrid を読み込み、
# 指定した段（Tier）の各ラベル区間におけるピッチ（基本周波数 F0）の
# 平均値（Mean）、中央値（Median）、最小値（Min）、最大値（Max）、標準偏差（StDev）
# を自動測定して TSV ファイルに一括保存します。
# イントネーション、アクセント、プロソディ研究に必携のスクリプトです。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: collect_pitch_data_from_files.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form ピッチ・F0統計量の一括抽出 (Collect Pitch Data)
    comment === 【フォルダ・出力指定】 ===
    text sound_dir C:\SpeechData\wav\
    sentence sound_ext .wav
    text textgrid_dir C:\SpeechData\tg\
    sentence textgrid_ext .TextGrid
    text result_file C:\SpeechData\pitch_results.tsv

    comment === 【抽出条件】 ===
    positive tier_number 1
    boolean skip_empty_labels 1

    comment === 【ピッチ分析パラメータ (F0抽出範囲)】 ===
    positive time_step 0.01
    comment 時間ステップ（秒）
    positive pitch_floor_hz 75.0
    comment ピッチ下限（Hz）。成人男性: 75 Hz、成人女性・子供: 100 Hz
    positive pitch_ceiling_hz 500.0
    comment ピッチ上限（Hz）。成人男性: 300 Hz、成人女性・子供: 500〜600 Hz
    sentence pitch_unit Hertz
    comment 単位 (Hertz, semitones re 100 Hz, ERB, mel, logHertz)
endform

# パス末尾の補正
if right$(sound_dir$, 1) <> "/" and right$(sound_dir$, 1) <> "\"
    sound_dir$ = sound_dir$ + "/"
endif
if right$(textgrid_dir$, 1) <> "/" and right$(textgrid_dir$, 1) <> "\"
    textgrid_dir$ = textgrid_dir$ + "/"
endif

clearinfo
echo === ピッチ（F0）一括抽出処理を開始します ===
echo 音声フォルダ: 'sound_dir$'
echo TextGridフォルダ: 'textgrid_dir$'
echo 出力ファイル: 'result_file$'
echo ピッチ探索範囲: 'pitch_floor_hz' 〜 'pitch_ceiling_hz' Hz ('pitch_unit$')

if fileReadable(result_file$)
    deleteFile: result_file$
endif

# ヘッダー行を出力
title_line$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch" + tab$ + "MedianPitch" + tab$ + "MinPitch" + tab$ + "MaxPitch" + tab$ + "StDevPitch" + tab$ + "Unit" + newline$
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
        
        # ピッチオブジェクトの生成 (To Pitch)
        selectObject: sound
        pitch = To Pitch: time_step, pitch_floor_hz, pitch_ceiling_hz
        
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
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    
                    if not (skip_empty_labels and clean_label$ == "")
                        selectObject: pitch
                        mean_f0 = Get mean: start_t, end_t, pitch_unit$
                        median_f0 = Get quantile: start_t, end_t, 0.5, pitch_unit$
                        min_f0 = Get minimum: start_t, end_t, pitch_unit$, "Parabolic"
                        max_f0 = Get maximum: start_t, end_t, pitch_unit$, "Parabolic"
                        stdev_f0 = Get standard deviation: start_t, end_t, pitch_unit$
                        
                        mean_str$ = if mean_f0 = undefined then "NA" else fixed$(mean_f0, 2) fi
                        med_str$ = if median_f0 = undefined then "NA" else fixed$(median_f0, 2) fi
                        min_str$ = if min_f0 = undefined then "NA" else fixed$(min_f0, 2) fi
                        max_str$ = if max_f0 = undefined then "NA" else fixed$(max_f0, 2) fi
                        std_str$ = if stdev_f0 = undefined then "NA" else fixed$(stdev_f0, 2) fi
                        
                        dur_ms = duration * 1000
                        row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$ + tab$ + pitch_unit$ + newline$
                        
                        appendFile: result_file$, row$
                        total_measurements = total_measurements + 1
                    endif
                endfor
            endif
        endif
        
        removeObject: sound
        removeObject: tg
        removeObject: pitch
        echo ['i'/'num_files'] 'basename$': ピッチ分析完了
    endif
endfor

removeObject: file_list

echo ==============================================
echo 完了: 合計 'total_measurements' 件のピッチデータを抽出しました。
echo 出力先: 'result_file$'
