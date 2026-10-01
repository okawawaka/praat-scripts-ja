# Praat Scripts (日本語解説版 / Japanese Edition)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Praat: 6.0+](https://img.shields.io/badge/Praat-6.0%2B-green.svg)](https://www.fon.hum.uva.nl/praat/)

言語学・音声学・音響分析のための日本語解説付き Praat スクリプト集です。  
Mietta Lennes 氏の **SpeCT (Speech Corpus Toolkit for Praat)** および [FieldDB/Praat-Scripts](https://github.com/FieldDB/Praat-Scripts) をベースに、ダイアログの日本語化、スクリプト内解説の追加、および Praat 6.x 系構文へのリファクタリングを行っています。

---

## 特徴

1. **ダイアログの日本語化**:
   - スクリプト実行時のパラメータ設定画面を日本語化しています。
2. **Praat 6.x 構文への対応**:
   - 旧形式のコマンドを最新の `selectObject` 等の関数型構文に更新し、警告なく動作するようにしています。
3. **ファイルパスの処理**:
   - 空白や日本語を含むディレクトリパスでもエラーが発生しにくいよう配慮しています。
4. **TSV形式での出力**:
   - 分析結果などの出力ファイルはタブ区切りテキスト（TSV）形式に統一しており、表計算ソフトやR等ですぐに読み込めます。

---

## 収録スクリプト一覧

### 1. 音声切り出し・区間アノテーション (`scripts/segmentation/`)

| スクリプト名 | 主な用途 |
| :--- | :--- |
| **[`extract_intervals_to_wav.praat`](scripts/segmentation/extract_intervals_to_wav.praat)** | TextGridのラベル区間ごとに、個別のWAVファイルとして切り出して保存する |
| **[`mark_pauses.praat`](scripts/segmentation/mark_pauses.praat)** | 音声の音量から無音・ポーズ区間を検出し、TextGridに境界線とラベルを付与する |

---

### 2. 音響特徴量・分析データ抽出 (`scripts/acoustic-analysis/`)

| スクリプト名 | 主な用途 |
| :--- | :--- |
| **[`collect_formant_data.praat`](scripts/acoustic-analysis/collect_formant_data.praat)** | 各母音区間の中央点におけるフォルマント（F1〜F5）と帯域幅を測定し、TSVに出力する |
| **[`collect_pitch_data.praat`](scripts/acoustic-analysis/collect_pitch_data.praat)** | 各区間のピッチ（F0）の平均値・中央値・最大/最小値・標準偏差を集計する |
| **[`calculate_segment_durations.praat`](scripts/acoustic-analysis/calculate_segment_durations.praat)** | 各区間の開始時刻・終了時刻・継続時間（秒/ミリ秒）を集計する |

---

### 3. 音声ファイル前処理 (`scripts/batch-processing/`)

| スクリプト名 | 主な用途 |
| :--- | :--- |
| **[`change_sample_rate.praat`](scripts/batch-processing/change_sample_rate.praat)** | フォルダ内のWAVファイルを指定したサンプリングレート（16kHz等）にリサンプリングする |
| **[`convert_stereo_to_mono.praat`](scripts/batch-processing/convert_stereo_to_mono.praat)** | ステレオ音声（2ch）からモノラル（1ch）に変換する（左右個別抽出または合成） |

---

### 4. グラフ・母音図描画 (`scripts/visualization/`)

| スクリプト名 | 主な用途 |
| :--- | :--- |
| **[`draw_formant_chart.praat`](scripts/visualization/draw_formant_chart.praat)** | 抽出したフォルマントデータから F1-F2 母音図を描画する |

---

### Google Colab 版

Praat をローカル環境にインストールすることなく、ブラウザ上で実行できる Google Colab ノートブックです（Pythonライブラリ `praat-parselmouth` を使用）。

| ノートブック名 | リンク | 概要 |
| :--- | :--- | :--- |
| **区間継続時間の計算** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/calculate_segment_durations.ipynb) | TextGrid を選択し、継続時間（秒/ms）を集計して TSV をダウンロード |
| **フォルマント抽出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/collect_formant_data.ipynb) | 音声とTextGridから各区間中央点のF1〜F5および帯域幅を測定して TSV をダウンロード |
| **ピッチ（F0）統計抽出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/collect_pitch_data.ipynb) | 音声とTextGridから各区間の平均・中央値・最大/最小ピッチを測定して TSV をダウンロード |
| **音声区間の切り出し** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/extract_intervals_to_wav.ipynb) | TextGridの区間ラベルに従ってWAVを切り出し、ZIPでダウンロード |
| **無音・ポーズの自動検出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/mark_pauses.ipynb) | 音声(WAV)から無音・ポーズ区間を検出し、生成されたTextGridをZIPでダウンロード |

> [!NOTE]
> **分析環境による測定値の差異について**:  
> フォルマントなどの音響特徴量の数値は、OS（Windows / macOS / Linux）やCPUアーキテクチャ、浮動小数点演算の仕様、Praatとライブラリ（parselmouth）のバージョンの違い等により、Praat本体で実行した場合と Google Colab 上で実行した場合とでわずかに異なる値が出力される可能性があります。厳密な比較を行う実験・研究では、同一の実行環境で測定することを推奨します。

---

## プラグインとしての導入

本スクリプト集は Praat のプラグイン機能に対応しています。プラグインとして配置することで、スクリプトファイルを個別に開くことなく、Praat のメニューバーおよびアクションボタンから直接機能を呼び出せます。

### インストール手順

利用環境に応じて以下のいずれかの方法でインストールを行います。

#### 1. Windows用インストーラー（.exe）

1. [Releases](https://github.com/okawawaka/praat-scripts-ja/releases/latest) から `Praat-JapaneseTools-Setup.exe` をダウンロードします。
2. ダウンロードしたファイルを実行し、画面の案内に従ってインストールを完了します。
   - 管理者権限は不要です（ユーザープロファイル配下の Praat プラグインディレクトリへ自動配置されます）。
3. Praat を起動（または再起動）します。
   - メニューバーの `Praat` -> `日本語音声ツール (JA)` に各種コマンドが登録されます。
   - オブジェクトウィンドウで Sound または TextGrid を選択した際、右側のアクションパネルにも `日本語ツール (JA)` が表示されます。

**アンインストール:**  
Windows の「設定」 -> 「アプリ」 -> 「インストールされているアプリ」から通常の手順でアンインストールできます。

---

#### 2. Praat スクリプト（install.praat）

OS（Windows / macOS / Linux）を問わず、Praat 上からインストールを実行できます。

1. 本リポジトリ内の [`installer/install.praat`](installer/install.praat) を Praat で開きます（`Praat` -> `Open Praat script...` またはウィンドウへのドラッグ＆ドロップ）。
2. スクリプトエディタで `Run` -> `Run` を実行します。
3. 表示されるダイアログの「インストール実行」をクリックします。
4. Praat を再起動します。

---

#### 3. シェルスクリプト / バッチファイル

リポジトリを作業ディレクトリにクローンまたは展開した状態で、`installer/` 配下のスクリプトを実行してシンボリックリンクまたはジャンクションを作成します。

##### Windows
`installer/install.bat` を実行します（`%USERPROFILE%\Praat\plugin_JapaneseTools` へリンクが作成されます）。

##### macOS / Linux
ターミナルで以下を実行します：
```bash
bash installer/install.sh
```
（macOS: `~/Library/Preferences/Praat Prefs/plugin_JapaneseTools`、Linux: `~/.praat-dir/plugin_JapaneseTools` へリンクが作成されます）

**アンインストール:**
- Windows: `installer/uninstall.bat` を実行
- macOS / Linux: `bash installer/uninstall.sh` を実行

---

## 単体スクリプトとしての実行方法

1. **Praat を起動**:
   - メニューバーの **`Praat`** $\to$ **`Open Praat script...`** を選択します。
2. **スクリプトを選択**:
   - 実行したいスクリプト（例: `scripts/segmentation/extract_intervals_to_wav.praat`）を開きます。
3. **スクリプトを実行**:
   - スクリプトエディタのメニュー **`Run`** $\to$ **`Run`**（またはショートカット `Ctrl + R` / `Cmd + R`）を選択します。
4. **設定ダイアログに入力**:
   - パスやパラメータを入力して **`OK`** を押すと処理が開始されます。

---

## 実行前の準備

1. **音声ファイルと TextGrid のファイル名**:
   - 多くのスクリプトは、同一ディレクトリ内に同名の `.wav` と `.TextGrid` が配置されていることを前提としています（例: `speaker01_001.wav` と `speaker01_001.TextGrid`）。
2. **Tier番号の確認**:
   - 分析対象とする区間（単語、音素など）が含まれる Tier が上から何段目（1, 2, ...）にあるかを確認し、設定ダイアログの「対象Tier番号」に指定してください。

---

## ライセンス・クレジット

本プロジェクトは **GNU General Public License v3.0 (GPL-3.0)** のもとで配布されています。

- **オリジナルスクリプト**:
  - Mietta Lennes 氏 (University of Helsinki) — [SpeCT (Speech Corpus Toolkit for Praat)](http://www.helsinki.fi/~lennes/praat-scripts/)
  - [FieldDB/Praat-Scripts](https://github.com/FieldDB/Praat-Scripts)
- **日本語化・Praat 6.x 対応**:
  - [okawawaka](https://github.com/okawawaka)
