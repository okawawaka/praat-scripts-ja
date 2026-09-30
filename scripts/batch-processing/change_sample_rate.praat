# ==============================================================================
# スクリプト名: change_sample_rate.praat (サンプリング周波数の一括変換)
# 
# 【概要】
# 指定フォルダ内のすべての音声ファイル（WAV）を、指定したサンプリング周波数
# （例: 16000 Hz, 22050 Hz, 44100 Hz）にリサンプリングし、指定フォルダに一括保存します。
# Praatのフォルマント分析や、音声認識・機械学習モデル（Whisper等）への
# データ前処理として必須のスクリプトです。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: change_sample_rate_of_sound_files.praat)
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form サンプリング周波数の一括変換 (Change Sample Rate)
    comment === 【フォルダ指定】 ===
    text input_dir C:\SpeechData\wav_orig\
    sentence sound_ext .wav
    text output_dir C:\SpeechData\wav_resampled\

    comment === 【変換設定】 ===
    positive target_sample_rate 16000
    comment 変換後のサンプリング周波数（Hz）。標準: 16000, 22050, 44100, 48000
    positive precision 50
    comment 補間精度（サンプル数）。通常はデフォルトの 50 で十分です
endform

# パス末尾の補正
if right$(input_dir$, 1) <> "/" and right$(input_dir$, 1) <> "\"
    input_dir$ = input_dir$ + "/"
endif
if right$(output_dir$, 1) <> "/" and right$(output_dir$, 1) <> "\"
    output_dir$ = output_dir$ + "/"
endif

clearinfo
echo === サンプリング周波数の一括変換を開始します ===
echo 入力フォルダ: 'input_dir$'
echo 出力フォルダ: 'output_dir$'
echo 変換後サンプリング周波数: 'target_sample_rate' Hz

file_list = Create Strings as file list: "fileList", input_dir$ + "*" + sound_ext$
num_files = Get number of strings

if num_files = 0
    removeObject: file_list
    exitScript: "【エラー】対象フォルダに対象の音声ファイル（*" + sound_ext$ + "）が見つかりませんでした。"
endif

for i to num_files
    selectObject: file_list
    filename$ = Get string: i
    
    sound_path$ = input_dir$ + filename$
    sound = Read from file: sound_path$
    
    selectObject: sound
    orig_sr = Get sampling frequency
    
    if orig_sr <> target_sample_rate
        resampled = Resample: target_sample_rate, precision
        selectObject: resampled
        Save as WAV file: output_dir$ + filename$
        removeObject: resampled
        echo ['i'/'num_files'] 'filename$': 'orig_sr' Hz -> 'target_sample_rate' Hz に変換完了
    else
        Save as WAV file: output_dir$ + filename$
        echo ['i'/'num_files'] 'filename$': 既に 'target_sample_rate' Hz のためそのままコピー保存
    endif
    
    removeObject: sound
endfor

removeObject: file_list

echo ==============================================
echo すべての変換が完了しました。
echo 保存先: 'output_dir$'
