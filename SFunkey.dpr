program SFunKey;

uses
  Forms,
  SFunkeyUnit in 'SFunkeyUnit.pas' {SFunkeyMain},
  SplashUnit in 'SplashUnit.pas' {SplashForm},
  System_Process in 'System_Process.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSFunkeyMain, SFunkeyMain);
  Application.CreateForm(TSplashForm, SplashForm);
  Application.Run;
end.
