program Forca;

uses
  System.StartUpCopy,
  FMX.Forms,
  UFTelaJogo in 'UFTelaJogo.pas' {FTelaJogo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFTelaJogo, FTelaJogo);
  Application.Run;
end.
