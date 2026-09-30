# ==============================================================================
# スクリプト名: calculate_segment_durations.praat (区間継続時間・デュレーションの一括計算)
# 
# 【概要】
# フォルダ内の TextGrid ファイルから、指定した段（Tier）の
# 各区間の開始時刻、終了時刻、継続時間（秒およびミリ秒）を一覧集計し、
# TSV ファイルに出力します。母音の長短、子音の閉鎖持続時間（VOT）、ポーズ長の研究に便利です。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: calculate_segment_durations.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form 区間継続時間の一括計算 (Calculate Segment Durations)
    comment === 【フォルダ・出力指定】 ===
    text textgrid_dir C:\SpeechData\tg\
    sentence textgrid_ext .TextGrid
    text result_file C:\SpeechData\duration_results.tsv

    comment === 【集計条件】 ===
    positive tier_number 1
    comment 対象のTier番号
    boolean skip_empty_intervals 1
    comment 空白ラベル（無音区間など）を除外するかどうか
endform

# パス末尾の補正
if right$(textgrid_dir$, 1) <> "/" and right$(textgrid_dir$, 1) <> "\"
    textgrid_dir$ = textgrid_dir$ + "/"
endif

clearinfo
echo === 区間継続時間の計算処理を開始します ===
echo TextGridフォルダ: 'textgrid_dir$'
echo 対象Tier: 'tier_number'
echo 出力ファイル: 'result_file$'

if fileReadable(result_file$)
    deleteFile: result_file$
endif

title_line$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms" + newline$
writeFile: result_file$, title_line$

file_list = Create Strings as file list: "fileList", textgrid_dir$ + "*" + textgrid_ext$
num_files = Get number of strings

if num_files = 0
    removeObject: file_list
    exitScript: "【エラー】対象フォルダに TextGrid ファイルが見つかりませんでした。"
endif

total_intervals = 0

for i to num_files
    selectObject: file_list
    filename$ = Get string: i
    basename$ = filename$ - textgrid_ext$
    tg_path$ = textgrid_dir$ + filename$
    
    tg = Read from file: tg_path$
    
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
                duration_s = end_t - start_t
                duration_ms = duration_s * 1000
                
                clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                
                if not (skip_empty_intervals and clean_label$ == "")
                    row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(duration_s, 4) + tab$ + fixed$(duration_ms, 2) + newline$
                    appendFile: result_file$, row$
                    total_intervals = total_intervals + 1
                endif
            endfor
        endif
    endif
    
    removeObject: tg
    echo ['i'/'num_files'] 'basename$': 処理完了
endfor

removeObject: file_list

echo ==============================================
echo 完了: 合計 'total_intervals' 件の区間時間を集計しました。
echo 出力先: 'result_file$'
