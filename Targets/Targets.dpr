program Targets;

uses
  Vcl.Forms,
  UFTargets in 'UFTargets.pas' {FTargets},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TFTargets, FTargets);
  Application.Run;
end.
