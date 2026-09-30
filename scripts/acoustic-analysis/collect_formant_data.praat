# ==============================================================================
# スクリプト名: collect_formant_data.praat (フォルマントデータの一括抽出)
# 
# 【概要】
# 音声と TextGrid から、指定した段（Tier）の各ラベル区間の中央点（50%地点）における
# フォルマント周波数（F1〜F5）および帯域幅（B1〜B3）を自動測定します。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクト分析モード】
#    Praat上で Sound と TextGrid を選択している場合、
#    パス指定なしで即座に分析し、画面（Infoウィンドウ）に結果を表示します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内の同名ペアを一括集計し、同じフォルダ内に "formant_results.tsv"
#    を自動保存します。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: collect_formant_data_from_files.praat)
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
    beginPause: "フォルマント分析（選択オブジェクト）"
        comment: "Praat上で選択されている Sound / TextGrid を分析します。"
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_labels", 0
        comment: "最大フォルマント周波数（女性: 5500, 男性: 5000, 子供: 8000 Hz）:"
        positive: "max_formant_hz", 5500
        comment: "最大フォルマント数:"
        integer: "max_num_formants", 5
        comment: "結果をTSVファイルとしても保存する:"
        boolean: "save_to_tsv", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    max_f_hz = max_formant_hz
    max_n_formants = max_num_formants
    do_save_tsv = save_to_tsv
    
    tsv_out_file$ = ""
    if do_save_tsv
        tsv_out_file$ = chooseWriteFile$: "保存先のTSVファイル名を指定してください", "formant_results.tsv"
        if tsv_out_file$ == ""
            do_save_tsv = 0
        endif
    endif

    sound_id = selected("Sound", 1)
    tg_id = selected("TextGrid", 1)
    
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    clearinfo
    header$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MidTime_s" + tab$ + "F1_Hz" + tab$ + "F2_Hz" + tab$ + "F3_Hz" + tab$ + "F4_Hz" + tab$ + "F5_Hz" + tab$ + "B1_Hz" + tab$ + "B2_Hz" + tab$ + "B3_Hz"
    appendInfoLine: header$
    
    if do_save_tsv and tsv_out_file$ <> ""
        writeFileLine: tsv_out_file$, header$
    endif
    
    # フォルマント解析オブジェクト作成 (Burg法)
    selectObject: sound_id
    formant = To Formant (burg): 0.01, max_n_formants, max_f_hz, 0.025, 50
    
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
                mid_t = start_t + (duration_s / 2)
                
                clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                
                should_skip = 0
                if skip_empty = 1 and clean_label$ = ""
                    should_skip = 1
                endif
                
                if should_skip = 0
                    selectObject: formant
                    f1 = Get value at time: 1, mid_t, "Hertz", "Linear"
                    f2 = Get value at time: 2, mid_t, "Hertz", "Linear"
                    f3 = Get value at time: 3, mid_t, "Hertz", "Linear"
                    f4 = Get value at time: 4, mid_t, "Hertz", "Linear"
                    f5 = Get value at time: 5, mid_t, "Hertz", "Linear"
                    b1 = Get bandwidth at time: 1, mid_t, "Hertz", "Linear"
                    b2 = Get bandwidth at time: 2, mid_t, "Hertz", "Linear"
                    b3 = Get bandwidth at time: 3, mid_t, "Hertz", "Linear"
                    
                    # undefined の安全な文字列化
                    f1$ = if f1 = undefined then "NA" else fixed$(f1, 2) endif
                    if f1 = undefined
                        f1$ = "NA"
                    else
                        f1$ = fixed$(f1, 2)
                    endif
                    if f2 = undefined
                        f2$ = "NA"
                    else
                        f2$ = fixed$(f2, 2)
                    endif
                    if f3 = undefined
                        f3$ = "NA"
                    else
                        f3$ = fixed$(f3, 2)
                    endif
                    if f4 = undefined
                        f4$ = "NA"
                    else
                        f4$ = fixed$(f4, 2)
                    endif
                    if f5 = undefined
                        f5$ = "NA"
                    else
                        f5$ = fixed$(f5, 2)
                    endif
                    if b1 = undefined
                        b1$ = "NA"
                    else
                        b1$ = fixed$(b1, 2)
                    endif
                    if b2 = undefined
                        b2$ = "NA"
                    else
                        b2$ = fixed$(b2, 2)
                    endif
                    if b3 = undefined
                        b3$ = "NA"
                    else
                        b3$ = fixed$(b3, 2)
                    endif
                    
                    dur_ms = duration_s * 1000
                    row$ = sound_name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + fixed$(mid_t, 4) + tab$ + f1$ + tab$ + f2$ + tab$ + f3$ + tab$ + f4$ + tab$ + f5$ + tab$ + b1$ + tab$ + b2$ + tab$ + b3$
                    appendInfoLine: row$
                    
                    if do_save_tsv and tsv_out_file$ <> ""
                        appendFileLine: tsv_out_file$, row$
                    endif
                endif
            endfor
        else
            echo 【注意】 選択された段はインターバル段ではありません。
        endif
    else
        echo 【注意】 指定されたTier番号が存在しません（総段数: 'num_tiers'）。
    endif
    
    removeObject: formant

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "音声(WAV)とTextGridが入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    default_tsv$ = folder$ + "formant_results.tsv"
    
    beginPause: "フォルマント分析（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_labels", 0
        comment: "最大フォルマント周波数（女性: 5500, 男性: 5000, 子供: 8000 Hz）:"
        positive: "max_formant_hz", 5500
        comment: "最大フォルマント数:"
        integer: "max_num_formants", 5
        comment: "結果保存先のTSVファイル名:"
        sentence: "result_file", default_tsv$
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    max_f_hz = max_formant_hz
    max_n_formants = max_num_formants
    out_file$ = result_file$
    
    if out_file$ == ""
        out_file$ = default_tsv$
    endif
    
    clearinfo
    header$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MidTime_s" + tab$ + "F1_Hz" + tab$ + "F2_Hz" + tab$ + "F3_Hz" + tab$ + "F4_Hz" + tab$ + "F5_Hz" + tab$ + "B1_Hz" + tab$ + "B2_Hz" + tab$ + "B3_Hz"
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
            formant = To Formant (burg): 0.01, max_n_formants, max_f_hz, 0.025, 50
            
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
                        mid_t = start_t + (duration_s / 2)
                        
                        clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                        
                        should_skip = 0
                        if skip_empty = 1 and clean_label$ = ""
                            should_skip = 1
                        endif
                        
                        if should_skip = 0
                            selectObject: formant
                            f1 = Get value at time: 1, mid_t, "Hertz", "Linear"
                            f2 = Get value at time: 2, mid_t, "Hertz", "Linear"
                            f3 = Get value at time: 3, mid_t, "Hertz", "Linear"
                            f4 = Get value at time: 4, mid_t, "Hertz", "Linear"
                            f5 = Get value at time: 5, mid_t, "Hertz", "Linear"
                            b1 = Get bandwidth at time: 1, mid_t, "Hertz", "Linear"
                            b2 = Get bandwidth at time: 2, mid_t, "Hertz", "Linear"
                            b3 = Get bandwidth at time: 3, mid_t, "Hertz", "Linear"
                            
                            if f1 = undefined
                                f1$ = "NA"
                            else
                                f1$ = fixed$(f1, 2)
                            endif
                            if f2 = undefined
                                f2$ = "NA"
                            else
                                f2$ = fixed$(f2, 2)
                            endif
                            if f3 = undefined
                                f3$ = "NA"
                            else
                                f3$ = fixed$(f3, 2)
                            endif
                            if f4 = undefined
                                f4$ = "NA"
                            else
                                f4$ = fixed$(f4, 2)
                            endif
                            if f5 = undefined
                                f5$ = "NA"
                            else
                                f5$ = fixed$(f5, 2)
                            endif
                            if b1 = undefined
                                b1$ = "NA"
                            else
                                b1$ = fixed$(b1, 2)
                            endif
                            if b2 = undefined
                                b2$ = "NA"
                            else
                                b2$ = fixed$(b2, 2)
                            endif
                            if b3 = undefined
                                b3$ = "NA"
                            else
                                b3$ = fixed$(b3, 2)
                            endif
                            
                            dur_ms = duration_s * 1000
                            row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + fixed$(mid_t, 4) + tab$ + f1$ + tab$ + f2$ + tab$ + f3$ + tab$ + f4$ + tab$ + f5$ + tab$ + b1$ + tab$ + b2$ + tab$ + b3$
                            appendInfoLine: row$
                            appendFileLine: out_file$, row$
                        endif
                    endfor
                endif
            endif
            
            removeObject: sound
            removeObject: tg
            removeObject: formant
        endif
    endfor
    
    removeObject: file_list
endif
