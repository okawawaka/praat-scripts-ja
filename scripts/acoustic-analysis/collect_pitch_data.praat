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
#    が起動します。フォルダ内の同名ペアを一括集計し、同じフォルダ内に "pitch_results.csv"（または .tsv）
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

# どちらか片方だけ選ばれている場合の同名オブジェクト自動補完
if num_sound > 0 and num_tg == 0
    sound_id = selected("Sound", 1)
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    matching_tg = Find Object: "TextGrid " + sound_name$
    if matching_tg > 0
        plusObject: sound_id
        num_tg = 1
    endif
elsif num_tg > 0 and num_sound == 0
    tg_id = selected("TextGrid", 1)
    selectObject: tg_id
    tg_name$ = selected$("TextGrid")
    matching_sound = Find Object: "Sound " + tg_name$
    if matching_sound > 0
        plusObject: tg_id
        num_sound = 1
    endif
endif

if num_sound > 0 and num_tg > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound と TextGrid を直接分析（パス指定不要）
    # ==========================================================================
    beginPause: "ピッチ分析（選択オブジェクト）"
        comment: "Praat上で選択されている Sound / TextGrid を分析します。"
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_labels", 0
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300, 女性・子供: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "結果をファイル(CSV/TSV)としても保存する:"
        boolean: "save_to_file", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    p_floor = pitch_floor_hz
    p_ceil = pitch_ceiling_hz
    do_save_file = save_to_file
    
    out_file$ = ""
    if do_save_file
        out_file$ = chooseWriteFile$: "保存先のファイル名を指定してください (.csv または .tsv)", "pitch_results.csv"
        if out_file$ == ""
            do_save_file = 0
        endif
    endif

    sep$ = tab$
    is_csv = 0
    if right$(out_file$, 4) == ".csv" or right$(out_file$, 4) == ".CSV"
        sep$ = ","
        is_csv = 1
    endif

    sound_id = selected("Sound", 1)
    tg_id = selected("TextGrid", 1)
    
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    clearinfo
    header_display$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz"
    header_file$ = "ObjectName" + sep$ + "IntervalIndex" + sep$ + "Label" + sep$ + "StartTime_s" + sep$ + "EndTime_s" + sep$ + "Duration_ms" + sep$ + "MeanPitch_Hz" + sep$ + "MedianPitch_Hz" + sep$ + "MinPitch_Hz" + sep$ + "MaxPitch_Hz" + sep$ + "StDevPitch_Hz"
    appendInfoLine: header_display$
    
    if do_save_file and out_file$ <> ""
        writeFileLine: out_file$, header_file$
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
                
                should_skip = 0
                if skip_empty = 1 and clean_label$ = ""
                    should_skip = 1
                endif
                
                if should_skip = 0
                    selectObject: pitch
                    mean_f0 = Get mean: start_t, end_t, "Hertz"
                    median_f0 = Get quantile: start_t, end_t, 0.5, "Hertz"
                    min_f0 = Get minimum: start_t, end_t, "Hertz", "Parabolic"
                    max_f0 = Get maximum: start_t, end_t, "Hertz", "Parabolic"
                    stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                    
                    if mean_f0 = undefined
                        mean_str$ = "NA"
                    else
                        mean_str$ = fixed$(mean_f0, 2)
                    endif
                    
                    if median_f0 = undefined
                        med_str$ = "NA"
                    else
                        med_str$ = fixed$(median_f0, 2)
                    endif
                    
                    if min_f0 = undefined
                        min_str$ = "NA"
                    else
                        min_str$ = fixed$(min_f0, 2)
                    endif
                    
                    if max_f0 = undefined
                        max_str$ = "NA"
                    else
                        max_str$ = fixed$(max_f0, 2)
                    endif
                    
                    if stdev_f0 = undefined
                        std_str$ = "NA"
                    else
                        std_str$ = fixed$(stdev_f0, 2)
                    endif
                    
                    dur_ms = duration_s * 1000
                    row_display$ = sound_name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$
                    appendInfoLine: row_display$
                    
                    if do_save_file and out_file$ <> ""
                        file_label$ = clean_label$
                        if is_csv and (index(file_label$, ",") > 0 or index(file_label$, """") > 0)
                            file_label$ = """" + replace_regex$(file_label$, """", """""", 0) + """"
                        endif
                        file_sound$ = sound_name$
                        if is_csv and (index(file_sound$, ",") > 0 or index(file_sound$, """") > 0)
                            file_sound$ = """" + replace_regex$(file_sound$, """", """""", 0) + """"
                        endif
                        row_file$ = file_sound$ + sep$ + string$(j) + sep$ + file_label$ + sep$ + fixed$(start_t, 4) + sep$ + fixed$(end_t, 4) + sep$ + fixed$(dur_ms, 2) + sep$ + mean_str$ + sep$ + med_str$ + sep$ + min_str$ + sep$ + max_str$ + sep$ + std_str$
                        appendFileLine: out_file$, row_file$
                    endif
                endif
            endfor
        else
            echo 【注意】 選択された段はインターバル段ではありません。
        endif
    else
        echo 【注意】 指定されたTier番号が存在しません（総段数: 'num_tiers'）。
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
    
    default_out$ = folder$ + "pitch_results.csv"
    
    beginPause: "ピッチ分析（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_labels", 0
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300, 女性・子供: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "結果保存先ファイル名（.csv または .tsv）:"
        sentence: "result_file", default_out$
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
        out_file$ = default_out$
    endif

    sep$ = tab$
    is_csv = 0
    if right$(out_file$, 4) == ".csv" or right$(out_file$, 4) == ".CSV"
        sep$ = ","
        is_csv = 1
    endif
    
    clearinfo
    header_display$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz"
    header_file$ = "Filename" + sep$ + "IntervalIndex" + sep$ + "Label" + sep$ + "StartTime_s" + sep$ + "EndTime_s" + sep$ + "Duration_ms" + sep$ + "MeanPitch_Hz" + sep$ + "MedianPitch_Hz" + sep$ + "MinPitch_Hz" + sep$ + "MaxPitch_Hz" + sep$ + "StDevPitch_Hz"
    appendInfoLine: header_display$
    writeFileLine: out_file$, header_file$
    
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
                        
                        should_skip = 0
                        if skip_empty = 1 and clean_label$ = ""
                            should_skip = 1
                        endif
                        
                        if should_skip = 0
                            selectObject: pitch
                            mean_f0 = Get mean: start_t, end_t, "Hertz"
                            median_f0 = Get quantile: start_t, end_t, 0.5, "Hertz"
                            min_f0 = Get minimum: start_t, end_t, "Hertz", "Parabolic"
                            max_f0 = Get maximum: start_t, end_t, "Hertz", "Parabolic"
                            stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                            
                            if mean_f0 = undefined
                                mean_str$ = "NA"
                            else
                                mean_str$ = fixed$(mean_f0, 2)
                            endif
                            
                            if median_f0 = undefined
                                med_str$ = "NA"
                            else
                                med_str$ = fixed$(median_f0, 2)
                            endif
                            
                            if min_f0 = undefined
                                min_str$ = "NA"
                            else
                                min_str$ = fixed$(min_f0, 2)
                            endif
                            
                            if max_f0 = undefined
                                max_str$ = "NA"
                            else
                                max_str$ = fixed$(max_f0, 2)
                            endif
                            
                            if stdev_f0 = undefined
                                std_str$ = "NA"
                            else
                                std_str$ = fixed$(stdev_f0, 2)
                            endif
                            
                            dur_ms = duration_s * 1000
                            row_display$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$
                            appendInfoLine: row_display$
                            
                            file_label$ = clean_label$
                            if is_csv and (index(file_label$, ",") > 0 or index(file_label$, """") > 0)
                                file_label$ = """" + replace_regex$(file_label$, """", """""", 0) + """"
                            endif
                            file_base$ = basename$
                            if is_csv and (index(file_base$, ",") > 0 or index(file_base$, """") > 0)
                                file_base$ = """" + replace_regex$(file_base$, """", """""", 0) + """"
                            endif
                            row_file$ = file_base$ + sep$ + string$(j) + sep$ + file_label$ + sep$ + fixed$(start_t, 4) + sep$ + fixed$(end_t, 4) + sep$ + fixed$(dur_ms, 2) + sep$ + mean_str$ + sep$ + med_str$ + sep$ + min_str$ + sep$ + max_str$ + sep$ + std_str$
                            appendFileLine: out_file$, row_file$
                        endif
                    endfor
                endif
            endif
            
            removeObject: sound
            removeObject: tg
            removeObject: pitch
        endif
    endfor
    
    removeObject: file_list
endif
