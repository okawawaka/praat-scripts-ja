# ==============================================================================
# スクリプト名: collect_pitch_data.praat (ピッチ・F0統計量の一括抽出)
# 
# 【概要】
# 音声と TextGrid から、指定した段（Tier）の各ラベル区間におけるピッチ（基本周波数 F0）の
# 平均値（Mean）、中央値（Median）、最小値（Min）、最大値（Max）、標準偏差（StDev）
# を自動測定して一覧集計します。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクト分析モード】
#    Praat上で Sound と TextGrid を選択している場合、
#    パス指定なしで即座に分析し、画面（Infoウィンドウ）に結果を表示します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内の同名ペアを一括集計し、同じフォルダ内に "pitch_results.tsv"
#    を自動保存します。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: collect_pitch_data_from_files.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

# 選択中のオブジェクト数を確認
num_sound = numberOfSelected("Sound")
num_tg = numberOfSelected("TextGrid")

if num_sound > 0 and num_tg > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound と TextGrid を直接分析（パス指定不要）
    # ==========================================================================
    beginPause: "ピッチ分析（選択オブジェクト）"
        comment: "Praat上で選択されている Sound / TextGrid を分析します。"
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_labels", 1
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300, 女性・子供: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "結果をTSVファイルとしても保存する:"
        boolean: "save_to_tsv", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    p_floor = pitch_floor_hz
    p_ceil = pitch_ceiling_hz
    do_save_tsv = save_to_tsv
    
    tsv_out_file$ = ""
    if do_save_tsv
        tsv_out_file$ = chooseWriteFile$: "保存先のTSVファイル名を指定してください", "pitch_results.tsv"
        if tsv_out_file$ == ""
            do_save_tsv = 0
        endif
    endif

    sound_id = selected("Sound", 1)
    tg_id = selected("TextGrid", 1)
    
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    clearinfo
    header$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz"
    appendInfoLine: header$
    
    if do_save_tsv and tsv_out_file$ <> ""
        writeFileLine: tsv_out_file$, header$
    endif
    
    # ピッチオブジェクト生成
    selectObject: sound_id
    pitch = To Pitch: 0.01, p_floor, p_ceil
    
    selectObject: tg_id
    num_tiers = Get number of tiers
    
    if target_tier <= num_tiers
        is_interval = Is interval tier: target_tier
        if is_interval == 1
            num_intervals = Get number of intervals: target_tier
            for j to num_intervals
                selectObject: tg_id
                label$ = Get label of interval: target_tier, j
                start_t = Get start time of interval: target_tier, j
                end_t = Get end time of interval: target_tier, j
                duration_s = end_t - start_t
                
                clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                
                if not (skip_empty and clean_label$ == "")
                    selectObject: pitch
                    mean_f0 = Get mean: start_t, end_t, "Hertz"
                    median_f0 = Get quantile: start_t, end_t, 0.5, "Hertz"
                    min_f0 = Get minimum: start_t, end_t, "Hertz", "Parabolic"
                    max_f0 = Get maximum: start_t, end_t, "Hertz", "Parabolic"
                    stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                    
                    mean_str$ = if mean_f0 = undefined then "NA" else fixed$(mean_f0, 2) fi
                    med_str$ = if median_f0 = undefined then "NA" else fixed$(median_f0, 2) fi
                    min_str$ = if min_f0 = undefined then "NA" else fixed$(min_f0, 2) fi
                    max_str$ = if max_f0 = undefined then "NA" else fixed$(max_f0, 2) fi
                    std_str$ = if stdev_f0 = undefined then "NA" else fixed$(stdev_f0, 2) fi
                    
                    dur_ms = duration_s * 1000
                    row$ = sound_name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$
                    appendInfoLine: row$
                    
                    if do_save_tsv and tsv_out_file$ <> ""
                        appendFileLine: tsv_out_file$, row$
                    endif
                endfor
            endif
        endif
    endif
    
    removeObject: pitch

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "音声(WAV)とTextGridが入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    # パス末尾のセパレータ補正
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    default_tsv$ = folder$ + "pitch_results.tsv"
    
    beginPause: "ピッチ分析（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_labels", 1
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300, 女性・子供: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "結果保存先のTSVファイル名:"
        sentence: "result_file", default_tsv$
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    p_floor = pitch_floor_hz
    p_ceil = pitch_ceiling_hz
    out_file$ = result_file$
    
    if out_file$ == ""
        out_file$ = default_tsv$
    endif
    
    clearinfo
    header$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz"
    appendInfoLine: header$
    writeFileLine: out_file$, header$
    
    file_list = Create Strings as file list: "fileList", folder$ + "*.wav"
    num_files = Get number of strings
    
    if num_files = 0
        removeObject: file_list
        exitScript: "【エラー】フォルダ内に .wav ファイルが見つかりませんでした: " + folder$
    endif
    
    for i to num_files
        selectObject: file_list
        filename$ = Get string: i
        basename$ = filename$ - ".wav"
        
        sound_path$ = folder$ + filename$
        tg_path$ = folder$ + basename$ + ".TextGrid"
        
        if not fileReadable(tg_path$)
            tg_path$ = folder$ + basename$ + ".textgrid"
        endif
        
        if fileReadable(tg_path$)
            sound = Read from file: sound_path$
            tg = Read from file: tg_path$
            
            selectObject: sound
            pitch = To Pitch: 0.01, p_floor, p_ceil
            
            selectObject: tg
            num_tiers = Get number of tiers
            
            if target_tier <= num_tiers
                is_interval = Is interval tier: target_tier
                if is_interval == 1
                    num_intervals = Get number of intervals: target_tier
                    for j to num_intervals
                        selectObject: tg
                        label$ = Get label of interval: target_tier, j
                        start_t = Get start time of interval: target_tier, j
                        end_t = Get end time of interval: target_tier, j
                        duration_s = end_t - start_t
                        
                        clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                        
                        if not (skip_empty and clean_label$ == "")
                            selectObject: pitch
                            mean_f0 = Get mean: start_t, end_t, "Hertz"
                            median_f0 = Get quantile: start_t, end_t, 0.5, "Hertz"
                            min_f0 = Get minimum: start_t, end_t, "Hertz", "Parabolic"
                            max_f0 = Get maximum: start_t, end_t, "Hertz", "Parabolic"
                            stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                            
                            mean_str$ = if mean_f0 = undefined then "NA" else fixed$(mean_f0, 2) fi
                            med_str$ = if median_f0 = undefined then "NA" else fixed$(median_f0, 2) fi
                            min_str$ = if min_f0 = undefined then "NA" else fixed$(min_f0, 2) fi
                            max_str$ = if max_f0 = undefined then "NA" else fixed$(max_f0, 2) fi
                            std_str$ = if stdev_f0 = undefined then "NA" else fixed$(stdev_f0, 2) fi
                            
                            dur_ms = duration_s * 1000
                            row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$
                            appendInfoLine: row$
                            appendFileLine: out_file$, row$
                        endfor
                    endif
                endif
            endif
            
            removeObject: sound
            removeObject: tg
            removeObject: pitch
        endif
    endfor
    
    removeObject: file_list
endif
