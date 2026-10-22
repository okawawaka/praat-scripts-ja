# ==============================================================================
# スクリプト名: collect_pitch_data.praat (ピッチ・F0統計量の一括抽出)
# 
# 【概要】
# 音声と TextGrid から、指定した段（Tier）の各ラベル区間におけるピッチ（基本周波数 F0）の
# 平均値（Mean）、中央値（Median）、最小値（Min）、最大値（Max）、標準偏差（StDev）、
# および四分位数（Q25, Q75）を自動測定して一覧集計します。
# 
# 【四分位数(IQR)による異常値・倍音・半周波音フィルタリング機能】
# 音声分析で頻発するオクターブ跳躍（倍音誤検出: F0が2倍になる現象）や
# オクターブドロップ（半周波誤検出: F0が半分になる現象）、ノイズによる外れ値を
# 音響音声学で標準的な「四分位範囲（IQR / Tukey's fences）」によって自動検出し排除します。
# 
# 【単一話者／複数話者（対話）への両対応モード】
# 1. 「ファイル全体」基準（単一話者向け）:
#    話者適応型 2-Pass 最適ピッチ抽出 (De Looze & Hirst法) とファイル全体の四分位数により、
#    母音1音などの極めて短い区間でも安定して倍音・半周波音を排除します。
# 2. 「発話区間ごと」基準（複数話者・対話録音向け）:
#    各区間（インターバル）ごとにその発話者のピッチ分布から四分位数を局所計算するため、
#    男性（低音）と女性（高音）が混在する対話音声でも誤判定を起こさず安全に測定できます。
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
        plusObject: matching_tg
        num_tg = 1
    endif
elsif num_tg > 0 and num_sound == 0
    tg_id = selected("TextGrid", 1)
    selectObject: tg_id
    tg_name$ = selected$("TextGrid")
    matching_sound = Find Object: "Sound " + tg_name$
    if matching_sound > 0
        plusObject: matching_sound
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
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100, 対話混合: 60 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300〜500, 女性・子供: 500〜600, 対話混合: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "四分位数(IQR)による異常値（倍音・半周波音）の自動排除:"
        boolean: "filter_pitch_outliers", 1
        comment: "外れ値判定の計算単位（単一話者ならファイル全体、複数話者・対話なら区間ごと）:"
        choice: "filter_scope", 1
            option: "ファイル全体（単一話者・短区間でも安定）"
            option: "発話区間ごと（複数話者・対話録音向け）"
        comment: "外れ値判定のIQR倍率（標準: 1.5。1.0〜1.5推奨）:"
        positive: "iqr_multiplier", 1.5
        comment: "TSVで保存（タブ区切り .tsv）:"
        boolean: "save_to_tsv", 0
        comment: "CSVで保存（カンマ区切り .csv）:"
        boolean: "save_to_csv", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    p_floor = pitch_floor_hz
    p_ceil = pitch_ceiling_hz
    do_filter_outliers = filter_pitch_outliers
    f_scope = filter_scope
    iqr_mult = iqr_multiplier
    do_save_tsv = save_to_tsv
    do_save_csv = save_to_csv
    
    tsv_out_file$ = ""
    if do_save_tsv
        tsv_out_file$ = chooseWriteFile$: "TSVファイルの保存先を指定してください", "pitch_results.tsv"
        if tsv_out_file$ == ""
            do_save_tsv = 0
        elsif right$(tsv_out_file$, 4) <> ".tsv" and right$(tsv_out_file$, 4) <> ".TSV"
            tsv_out_file$ = tsv_out_file$ + ".tsv"
        endif
    endif

    csv_out_file$ = ""
    if do_save_csv
        csv_out_file$ = chooseWriteFile$: "CSVファイルの保存先を指定してください", "pitch_results.csv"
        if csv_out_file$ == ""
            do_save_csv = 0
        elsif right$(csv_out_file$, 4) <> ".csv" and right$(csv_out_file$, 4) <> ".CSV"
            csv_out_file$ = csv_out_file$ + ".csv"
        endif
    endif

    sound_id = selected("Sound", 1)
    tg_id = selected("TextGrid", 1)
    
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    clearinfo
    header_tsv$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz" + tab$ + "Q25Pitch_Hz" + tab$ + "Q75Pitch_Hz"
    header_csv$ = "ObjectName,IntervalIndex,Label,StartTime_s,EndTime_s,Duration_ms,MeanPitch_Hz,MedianPitch_Hz,MinPitch_Hz,MaxPitch_Hz,StDevPitch_Hz,Q25Pitch_Hz,Q75Pitch_Hz"
    appendInfoLine: header_tsv$
    
    if do_save_tsv and tsv_out_file$ <> ""
        writeFileLine: tsv_out_file$, header_tsv$
    endif
    if do_save_csv and csv_out_file$ <> ""
        writeFileLine: csv_out_file$, header_csv$
    endif
    
    # ピッチオブジェクト生成
    selectObject: sound_id
    pitch_init = To Pitch: 0.0, p_floor, p_ceil
    
    if do_filter_outliers
        if f_scope == 1
            # ------------------------------------------------------------------
            # 【方式1: ファイル全体】単一話者の音声向け（極短区間でも安定）
            # ------------------------------------------------------------------
            selectObject: pitch_init
            q25_all = Get quantile: 0.0, 0.0, 0.25, "Hertz"
            q50_all = Get quantile: 0.0, 0.0, 0.50, "Hertz"
            q75_all = Get quantile: 0.0, 0.0, 0.75, "Hertz"
            
            if q25_all <> undefined and q75_all <> undefined and q50_all <> undefined
                # Step 1: 話者適応型 2-Pass 最適ピッチ抽出 (De Looze & Hirst法)
                opt_floor = round(q25_all * 0.75)
                opt_ceiling = round(q75_all * 1.50)
                
                if opt_floor < p_floor
                    opt_floor = p_floor
                endif
                if opt_ceiling > p_ceil
                    opt_ceiling = p_ceil
                endif
                
                if opt_floor < opt_ceiling
                    selectObject: sound_id
                    pitch_opt = To Pitch: 0.0, opt_floor, opt_ceiling
                    removeObject: pitch_init
                    pitch = pitch_opt
                else
                    pitch = pitch_init
                endif
                
                # Step 2: 四分位数（IQR法 / Tukey's fences）による倍音・半周波・異常値フレーム除外
                selectObject: pitch
                q25 = Get quantile: 0.0, 0.0, 0.25, "Hertz"
                q50 = Get quantile: 0.0, 0.0, 0.50, "Hertz"
                q75 = Get quantile: 0.0, 0.0, 0.75, "Hertz"
                
                if q25 <> undefined and q75 <> undefined and q50 <> undefined
                    iqr = q75 - q25
                    min_iqr = q50 * 0.15
                    if min_iqr < 20.0
                        min_iqr = 20.0
                    endif
                    if iqr < min_iqr
                        iqr = min_iqr
                    endif
                    
                    cutoff_low = q25 - iqr_mult * iqr
                    cutoff_high = q75 + iqr_mult * iqr
                    
                    octave_low = q50 * 0.55
                    octave_high = q50 * 1.85
                    if cutoff_low < octave_low
                        cutoff_low = octave_low
                    endif
                    if cutoff_high > octave_high
                        cutoff_high = octave_high
                    endif
                    
                    if cutoff_low < p_floor
                        cutoff_low = p_floor
                    endif
                    if cutoff_high > p_ceil
                        cutoff_high = p_ceil
                    endif
                    
                    Formula: "if self < " + string$(cutoff_low) + " or self > " + string$(cutoff_high) + " then undefined else self fi"
                endif
            else
                pitch = pitch_init
            endif
        else
            # ------------------------------------------------------------------
            # 【方式2: 発話区間ごと】複数話者・対話の音声向け（話者混在でも安全）
            # ------------------------------------------------------------------
            pitch = pitch_init
            
            selectObject: tg_id
            num_tiers_chk = Get number of tiers
            if target_tier <= num_tiers_chk
                is_int_chk = Is interval tier: target_tier
                if is_int_chk == 1
                    n_int_chk = Get number of intervals: target_tier
                    for k to n_int_chk
                        selectObject: tg_id
                        k_start = Get start time of interval: target_tier, k
                        k_end = Get end time of interval: target_tier, k
                        
                        selectObject: pitch
                        k_q25 = Get quantile: k_start, k_end, 0.25, "Hertz"
                        k_q50 = Get quantile: k_start, k_end, 0.50, "Hertz"
                        k_q75 = Get quantile: k_start, k_end, 0.75, "Hertz"
                        
                        if k_q25 <> undefined and k_q75 <> undefined and k_q50 <> undefined
                            k_iqr = k_q75 - k_q25
                            k_min_iqr = k_q50 * 0.15
                            if k_min_iqr < 20.0
                                k_min_iqr = 20.0
                            endif
                            if k_iqr < k_min_iqr
                                k_iqr = k_min_iqr
                            endif
                            
                            k_c_low = k_q25 - iqr_mult * k_iqr
                            k_c_high = k_q75 + iqr_mult * k_iqr
                            
                            k_oct_low = k_q50 * 0.55
                            k_oct_high = k_q50 * 1.85
                            if k_c_low < k_oct_low
                                k_c_low = k_oct_low
                            endif
                            if k_c_high > k_oct_high
                                k_c_high = k_oct_high
                            endif
                            
                            if k_c_low < p_floor
                                k_c_low = p_floor
                            endif
                            if k_c_high > p_ceil
                                k_c_high = p_ceil
                            endif
                            
                            Formula: "if x >= " + string$(k_start) + " and x <= " + string$(k_end) + " and (self < " + string$(k_c_low) + " or self > " + string$(k_c_high) + ") then undefined else self fi"
                        endif
                    endfor
                endif
            endif
        endif
    else
        pitch = pitch_init
    endif
    
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
                    min_f0 = Get minimum: start_t, end_t, "Hertz", "None"
                    max_f0 = Get maximum: start_t, end_t, "Hertz", "None"
                    stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                    q25_f0 = Get quantile: start_t, end_t, 0.25, "Hertz"
                    q75_f0 = Get quantile: start_t, end_t, 0.75, "Hertz"
                    
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

                    if q25_f0 = undefined
                        q25_str$ = "NA"
                    else
                        q25_str$ = fixed$(q25_f0, 2)
                    endif

                    if q75_f0 = undefined
                        q75_str$ = "NA"
                    else
                        q75_str$ = fixed$(q75_f0, 2)
                    endif
                    
                    dur_ms = duration_s * 1000
                    row_tsv$ = sound_name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$ + tab$ + q25_str$ + tab$ + q75_str$
                    appendInfoLine: row_tsv$
                    
                    if do_save_tsv and tsv_out_file$ <> ""
                        appendFileLine: tsv_out_file$, row_tsv$
                    endif
                    if do_save_csv and csv_out_file$ <> ""
                        csv_label$ = clean_label$
                        if index(csv_label$, ",") > 0 or index(csv_label$, """") > 0
                            csv_label$ = """" + replace_regex$(csv_label$, """", """""", 0) + """"
                        endif
                        csv_sound$ = sound_name$
                        if index(csv_sound$, ",") > 0 or index(csv_sound$, """") > 0
                            csv_sound$ = """" + replace_regex$(csv_sound$, """", """""", 0) + """"
                        endif
                        row_csv$ = csv_sound$ + "," + string$(j) + "," + csv_label$ + "," + fixed$(start_t, 4) + "," + fixed$(end_t, 4) + "," + fixed$(dur_ms, 2) + "," + mean_str$ + "," + med_str$ + "," + min_str$ + "," + max_str$ + "," + std_str$ + "," + q25_str$ + "," + q75_str$
                        appendFileLine: csv_out_file$, row_csv$
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
    
    tsv_out_file$ = folder$ + "pitch_results.tsv"
    csv_out_file$ = folder$ + "pitch_results.csv"
    
    beginPause: "ピッチ分析（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_labels", 0
        comment: "ピッチ探索下限（男性: 75, 女性・子供: 100, 対話混合: 60 Hz）:"
        positive: "pitch_floor_hz", 75.0
        comment: "ピッチ探索上限（男性: 300〜500, 女性・子供: 500〜600, 対話混合: 500〜600 Hz）:"
        positive: "pitch_ceiling_hz", 500.0
        comment: "四分位数(IQR)による異常値（倍音・半周波音）の自動排除:"
        boolean: "filter_pitch_outliers", 1
        comment: "外れ値判定の計算単位（単一話者ならファイル全体、複数話者・対話なら区間ごと）:"
        choice: "filter_scope", 1
            option: "ファイル全体（単一話者・短区間でも安定）"
            option: "発話区間ごと（複数話者・対話録音向け）"
        comment: "外れ値判定のIQR倍率（標準: 1.5。1.0〜1.5推奨）:"
        positive: "iqr_multiplier", 1.5
        comment: "TSVで保存 (pitch_results.tsv):"
        boolean: "save_to_tsv", 1
        comment: "CSVで保存 (pitch_results.csv):"
        boolean: "save_to_csv", 1
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_labels
    p_floor = pitch_floor_hz
    p_ceil = pitch_ceiling_hz
    do_filter_outliers = filter_pitch_outliers
    f_scope = filter_scope
    iqr_mult = iqr_multiplier
    do_save_tsv = save_to_tsv
    do_save_csv = save_to_csv
    
    clearinfo
    header_tsv$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_ms" + tab$ + "MeanPitch_Hz" + tab$ + "MedianPitch_Hz" + tab$ + "MinPitch_Hz" + tab$ + "MaxPitch_Hz" + tab$ + "StDevPitch_Hz" + tab$ + "Q25Pitch_Hz" + tab$ + "Q75Pitch_Hz"
    header_csv$ = "Filename,IntervalIndex,Label,StartTime_s,EndTime_s,Duration_ms,MeanPitch_Hz,MedianPitch_Hz,MinPitch_Hz,MaxPitch_Hz,StDevPitch_Hz,Q25Pitch_Hz,Q75Pitch_Hz"
    appendInfoLine: header_tsv$
    
    if do_save_tsv
        writeFileLine: tsv_out_file$, header_tsv$
    endif
    if do_save_csv
        writeFileLine: csv_out_file$, header_csv$
    endif
    
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
            
            # ピッチオブジェクト生成
            selectObject: sound
            pitch_init = To Pitch: 0.0, p_floor, p_ceil
            
            if do_filter_outliers
                if f_scope == 1
                    # ----------------------------------------------------------
                    # 【方式1: ファイル全体】単一話者の音声向け（極短区間でも安定）
                    # ----------------------------------------------------------
                    selectObject: pitch_init
                    q25_all = Get quantile: 0.0, 0.0, 0.25, "Hertz"
                    q50_all = Get quantile: 0.0, 0.0, 0.50, "Hertz"
                    q75_all = Get quantile: 0.0, 0.0, 0.75, "Hertz"
                    
                    if q25_all <> undefined and q75_all <> undefined and q50_all <> undefined
                        # Step 1: 話者適応型 2-Pass 最適ピッチ抽出 (De Looze & Hirst法)
                        opt_floor = round(q25_all * 0.75)
                        opt_ceiling = round(q75_all * 1.50)
                        
                        if opt_floor < p_floor
                            opt_floor = p_floor
                        endif
                        if opt_ceiling > p_ceil
                            opt_ceiling = p_ceil
                        endif
                        
                        if opt_floor < opt_ceiling
                            selectObject: sound
                            pitch_opt = To Pitch: 0.0, opt_floor, opt_ceiling
                            removeObject: pitch_init
                            pitch = pitch_opt
                        else
                            pitch = pitch_init
                        endif
                        
                        # Step 2: 四分位数（IQR法 / Tukey's fences）による倍音・半周波・異常値フレーム除外
                        selectObject: pitch
                        q25 = Get quantile: 0.0, 0.0, 0.25, "Hertz"
                        q50 = Get quantile: 0.0, 0.0, 0.50, "Hertz"
                        q75 = Get quantile: 0.0, 0.0, 0.75, "Hertz"
                        
                        if q25 <> undefined and q75 <> undefined and q50 <> undefined
                            iqr = q75 - q25
                            min_iqr = q50 * 0.15
                            if min_iqr < 20.0
                                min_iqr = 20.0
                            endif
                            if iqr < min_iqr
                                iqr = min_iqr
                            endif
                            
                            cutoff_low = q25 - iqr_mult * iqr
                            cutoff_high = q75 + iqr_mult * iqr
                            
                            octave_low = q50 * 0.55
                            octave_high = q50 * 1.85
                            if cutoff_low < octave_low
                                cutoff_low = octave_low
                            endif
                            if cutoff_high > octave_high
                                cutoff_high = octave_high
                            endif
                            
                            if cutoff_low < p_floor
                                cutoff_low = p_floor
                            endif
                            if cutoff_high > p_ceil
                                cutoff_high = p_ceil
                            endif
                            
                            Formula: "if self < " + string$(cutoff_low) + " or self > " + string$(cutoff_high) + " then undefined else self fi"
                        endif
                    else
                        pitch = pitch_init
                    endif
                else
                    # ----------------------------------------------------------
                    # 【方式2: 発話区間ごと】複数話者・対話の音声向け（話者混在でも安全）
                    # ----------------------------------------------------------
                    pitch = pitch_init
                    
                    selectObject: tg
                    num_tiers_chk = Get number of tiers
                    if target_tier <= num_tiers_chk
                        is_int_chk = Is interval tier: target_tier
                        if is_int_chk == 1
                            n_int_chk = Get number of intervals: target_tier
                            for k to n_int_chk
                                selectObject: tg
                                k_start = Get start time of interval: target_tier, k
                                k_end = Get end time of interval: target_tier, k
                                
                                selectObject: pitch
                                k_q25 = Get quantile: k_start, k_end, 0.25, "Hertz"
                                k_q50 = Get quantile: k_start, k_end, 0.50, "Hertz"
                                k_q75 = Get quantile: k_start, k_end, 0.75, "Hertz"
                                
                                if k_q25 <> undefined and k_q75 <> undefined and k_q50 <> undefined
                                    k_iqr = k_q75 - k_q25
                                    k_min_iqr = k_q50 * 0.15
                                    if k_min_iqr < 20.0
                                        k_min_iqr = 20.0
                                    endif
                                    if k_iqr < k_min_iqr
                                        k_iqr = k_min_iqr
                                    endif
                                    
                                    k_c_low = k_q25 - iqr_mult * k_iqr
                                    k_c_high = k_q75 + iqr_mult * k_iqr
                                    
                                    k_oct_low = k_q50 * 0.55
                                    k_oct_high = k_q50 * 1.85
                                    if k_c_low < k_oct_low
                                        k_c_low = k_oct_low
                                    endif
                                    if k_c_high > k_oct_high
                                        k_c_high = k_oct_high
                                    endif
                                    
                                    if k_c_low < p_floor
                                        k_c_low = p_floor
                                    endif
                                    if k_c_high > p_ceil
                                        k_c_high = p_ceil
                                    endif
                                    
                                    Formula: "if x >= " + string$(k_start) + " and x <= " + string$(k_end) + " and (self < " + string$(k_c_low) + " or self > " + string$(k_c_high) + ") then undefined else self fi"
                                endif
                            endfor
                        endif
                    endif
                endif
            else
                pitch = pitch_init
            endif
            
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
                            min_f0 = Get minimum: start_t, end_t, "Hertz", "None"
                            max_f0 = Get maximum: start_t, end_t, "Hertz", "None"
                            stdev_f0 = Get standard deviation: start_t, end_t, "Hertz"
                            q25_f0 = Get quantile: start_t, end_t, 0.25, "Hertz"
                            q75_f0 = Get quantile: start_t, end_t, 0.75, "Hertz"
                            
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

                            if q25_f0 = undefined
                                q25_str$ = "NA"
                            else
                                q25_str$ = fixed$(q25_f0, 2)
                            endif

                            if q75_f0 = undefined
                                q75_str$ = "NA"
                            else
                                q75_str$ = fixed$(q75_f0, 2)
                            endif
                            
                            dur_ms = duration_s * 1000
                            row_tsv$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_ms, 2) + tab$ + mean_str$ + tab$ + med_str$ + tab$ + min_str$ + tab$ + max_str$ + tab$ + std_str$ + tab$ + q25_str$ + tab$ + q75_str$
                            appendInfoLine: row_tsv$
                            
                            if do_save_tsv
                                appendFileLine: tsv_out_file$, row_tsv$
                            endif
                            if do_save_csv
                                csv_label$ = clean_label$
                                if index(csv_label$, ",") > 0 or index(csv_label$, """") > 0
                                    csv_label$ = """" + replace_regex$(csv_label$, """", """""", 0) + """"
                                endif
                                csv_base$ = basename$
                                if index(csv_base$, ",") > 0 or index(csv_base$, """") > 0
                                    csv_base$ = """" + replace_regex$(csv_base$, """", """""", 0) + """"
                                endif
                                row_csv$ = csv_base$ + "," + string$(j) + "," + csv_label$ + "," + fixed$(start_t, 4) + "," + fixed$(end_t, 4) + "," + fixed$(dur_ms, 2) + "," + mean_str$ + "," + med_str$ + "," + min_str$ + "," + max_str$ + "," + std_str$ + "," + q25_str$ + "," + q75_str$
                                appendFileLine: csv_out_file$, row_csv$
                            endif
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
