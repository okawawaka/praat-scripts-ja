# ==============================================================================
# Praat 日本語音声ツール プラグイン インストーラー (PowerShell)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Praat 日本語音声ツール - インストーラー"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Praat 日本語音声ツール プラグイン インストーラー" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$praatDir = Join-Path $env:USERPROFILE "Praat"
$pluginDir = Join-Path $praatDir "plugin_JapaneseTools"
$srcDir = Split-Path -Parent $PSScriptRoot

# 1. Praat 設定フォルダの確認・作成
if (-not (Test-Path -LiteralPath $praatDir)) {
    Write-Host "[作成中] Praat 設定ディレクトリを作成します: $praatDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $praatDir -Force | Out-Null
}

# 2. 既存のプラグイン登録を安全に解除
if (Test-Path -LiteralPath $pluginDir) {
    Write-Host "[クリーンアップ] 既存のプラグイン登録を更新します..." -ForegroundColor Gray
    $item = Get-Item -LiteralPath $pluginDir -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        cmd /c "rmdir /q `"$pluginDir`"" 2>$null
    } else {
        Remove-Item -LiteralPath $pluginDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 3. ジャンクションリンクの作成（管理者権限不要）
Write-Host "[登録中] プラグインを Praat にリンクしています..." -ForegroundColor Cyan
$mklinkOut = cmd /c "mklink /J `"$pluginDir`" `"$srcDir`"" 2>&1

if (Test-Path -LiteralPath $pluginDir) {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "  【成功】プラグインのインストールが正常に完了しました！" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "【利用できるメニュー】" -ForegroundColor White
    Write-Host "  1. メニューバー: [Praat] -> [日本語音声ツール (JA)]" -ForegroundColor White
    Write-Host "  2. 右側アクションボタン: Sound や TextGrid 選択時に [日本語ツール (JA)]" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[フォールバック] ジャンクション作成に失敗したためフォルダコピーで導入します..." -ForegroundColor Yellow
    Copy-Item -Path $srcDir -Destination $pluginDir -Recurse -Force
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "  【完了】フォルダコピーによる導入が完了しました！" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host ""
}

# 4. Praat 起動確認と再起動の案内
$runningPraat = Get-Process Praat -ErrorAction SilentlyContinue
if ($runningPraat) {
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "【重要なお知らせ】" -ForegroundColor Yellow
    Write-Host "現在 Praat が起動しています。" -ForegroundColor Yellow
    Write-Host "新しいメニューを Praat に反映させるため、" -ForegroundColor Yellow
    Write-Host "一度 Praat を閉じてから再起動してください。" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
} else {
    Write-Host "Praat を起動して新しいメニューをご確認ください。" -ForegroundColor Cyan
}
