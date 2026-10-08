# ==============================================================================
# スクリプト名: calculate_segment_durations.praat (区間継続時間・デュレーションの一括計算)
# 
# 【概要】
# TextGrid の指定した段（Tier）の各区間の開始時刻、終了時刻、継続時間（秒およびミリ秒）を一覧集計します。
# 
# 【2大出力機能】
# 1. 【CSV/TSV・画面出力】: 全区間の継続時間（秒・ミリ秒）を、指定の見出し付きテーブルとして
#    Praatの画面（Infoウィンドウ）およびCSV/TSVファイルに完全出力します。
#    そのままExcelやスプレッドシートにコピペ・直接読み込み可能です。
# 2. 【TextGridへの書き込み】: 各区間の継続時間数値（例: "145.20ms"）を、TextGrid内に新しいTier
#    （duration段）として直接書き込み・保存可能です。
#
# 【ハイブリッド機能】
# - Praat上でTextGridを選択中 $\to$ 選択中のオブジェクトを即座に分析（パス指定不要）
# - Praat上で未選択 $\to$ 自動でフォルダ参照ダイアログが起動して一括処理
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: calculate_segment_durations.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

# 選択中のTextGridオブジェクト数を確認
num_selected = numberOfSelected("TextGrid")

if num_selected > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の TextGrid を直接分析（パス指定不要）
    # ==========================================================================
    beginPause: "区間継続時間の計算（選択オブジェクト分析）"
        comment: "Praat上で選択されている " + string$(num_selected) + " 個の TextGrid を分析します。"
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_intervals", 0
        comment: "TextGrid内に継続時間のTierを追加して書き込む:"
        boolean: "write_to_textgrid", 0
        comment: "結果をファイル(CSV/TSV)としても保存する:"
        boolean: "save_to_file", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_intervals
    do_write_tg = write_to_textgrid
    do_save_file = save_to_file
    
    out_file$ = ""
    if do_save_file
        out_file$ = chooseWriteFile$: "保存先のファイル名を指定してください (.csv または .tsv)", "duration_results.csv"
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

    # 選択されている全オブジェクトのIDを取得
    for i to num_selected
        tg_id[i] = selected("TextGrid", i)
    endfor

    # Praat画面の初期化と見出し出力
    clearinfo
    header_display$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    header_file$ = "ObjectName" + sep$ + "IntervalIndex" + sep$ + "Label" + sep$ + "StartTime_s" + sep$ + "EndTime_s" + sep$ + "Duration_s" + sep$ + "Duration_ms"
    appendInfoLine: header_display$
    
    if do_save_file and out_file$ <> ""
        writeFileLine: out_file$, header_file$
    endif
    
    total_intervals = 0
    
    for i to num_selected
        current_tg = tg_id[i]
        selectObject: current_tg
        name$ = selected$("TextGrid")
        
        num_tiers = Get number of tiers
        if target_tier <= num_tiers
            is_interval = Is interval tier: target_tier
            if is_interval == 1
                num_intervals = Get number of intervals: target_tier
                
                # TextGrid書き込み用の新しいTierを末尾に追加
                if do_write_tg
                    selectObject: current_tg
                    dur_tier_idx = num_tiers + 1
                    tier_label$ = "dur_t" + string$(target_tier) + "_ms"
                    Insert interval tier: dur_tier_idx, tier_label$
                endif
                
                for j to num_intervals
                    selectObject: current_tg
                    label$ = Get label of interval: target_tier, j
                    start_t = Get start time of interval: target_tier, j
                    end_t = Get end time of interval: target_tier, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    start_str$ = fixed$(start_t, 4)
                    end_str$ = fixed$(end_t, 4)
                    dur_s_str$ = fixed$(dur_s, 4)
                    dur_ms_str$ = fixed$(dur_ms, 2)
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    
                    if not (skip_empty and clean_label$ == "")
                        row_display$ = name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + start_str$ + tab$ + end_str$ + tab$ + dur_s_str$ + tab$ + dur_ms_str$
                        appendInfoLine: row_display$
                        
                        if do_save_file and out_file$ <> ""
                            file_label$ = clean_label$
                            if is_csv and (index(file_label$, ",") > 0 or index(file_label$, """") > 0)
                                file_label$ = """" + replace_regex$(file_label$, """", """""", 0) + """"
                            endif
                            file_name$ = name$
                            if is_csv and (index(file_name$, ",") > 0 or index(file_name$, """") > 0)
                                file_name$ = """" + replace_regex$(file_name$, """", """""", 0) + """"
                            endif
                            row_file$ = file_name$ + sep$ + string$(j) + sep$ + file_label$ + sep$ + start_str$ + sep$ + end_str$ + sep$ + dur_s_str$ + sep$ + dur_ms_str$
                            appendFileLine: out_file$, row_file$
                        endif
                        total_intervals = total_intervals + 1
                        
                        # TextGridに継続時間(ms)を書き込む
                        if do_write_tg
                            selectObject: current_tg
                            if start_t > 0
                                int_at_start = Get interval at time: dur_tier_idx, start_t
                                int_start_time = Get start time of interval: dur_tier_idx, int_at_start
                                if abs(int_start_time - start_t) > 0.0001
                                    Insert boundary: dur_tier_idx, start_t
                                endif
                            endif
                            if end_t < Get total duration
                                int_at_end = Get interval at time: dur_tier_idx, end_t
                                int_end_time = Get end time of interval: dur_tier_idx, int_at_end
                                if abs(int_end_time - end_t) > 0.0001
                                    Insert boundary: dur_tier_idx, end_t
                                endif
                            endif
                            mid_t = (start_t + end_t) / 2
                            target_int = Get interval at time: dur_tier_idx, mid_t
                            Set interval text: dur_tier_idx, target_int, dur_ms_str$ + "ms"
                        endif
                    endif
                endfor
            endif
        endif
    endfor

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "TextGridファイルが入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    # パス末尾のセパレータ補正
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    default_out$ = folder$ + "duration_results.csv"
    
    beginPause: "区間継続時間の計算（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "対象ファイルの拡張子:"
        sentence: "extension", ".TextGrid"
        comment: "空白ラベル（無音区間など）を除外する（チェックを外すと全区間を測定）:"
        boolean: "skip_empty_intervals", 0
        comment: "TextGridファイル自体にも継続時間Tierを追加・上書き保存する:"
        boolean: "write_to_textgrid", 0
        comment: "結果保存先ファイル名（.csv または .tsv）:"
        sentence: "result_file", default_out$
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    ext$ = extension$
    skip_empty = skip_empty_intervals
    do_write_tg = write_to_textgrid
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
    
    # Praat画面の初期化と見出し出力
    clearinfo
    header_display$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    header_file$ = "ObjectName" + sep$ + "IntervalIndex" + sep$ + "Label" + sep$ + "StartTime_s" + sep$ + "EndTime_s" + sep$ + "Duration_s" + sep$ + "Duration_ms"
    appendInfoLine: header_display$
    
    writeFileLine: out_file$, header_file$
    
    file_list = Create Strings as file list: "fileList", folder$ + "*" + ext$
    num_files = Get number of strings
    
    if num_files = 0
        removeObject: file_list
        exitScript: "【エラー】フォルダ内に " + ext$ + " ファイルが見つかりませんでした: " + folder$
    endif
    
    total_intervals = 0
    
    for i to num_files
        selectObject: file_list
        filename$ = Get string: i
        basename$ = filename$ - ext$
        
        tg_path$ = folder$ + filename$
        tg = Read from file: tg_path$
        selectObject: tg
        num_tiers = Get number of tiers
        
        if target_tier <= num_tiers
            is_interval = Is interval tier: target_tier
            if is_interval == 1
                num_intervals = Get number of intervals: target_tier
                
                if do_write_tg
                    selectObject: tg
                    dur_tier_idx = num_tiers + 1
                    tier_label$ = "dur_t" + string$(target_tier) + "_ms"
                    Insert interval tier: dur_tier_idx, tier_label$
                endif
                
                for j to num_intervals
                    selectObject: tg
                    label$ = Get label of interval: target_tier, j
                    start_t = Get start time of interval: target_tier, j
                    end_t = Get end time of interval: target_tier, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    start_str$ = fixed$(start_t, 4)
                    end_str$ = fixed$(end_t, 4)
                    dur_s_str$ = fixed$(dur_s, 4)
                    dur_ms_str$ = fixed$(dur_ms, 2)
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    
                    if not (skip_empty and clean_label$ == "")
                        row_display$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + start_str$ + tab$ + end_str$ + tab$ + dur_s_str$ + tab$ + dur_ms_str$
                        appendInfoLine: row_display$
                        
                        file_label$ = clean_label$
                        if is_csv and (index(file_label$, ",") > 0 or index(file_label$, """") > 0)
                            file_label$ = """" + replace_regex$(file_label$, """", """""", 0) + """"
                        endif
                        file_base$ = basename$
                        if is_csv and (index(file_base$, ",") > 0 or index(file_base$, """") > 0)
                            file_base$ = """" + replace_regex$(file_base$, """", """""", 0) + """"
                        endif
                        row_file$ = file_base$ + sep$ + string$(j) + sep$ + file_label$ + sep$ + start_str$ + sep$ + end_str$ + sep$ + dur_s_str$ + sep$ + dur_ms_str$
                        appendFileLine: out_file$, row_file$
                        total_intervals = total_intervals + 1
                        
                        if do_write_tg
                            selectObject: tg
                            if start_t > 0
                                int_at_start = Get interval at time: dur_tier_idx, start_t
                                int_start_time = Get start time of interval: dur_tier_idx, int_at_start
                                if abs(int_start_time - start_t) > 0.0001
                                    Insert boundary: dur_tier_idx, start_t
                                endif
                            endif
                            if end_t < Get total duration
                                int_at_end = Get interval at time: dur_tier_idx, end_t
                                int_end_time = Get end time of interval: dur_tier_idx, int_at_end
                                if abs(int_end_time - end_t) > 0.0001
                                    Insert boundary: dur_tier_idx, end_t
                                endif
                            endif
                            mid_t = (start_t + end_t) / 2
                            target_int = Get interval at time: dur_tier_idx, mid_t
                            Set interval text: dur_tier_idx, target_int, dur_ms_str$ + "ms"
                        endif
                    endif
                endfor
                
                if do_write_tg
                    selectObject: tg
                    Save as text file: tg_path$
                endif
            endif
        endif
        
        removeObject: tg
    endfor
    
    removeObject: file_list
endif
