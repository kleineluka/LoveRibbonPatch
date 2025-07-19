[Setup]
AppName=Love Ribbon 18+ Patch
AppVersion=1.0
DefaultDirName={code:GetGameInstallPath}
DisableDirPage=yes
Uninstallable=yes
UninstallDisplayIcon={app}\game\hpatch.rpa
OutputBaseFilename=LoveRibbon18PatchInstaller
Compression=lzma
SolidCompression=yes
WizardImageFile=banner.bmp
SetupIconFile=icon.ico

[Files]
Source: "hpatch.rpa"; DestDir: "{app}\game"; Flags: ignoreversion

[Icons]
Name: "{group}\Uninstall Love Ribbon 18+ Patch"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\game\hpatch.rpa"; Description: "Installed Patch"; Flags: postinstall shellexec nowait
; Show a cute confirmation
[Code]
function GetSteamPath(): string;
var
  Key: string;
begin
  Key := 'Software\Valve\Steam';
  if RegQueryStringValue(HKEY_CURRENT_USER, Key, 'SteamPath', Result) then
    Result := Result
  else
    Result := '';
end;

function ReadStringFromFile(const FileName, Key: string): string;
var
  FileContents, Line: AnsiString;
  Lines: TArrayOfString;
  I: Integer;
begin
  Result := '';
  if not LoadStringFromFile(FileName, FileContents) then Exit;
  Lines := SplitString(FileContents, #10);
  for I := 0 to GetArrayLength(Lines)-1 do
  begin
    Line := Trim(Lines[I]);
    if Pos('"' + Key + '"', Line) = 1 then
    begin
      Result := Trim(StringChange(Line, ['"' + Key + '"', '', '"', '', '\', '']));
      Result := Copy(Result, Pos(':', Result) + 1, MaxInt);
      Exit;
    end;
  end;
end;

function GetGameInstallPath(Param: String): String;
var
  SteamPath, LibVDF, Manifest, InstallDir, GamePath: String;
  I: Integer;
  LibPath: String;
begin
  SteamPath := GetSteamPath();
  LibVDF := SteamPath + '\steamapps\libraryfolders.vdf';
  for I := 0 to 10 do begin
    LibPath := ReadStringFromFile(LibVDF, IntToStr(I));
    if LibPath = '' then continue;
    Manifest := LibPath + '\steamapps\appmanifest_559610.acf';
    if FileExists(Manifest) then begin
      InstallDir := ReadStringFromFile(Manifest, 'installdir');
      GamePath := LibPath + '\steamapps\common\' + InstallDir;
      Result := GamePath;
      Exit;
    end;
  end;
  // fallback
  Result := ExpandConstant('{pf}\Steam\steamapps\common\Love Ribbon');
end;

// Show message box after install finishes
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then begin
    MsgBox('Censourship is never the answer, especially for such loving sisters.', mbInformation, MB_OK);
  end;
end;
