# Praat Scripts (日本語解説版 / Japanese Edition) 🎙️

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Praat: 6.0+](https://img.shields.io/badge/Praat-6.0%2B-green.svg)](https://www.fon.hum.uva.nl/praat/)

言語学・音声学・音響分析のための **日本語解説付き Praat スクリプト集** です。  
世界中で広く利用されている Mietta Lennes 氏の **SpeCT (Speech Corpus Toolkit for Praat)** および [FieldDB/Praat-Scripts](https://github.com/FieldDB/Praat-Scripts) をベースに、**入力画面の完全日本語化**、**初心者向けの丁寧なインライン解説**、および **現行の Praat 6.x 系モダン構文へのリファクタリング** を施しています。

---

## 💡 本リポジトリの特徴

1. **すべての操作ダイアログが日本語**:
   - スクリプト実行時の入力フォーム（パラメータ設定画面）を自然な日本語にローカライズ。
2. **Praat 6.x 系モダン構文に準拠**:
   - 旧式コマンドを最新の `selectObject` 等の関数型構文に更新し、警告が出ず安全に動作します。
3. **日本語Windows環境への配慮**:
   - 日本語パスや空白を含むディレクトリでもエラーを起こしにくいセーフティガード（自動スラッシュ補正など）を搭載。
4. **Excel / R との親和性**:
   - 出力形式はすべてタブ区切りテキスト（TSV）に統一されており、Excelや統計解析ソフトですぐに開いて分析できます。

---

## 📂 収録スクリプト一覧 & 逆引きガイド

### 1. 音声切り出し・区間アノテーション (`scripts/segmentation/`)

| スクリプト名 | やりたいこと / 主な用途 |
| :--- | :--- |
| **[`extract_intervals_to_wav.praat`](scripts/segmentation/extract_intervals_to_wav.praat)** | TextGridのラベル区間ごとに、個別のWAVファイルとして一括切り出し保存する（★**ハイブリッド対応**） |
| **[`mark_pauses.praat`](scripts/segmentation/mark_pauses.praat)** | 音声の強さ（音量）から無音・ポーズ区間を自動検出し、TextGridに境界線・ラベルを付与する（★**ハイブリッド対応**） |

---

### 2. 音響特徴量・分析データ一括抽出 (`scripts/acoustic-analysis/`)

| スクリプト名 | やりたいこと / 主な用途 |
| :--- | :--- |
| **[`collect_formant_data.praat`](scripts/acoustic-analysis/collect_formant_data.praat)** | 各母音区間の中央点におけるフォルマント（F1〜F5）と帯域幅を一括測定し、TSVに出力する（★**ハイブリッド対応**） |
| **[`collect_pitch_data.praat`](scripts/acoustic-analysis/collect_pitch_data.praat)** | 各区間のピッチ（F0）の平均値・中央値・最大/最小値・標準偏差を一括集計する（★**ハイブリッド対応**） |
| **[`calculate_segment_durations.praat`](scripts/acoustic-analysis/calculate_segment_durations.praat)** | 各区間の開始時刻・終了時刻・継続時間（秒/ミリ秒）を一覧集計する（★**ハイブリッド対応 / TextGrid書き込み対応**） |

---

### 3. 音声ファイル一括前処理 (`scripts/batch-processing/`)

| スクリプト名 | やりたいこと / 主な用途 |
| :--- | :--- |
| **[`change_sample_rate.praat`](scripts/batch-processing/change_sample_rate.praat)** | フォルダ内のすべてのWAVファイルを指定したサンプリングレート（16kHz等）に一括リサンプリングする（★**ハイブリッド対応**） |
| **[`convert_stereo_to_mono.praat`](scripts/batch-processing/convert_stereo_to_mono.praat)** | ステレオ音声（2ch）からモノラル（1ch）に一括変換する（左右個別抽出または合成）（★**ハイブリッド対応**） |

---

### 4. グラフ・母音図描画 (`scripts/visualization/`)

| スクリプト名 | やりたいこと / 主な用途 |
| :--- | :--- |
| **[`draw_formant_chart.praat`](scripts/visualization/draw_formant_chart.praat)** | 抽出したフォルマントデータから、音声学の慣例（軸反転）に従った F1-F2 母音図を自動描画する（★**ハイブリッド対応**） |

---

### 🌐 Google Colab 版（ブラウザで即実行可能）

Praat をインストールしていない環境でも、ブラウザ上のファイル選択ダイアログから実行できる Google Colab ノートブック群です。Praat の C++ コアエンジン（`praat-parselmouth`）を使用しているため、**Praat 本体と 100% 同一の結果**が得られます。

| ノートブック名 | リンク / 実行 | 概要 |
| :--- | :--- | :--- |
| **区間継続時間の計算** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/calculate_segment_durations.ipynb) | ダイアログで TextGrid を選択し、継続時間（秒/ms）を一覧集計して TSV をダウンロード |
| **フォルマント一括抽出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/collect_formant_data.ipynb) | 音声とTextGridから各区間中央点のF1〜F5および帯域幅を一括測定して TSV をダウンロード |
| **ピッチ（F0）統計一括抽出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/collect_pitch_data.ipynb) | 音声とTextGridから各区間の平均・中央値・最大/最小ピッチを測定して TSV をダウンロード |
| **音声区間の一括切り出し** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/extract_intervals_to_wav.ipynb) | TextGridの区間ラベルに従ってWAVを一括切り出しし、ZIPアーカイブで一括ダウンロード |
| **無音・ポーズの自動検出** | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/okawawaka/praat-scripts-ja/blob/main/notebooks/mark_pauses.ipynb) | 音声(WAV)から無音・ポーズ区間を自動検出し、生成されたTextGridをZIPで一括ダウンロード |

---

## 🚀 使い方（Praat スクリプトの実行方法）

### 前提条件
- お手元のパソコンに **Praat** がインストールされていること（[公式サイト](https://www.fon.hum.uva.nl/praat/) よりダウンロード可能）。

### 手順
1. **本リポジトリをダウンロード**:
   - 緑色の「Code」ボタン $\to$ 「Download ZIP」からダウンロードして解凍するか、`git clone` します。
2. **Praat を起動**:
   - 上部メニューバーの **`Praat`** $\to$ **`Open Praat script...`** を選択します。
3. **スクリプトを選択**:
   - 実行したいスクリプト（例: `scripts/segmentation/extract_intervals_to_wav.praat`）を開きます。
4. **スクリプトを実行**:
   - スクリプトエディタが開いたら、メニューの **`Run`** $\to$ **`Run`**（またはショートカット `Ctrl + R` / `Cmd + R`）を押します。
5. **設定ダイアログに入力**:
   - 日本語のフォームが表示されます。対象フォルダのパスやパラメータを入力し、**`OK`** を押すと自動処理が始まります。

> [!TIP]
> **フォルダパスの入力について**:  
> Windows の場合は `C:\Users\username\Desktop\data\` のように、フォルダパスの末尾に `\` または `/` を含めて指定してください（スクリプト側でも自動補正されます）。

---

## 🧪 お手元の音声データで試す準備

本リポジトリには著作権・肖像権保護のためサンプルの音声ファイルは同梱していません。ご自身の手持ちの音声や研究データでお試しください。

1. **同名のペアを用意する**:
   - 多くのスクリプトは、同じフォルダ内に同名の `.wav` と `.TextGrid` があることを前提としています。  
     （例: `speaker01_001.wav` と `speaker01_001.TextGrid`）
2. **Tier番号を確認する**:
   - 分析対象としたい段（単語Tier、音素Tierなど）が上から何段目（1, 2, ...）にあるかを確認して、設定画面の「対象Tier番号」に指定してください。

---

## 📜 ライセンス・原著作者クレジット

本プロジェクトは **GNU General Public License v3.0 (GPL-3.0)** のもとで配布されています。

- **原典・オリジナルスクリプト**:
  - **Mietta Lennes 氏** (ヘルシンキ大学) — [SpeCT (Speech Corpus Toolkit for Praat)](http://www.helsinki.fi/~lennes/praat-scripts/)
  - [FieldDB/Praat-Scripts](https://github.com/FieldDB/Praat-Scripts)
- **日本語化・モダンPraat構文対応・ドキュメント作成**:
  - [okawawaka](https://github.com/okawawaka)

音声学・音響音声学コミュニティに多大な貢献をされた Mietta Lennes 氏をはじめとする原作者・開発者の方々に深く感謝申し上げます。
