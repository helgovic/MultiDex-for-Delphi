unit UMultiDex;

interface

uses
  Windows, SysUtils, vcl.Graphics, Classes, Vcl.Menus, Vcl.ActnList, ToolsAPI, Vcl.Dialogs,
  Vcl.ComCtrls, Contnrs, Vcl.ExtCtrls, System.IniFiles, System.IOUtils;

type

  TMultiDexExpert = class(TObject)
  private
    { Private declarations }
    FProjectMenu,
    FMenuMultiDex: TMenuItem;
    FActionMultiDex: TAction;
    FMenuRunDex: TMenuItem;
    FActionRunDex: TAction;
    FMenuD8: TMenuItem;
    FActionD8: TAction;
    procedure MenuD8Execute(Sender: TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
    class function Instance: TMultiDexExpert;
    procedure ExecutePostBuildEvent(const Text: string);
    procedure ExecutePreBuildEvent;
    { Action Event Handlers }
    procedure MenuMultiDexExecute(Sender : TObject);
    procedure MenuRunDexExecute(Sender : TObject);
  public
  end;

  TCompileNotifier = class(TInterfacedObject, IOTACompileNotifier)
  protected
    procedure ProjectCompileStarted(const Project: IOTAProject; Mode: TOTACompileMode);
    procedure ProjectCompileFinished(const Project: IOTAProject; Result: TOTACompileResult);
    procedure ProjectGroupCompileStarted(Mode: TOTACompileMode);
    procedure ProjectGroupCompileFinished(Result: TOTACompileResult);
  end;

  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
  protected
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
  end;

function MultiDexExpert: TMultiDexExpert;

function GetCurrentProject: IOTAProject;
function GetCurrentProjectFileName: string;
function GetProjectGroup: IOTAProjectGroup;

implementation

uses JclStrings, DeploymentAPI;

var
  FMultiDexExpert: TMultiDexExpert;
  CompNot: Integer;
  IDENot: Integer;

function MultiDexExpert: TMultiDexExpert;
begin
  Result := TMultiDexExpert.Instance;
end;

class function TMultiDexExpert.Instance: TMultiDexExpert;
begin
  if FMultiDexExpert = nil then
    FMultiDexExpert := TMultiDexExpert.Create;
  Result := FMultiDexExpert;
end;

function FindMenuItem(MenuCaptions: String): TMenuItem;
var
   Captions: TStringList;
   NTAServices: INTAServices;
   y, i: integer;
   MenuItems: TMenuItem;
   Caption: String;
   Found: Boolean;
begin

   Result := nil;

   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         Captions := TStringList.Create;
         Captions.Delimiter := ';';
         Captions.StrictDelimiter := True;
         Captions.DelimitedText := MenuCaptions;

         MenuItems := NTAServices.MainMenu.Items;

         for y := 0 to Captions.Count - 1 do
            begin

               Found := False;

               for i := 0 to MenuItems.Count - 1 do
                  begin

                     Caption := StringReplace(MenuItems.Items[i].Caption, '&', '', []);

                     if Uppercase(Caption) = Uppercase(Captions[y])
                     then
                        begin
                           MenuItems := MenuItems.Items[i];
                           Found := True;
                           Break;
                        end;

                  end;

               if not Found
               then
                  begin
                     Captions.DisposeOf;
                     Exit;
                  end;

            end;

         Result := MenuItems;
         Captions.DisposeOf;

      end;

end;

function GetProjectGroup: IOTAProjectGroup;

var
   IModuleServices: IOTAModuleServices;
   IModule: IOTAModule;
   i: Integer;

begin

   IModuleServices := BorlandIDEServices as IOTAModuleServices;

   Result := nil;

   for i := 0 to IModuleServices.ModuleCount - 1 do
      begin

         IModule := IModuleServices.Modules[i];

         if IModule.QueryInterface(IOTAProjectGroup, Result) = S_OK
         then
            Break;

      end;

end;

function GetCurrentProject: IOTAProject;

var
   Project: IOTAProject;
   ProjectGroup: IOTAProjectGroup;

begin

   Result := nil;

   ProjectGroup := GetProjectGroup;

   if Assigned(ProjectGroup)
   then
      begin

         Project := ProjectGroup.ActiveProject;

         if Assigned(Project)
         then
            Result := Project;

      end;

end;

function GetCurrentProjectFileName: string;

var
  IProject: IOTAProject;
begin
  Result := '';

  IProject := GetCurrentProject;
  if Assigned(IProject) then
  begin
    Result := IProject.FileName;
  end;
end;

procedure TMultiDexExpert.ExecutePostBuildEvent(const Text: String);
var
  x: Integer;
  ProjFile: TextFile;
  ProjFileOut: TextFile;
  Line, LineOut: String;
  FileList: TArray<String>;
  ShortName: String;
  ProjectDeployment: IProjectDeployment;
  RCResult: TReconcileResult;
  RunDex: Boolean;
  PlatFormConfig: String;

begin

   PlatformConfig := GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration;

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      RunDex := ReadBool('MultiDexSettings', 'RunDex', True);

   if (Pos('Android', PlatformConfig) > 0) and
      (RunDex)
   then
      begin

         AssignFile(ProjFile, GetCurrentProjectFileName);
         Reset(ProjFile);
         AssignFile(ProjFileOut, ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');
         ReWrite(ProjFileOut);

         FileList := TDirectory.GetFiles(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration, '*.dex', TSearchOption.soTopDirectoryOnly);

         while not Eof(ProjFile) do
            begin

               Readln(ProjFile, Line);

               if (Pos('<DeployFile', Line) > 0) and
                  (Pos('Class="File"', Line) > 0) and
                  (Pos('classes', StrBefore('" Configuration=', StrAfter('LocalName="', Line))) > 0) and
                  (Pos('.dex', StrBefore('" Configuration=', StrAfter('LocalName="', Line))) > 0)
               then
                  while Pos('</DeployFile>', Line) = 0 do
                     Readln(ProjFile, Line)
               else
                  WriteLn(ProjFileOut, Line);

            end;

         CloseFile(ProjFile);
         CloseFile(ProjFileOut);

         AssignFile(ProjFileOut, ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');
         AssignFile(ProjFile, GetCurrentProjectFileName);

         Reset(ProjFileOut);
         Rewrite(ProjFile);

         while not Eof(ProjFileOut) do
            begin

               Readln(ProjFileOut, Line);

               WriteLn(ProjFile, Line);

               if Pos('<Deployment', Line) > 0
               then
                  begin

                     for x := 0 to High(FileList) do
                        begin

                           if ExtractFileName(FileList[x]) = 'classes.dex'
                           then
                              Continue;

                           ShortName := 'Android\Debug\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android\Release\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android64\Debug\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android64">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android64\Release\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android64">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                        end;

                  end;

            end;

         CloseFile(ProjFile);
         CloseFile(ProjFileOut);

         DeleteFile(ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');

         with BorlandIDEServices as IOTAModuleServices do
            FindModule(GetCurrentProjectFileName).Refresh(True);

         if Supports(GetCurrentProject, IProjectDeployment, ProjectDeployment)
         then
            begin
               RCResult := ProjectDeployment.Reconcile();
               ProjectDeployment.SaveToMSBuild;
            end;

         with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
            begin
               WriteBool('MultiDexSettings', 'RunDex', False);
               UpdateFile;
            end;

         FActionRunDex.Checked := False;
         FMenuRunDex.Checked := False;

      end;

end;

procedure TMultiDexExpert.ExecutePreBuildEvent;

var
   x, i: Integer;
   BDSDir: string;
   FileList: TArray<String>;
   FileLines: TStringList;
   Found: Boolean;
   PlatformConfig: String;
   MultiDex: Boolean;
   RunDex: Boolean;
   D8: Boolean;

begin

   if (not FileExists(System.SysUtils.GetEnvironmentVariable('BDS') + '\bin\CodeGear.CommonMDD8.Targets')) and
      (not FileExists(System.SysUtils.GetEnvironmentVariable('BDS') + '\bin\CodeGear.CommonNMD8.Targets'))
   then
      begin
         ShowMessage('Target files not found. You have to run Targets.exe, located in the bin directory.');
         Exit;
      end;

   PlatformConfig := GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration;

   if Pos('Android', PlatformConfig) > 0
   then
      begin

         BDSDir := System.SysUtils.GetEnvironmentVariable('BDS');

         with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
            begin
               MultiDex := ReadBool('MultiDexSettings', 'MultiDex', False);
               RunDex := ReadBool('MultiDexSettings', 'RunDex', True);
               D8 := ReadBool('MultiDexSettings', 'D8', False);
            end;

         if MultiDex
         then
            begin

               if D8
               then
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonMDD8.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end
               else
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonMDDX.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end;

            end
         else
            begin

               if D8
               then
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonNMD8.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end
               else
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonNMDX.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end;

            end;

         if RunDex
         then
            begin

               if DirectoryExists(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration)
               then
                  begin

                     FileList := TDirectory.GetFiles(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration, '*.dex', TSearchOption.soTopDirectoryOnly);

                     for x := 0 to High(FileList) do
                        if ExtractFileName(FileList[x]) <> 'classes.dex'
                        then
                           DeleteFile(FileList[x]);

                  end;

               if FileExists(BDSDir + '\bin\CodeGear.DelphiRD.Targets')
               then
                  begin
                     RenameFile(BDSDir + '\bin\CodeGear.Delphi.Targets', BDSDir + '\bin\CodeGear.DelphiDRD.Targets');
                     RenameFile(BDSDir + '\bin\CodeGear.DelphiRD.Targets', BDSDir + '\bin\CodeGear.Delphi.Targets');
                  end;

            end
         else
            begin

               if FileExists(BDSDir + '\bin\CodeGear.DelphiDRD.Targets')
               then
                  begin
                     RenameFile(BDSDir + '\bin\CodeGear.Delphi.Targets', BDSDir + '\bin\CodeGear.DelphiRD.Targets');
                     RenameFile(BDSDir + '\bin\CodeGear.DelphiDRD.Targets', BDSDir + '\bin\CodeGear.Delphi.Targets');
                  end;

            end;

      end;

end;

procedure TMultiDexExpert.MenuMultiDexExecute(Sender: TObject);

var
   IsOn: Boolean;

begin

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      begin

         IsOn := ReadBool('MultiDexSettings', 'MultiDex', False);

         if IsOn
         then
            begin
               WriteBool('MultiDexSettings', 'MultiDex', False);
               FMenuMultiDex.Checked := False;
               FActionMultiDex.Checked := False;
            end
         else
            begin
               WriteBool('MultiDexSettings', 'MultiDex', True);
               FMenuMultiDex.Checked := True;
               FActionMultiDex.Checked := True;
            end;

         UpdateFile;

      end;

end;

procedure TMultiDexExpert.MenuD8Execute(Sender: TObject);

var
   IsOn: Boolean;

begin

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      begin

         IsOn := ReadBool('MultiDexSettings', 'D8', False);

         if IsOn
         then
            begin
               WriteBool('MultiDexSettings', 'D8', False);
               FMenuD8.Checked := False;
               FActionD8.Checked := False;
            end
         else
            begin
               WriteBool('MultiDexSettings', 'D8', True);
               FMenuD8.Checked := True;
               FActionD8.Checked := True;
            end;

         UpdateFile;

      end;


end;

procedure TMultiDexExpert.MenuRunDexExecute(Sender: TObject);

var
   IsOn: Boolean;

begin

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      begin

         IsOn := ReadBool('MultiDexSettings', 'RunDex', True);

         if IsOn
         then
            begin
               WriteBool('MultiDexSettings', 'RunDex', False);
               FMenuRunDex.Checked := False;
               FActionRunDex.Checked := False;
            end
         else
            begin
               WriteBool('MultiDexSettings', 'RunDex', True);
               FMenuRunDex.Checked := True;
               FActionRunDex.Checked := True;
            end;

         UpdateFile;

      end;


end;

constructor TMultiDexExpert.Create;
var
   NTAServices : INTAServices;
   Bmp: TBitmap;
   ImageIndex: integer;
   Intf: TCompileNotifier;
   Intf2: TIDENotifier;

begin

   inherited Create;
   intf := TCompileNotifier.Create;
   CompNot := (BorlandIDEServices as IOTACompileServices).AddNotifier(Intf);
   Intf2 := TIDENotifier.Create;
   IDENot := (BorlandIDEServices as IOTAServices).AddNotifier(Intf2);

  { Main menu item }
   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         Bmp := TBitmap.Create;
         Bmp.LoadFromResourceName(HInstance, 'MD16');
         ImageIndex := NTAServices.AddMasked(Bmp, Bmp.TransparentColor,
                                  'Softmagical MultiDex icon');

         FProjectMenu := FindMenuItem('Project;QA Audits...');

         FActionMultiDex := TAction.Create(nil);
         FActionMultiDex.Category := 'Project';
         FActionMultiDex.Caption := 'MultiDex';
         FActionMultiDex.Hint := 'Project MultiDex';
         FActionMultiDex.Name := 'MultiDexAction';
         FActionMultiDex.Visible := True;
         FActionMultiDex.OnExecute := MenuMultiDexExecute;
         FActionMultiDex.Enabled := True;
         FActionMultiDex.AutoCheck := False;
         FMenuMultiDex := TMenuItem.Create(nil);
         FMenuMultiDex.AutoCheck := False;
         FMenuMultiDex.Name := 'MultiDex';
         FMenuMultiDex.Caption := 'MultiDex';
         FMenuMultiDex.AutoHotkeys := maAutomatic;
         FMenuMultiDex.Action := FActionMultiDex;
         NTAServices.AddActionMenu(FProjectMenu.Name, FActionMultiDex, FMenuMultiDex, True);
         FActionMultiDex.ImageIndex := ImageIndex;
         FMenuMultiDex.ImageIndex := ImageIndex;

         Bmp.LoadFromResourceName(HInstance, 'RD16');
         ImageIndex := NTAServices.AddMasked(Bmp, Bmp.TransparentColor,
                                  'Softmagical RunDex icon');

         FActionRunDex := TAction.Create(nil);
         FActionRunDex.Category := 'Project';
         FActionRunDex.Caption := 'RunDex';
         FActionRunDex.Hint := 'Project RunDex';
         FActionRunDex.Name := 'RunDexAction';
         FActionRunDex.Visible := True;
         FActionRunDex.OnExecute := MenuRunDexExecute;
         FActionRunDex.Enabled := True;
         FActionRunDex.AutoCheck := False;
         FMenuRunDex := TMenuItem.Create(nil);
         FMenuRunDex.Name := 'RunDex';
         FMenuRunDex.Caption := 'Run Dex';
         FMenuRunDex.AutoHotkeys := maAutomatic;
         FMenuRunDex.AutoCheck := False;
         FMenuRunDex.Action := FActionRunDex;
         NTAServices.AddActionMenu(FProjectMenu.Name, FActionRunDex, FMenuRunDex, True);
         FActionRunDex.ImageIndex := ImageIndex;
         FMenuRunDex.ImageIndex := ImageIndex;

         Bmp.LoadFromResourceName(HInstance, 'D816');
         ImageIndex := NTAServices.AddMasked(Bmp, Bmp.TransparentColor,
                                  'Softmagical D8 icon');

         Bmp.DisposeOf;

         FActionD8 := TAction.Create(nil);
         FActionD8.Category := 'Project';
         FActionD8.Caption := 'Use D8 dexer';
         FActionD8.Hint := 'Use D8 dexer';
         FActionD8.Name := 'D8Action';
         FActionD8.Visible := True;
         FActionD8.OnExecute := MenuD8Execute;
         FActionD8.Enabled := True;
         FActionD8.AutoCheck := False;
         FMenuD8 := TMenuItem.Create(nil);
         FMenuD8.Name := 'D8';
         FMenuD8.Caption := 'Use D8 dexer';
         FMenuD8.AutoHotkeys := maAutomatic;
         FMenuD8.AutoCheck := False;
         FMenuD8.Action := FActionD8;
         NTAServices.AddActionMenu(FProjectMenu.Name, FActionD8, FMenuD8, True);
         FActionD8.ImageIndex := ImageIndex;
         FMenuD8.ImageIndex := ImageIndex;

      end;

end;

destructor TMultiDexExpert.Destroy;

var
   Service : INTAServices;

begin

   Service := (BorlandIDEServices as INTAServices);

   if (FProjectMenu = nil)
   then
      begin

         if (-1 <> Service.MainMenu.Items.IndexOf(FMenuMultiDex))
         then
            Service.MainMenu.Items.Remove(FMenuMultiDex)
         else
            begin

               if (-1 <> FProjectMenu.IndexOf(FMenuMultiDex))
               then
                  FProjectMenu.Remove(FMenuMultiDex);

            end;

         if (-1 <> Service.MainMenu.Items.IndexOf(FMenuRunDex))
         then
            Service.MainMenu.Items.Remove(FMenuRunDex)
         else
            begin

               if (-1 <> FProjectMenu.IndexOf(FMenuRunDex))
               then
                  FProjectMenu.Remove(FMenuRunDex);

            end;

         if (-1 <> Service.MainMenu.Items.IndexOf(FMenuD8))
         then
            Service.MainMenu.Items.Remove(FMenuD8)
         else
            begin

               if (-1 <> FProjectMenu.IndexOf(FMenuD8))
               then
                  FProjectMenu.Remove(FMenuD8);

            end;

      end;

   FMenuMultiDex.Free;
   FActionMultiDex.Free;
   FMenuRunDex.Free;
   FActionRunDex.Free;
   FMenuD8.Free;
   FActionD8.Free;

   (BorlandIDEServices as IOTACompileServices).RemoveNotifier(CompNot);

   inherited Destroy;

end;

{ TCompileNotifier }

procedure TCompileNotifier.ProjectCompileFinished(const Project: IOTAProject;
  Result: TOTACompileResult);
begin

   if Result = crOTASucceeded
   then
      MultiDexExpert.ExecutePostBuildEvent('Build Success');

end;

procedure TCompileNotifier.ProjectCompileStarted(const Project: IOTAProject;
  Mode: TOTACompileMode);
begin
   MultiDexExpert.ExecutePreBuildEvent;
end;

procedure TCompileNotifier.ProjectGroupCompileFinished(
  Result: TOTACompileResult);
begin

end;

procedure TCompileNotifier.ProjectGroupCompileStarted(Mode: TOTACompileMode);
begin

end;

{ TIDENotifier }

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin

end;

procedure TIDENotifier.AfterSave;
begin

end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin

end;

procedure TIDENotifier.BeforeSave;
begin

end;

procedure TIDENotifier.Destroyed;
begin

end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin

   if NotifyCode = ofnActiveProjectChanged
   then
      with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
         begin

            MultiDexExpert.FActionMultiDex.Checked := ReadBool('MultiDexSettings', 'MultiDex', False);
            MultiDexExpert.FMenuMultiDex.Checked := ReadBool('MultiDexSettings', 'MultiDex', False);

            MultiDexExpert.FActionRunDex.Checked := ReadBool('MultiDexSettings', 'RunDex', True);
            MultiDexExpert.FMenuRunDex.Checked := ReadBool('MultiDexSettings', 'RunDex', True);

            MultiDexExpert.FActionD8.Checked := ReadBool('MultiDexSettings', 'D8', False);
            MultiDexExpert.FMenuD8.Checked := ReadBool('MultiDexSettings', 'D8', False);

         end;

end;

procedure TIDENotifier.Modified;
begin

end;

initialization
  FMultiDexExpert := TMultiDexExpert.Instance;
finalization
  FreeAndNil(FMultiDexExpert);

end.
