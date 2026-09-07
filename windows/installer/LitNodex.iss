#ifndef MyVersion
  #error MyVersion must be supplied to ISCC, for example /DMyVersion=4.3.2
#endif

#define MyAppName "LitNodex"
#define MyPublisher "LitNodex"
#define MyURL "https://github.com/13ray0914/LitNodex"

[Setup]
AppId={{5A634499-6084-4E15-BB2B-3AE22A15C6EE}
AppName={#MyAppName}
AppVersion={#MyVersion}
AppVerName={#MyAppName} {#MyVersion}
AppPublisher={#MyPublisher}
AppPublisherURL={#MyURL}
AppSupportURL={#MyURL}/issues
AppUpdatesURL={#MyURL}/releases
DefaultDirName={localappdata}\Programs\LitNodex
DefaultGroupName=LitNodex
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
OutputDir=..\..\dist-installer
OutputBaseFilename=LitNodex-{#MyVersion}-setup
SetupIconFile=..\..\assets\litnodex.ico
UninstallDisplayIcon={app}\litnodex.ico
LicenseFile=..\..\LICENSE
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Files]
Source: "payload\litnodex-*.whl"; DestDir: "{app}\payload"; Flags: ignoreversion
Source: "install_wsl.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "launch_litnodex.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\litnodex.ico"; DestDir: "{app}"; DestName: "litnodex.ico"; Flags: ignoreversion
Source: "..\..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\LitNodex"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\launch_litnodex.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\litnodex.ico"
Name: "{autodesktop}\LitNodex"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\launch_litnodex.ps1"""; WorkingDir: "{app}"; IconFilename: "{app}\litnodex.ico"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: checkedonce

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\install_wsl.ps1"""; StatusMsg: "Installing LitNodex in Ubuntu/WSL..."; Flags: waituntilterminated runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""{app}\launch_litnodex.ps1"""; Description: "Launch LitNodex"; Flags: postinstall nowait skipifsilent runasoriginaluser

[UninstallDelete]
; Scientific PDFs, generated results, config.json, and the WSL workspace are intentionally preserved.
Type: filesandordirs; Name: "{app}\payload"
