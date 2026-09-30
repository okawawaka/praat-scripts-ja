# ==============================================================================
# スクリプト名: change_sample_rate.praat (サンプリング周波数の一括変換)
# 
# 【概要】
# 音声ファイル（WAV）を指定したサンプリング周波数（例: 16000 Hz, 22050 Hz, 44100 Hz）
# にリサンプリングします。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクトモード】
#    Praat上で Sound を選択している場合、その音声を即座にリサンプリングして
#    Praat Objects 上に新しい Sound として追加します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内の全WAVを一括変換し、同じフォルダ内の
#    "resampled_[周波数]/" フォルダに自動保存します。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: change_sample_rate_of_sound_files.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

num_sound = numberOfSelected("Sound")

if num_sound > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound を直接リサンプリング
    # ==========================================================================
    beginPause: "サンプリング周波数の変換（選択オブジェクト）"
        comment: "Praat上で選択されている " + string$(num_sound) + " 個の Sound を変換します。"
        comment: "変換後のサンプリング周波数（Hz。標準: 16000, 22050, 44100, 48000）:"
        positive: "target_sample_rate", 16000
        comment: "補間精度（通常は 50 で十分です）:"
        positive: "precision_samples", 50
    clicked = endPause: "キャンセル", "リサンプリングを実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    t_rate = target_sample_rate
    prec = precision_samples
    
    for i to num_sound
        sound_id[i] = selected("Sound", i)
    endfor
    
    clearinfo
    appendInfoLine: "=== サンプリング周波数の変換を開始します ==="
    appendInfoLine: "変換先サンプリング周波数: ", t_rate, " Hz"
    
    for i to num_sound
        current_id = sound_id[i]
        selectObject: current_id
        name$ = selected$("Sound")
        orig_sr = Get sampling frequency
        
        if orig_sr <> t_rate
            resampled = Resample: t_rate, prec
            Rename: name$ + "_" + string$(t_rate)
            appendInfoLine: "[", i, "/", num_sound, "] ", name$, ": ", orig_sr, " Hz -> ", t_rate, " Hz に変換しました。"
        else
            appendInfoLine: "[", i, "/", num_sound, "] ", name$, ": 既に ", t_rate, " Hz です。"
        endif
    endfor
    appendInfoLine: "完了: Praat Objects リストをご確認ください。"

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "リサンプリングしたいWAVファイルが入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    beginPause: "サンプリング周波数の一括変換（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "変換後のサンプリング周波数（Hz。標準: 16000, 22050, 44100, 48000）:"
        positive: "target_sample_rate", 16000
        comment: "補間精度（通常は 50 で十分です）:"
        positive: "precision_samples", 50
    clicked = endPause: "キャンセル", "一括リサンプリングを実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    t_rate = target_sample_rate
    prec = precision_samples
    out_dir$ = folder$ + "resampled_" + string$(t_rate) + "/"
    
    createDirectory: out_dir$
    
    clearinfo
    appendInfoLine: "=== サンプリング周波数の一括変換を開始します ==="
    appendInfoLine: "入力フォルダ: ", folder$
    appendInfoLine: "出力フォルダ: ", out_dir$
    appendInfoLine: "変換先周波数: ", t_rate, " Hz"
    
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
        orig_sr = Get sampling frequency
        
        if orig_sr <> t_rate
            resampled = Resample: t_rate, prec
            selectObject: resampled
            Save as WAV file: out_dir$ + filename$
            removeObject: resampled
            appendInfoLine: "[", i, "/", num_files, "] ", filename$, ": ", orig_sr, " Hz -> ", t_rate, " Hz に変換完了"
        else
            Save as WAV file: out_dir$ + filename$
            appendInfoLine: "[", i, "/", num_files, "] ", filename$, ": 既に ", t_rate, " Hz です（そのまま保存）"
        endif
        
        removeObject: sound
    endfor
    
    removeObject: file_list
    appendInfoLine: "=============================================="
    appendInfoLine: "完了: すべての音声を変換して保存しました。"
    appendInfoLine: "保存先: ", out_dir$
endif
