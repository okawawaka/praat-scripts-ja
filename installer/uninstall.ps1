# ==============================================================================
# Praat 日本語音声ツール プラグイン アンインストーラー (PowerShell)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Praat 日本語音声ツール - アンインストーラー"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Praat 日本語音声ツール プラグイン アンインストーラー" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$praatDir = Join-Path $env:USERPROFILE "Praat"
$pluginDir = Join-Path $praatDir "plugin_JapaneseTools"
$buttonsFile = Join-Path $praatDir "Buttons5.ini"

# 1. 起動中 Praat プロセスの確認
$runningPraat = Get-Process Praat -ErrorAction SilentlyContinue
if ($runningPraat) {
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "【重要】現在 Praat が起動しています！" -ForegroundColor Yellow
    Write-Host "Praat が開いたままだと、メモリ上にメニューが保持されたままになり、" -ForegroundColor Yellow
    Write-Host "画面からメニューが消去されません。" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    $reply = Read-Host "Praat を今すぐ自動終了して続行しますか？ (Y: 終了して続行 / N: 手動で閉じる) [Y]"
    if ($reply -eq "" -or $reply -match "^[yY]") {
        Stop-Process -Name Praat -Force
        Start-Sleep -Milliseconds 500
        Write-Host "[完了] Praat を終了しました。" -ForegroundColor Green
    } else {
        Write-Host "[案内] アンインストール後、必ず手動で Praat を再起動してください。" -ForegroundColor Cyan
    }
    Write-Host ""
}

# 2. プラグインフォルダ・ジャンクションの完全削除
Write-Host "[削除中] プラグイン登録を解除しています..." -ForegroundColor Cyan
$deleted = $false

# plugin_JapaneseTools の削除
if (Test-Path -LiteralPath $pluginDir) {
    $item = Get-Item -LiteralPath $pluginDir -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        cmd /c "rmdir /q `"$pluginDir`"" 2>$null
    } else {
        Remove-Item -LiteralPath $pluginDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if (-not (Test-Path -LiteralPath $pluginDir)) {
        Write-Host "  -> プラグインフォルダ (plugin_JapaneseTools) を正常に削除しました。" -ForegroundColor Green
        $deleted = $true
    } else {
        # 再度強制削除
        cmd /c "rd /s /q `"$pluginDir`"" 2>$null
        $deleted = -not (Test-Path -LiteralPath $pluginDir)
    }
} else {
    Write-Host "  -> プラグインフォルダは既に登録解除されています。" -ForegroundColor Gray
    $deleted = $true
}

# 過去の古い名前プラグインフォルダ（plugin_ja, plugin_scripts_ja 等）も念のためチェック
$legacyPlugins = @("plugin_ja", "plugin_scripts_ja", "plugin_japanese_tools")
foreach ($legacy in $legacyPlugins) {
    $legPath = Join-Path $praatDir $legacy
    if (Test-Path -LiteralPath $legPath) {
        Remove-Item -LiteralPath $legPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  -> 過去の旧プラグイン ($legacy) もクリーンアップしました。" -ForegroundColor Gray
    }
}

# 3. Buttons5.ini のクリーンアップ（もしキャッシュがあれば削除）
if (Test-Path -LiteralPath $buttonsFile) {
    try {
        $content = Get-Content -LiteralPath $buttonsFile -Encoding utf8 -ErrorAction SilentlyContinue
        $filtered = $content | Where-Object { $_ -notmatch "JapaneseTools|日本語音声ツール|日本語ツール" }
        if ($content.Count -ne $filtered.Count) {
            Set-Content -LiteralPath $buttonsFile -Value $filtered -Encoding utf8
            Write-Host "  -> Praat 設定 (Buttons5.ini) からプラグインの痕跡をクリーンアップしました。" -ForegroundColor Green
        }
    } catch {
        # エラーは無視
    }
}

Write-Host ""
if ($deleted) {
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "  【成功】アンインストールが正常に完了しました！" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "Praat を起動した際、メニューからプラグインが完全に消去されています。" -ForegroundColor White
} else {
    Write-Host "【警告】一部のファイルがロックされている可能性があります。" -ForegroundColor Red
    Write-Host "Praat を完全に終了した状態で、再度 uninstall.bat をお試しください。" -ForegroundColor Yellow
}
