#define AppName "CodeVault"
#ifndef AppVersion
	#define AppVersion "1.0.0"
#endif
#ifndef AppBuild
	#define AppBuild "1"
#endif
#define AppPublisher "Ahanova AI Technologies Pvt. Ltd."
#define AppExeName "codevault.exe"

[Setup]
AppId={{6B9DE320-6907-47A7-93FC-6B07AD25C0B7}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://ahanova.in
AppSupportURL=mailto:wecare@ahanova.in
DefaultDirName={autopf}\Ahanova\CodeVault
DefaultGroupName=CodeVault
OutputDir=..\..\dist\windows
OutputBaseFilename=CodeVault-{#AppVersion}-Windows-x64
SetupIconFile=..\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#AppExeName}
VersionInfoVersion={#AppVersion}.{#AppBuild}

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\CodeVault"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\CodeVault"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Launch CodeVault"; Flags: nowait postinstall skipifsilent

; Company databases and backups under LocalAppData are intentionally retained.
