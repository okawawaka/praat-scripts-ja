# ==============================================================================
# スクリプト名: mark_pauses.praat (無音・ポーズ区間の自動検出)
# 
# 【概要】
# 音声ファイルから音の強さ（Intensity）を計算し、指定のしきい値以下の無音・休止区間
# （ポーズ）を自動検出して、TextGridの新しい段（Tier）を作成・追加します。
# 
# 【ハイブリッド機能（パス手動入力不要）】
# 1. 【選択オブジェクトモード】
#    Praat上で Sound を選択している場合、その音声から即座にポーズを検出し、
#    Praat Objects 上に新しい TextGrid を自動生成します。
# 2. 【フォルダ一括処理モード】
#    Praat上で何も選択していない場合、自動的にマウスで選べる「フォルダ参照ダイアログ」
#    が起動します。フォルダ内のWAVファイルから一括でポーズ検出し、同じフォルダ内に
#    .TextGrid ファイルを自動保存します。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: mark_pauses.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

clearinfo

num_sound = numberOfSelected("Sound")
num_tg = numberOfSelected("TextGrid")

if num_sound > 0
    # ==========================================================================
    # 【モード1】Praat上で選択中の Sound から直接ポーズ検出
    # ==========================================================================
    beginPause: "ポーズ自動検出（選択オブジェクト）"
        comment: "Praat上で選択されている Sound からポーズを検出します。"
        comment: "最小ポーズ長（秒。標準: 0.15 〜 0.3秒）:"
        positive: "min_pause_duration", 0.2
        comment: "最小発話長（秒。標準: 0.05 〜 0.1秒）:"
        positive: "min_sounding_duration", 0.1
        comment: "無音しきい値（dB。最大音量からの相対値、例: -25 dB）:"
        real: "silence_threshold", -25.0
        comment: "ポーズ区間に書き込むラベル（例: _ や pau）:"
        sentence: "pause_label", "_"
        comment: "有音区間に書き込むラベル（空白可）:"
        sentence: "sounding_label", "sound"
    clicked = endPause: "キャンセル", "ポーズ検出を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    p_min_pause = min_pause_duration
    p_min_sound = min_sounding_duration
    p_sil_thresh = silence_threshold
    p_lbl$ = pause_label$
    s_lbl$ = sounding_label$
    
    sound_id = selected("Sound", 1)
    selectObject: sound_id
    sound_name$ = selected$("Sound")
    
    # ポーズ検出用TextGridを生成
    selectObject: sound_id
    intensity_tg = To TextGrid (silences): p_sil_thresh, p_min_pause, p_min_sound, p_lbl$, s_lbl$
    Rename: sound_name$ + "_pause"
    
    # もし同時にTextGridも選択されていた場合はその段を統合
    if num_tg > 0
        tg_id = selected("TextGrid", 1)
        selectObject: tg_id
        num_tiers = Get number of tiers
        target_tier = num_tiers + 1
        Insert interval tier: target_tier, "pause"
        
        selectObject: intensity_tg
        num_intervals = Get number of intervals: 1
        for j to num_intervals
            selectObject: intensity_tg
            start_t = Get start time of interval: 1, j
            end_t = Get end time of interval: 1, j
            lbl$ = Get label of interval: 1, j
            
            selectObject: tg_id
            if start_t > 0
                Insert boundary: target_tier, start_t
            endif
            int_idx = Get interval at time: target_tier, (start_t + end_t) / 2
            Set interval text: target_tier, int_idx, lbl$
        endfor
        removeObject: intensity_tg
        selectObject: tg_id
        appendInfoLine: "完了: 選択中の TextGrid に 'pause' 段を追加しました。"
    else
        selectObject: intensity_tg
        appendInfoLine: "完了: 新しい TextGrid (", sound_name$, "_pause) を作成しました。"
    endif

else
    # ==========================================================================
    # 【モード2】フォルダ参照ダイアログによる一括処理（パス手打ち不要）
    # ==========================================================================
    folder$ = chooseDirectory$: "音声(WAV)が入っているフォルダを選択してください"
    if folder$ == ""
        exitScript: "処理がキャンセルされました。"
    endif
    
    if right$(folder$, 1) <> "/" and right$(folder$, 1) <> "\"
        folder$ = folder$ + "/"
    endif
    
    beginPause: "ポーズ自動検出（フォルダ一括処理）"
        comment: "選択フォルダ: " + folder$
        comment: "最小ポーズ長（秒。標準: 0.15 〜 0.3秒）:"
        positive: "min_pause_duration", 0.2
        comment: "最小発話長（秒。標準: 0.05 〜 0.1秒）:"
        positive: "min_sounding_duration", 0.1
        comment: "無音しきい値（dB。最大音量からの相対値、例: -25 dB）:"
        real: "silence_threshold", -25.0
        comment: "ポーズ区間に書き込むラベル（例: _ や pau）:"
        sentence: "pause_label", "_"
        comment: "有音区間に書き込むラベル（空白可）:"
        sentence: "sounding_label", "sound"
    clicked = endPause: "キャンセル", "一括検出を実行", 2, 1
    
    if clicked = 1
        exitScript: "処理がキャンセルされました。"
    endif
    
    p_min_pause = min_pause_duration
    p_min_sound = min_sounding_duration
    p_sil_thresh = silence_threshold
    p_lbl$ = pause_label$
    s_lbl$ = sounding_label$
    
    clearinfo
    appendInfoLine: "=== ポーズ自動検出（フォルダ一括処理）を開始します ==="
    appendInfoLine: "対象フォルダ: ", folder$
    
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
        
        sound = Read from file: sound_path$
        
        # 既存のTextGridがあれば読み込み、なければ新規作成
        if fileReadable(tg_path$)
            tg = Read from file: tg_path$
        else
            selectObject: sound
            tg = To TextGrid: "pause", ""
        endif
        
        selectObject: sound
        intensity_tg = To TextGrid (silences): p_sil_thresh, p_min_pause, p_min_sound, p_lbl$, s_lbl$
        
        selectObject: tg
        num_tiers = Get number of tiers
        target_tier = num_tiers + 1
        Insert interval tier: target_tier, "pause"
        
        selectObject: intensity_tg
        num_intervals = Get number of intervals: 1
        for j to num_intervals
            selectObject: intensity_tg
            start_t = Get start time of interval: 1, j
            end_t = Get end time of interval: 1, j
            lbl$ = Get label of interval: 1, j
            
            selectObject: tg
            if start_t > 0
                Insert boundary: target_tier, start_t
            endif
            int_idx = Get interval at time: target_tier, (start_t + end_t) / 2
            Set interval text: target_tier, int_idx, lbl$
        endfor
        
        selectObject: tg
        Save as text file: tg_path$
        
        removeObject: sound
        removeObject: tg
        removeObject: intensity_tg
        appendInfoLine: "[", i, "/", num_files, "] ", basename$, ": ポーズ検出完了（", num_intervals, " 区間）"
    endfor
    
    removeObject: file_list
    appendInfoLine: "=============================================="
    appendInfoLine: "完了: すべての音声ファイルにポーズ段を付与して保存しました。"
endif
