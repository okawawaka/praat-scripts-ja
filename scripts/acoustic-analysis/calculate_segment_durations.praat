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
    beginPause: "区間継続時間の計算（選択中のオブジェクトを分析）"
        comment: "Praat上で選択されている " + string$(num_selected) + " 個の TextGrid を分析します。"
        positive: "対象のTier番号", 1
        boolean: "空白ラベルを除外する", 1
        boolean: "TSVファイルとしても保存する", 0
    clicked = endPause: "キャンセル", "分析を実行", 2, 1
    
    if clicked = 1
        exitScript: "キャンセルされました。"
    endif
    
    tier_number = 対象のTier番号
    skip_empty = 空白ラベルを除外する
    save_tsv = TSVファイルとしても保存する
    
    tsv_out_file$ = ""
    if save_tsv
        tsv_out_file$ = chooseWriteFile$: "保存先のTSVファイルを指定してください", "duration_results.tsv"
        if tsv_out_file$ = ""
            save_tsv = 0
        endif
    endif

    # 選択されている全オブジェクトのIDを取得
    for i to num_selected
        tg_id[i] = selected("TextGrid", i)
    endfor

    echo === 区間継続時間の計算結果 ===
    echo 対象オブジェクト数: 'num_selected' 件
    echo 対象Tier: 'tier_number'
    printline
    
    header$ = "ObjectName" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    echo 'header$'
    
    if save_tsv
        writeFileLine: tsv_out_file$, header$
    endif
    
    total_intervals = 0
    
    for i to num_selected
        current_tg = tg_id[i]
        selectObject: current_tg
        name$ = selected$("TextGrid")
        
        num_tiers = Get number of tiers
        if tier_number <= num_tiers
            if Is interval tier: tier_number
                num_intervals = Get number of intervals: tier_number
                for j to num_intervals
                    label$ = Get label of interval: tier_number, j
                    start_t = Get start time of interval: tier_number, j
                    end_t = Get end time of interval: tier_number, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    if not (skip_empty and clean_label$ == "")
                        row$ = name$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_s, 4) + tab$ + fixed$(dur_ms, 2)
                        echo 'row$'
                        if save_tsv
                            appendFileLine: tsv_out_file$, row$
                        endif
                        total_intervals = total_intervals + 1
                    endif
                endfor
            else
                echo 【注意】 'name$' の Tier 'tier_number' はインターバル段ではありません。
            endif
        else
            echo 【注意】 'name$' には Tier 'tier_number' が存在しません。
        endif
    endfor
    
    printline
    echo ==============================================
    echo 完了: 合計 'total_intervals' 件の区間時間を集計しました。
    if save_tsv
        echo ファイル保存先: 'tsv_out_file$'
    endif

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "TextGridファイルが入っているフォルダを選択してください"
    if folder$ = ""
        exitScript: "キャンセルされました。"
    endif
    
    # パス末尾のセパレータ補正
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    default_tsv$ = folder$ + "duration_results.tsv"
    
    beginPause: "区間継続時間の計算（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        positive: "対象のTier番号", 1
        sentence: "拡張子", ".TextGrid"
        boolean: "空白ラベルを除外する", 1
        sentence: "結果保存先ファイル名", default_tsv$
    clicked = endPause: "キャンセル", "一括処理を実行", 2, 1
    
    if clicked = 1
        exitScript: "キャンセルされました。"
    endif
    
    tier_number = 対象のTier番号
    ext$ = 拡張子$
    skip_empty = 空白ラベルを除外する
    result_file$ = 結果保存先ファイル名$
    
    echo === フォルダ一括処理を開始します ===
    echo 対象フォルダ: 'folder$'
    echo 対象Tier: 'tier_number'
    echo 保存先: 'result_file$'
    
    if fileReadable(result_file$)
        deleteFile: result_file$
    endif
    
    header$ = "Filename" + tab$ + "IntervalIndex" + tab$ + "Label" + tab$ + "StartTime_s" + tab$ + "EndTime_s" + tab$ + "Duration_s" + tab$ + "Duration_ms"
    writeFileLine: result_file$, header$
    
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
        
        if tier_number <= num_tiers
            if Is interval tier: tier_number
                num_intervals = Get number of intervals: tier_number
                for j to num_intervals
                    selectObject: tg
                    label$ = Get label of interval: tier_number, j
                    start_t = Get start time of interval: tier_number, j
                    end_t = Get end time of interval: tier_number, j
                    dur_s = end_t - start_t
                    dur_ms = dur_s * 1000
                    
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    if not (skip_empty and clean_label$ == "")
                        row$ = basename$ + tab$ + string$(j) + tab$ + clean_label$ + tab$ + fixed$(start_t, 4) + tab$ + fixed$(end_t, 4) + tab$ + fixed$(dur_s, 4) + tab$ + fixed$(dur_ms, 2)
                        appendFileLine: result_file$, row$
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
    echo 保存先: 'result_file$'
endif
