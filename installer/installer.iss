; ==============================================================================
; Inno Setup Script: Praat 日本語音声ツール (praat-scripts-ja)
; 公式リポジトリ: https://github.com/okawawaka/praat-scripts-ja
; ==============================================================================

#define MyAppName "Praat 日本語音声ツール"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "okawawaka"
#define MyAppURL "https://github.com/okawawaka/praat-scripts-ja"

[Setup]
; 1. 一般ユーザー権限でインストール（管理者権限不要・UAC不要）
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
AppId={{D37E6B2A-98C3-4E1B-9430-67B7A8B108E1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}

; 2. プラグイン配置先: {%USERPROFILE}\Praat\plugin_JapaneseTools
DefaultDirName={%USERPROFILE}\Praat\plugin_JapaneseTools
DisableDirPage=no
DisableProgramGroupPage=yes
DirExistsWarning=no
Uninstallable=yes
UninstallDisplayName={#MyAppName} (Praat プラグイン)

; 3. 出力ファイル設定
OutputDir=..\dist
OutputBaseFilename=Praat-JapaneseTools-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "..\setup.praat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs
