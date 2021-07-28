unit UFTargets;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Winapi.AccCtrl, Winapi.AclAPI;

type
  TFTargets = class(TForm)
    CBBerlin: TCheckBox;
    CBTokio: TCheckBox;
    CBRio: TCheckBox;
    CBSydney: TCheckBox;
    BOK: TButton;
    LBerlinInst: TLabel;
    LSydneyInst: TLabel;
    LRioInst: TLabel;
    LTokioInst: TLabel;
    BBerlinUI: TButton;
    BTokioUI: TButton;
    BRioUI: TButton;
    BSydneyUI: TButton;
    BClose: TButton;
    BBerlinUpd: TButton;
    BTokioUpd: TButton;
    BUpdRio: TButton;
    BUpdSydney: TButton;
    procedure FormShow(Sender: TObject);
    procedure BOKClick(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure CBBerlinClick(Sender: TObject);
    procedure BBerlinUIClick(Sender: TObject);
    procedure BTokioUIClick(Sender: TObject);
    procedure BRioUIClick(Sender: TObject);
    procedure BSydneyUIClick(Sender: TObject);
    procedure BBerlinUpdClick(Sender: TObject);
    procedure BTokioUpdClick(Sender: TObject);
    procedure BUpdRioClick(Sender: TObject);
    procedure BUpdSydneyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FTargets: TFTargets;

implementation

{$R *.dfm}

procedure SetPermissions(Path: String);

var
   Sid: PSID;
   peUse: DWORD;
   cchDomain: DWORD;
   cchName: DWORD;
   Name: array of Char;
   Domain: array of Char;
   pDACL: PACL;
   pEA: PEXPLICIT_ACCESS_W;
   R: DWORD;
   foldername: String;

begin

   foldername := Path;
   Sid := nil;
   Win32Check(ConvertStringSidToSidA(PAnsiChar('S-1-1-0'), Sid));
   cchName := 0;
   cchDomain := 0;

   //Get Length
   if (not LookupAccountSid(nil, Sid, nil, cchName, nil, cchDomain, peUse)) and
      (GetLastError = ERROR_INSUFFICIENT_BUFFER)
   then
      begin

         SetLength(Name, cchName);
         SetLength(Domain, cchDomain);

         if LookupAccountSid(nil, Sid, @Name[0], cchName, @Domain[0], cchDomain, peUse)
         then
            begin

               pEA := AllocMem(SizeOf(EXPLICIT_ACCESS));
               BuildExplicitAccessWithName(pEA, PChar(Name), GENERIC_ALL{GENERIC_READ},GRANT_ACCESS, SUB_CONTAINERS_AND_OBJECTS_INHERIT{NO_INHERITANCE});
               R := SetEntriesInAcl(1, pEA, nil, pDACL);

               if R = ERROR_SUCCESS
               then
                  begin

                     if SetNamedSecurityInfo(pchar(foldername), SE_FILE_OBJECT,DACL_SECURITY_INFORMATION, nil, nil, pDACL, nil) <> ERROR_SUCCESS
                     then
                        ShowMessage('SetNamedSecurityInfo failed: ' + SysErrorMessage(GetLastError));

                     LocalFree(Cardinal(pDACL));

                  end
               else
                  ShowMessage('SetEntriesInAcl failed: ' + SysErrorMessage(R));

            end;

      end;

end;

procedure TFTargets.BBerlinUIClick(Sender: TObject);
begin

   if not FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets')
   then
      begin
         ShowMessage('Backup file C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets not found. Cannot uninstall');
         Exit;
      end;

   if not DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Common.Targets')
   then
      begin
         ShowMessage('Could not delete file C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Common.Targets. You must close the IDE');
         Exit;
      end;

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNM.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNM.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDD8.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNMD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNMD8.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Common.Targets');

   DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Delphi.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiDRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiDRD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiRD.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Delphi.Targets');

   CBBerlin.Enabled := True;
   LBerlinInst.Visible := False;
   BBerlinUI.Visible := False;

end;

procedure TFTargets.BBerlinUpdClick(Sender: TObject);

var
   FileLines, FileLines2: TStringList;
   i, x: Integer;

begin

   FileLines := TStringList.Create;
   FileLines2 := TStringList.Create;

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDD8.Targets');

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNMD8.Targets');

   CBBerlin.Enabled := False;
   CBBerlin.Checked := False;
   LBerlinInst.Visible := True;
   BBerlinUI.Enabled := True;
   BBerlinUpd.Enabled := False;

end;

procedure TFTargets.BCloseClick(Sender: TObject);
begin
   Self.Close;
end;

procedure TFTargets.BOKClick(Sender: TObject);

var
   FileLines, FileLines2: TStringList;
   i, x: Integer;

begin

   FileLines := TStringList.Create;
   FileLines2 := TStringList.Create;

   if CBBerlin.Checked
   then
      begin

         SetPermissions('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Common.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Common.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin
               FileLines.Insert(i, FileLines2[x]);
               Inc(i);
            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDDX.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDD8.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNMD8.Targets');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Delphi.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.Delphi.Targets');

         i := 0;

         while (i < FileLines.Count) and (Pos('<CoreBuildDependsOn>', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('BuildClassesDex', FileLines[i]) = 0) do
            Inc(i);

         FileLines.Delete(i);

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.DelphiDRD.Targets');

         CBBerlin.Enabled := False;
         CBBerlin.Checked := False;
         LBerlinInst.Visible := True;
         BBerlinUI.Enabled := True;

      end;

   if CBTokio.Checked
   then
      begin

         SetPermissions('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Common.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Common.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin
               FileLines.Insert(i, FileLines2[x]);
               Inc(i);
            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDDX.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDD8.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNMD8.Targets');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Delphi.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Delphi.Targets');

         i := 0;

         while (i < FileLines.Count) and (Pos('<CoreBuildDependsOn>', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('BuildClassesDex', FileLines[i]) = 0) do
            Inc(i);

         FileLines.Delete(i);

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiDRD.Targets');

         CBTokio.Enabled := False;
         CBTokio.Checked := False;
         LTokioInst.Visible := True;
         BTokioUI.Enabled := True;

      end;

   if CBRio.Checked
   then
      begin

         SetPermissions('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Common.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Common.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin
               FileLines.Insert(i, FileLines2[x]);
               Inc(i);
            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDDX.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDD8.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNMD8.Targets');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Delphi.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Delphi.Targets');

         i := 0;

         while (i < FileLines.Count) and (Pos('<CoreBuildDependsOn>', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('BuildClassesDex', FileLines[i]) = 0) do
            Inc(i);

         FileLines.Delete(i);

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiDRD.Targets');

         CBRio.Enabled := False;
         CBRio.Checked := False;
         LRioInst.Visible := True;
         BRioUI.Enabled := True;

      end;

   if CBSydney.Checked
   then
      begin

         SetPermissions('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Common.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Common.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin
               FileLines.Insert(i, FileLines2[x]);
               Inc(i);
            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDDX.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDD8.Targets');

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets');
         FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

         i := 0;

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
            Inc(i);

         FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

         while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
            Inc(i);

         while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
            FileLines.Delete(i);

         for x := 0 to FileLines2.Count - 1 do
            begin

               if Pos('dx.bat', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath>');
                     Inc(i);
                     Continue;
                  end;

               if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
               then
                  begin
                     FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
                     Inc(i);
                     Continue;
                  end;

               FileLines.Insert(i, FileLines2[x]);
               Inc(i);

            end;

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNMD8.Targets');

         CopyFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Delphi.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiBack.Targets', False);

         FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Delphi.Targets');

         i := 0;

         while (i < FileLines.Count) and (Pos('<CoreBuildDependsOn>', FileLines[i]) = 0) do
            Inc(i);

         while (i < FileLines.Count) and (Pos('BuildClassesDex', FileLines[i]) = 0) do
            Inc(i);

         FileLines.Delete(i);

         FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiDRD.Targets');

         CBSydney.Enabled := False;
         CBSydney.Checked := False;
         LSydneyInst.Visible := True;
         BSydneyUI.Enabled := True;

      end;

   FileLines.Free;
   FileLines2.Free;

   if (CBBerlin.Checked) or
      (CBTokio.Checked) or
      (CBRio.Checked) or
      (CBSydney.Checked)
   then
      BOK.Enabled := True
   else
      BOK.Enabled := False;

end;

procedure TFTargets.BRioUIClick(Sender: TObject);
begin

   if not FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets')
   then
      begin
         ShowMessage('Backup file C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets not found. Cannot uninstall');
         Exit;
      end;

   if not DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Common.Targets')
   then
      begin
         ShowMessage('Could not delete file C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Common.Targets. You must close the IDE');
         Exit;
      end;

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNM.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNM.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDD8.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNMD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNMD8.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Common.Targets');

   DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Delphi.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiDRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiDRD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiRD.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.DelphiBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.Delphi.Targets');

   CBRio.Enabled := True;
   LRioInst.Visible := False;
   BRioUI.Visible := False;

end;

procedure TFTargets.BSydneyUIClick(Sender: TObject);
begin

   if not FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets')
   then
      begin
         ShowMessage('Backup file C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets not found. Cannot uninstall');
         Exit;
      end;

   if not DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Common.Targets')
   then
      begin
         ShowMessage('Could not delete file C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Common.Targets. You must close the IDE');
         Exit;
      end;

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNM.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNM.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDD8.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNMD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNMD8.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Common.Targets');

   DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Delphi.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiDRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiDRD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiRD.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.DelphiBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.Delphi.Targets');

   CBSydney.Enabled := True;
   LSydneyInst.Visible := False;
   BSydneyUI.Visible := False;

end;

procedure TFTargets.BTokioUIClick(Sender: TObject);
begin

   if not FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets')
   then
      begin
         ShowMessage('Backup file C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets not found. Cannot uninstall');
         Exit;
      end;

   if not DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Common.Targets')
   then
      begin
         ShowMessage('Could not delete file C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Common.Targets. You must close the IDE');
         Exit;
      end;

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNM.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNM.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDD8.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNMD8.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNMD8.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Common.Targets');

   DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Delphi.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiDRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiDRD.Targets');

   if FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiRD.Targets')
   then
      DeleteFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiRD.Targets');

   RenameFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.DelphiBack.Targets', 'C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.Delphi.Targets');

   CBTokio.Enabled := True;
   LTokioInst.Visible := False;
   BTokioUI.Visible := False;

end;

procedure TFTargets.BTokioUpdClick(Sender: TObject);

var
   FileLines, FileLines2: TStringList;
   i, x: Integer;

begin

   FileLines := TStringList.Create;
   FileLines2 := TStringList.Create;

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDD8.Targets');

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNMD8.Targets');

   CBTokio.Enabled := False;
   CBTokio.Checked := False;
   LTokioInst.Visible := True;
   BTokioUI.Enabled := True;
   BTokioUpd.Enabled := False;

end;

procedure TFTargets.BUpdRioClick(Sender: TObject);

var
   FileLines, FileLines2: TStringList;
   i, x: Integer;

begin

   FileLines := TStringList.Create;
   FileLines2 := TStringList.Create;

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDD8.Targets');

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNMD8.Targets');

   CBRio.Enabled := False;
   CBRio.Checked := False;
   LRioInst.Visible := True;
   BRioUI.Enabled := True;
   BUpdRio.Enabled := False;

end;

procedure TFTargets.BUpdSydneyClick(Sender: TObject);

var
   FileLines, FileLines2: TStringList;
   i, x: Integer;

begin

   FileLines := TStringList.Create;
   FileLines2 := TStringList.Create;

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --min-api 21 --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDD8.Targets');

   FileLines.LoadFromFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonBack.Targets');
   FileLines2.LoadFromFile(ExtractFilePath(Application.ExeName) + 'MakeDex.txt');

   i := 0;

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Pos('<UsingTask', FileLines[i]) > 0) do
      Inc(i);

   FileLines.Insert(i, '  <UsingTask TaskName="TrimEnd" AssemblyFile="$(BDS)\bin\Borland.Build.Tasks.Shared.dll"/>');

   while (i < FileLines.Count) and (Pos('GenClassesDex', FileLines[i]) = 0) do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i]) <> '') do
      Inc(i);

   while (i < FileLines.Count) and (Trim(FileLines[i + 2]) <> '========================================================================') do
      FileLines.Delete(i);

   for x := 0 to FileLines2.Count - 1 do
      begin

         if Pos('<JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')dx.bat</JavaDxPath''>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '   <JavaDxPath>@(JavaAaptPath->''%(RootDir)%(Directory)'')d8.bat</JavaDxPath''>');
               Inc(i);
               Continue;
            end;

         if Pos('<DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --dex --multi-dex --output="</DxClassesDexCmd>', FileLines2[x]) > 0
         then
            begin
               FileLines.Insert(i, '    <DxClassesDexCmd>PATH $(JDKPath)\bin;$(PATH) %26 "$(JavaDxPath)" --lib "$(SDKApiLevelPath)" --output="</DxClassesDexCmd>');
               Inc(i);
               Continue;
            end;

         FileLines.Insert(i, FileLines2[x]);
         Inc(i);

      end;

   FileLines.SaveToFile('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNMD8.Targets');

   CBSydney.Enabled := False;
   CBSydney.Checked := False;
   LSydneyInst.Visible := True;
   BSydneyUI.Enabled := True;
   BUpdSydney.Enabled := False;

end;

procedure TFTargets.CBBerlinClick(Sender: TObject);
begin
   if TCheckBox(Sender).Checked
   then
      BOK.Enabled := True
   else
      BOK.Enabled := False;
end;

procedure TFTargets.FormShow(Sender: TObject);
begin

  if DirectoryExists('C:\Program Files (x86)\Embarcadero\Studio\18.0')
  then

     if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMD.Targets')) or
        (FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNM.Targets'))
     then
        begin
           CBBerlin.Enabled := False;
           CBBerlin.Checked := False;
           LBerlinInst.Visible := True;
           BBerlinUI.Enabled := True;
           BBerlinUpd.Enabled := True;
        end
     else
        if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonMDDX.Targets')) or
           (FileExists('C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\CodeGear.CommonNMDX.Targets'))
        then
           begin
              CBBerlin.Enabled := False;
              CBBerlin.Checked := False;
              LBerlinInst.Visible := True;
              BBerlinUI.Enabled := False;
              BBerlinUpd.Enabled := False;
           end
        else
           begin
              CBBerlin.Checked := True;
              CBBerlin.Enabled := True;
              LBerlinInst.Visible := False;
              BBerlinUI.Enabled := False;
              BBerlinUpd.Enabled := False;
           end
  else
     begin
        CBBerlin.Enabled := False;
        BBerlinUI.Enabled := False;
        BBerlinUpd.Enabled := False;
     end;

  if DirectoryExists('C:\Program Files (x86)\Embarcadero\Studio\19.0')
  then
     if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMD.Targets')) or
        (FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNM.Targets'))
     then
        begin
           CBTokio.Enabled := False;
           CBTokio.Checked := False;
           LTokioInst.Visible := True;
           BTokioUI.Enabled := True;
           BTokioUpd.Enabled := True;
        end
     else
        if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonMDDX.Targets')) or
           (FileExists('C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\CodeGear.CommonNMDX.Targets'))
        then
           begin
              CBTokio.Enabled := False;
              CBTokio.Checked := False;
              LTokioInst.Visible := True;
              BTokioUI.Enabled := True;
              BTokioUpd.Enabled := False;
           end
        else
           begin
              CBTokio.Checked := True;
              CBTokio.Enabled := True;
              LTokioInst.Visible := False;
              BTokioUI.Enabled := False;
              BTokioUpd.Enabled := False;
           end
  else
     begin
        CBTokio.Enabled := False;
        BTokioUI.Enabled := False;
        BTokioUpd.Enabled := False;
     end;

  if DirectoryExists('C:\Program Files (x86)\Embarcadero\Studio\20.0')
  then
     if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMD.Targets')) or
        (FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNM.Targets'))
     then
        begin
           CBRio.Enabled := False;
           CBRio.Checked := False;
           LRioInst.Visible := True;
           BRioUI.Enabled := True;
           BUpdRio.Enabled := True;
        end
     else
        if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonMDDX.Targets')) or
           (FileExists('C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\CodeGear.CommonNMDX.Targets'))
        then
           begin
              CBRio.Enabled := False;
              CBRio.Checked := False;
              LRioInst.Visible := True;
              BRioUI.Enabled := True;
              BUpdRio.Enabled := False;
           end
        else
           begin
              CBRio.Checked := True;
              CBRio.Enabled := True;
              LRioInst.Visible := False;
              BRioUI.Enabled := False;
              BUpdRio.Enabled := False;
           end
  else
     begin
        CBRio.Enabled := False;
        BRioUI.Enabled := False;
        BUpdRio.Enabled := False;
     end;

  if DirectoryExists('C:\Program Files (x86)\Embarcadero\Studio\21.0')
  then
     if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMD.Targets')) or
        (FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNM.Targets'))
     then
        begin
           CBSydney.Enabled := False;
           CBSydney.Checked := False;
           LSydneyInst.Visible := True;
           BSydneyUI.Enabled := True;
           BUpdSydney.Enabled := True;
        end
     else
        if (FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonMDDX.Targets')) or
           (FileExists('C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\CodeGear.CommonNMDX.Targets'))
        then
           begin
              CBSydney.Enabled := False;
              CBSydney.Checked := False;
              LSydneyInst.Visible := True;
              BSydneyUI.Enabled := True;
              BUpdSydney.Enabled := False;
           end
        else
           begin
              CBSydney.Checked := True;
              CBSydney.Enabled := True;
              LSydneyInst.Visible := False;
              BSydneyUI.Enabled := False;
              BUpdSydney.Enabled := False;
           end
  else
     begin
        CBSydney.Enabled := False;
        BSydneyUI.Enabled := False;
        BUpdSydney.Enabled := False;
     end;

   if (CBBerlin.Checked) or
      (CBTokio.Checked) or
      (CBRio.Checked) or
      (CBSydney.Checked)
   then
      BOK.Enabled := True
   else
      BOK.Enabled := False;

end;

end.
