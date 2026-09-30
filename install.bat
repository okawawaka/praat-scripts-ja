@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ===================================================
echo  Praat 日本語音声ツール プラグイン インストーラー
echo ===================================================
echo.

set "PRAAT_DIR=%USERPROFILE%\Praat"
set "PLUGIN_DIR=%PRAAT_DIR%\plugin_JapaneseTools"
set "SRC_DIR=%~dp0"
set "SRC_DIR=%SRC_DIR:~0,-1%"

if not exist "%PRAAT_DIR%" (
    echo [作成中] Praat 設定ディレクトリを作成します: %PRAAT_DIR%
    mkdir "%PRAAT_DIR%"
)

if exist "%PLUGIN_DIR%" (
    echo [確認] 既存のプラグインまたはリンクが存在します。更新します...
    rmdir "%PLUGIN_DIR%" 2>nul
    if exist "%PLUGIN_DIR%" (
        rd /s /q "%PLUGIN_DIR%"
    )
)

echo [リンク作成] ジャンクションリンクを作成しています...
mklink /J "%PLUGIN_DIR%" "%SRC_DIR%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo  インストールが正常に完了しました！
    echo ===================================================
    echo Praat を起動（または再起動）してください。
    echo.
    echo ・メニューバー [Praat] -> [日本語音声ツール (JA)]
    echo ・オブジェクト選択時の右側アクションボタン [日本語ツール (JA)]
    echo から各機能をご利用いただけます。
) else (
    echo.
    echo [フォールバック] ジャンクション作成に失敗したため、フォルダコピーで導入します...
    xcopy /E /I /Y /Q "%SRC_DIR%" "%PLUGIN_DIR%"
    echo.
    echo コピーが完了しました。Praat を起動してご確認ください。
)

echo.
pause
