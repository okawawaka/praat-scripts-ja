# ==============================================================================
# スクリプト名: calculate_segment_durations.praat (区間継続時間・デュレーションの一括計算)
# 
# 【概要】
# TextGrid の指定した段（Tier）の各区間の開始時刻、終了時刻、継続時間（秒およびミリ秒）を一覧集計します。
# 母音の長短、子音の閉鎖持続時間（VOT）、ポーズ長の音響分析に最適です。
#
# 【ハイブリッド機能（簡単ファイル選択）】
# 1. 【オブジェクト分析モード】
#    Praat上で TextGrid を選択（反転表示）している場合、フォルダ指定なしで
#    選択中の TextGrid を即座に分析し、画面（Infoウィンドウ）に結果を表示します。
#    必要に応じてTSVファイルへの保存も可能です。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。パスの手打ち入力不要で、フォルダ内の全ファイルを一括集計し、
#    同じフォルダ内に "duration_results.tsv" を自動保存します。
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
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_intervals", 1
        comment: "結果をTSVファイルとしても保存する:"
        boolean: "save_to_tsv", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    # 変数の取得
    target_tier = tier_number
    skip_empty = skip_empty_intervals
    do_save_tsv = save_to_tsv
    
    tsv_out_file$ = ""
    if do_save_tsv
        tsv_out_file$ = chooseWriteFile$: "保存先のTSVファイル名を指定してください", "duration_results.tsv"
        if tsv_out_file$ == ""
            do_save_tsv = 0
            echo 【案内】ファイル保存がキャンセルされたため、画面表示のみ実行します。
        endif
    endif

    # 選択されている全オブジェクトのIDを取得
    for i to num_selected
        tg_id[i] = selected("TextGrid", i)
    endfor

    echo === 区間継続時間の計算結果 ===
    echo 対象オブジェクト数: 'num_selected' 件
    echo 対象Tier: 'target_tier'
    printline
    
    header$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    echo 'header$'
    
    if do_save_tsv and tsv_out_file$ <> ""
        writeFileLine: tsv_out_file$, header$
    endif
    
    total_intervals = 0
    
    for i to num_selected
        current_tg = tg_id[i]
        selectObject: current_tg
        name$ = selected$("TextGrid")
        
        num_tiers = Get number of tiers
        if target_tier <= num_tiers
            if Is interval tier: target_tier
                num_intervals = Get number of intervals: target_tier
                for j to num_intervals
                    selectObject: current_tg
                    label$ = Get label of interval: target_tier, j
                    start_t = Get start time of interval: target_tier, j
                    end_t = Get end time of interval: target_tier, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    if not (skip_empty and clean_label$ == "")
                        row$ = name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_s, 4) + tab$ + fixed$(dur_ms, 2)
                        echo 'row$'
                        if do_save_tsv and tsv_out_file$ <> ""
                            appendFileLine: tsv_out_file$, row$
                        endif
                        total_intervals = total_intervals + 1
                    endif
                endfor
            else
                echo 【注意】 'name$' の Tier 'target_tier' はインターバル段ではありません。
            endif
        else
            echo 【注意】 'name$' には Tier 'target_tier' が存在しません。
        endif
    endfor
    
    printline
    echo ==============================================
    echo 完了: 合計 'total_intervals' 件の区間時間を集計しました。
    if do_save_tsv and tsv_out_file$ <> ""
        echo TSV保存先: 'tsv_out_file$'
    endif

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
    
    default_tsv$ = folder$ + "duration_results.tsv"
    
    beginPause: "区間継続時間の計算（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "対象のTier番号（1以上の整数）:"
        positive: "tier_number", 1
        comment: "対象ファイルの拡張子:"
        sentence: "extension", ".TextGrid"
        comment: "空白ラベル（無音区間など）を除外する:"
        boolean: "skip_empty_intervals", 1
        comment: "結果保存先のTSVファイル名:"
        sentence: "result_file", default_tsv$
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    target_tier = tier_number
    ext$ = extension$
    skip_empty = skip_empty_intervals
    out_file$ = result_file$
    
    # 出力パスが空の場合は自動でデフォルト設定
    if out_file$ == ""
        out_file$ = default_tsv$
    endif
    
    echo === フォルダ一括処理を開始します ===
    echo 対象フォルダ: 'folder$'
    echo 対象Tier: 'target_tier'
    echo 保存先: 'out_file$'
    
    header$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    writeFileLine: out_file$, header$
    
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
        
        tg = Read from file: folder$ + filename$
        selectObject: tg
        num_tiers = Get number of tiers
        
        if target_tier <= num_tiers
            if Is interval tier: target_tier
                num_intervals = Get number of intervals: target_tier
                for j to num_intervals
                    selectObject: tg
                    label$ = Get label of interval: target_tier, j
                    start_t = Get start time of interval: target_tier, j
                    end_t = Get end time of interval: target_tier, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    if not (skip_empty and clean_label$ == "")
                        row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_s, 4) + tab$ + fixed$(dur_ms, 2)
                        appendFileLine: out_file$, row$
                        total_intervals = total_intervals + 1
                    endif
                endfor
            endif
        endif
        
        removeObject: tg
        echo ['i'/'num_files'] 'basename$': 集計完了
    endfor
    
    removeObject: file_list
    
    echo ==============================================
    echo 完了: 合計 'total_intervals' 件の区間時間を集計しました。
    echo 保存先: 'out_file$'
endif
