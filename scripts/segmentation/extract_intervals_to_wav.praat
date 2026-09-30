# ==============================================================================
# スクリプト名: extract_intervals_to_wav.praat (音声区間の一括切り出し)
# 
# 【概要】
# 音声ファイル（WAV）と対応する TextGrid から、指定した段（Tier）の各ラベル区間を
# 個別の WAV 音声ファイルとして一括切り出し保存します。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクトモード】
#    Praat上で Sound と TextGrid を選択している場合、そのオブジェクトから即座に切り出します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内の同名ペアを一括切り出しし、同じフォルダ内の "extracted/"
#    フォルダに自動保存します。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: praat-script-extract-utterances.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

num_sound = numberOfSelected("Sound")
num_tg = numberOfSelected("TextGrid")

if num_sound > 0 and num_tg > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound と TextGrid を直接切り出し
    # ==========================================================================
    beginPause: "音声区間の切り出し（選択オブジェクト）"
        comment: "Praat上で選択されている Sound / TextGrid から切り出します。"
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_intervals", 1
        comment: "連番をファイル名に含める（例: sound_1_label.wav）:"
        boolean: "include_file_index", 1
    clicked = endPause: "キャンセル", "保存先フォルダを選択", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    out_dir$ = chooseDirectory$: "切り出したWAVファイルを保存するフォルダを選択してください"
    if out_dir$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    if right$(out_dir$, 1) <> "/" and right$(out_dir$, 1) <> "\"
        out_dir$ = out_dir$ + "/"
    endif

    target_tier = tier_number
    skip_empty = skip_empty_intervals
    do_index = include_file_index
    
    sound_id = selected("Sound", 1)
    tg_id = selected("TextGrid", 1)
    
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    clearinfo
    appendInfoLine: "=== 音声区間の切り出しを開始します ==="
    appendInfoLine: "対象音声: ", sound_name$
    appendInfoLine: "保存先: ", out_dir$
    
    selectObject: tg_id
    num_tiers = Get number of tiers
    total_cut = 0
    
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
                    if duration_s > 0.001
                        selectObject: sound_id
                        part = Extract part: start_t, end_t, "rectangular", 1, "no"
                        
                        safe_label$ = replace_regex$(clean_label$, "[\/\\:\*\?\"<>\|]", "_", 0)
                        if safe_label$ == ""
                            safe_label$ = "interval"
                        endif
                        
                        if do_index
                            out_name$ = out_dir$ + sound_name$ + "_" + string$(j) + "_" + safe_label$ + ".wav"
                        else
                            out_name$ = out_dir$ + sound_name$ + "_" + safe_label$ + ".wav"
                        endif
                        
                        Save as WAV file: out_name$
                        removeObject: part
                        total_cut = total_cut + 1
                    endif
                endif
            endfor
        endif
    endif
    
    appendInfoLine: "完了: 合計 ", total_cut, " 個の音声ファイルを保存しました。"

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
    
    default_out$ = folder$ + "extracted/"
    
    beginPause: "音声区間の切り出し（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_intervals", 1
        comment: "連番をファイル名に含める（例: sound_1_label.wav）:"
        boolean: "include_file_index", 1
        comment: "切り出しファイルの保存先フォルダ名:"
        sentence: "output_dir", default_out$
    clicked = endPause: "キャンセル", "一括切り出しを実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    skip_empty = skip_empty_intervals
    do_index = include_file_index
    out_dir$ = output_dir$
    
    if out_dir$ == ""
        out_dir$ = default_out$
    endif
    if right$(out_dir$, 1) <> "/" and right$(out_dir$, 1) <> "\"
        out_dir$ = out_dir$ + "/"
    endif
    
    # 保存先ディレクトリの作成（Praat内部コマンド）
    createDirectory: out_dir$
    
    clearinfo
    appendInfoLine: "=== フォルダ一括切り出し処理を開始します ==="
    appendInfoLine: "対象フォルダ: ", folder$
    appendInfoLine: "保存先フォルダ: ", out_dir$
    
    file_list = Create Strings as file list: "fileList", folder$ + "*.wav"
    num_files = Get number of strings
    
    if num_files = 0
        removeObject: file_list
        exitScript: "【エラー】フォルダ内に .wav ファイルが見つかりませんでした: " + folder$
    endif
    
    total_cut = 0
    
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
            
            selectObject: tg
            num_tiers = Get number of tiers
            
            if target_tier <= num_tiers
                is_interval = Is interval tier: target_tier
                if is_interval == 1
                    num_intervals = Get number of intervals: target_tier
                    file_cut = 0
                    for j to num_intervals
                        selectObject: tg
                        label$ = Get label of interval: target_tier, j
                        start_t = Get start time of interval: target_tier, j
                        end_t = Get end time of interval: target_tier, j
                        duration_s = end_t - start_t
                        
                        clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                        
                        if not (skip_empty and clean_label$ == "")
                            if duration_s > 0.001
                                selectObject: sound
                                part = Extract part: start_t, end_t, "rectangular", 1, "no"
                                
                                safe_label$ = replace_regex$(clean_label$, "[\/\\:\*\?\"<>\|]", "_", 0)
                                if safe_label$ == ""
                                    safe_label$ = "interval"
                                endif
                                
                                if do_index
                                    out_name$ = out_dir$ + basename$ + "_" + string$(j) + "_" + safe_label$ + ".wav"
                                else
                                    out_name$ = out_dir$ + basename$ + "_" + safe_label$ + ".wav"
                                endif
                                
                                Save as WAV file: out_name$
                                removeObject: part
                                total_cut = total_cut + 1
                                file_cut = file_cut + 1
                            endif
                        endif
                    endfor
                    appendInfoLine: "[", i, "/", num_files, "] ", basename$, ": ", file_cut, " 区間を切り出しました。"
                endif
            endif
            
            removeObject: sound
            removeObject: tg
        endif
    endfor
    
    removeObject: file_list
    appendInfoLine: "=============================================="
    appendInfoLine: "完了: 合計 ", total_cut, " 個の音声ファイルを保存しました。"
    appendInfoLine: "保存先: ", out_dir$
endif
