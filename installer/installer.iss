; ==============================================================================
; Inno Setup Script: Praat 日本語音声ツール (praat-scripts-ja)
; 公式リポジトリ: https://github.com/okawawaka/praat-scripts-ja
; ==============================================================================

#define MyAppName "Praat 日本語音声ツール"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "okawawaka"
#define MyAppURL "https://github.com/okawawaka/praat-scripts-ja"

[Setup]
; 1. 管理者権限不要（ユーザーフォルダ内にインストールするため安全かつUACプロンプトなし）
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
AppId={{D37E6B2A-98C3-4E1B-9430-67B7A8B108E1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; 2. インストール先: Praat 標準のプラグイン配置先 (%USERPROFILE%\Praat\plugin_JapaneseTools)
DefaultDirName={userprofile}\Praat\plugin_JapaneseTools
DisableDirPage=no
DisableProgramGroupPage=yes
DirExistsWarning=no

; 3. 出力ファイル設定
OutputDir=..\dist
OutputBaseFilename=Praat-JapaneseTools-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; 4. アンインストーラー情報
UninstallFilesDir={userprofile}\Praat\plugin_JapaneseTools
UninstallDisplayName={#MyAppName} (Praat プラグイン)

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Messages]
SetupWindowTitle=Praat 日本語音声ツール プラグイン インストーラー
WelcomeLabel1=Praat 日本語音声ツールのインストール
WelcomeLabel2=このウィザードは、お使いのパソコンに [Praat 日本語音声ツール] プラグインを導入します。%n%nインストール先は自動的に Praat の設定フォルダに指定されています。%nそのまま「次へ」をクリックして進んでください。
FinishedHeadingLabel=インストールが完了しました
FinishedLabel=Praat 日本語音声ツールの導入が完了しました。%n%n【ご利用方法】%n1. Praat を起動します（既に開いている場合は一度終了して再起動してください）。%n2. Objects ウィンドウのメニューバー [Praat] -> [日本語音声ツール (JA)] が追加されます。%n3. Sound や TextGrid オブジェクト選択時にも右側に専用ボタンが表示されます。

[Files]
; プラグイン本体スクリプトおよび定義ファイル
Source: "..\setup.praat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs

[Code]
// Praat プロセスが稼働中か確認
function IsPraatRunning(): Boolean;
var
  FSWbemLocator: Variant;
  FWMIService: Variant;
  FWbemObjectSet: Variant;
begin
  Result := False;
  try
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2');
    FWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM Win32_Process WHERE Name = "Praat.exe"');
    Result := (FWbemObjectSet.Count > 0);
  except
    Result := False;
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if IsPraatRunning() then
  begin
    MsgBox('現在 Praat が起動しています。' #13#10 #13#10 +
           'インストーラーはそのまま続行できますが、新メニューを反映させるため、' #13#10 +
           'インストール完了後に Praat を再起動してください。', mbInformation, MB_OK);
  end;
end;
