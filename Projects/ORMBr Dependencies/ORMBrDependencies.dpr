program ORMBrDependencies;

uses
  Vcl.Forms,
  ormbr.dependencies.main in 'ormbr.dependencies.main.pas' {Form1},
  ormbr.dependencies.interfaces in 'ormbr.dependencies.interfaces.pas',
  ormbr.dependencies.executor in 'ormbr.dependencies.executor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
