# ==============================================================================
# スクリプト名: convert_stereo_to_mono.praat (ステレオ音声からモノラルへの一括変換)
# 
# 【概要】
# フォルダ内の2チャンネル（ステレオ）WAVファイルを、1チャンネル（モノラル）WAV
# に一括変換して保存します。
# 変換方式として「左チャンネル抽出」「右チャンネル抽出」「両チャンネル合成（平均）」
# を選択できます。
# 音声分析ソフトや音声認識モデルではモノラル音声が前提となることが多いため、非常に重宝します。
#
# 【原典クレジット】
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form ステレオからモノラルへの一括変換 (Convert Stereo to Mono)
    comment === 【フォルダ指定】 ===
    text input_dir C:\SpeechData\stereo_wav\
    sentence sound_ext .wav
    text output_dir C:\SpeechData\mono_wav\

    comment === 【変換モードの選択】 ===
    choice conversion_mode 3
        button チャンネル1（左ch）のみ抽出
        button チャンネル2（右ch）のみ抽出
        button 両チャンネルを合成（平均モノラル）
endform

# パス末尾の補正
if right$(input_dir$, 1) <> "/" and right$(input_dir$, 1) <> "\"
    input_dir$ = input_dir$ + "/"
endif
if right$(output_dir$, 1) <> "/" and right$(output_dir$, 1) <> "\"
    output_dir$ = output_dir$ + "/"
endif

clearinfo
echo === モノラル一括変換を開始します ===
echo 入力フォルダ: 'input_dir$'
echo 出力フォルダ: 'output_dir$'
echo 変換モード: 'conversion_mode$'

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
    num_channels = Get number of channels
    
    if num_channels = 1
        # すでにモノラルの場合はそのままコピー
        Save as WAV file: output_dir$ + filename$
        echo ['i'/'num_files'] 'filename$': 既にモノラルです（そのまま保存）
    else
        # ステレオ以上の場合は変換
        if conversion_mode = 1
            mono = Extract one channel: 1
        elsif conversion_mode = 2
            mono = Extract one channel: 2
        else
            mono = Convert to mono
        endif
        
        selectObject: mono
        Save as WAV file: output_dir$ + filename$
        removeObject: mono
        echo ['i'/'num_files'] 'filename$': モノラルに変換完了
    endif
    
    removeObject: sound
endfor

removeObject: file_list

echo ==============================================
echo すべての変換が完了しました。
echo 保存先: 'output_dir$'
