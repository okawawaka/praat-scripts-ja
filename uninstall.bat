@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ===================================================
echo  Praat 日本語音声ツール プラグイン アンインストーラー
echo ===================================================
echo.

set "PLUGIN_DIR=%USERPROFILE%\Praat\plugin_JapaneseTools"

if exist "%PLUGIN_DIR%" (
    rmdir "%PLUGIN_DIR%" 2>nul
    if exist "%PLUGIN_DIR%" (
        rd /s /q "%PLUGIN_DIR%"
    )
    echo プラグイン (plugin_JapaneseTools) を正常に削除・解除しました。
) else (
    echo プラグインはインストールされていませんでした。
)

echo.
pause
