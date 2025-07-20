[Setup]
AppName=Love Ribbon Censoured Patch
AppVersion=1.0
; use a default that is unlikely to be a real directory
DefaultDirName={pf}\LoveRibbon
DisableDirPage=yes
OutputBaseFilename=LoveRibbon18PatchInstaller
Compression=lzma
SolidCompression=yes
WizardImageFile=banner.bmp
SetupIconFile=icon.ico

[Files]
Source: "hpatch.rpa"; DestDir: "{app}\game"; Flags: ignoreversion

[Run]
;Filename: "{app}\game\hpatch.rpa"; Description: "Installed Patch"; Flags: postinstall shellexec nowait

[Code]
var
  GamePath: String;

function PosEx(const SubStr, S: string; Offset: Integer): Integer;
var
  i: Integer;
begin
  for i := Offset to Length(S) - Length(SubStr) + 1 do
  begin
    if Copy(S, i, Length(SubStr)) = SubStr then
    begin
      Result := i;
      Exit;
    end;
  end;
  Result := 0;
end;

function SplitString(const S, Delimiter: String): TArrayOfString;
var
  P, Start: Integer;
  List: TArrayOfString;
  I: Integer;
begin
  SetArrayLength(List, 0);
  P := Pos(Delimiter, S);
  Start := 1;
  I := 0;
  while P > 0 do
  begin
    SetArrayLength(List, I + 1);
    List[I] := Copy(S, Start, P - Start);
    Start := P + Length(Delimiter);
    P := PosEx(Delimiter, S, Start);
    Inc(I);
  end;
  SetArrayLength(List, I + 1);
  List[I] := Copy(S, Start, Length(S) - Start + 1);
  Result := List;
end;

function GetSteamPath(): string;
begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Valve\Steam', 'InstallPath', Result) then
    Result := Result
  else
    Result := '';
end;

function GetLibraryPaths(SteamPath: String): TArrayOfString;
var
  VDFPath, Line: String;
  Contents: AnsiString;
  Lines: TArrayOfString;
  I: Integer;
  Paths: TArrayOfString;
begin
  SetArrayLength(Paths, 1);
  Paths[0] := SteamPath; 

  VDFPath := SteamPath + '\steamapps\libraryfolders.vdf';
  if not LoadStringFromFile(VDFPath, Contents) then
  begin
    Result := Paths;
    Exit;
  end;

  Lines := SplitString(Contents, #10);
  for I := 0 to GetArrayLength(Lines)-1 do
  begin
    Line := Trim(Lines[I]);
    if Pos('"path"', Line) > 0 then
    begin
      Line := Copy(Line, Pos('"path"', Line) + 6, Length(Line));
      Line := Trim(Line);
      if (Length(Line) > 2) and (Line[1] = '"') then
      begin
        Line := Copy(Line, 2, Pos('"', Copy(Line, 2, Length(Line)-1)) - 1);
        SetArrayLength(Paths, GetArrayLength(Paths)+1);
        Paths[GetArrayLength(Paths)-1] := Line;
      end;
    end;
  end;
  Result := Paths;
end;

function ReadStringFromFile(const FileName, Key: string): string;
var
  FileContents, Line: AnsiString;
  Lines: TArrayOfString;
  I, P: Integer;
begin
  Result := '';
  if not LoadStringFromFile(FileName, FileContents) then Exit;
  Lines := SplitString(FileContents, #10);
  for I := 0 to GetArrayLength(Lines)-1 do
  begin
    Line := Trim(Lines[I]);
    if Pos('"' + Key + '"', Line) = 1 then
    begin
      P := Pos('"', Copy(Line, Length(Key) + 3, Length(Line)));
      if P > 0 then
      begin
        Line := Copy(Line, Length(Key) + 3 + P, Length(Line));
        P := Pos('"', Line);
        if P > 0 then
          Result := Copy(Line, 1, P - 1);
      end;
      Exit;
    end;
  end;
end;

function GetGameInstallPath(Param: String): String;
var
  SteamPath, ManifestPath, InstallDir: String;
  Libraries: TArrayOfString;
  I: Integer;
begin
  SteamPath := GetSteamPath();
  Libraries := GetLibraryPaths(SteamPath);
  for I := 0 to GetArrayLength(Libraries)-1 do
  begin
    ManifestPath := Libraries[I] + '\steamapps\appmanifest_559610.acf';
    if FileExists(ManifestPath) then
    begin
      InstallDir := ReadStringFromFile(ManifestPath, 'installdir');
      Result := Libraries[I] + '\steamapps\common\' + InstallDir;
      Exit;
    end;
  end;
  Result := '';
end;

procedure InitializeWizard();
begin
  GamePath := GetGameInstallPath('');
  if GamePath <> '' then
  begin
    WizardForm.DirEdit.Text := GamePath;
  end
  else
  begin
    MsgBox('Love Ribbon installation not found. Please make sure the game is installed through Steam.', mbError, MB_OK);
    Abort;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    MsgBox('Censorship is never the answer, especially for such loving sisters.', mbInformation, MB_OK);
  end;
end;