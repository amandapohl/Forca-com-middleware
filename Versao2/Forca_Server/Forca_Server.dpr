program Forca_Server;

uses
  System.StartUpCopy,
  FMX.Forms,
  UFPrincipal in 'UFPrincipal.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
