program Forca;

uses
  System.StartUpCopy,
  FMX.Forms,
  Thrift in '..\lib\delphi\src\Thrift.pas',
  Thrift.Collections in '..\lib\delphi\src\Thrift.Collections.pas',
  Thrift.Exception in '..\lib\delphi\src\Thrift.Exception.pas',
  Thrift.Utils in '..\lib\delphi\src\Thrift.Utils.pas',
  Thrift.Stream in '..\lib\delphi\src\Thrift.Stream.pas',
  Thrift.Protocol in '..\lib\delphi\src\Thrift.Protocol.pas',
  Thrift.Server in '..\lib\delphi\src\Thrift.Server.pas',
  Thrift.Transport in '..\lib\delphi\src\Thrift.Transport.pas',
  Thrift.Transport.WinHTTP in '..\lib\delphi\src\Thrift.Transport.WinHTTP.pas',
  Thrift.Transport.MsxmlHTTP in '..\lib\delphi\src\Thrift.Transport.MsxmlHTTP.pas',
  Thrift.WinHTTP in '..\lib\delphi\src\Thrift.WinHTTP.pas',
  Thrift.Socket in '..\lib\delphi\src\Thrift.Socket.pas',
  Shared in '..\Shared.pas',
  Tutorial in '..\Tutorial.pas',
  UFTelaJogo in 'UFTelaJogo.pas' {FTelaJogo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFTelaJogo, FTelaJogo);
  Application.Run;
end.
