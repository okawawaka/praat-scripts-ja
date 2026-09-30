# ==============================================================================
# スクリプト名: extract_intervals_to_wav.praat (音声区間の一括切り出し)
# 
# 【概要】
# フォルダ内の音声ファイル（WAV）と、対応する TextGrid ファイルを読み込み、
# 指定した段（Tier）の各ラベル区間を、個別の WAV 音声ファイルとして一括保存します。
# 音声コーパスの作成、単語・音素ごとの切り出し、機械学習用データセット作成に最適です。
#
# 【原典クレジット】
# ベース元: Mietta Lennes (SpeCT: Speech Corpus Toolkit for Praat)
#           および FieldDB/Praat-Scripts
# 改変・日本語化: okawawaka (praat-scripts-ja)
# ライセンス: GNU General Public License v3.0
# ==============================================================================

form 音声区間の一括切り出し (Extract Intervals to WAV)
    comment === 【フォルダ指定】（末尾に \ または / を付けてください） ===
    text sound_dir C:\SpeechData\wav\
    sentence sound_ext .wav
    text textgrid_dir C:\SpeechData\tg\
    sentence textgrid_ext .TextGrid
    text output_dir C:\SpeechData\extracted\

    comment === 【抽出条件】 ===
    positive tier_number 1
    boolean skip_empty_intervals 1
    comment 空白ラベル（無音区間など）をスキップする場合はチェックを入れる

    comment === 【出力ファイル名の命名規則】 ===
    boolean include_file_index 1
    comment チェック時: [元ファイル名]_[連番]_[ラベル名].wav
    comment 未チェック時: [元ファイル名]_[ラベル名].wav
endform

# パス末尾のセパレータ自動補正
if right$(sound_dir$, 1) <> "/" and right$(sound_dir$, 1) <> "\"
    sound_dir$ = sound_dir$ + "/"
endif
if right$(textgrid_dir$, 1) <> "/" and right$(textgrid_dir$, 1) <> "\"
    textgrid_dir$ = textgrid_dir$ + "/"
endif
if right$(output_dir$, 1) <> "/" and right$(output_dir$, 1) <> "\"
    output_dir$ = output_dir$ + "/"
endif

# 出力先ディレクトリの確認（書き込みテスト）
clearinfo
echo === 音声区間の一括切り出し処理を開始します ===
echo 入力音声フォルダ: 'sound_dir$'
echo 入力TextGridフォルダ: 'textgrid_dir$'
echo 出力フォルダ: 'output_dir$'
echo 対象Tier: 'tier_number'

# 対象フォルダ内のWAVファイル一覧を取得
file_list = Create Strings as file list: "fileList", sound_dir$ + "*" + sound_ext$
num_files = Get number of strings

if num_files = 0
    removeObject: file_list
    exitScript: "【エラー】対象フォルダに対象の音声ファイル（*" + sound_ext$ + "）が見つかりませんでした。"
endif

echo 処理対象ファイル数: 'num_files' 件
total_extracted = 0

for i to num_files
    selectObject: file_list
    filename$ = Get string: i
    basename$ = filename$ - sound_ext$
    
    tg_path$ = textgrid_dir$ + basename$ + textgrid_ext$
    sound_path$ = sound_dir$ + filename$
    
    # TextGrid が存在するか確認
    if fileReadable(tg_path$)
        # 音声とTextGridの読み込み
        sound = Read from file: sound_path$
        tg = Read from file: tg_path$
        
        selectObject: tg
        num_tiers = Get number of tiers
        
        if tier_number <= num_tiers
            is_interval = Is interval tier: tier_number
            if is_interval
                num_intervals = Get number of intervals: tier_number
                file_extracted = 0
                
                for j to num_intervals
                    selectObject: tg
                    label$ = Get label of interval: tier_number, j
                    start_time = Get start time of interval: tier_number, j
                    end_time = Get end time of interval: tier_number, j
                    duration = end_time - start_time
                    
                    # 空白ラベルの判定（前後の半角スペース・タブを除去）
                    clean_label$ = replace_regex$(label$, "^\s+|\s+$", "", 0)
                    
                    if not (skip_empty_intervals and clean_label$ == "")
                        # 0秒区間でないことを確認
                        if duration > 0.001
                            selectObject: sound
                            part = Extract part: start_time, end_time, "rectangular", 1, "no"
                            
                            # ファイル名に使用できない文字のサニタイズ (: / \ ? * " < > | 等)
                            safe_label$ = replace_regex$(clean_label$, "[\/\\:\*\?\"<>\|]", "_", 0)
                            if safe_label$ == ""
                                safe_label$ = "empty"
                            endif
                            
                            if include_file_index
                                out_name$ = output_dir$ + basename$ + "_" + string$(j) + "_" + safe_label$ + ".wav"
                            else
                                out_name$ = output_dir$ + basename$ + "_" + safe_label$ + ".wav"
                            endif
                            
                            Save as WAV file: out_name$
                            removeObject: part
                            total_extracted = total_extracted + 1
                            file_extracted = file_extracted + 1
                        endif
                    endif
                endfor
                echo ['i'/'num_files'] 'basename$': 'file_extracted' 区間を切り出しました。
            else
                echo ['i'/'num_files'] 警告: 'basename$' の Tier 'tier_number' はインターバル段ではありません（ポイント段です）。
            endif
        else
            echo ['i'/'num_files'] 警告: 'basename$' には Tier 'tier_number' が存在しません（総Tier数: 'num_tiers'）。
        endif
        
        removeObject: sound
        removeObject: tg
    else
        echo ['i'/'num_files'] スキップ: 'basename$' に対応する TextGrid が見つかりません。
    endif
endfor

removeObject: file_list

echo ==============================================
echo 完了: 合計 'total_extracted' 個の音声ファイルを保存しました。
echo 保存先: 'output_dir$'
