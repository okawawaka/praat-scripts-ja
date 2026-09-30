# ==============================================================================
# スクリプト名: mark_pauses.praat (無音・ポーズ区間の自動検出)
# 
# 【概要】
# フォルダ内の音声ファイルから音の強さ（Intensity）を計算し、
# 一定のしきい値以下の無音・休止区間（ポーズ）を自動検出します。
# 検出結果は既存の TextGrid に新しい段（Tier）として追加されるか、
# 新規の TextGrid ファイルとして作成・保存されます。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: mark_pauses.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form 無音・ポーズ区間の自動検出 (Mark Pauses)
    comment === 【フォルダ指定】 ===
    text sound_dir C:\SpeechData\wav\
    sentence sound_ext .wav
    text textgrid_dir C:\SpeechData\tg\
    sentence textgrid_ext .TextGrid

    comment === 【ポーズ検出の音響パラメータ】 ===
    positive min_pause_duration 0.2
    comment 最小ポーズ長（秒）。これより短い無音は無視されます（標準: 0.15 〜 0.3秒）

    positive min_sounding_duration 0.1
    comment 最小発話長（秒）。これより短い音はノイズとみなされます（標準: 0.05 〜 0.1秒）

    real silence_threshold -25.0
    comment 無音しきい値（dB）。最大音量からの相対値（例: -25 dB）

    comment === 【TextGrid の出力設定】 ===
    sentence tier_name pause
    comment 追加するTierの名前

    sentence pause_label _
    comment ポーズ区間に書き込むラベル（例: _ や pau、silence など）

    sentence sounding_label sound
    comment 有音区間に書き込むラベル（空白にすると無名区間になります）
endform

# パス末尾の補正
if right$(sound_dir$, 1) <> "/" and right$(sound_dir$, 1) <> "\"
    sound_dir$ = sound_dir$ + "/"
endif
if right$(textgrid_dir$, 1) <> "/" and right$(textgrid_dir$, 1) <> "\"
    textgrid_dir$ = textgrid_dir$ + "/"
endif

clearinfo
echo === 無音・ポーズ検出処理を開始します ===
echo 音声フォルダ: 'sound_dir$'
echo TextGridフォルダ: 'textgrid_dir$'
echo 最小ポーズ長: 'min_pause_duration' 秒
echo 無音しきい値: 'silence_threshold' dB

file_list = Create Strings as file list: "fileList", sound_dir$ + "*" + sound_ext$
num_files = Get number of strings

if num_files = 0
    removeObject: file_list
    exitScript: "【エラー】対象フォルダに対象の音声ファイル（*" + sound_ext$ + "）が見つかりませんでした。"
endif

for i to num_files
    selectObject: file_list
    filename$ = Get string: i
    basename$ = filename$ - sound_ext$
    
    sound_path$ = sound_dir$ + filename$
    tg_path$ = textgrid_dir$ + basename$ + textgrid_ext$
    
    sound = Read from file: sound_path$
    
    # 既存のTextGridがあれば読み込み、なければ新規作成
    if fileReadable(tg_path$)
        tg = Read from file: tg_path$
    else
        selectObject: sound
        sound_dur = Get total duration
        tg = To TextGrid: "dummy", ""
        removeObject: "TextGrid dummy"
        selectObject: sound
        tg = To TextGrid: tier_name$, ""
    endif
    
    # 音声からポーズ検出用TextGridを生成 (To TextGrid (silences))
    selectObject: sound
    intensity_tg = To TextGrid (silences): silence_threshold, min_pause_duration, min_sounding_duration, pause_label$, sounding_label$
    
    # 生成された段を対象TextGridに追加
    selectObject: tg
    num_tiers = Get number of tiers
    target_tier = num_tiers + 1
    Insert interval tier: target_tier, tier_name$
    
    # ポーズ区間をコピー
    selectObject: intensity_tg
    num_intervals = Get number of intervals: 1
    
    for j to num_intervals
        selectObject: intensity_tg
        start_t = Get start time of interval: 1, j
        end_t = Get end time of interval: 1, j
        lbl$ = Get label of interval: 1, j
        
        selectObject: tg
        # 境界を追加
        if start_t > 0
            Insert boundary: target_tier, start_t
        endif
        # ラベルを設定
        int_idx = Get interval at time: target_tier, (start_t + end_t) / 2
        Set interval text: target_tier, int_idx, lbl$
    endfor
    
    # 保存
    selectObject: tg
    Save as text file: tg_path$
    
    removeObject: sound
    removeObject: tg
    removeObject: intensity_tg
    
    echo ['i'/'num_files'] 'basename$': ポーズ検出完了（'num_intervals' 区間）
endfor

removeObject: file_list

echo ==============================================
echo すべての処理が完了しました。
