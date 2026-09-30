# ==============================================================================
# スクリプト名: convert_stereo_to_mono.praat (ステレオ音声からモノラルへの一括変換)
# 
# 【概要】
# 2チャンネル（ステレオ）のWAVファイルを、1チャンネル（モノラル）WAVに変換します。
# 変換方式として「左ch抽出」「右ch抽出」「両ch合成（平均）」を選択可能です。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクトモード】
#    Praat上で Sound を選択している場合、その音声を即座にモノラル化して
#    Praat Objects 上に新しい Sound として追加します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内の全WAVを一括変換し、同じフォルダ内の
#    "mono/" フォルダに自動保存します。
#
# 【原典クレジット】
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

num_sound = numberOfSelected("Sound")

if num_sound > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound を直接モノラル化
    # ==========================================================================
    beginPause: "モノラル変換（選択オブジェクト）"
        comment: "Praat上で選択されている " + string$(num_sound) + " 個の Sound を変換します。"
        comment: "変換モードの選択:"
        choice: "conversion_mode", 3
            option: "左チャンネル(1ch)のみ抽出"
            option: "右チャンネル(2ch)のみ抽出"
            option: "両チャンネルを合成（平均モノラル）"
    clicked = endPause: "キャンセル", "モノラル変換を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    mode = conversion_mode
    
    for i to num_sound
        sound_id[i] = selected("Sound", i)
    endfor
    
    clearinfo
    appendInfoLine: "=== モノラル変換を開始します ==="
    
    for i to num_sound
        current_id = sound_id[i]
        selectObject: current_id
        name$ = selected$("Sound")
        num_ch = Get number of channels
        
        if num_ch == 1
            appendInfoLine: "[", i, "/", num_sound, "] ", name$, ": 既にモノラルです。"
        else
            if mode == 1
                mono = Extract one channel: 1
                Rename: name$ + "_ch1"
            elsif mode == 2
                mono = Extract one channel: 2
                Rename: name$ + "_ch2"
            else
                mono = Convert to mono
                Rename: name$ + "_mono"
            endif
            appendInfoLine: "[", i, "/", num_sound, "] ", name$, ": モノラルに変換しました。"
        endif
    endfor
    appendInfoLine: "完了: Praat Objects リストをご確認ください。"

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "モノラル変換したいWAVファイルが入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    out_dir$ = folder$ + "mono/"
    
    beginPause: "ステレオからモノラルへの一括変換（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "変換モードの選択:"
        choice: "conversion_mode", 3
            option: "左チャンネル(1ch)のみ抽出"
            option: "右チャンネル(2ch)のみ抽出"
            option: "両チャンネルを合成（平均モノラル）"
        comment: "保存先フォルダ名:"
        sentence: "output_dir", out_dir$
    clicked = endPause: "キャンセル", "一括変換を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    mode = conversion_mode
    target_out$ = output_dir$
    if target_out$ == ""
        target_out$ = out_dir$
    endif
    if right$(target_out$, 1) <> "/" and right$(target_out$, 1) <> "\"
        target_out$ = target_out$ + "/"
    endif
    
    createDirectory: target_out$
    
    clearinfo
    appendInfoLine: "=== モノラル一括変換を開始します ==="
    appendInfoLine: "入力フォルダ: ", folder$
    appendInfoLine: "出力フォルダ: ", target_out$
    
    file_list = Create Strings as file list: "fileList", folder$ + "*.wav"
    num_files = Get number of strings
    
    if num_files = 0
        removeObject: file_list
        exitScript: "【エラー】フォルダ内に .wav ファイルが見つかりませんでした: " + folder$
    endif
    
    for i to num_files
        selectObject: file_list
        filename$ = Get string: i
        
        sound = Read from file: folder$ + filename$
        selectObject: sound
        num_ch = Get number of channels
        
        if num_ch == 1
            Save as WAV file: target_out$ + filename$
            appendInfoLine: "[", i, "/", num_files, "] ", filename$, ": 既にモノラルです（そのまま保存）"
        else
            if mode == 1
                mono = Extract one channel: 1
            elsif mode == 2
                mono = Extract one channel: 2
            else
                mono = Convert to mono
            endif
            
            selectObject: mono
            Save as WAV file: target_out$ + filename$
            removeObject: mono
            appendInfoLine: "[", i, "/", num_files, "] ", filename$, ": モノラルに変換完了"
        endif
        
        removeObject: sound
    endfor
    
    removeObject: file_list
    appendInfoLine: "=============================================="
    appendInfoLine: "完了: すべての音声をモノラル化して保存しました。"
    appendInfoLine: "保存先: ", target_out$
endif
