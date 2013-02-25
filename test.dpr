program test;

uses
  Vcl.Forms,
  main in 'main.pas' {mainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TmainFrm, mainFrm);
  Application.Run;
end.
