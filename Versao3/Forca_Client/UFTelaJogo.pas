unit UFTelaJogo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdSocksServer,
  IdTCPConnection, IdTCPClient, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FMX.ScrollBox, FMX.Layouts, Generics.Collections, Thrift,
  Thrift.Collections, Thrift.Exception, Thrift.Utils,
  Thrift.Stream, Thrift.Protocol, Thrift.Server, Thrift.Transport,
  Thrift.Transport.WinHTTP, Thrift.Transport.MsxmlHTTP, Thrift.WinHTTP, Shared,
  Tutorial;

type
  TFTelaJogo = class(TForm)
    StyleBook1: TStyleBook;
    ClienteSocket: TIdTCPClient;
    edtBaseDescoberto: TEdit;
    edtBaseOculto: TEdit;
    GBJogar: TGroupBox;
    gpRoleta: TGroupBox;
    btnRoleta: TButton;
    gpPalpite: TGroupBox;
    edtLetra: TEdit;
    Button1: TButton;
    edtPalavra: TEdit;
    Button2: TButton;
    GroupBox2: TGroupBox;
    SGJogadores: TStringGrid;
    nome: TStringColumn;
    pontos: TStringColumn;
    lblJogador: TLabel;
    lblPontos: TLabel;
    lblPontoValendo: TLabel;
    Panel1: TPanel;
    PnlLetras: TPanel;
    ScrollBox1: TScrollBox;
    GBNome: TGroupBox;
    EdtNome: TEdit;
    btnNome: TButton;
    edtHost: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnRoletaClick(Sender: TObject);
    procedure btnNomeClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    procedure GeraTela(aPalavra: string);
    procedure CriaLetra(aLetra: string; aIndice: Integer);
    procedure LimpaLista(aLista: TStringList);
    procedure AtualizaTela;
    procedure PopulaJogadores(aJogadores: string);
    procedure ComunicaServer;
    procedure FinalizaThread(Sender: Tobject);
    procedure AtualizaDados(aItem, aDados: string);
    function AtualizaPontos(aJogador : Integer) : String;
    { Private declarations }
  public
    { Public declarations }
  end;

  TJogador = class
  public
    Nome: string;
    Pontos: Integer;
  end;

var
  FTelaJogo: TFTelaJogo;
  FLetras: TStringList;
  FPalavraAtual: string;
  FJogadores: TStringList;
  FIndiceJogadorAtual: Integer;
  FPontosValendo: Integer;
  FLetrasUtilizadas: TStringList;
  FThread: TThread;
  FAtualizando: Boolean;
  FComunicando: Boolean;
  FJogador: string;
  FAtualizaPalavra : Boolean;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

procedure TFTelaJogo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimpaLista(FLetras);
  LimpaLista(FJogadores);
  FLetrasUtilizadas.Free;
  FLetras.Free;
  FJogadores.Free;
end;

procedure TFTelaJogo.FormCreate(Sender: TObject);
var
  vJogador: TJogador;
  vTemp: TStringList;
begin
  vTemp := TStringList.Create;
  FLetrasUtilizadas := TStringList.Create;

  FLetras := TStringList.Create;

  FJogadores := TStringList.Create;
  FIndiceJogadorAtual := 0;

  FAtualizaPalavra := False;
end;

procedure TFTelaJogo.LimpaLista(aLista: TStringList);
var
  i: Integer;
begin
  for i := aLista.Count - 1 downto 0 do
  begin
    aLista.Objects[i].Free;
  end;
  aLista.Clear;
end;

procedure TFTelaJogo.GeraTela(aPalavra: string);
var
  i: Integer;
begin
  LimpaLista(FLetras);
  for i := PnlLetras.ComponentCount - 1 downto 0 do
  begin
    PnlLetras.Components[i].Free;
  end;
  for i := Length(aPalavra) downto 1 do
  begin
    CriaLetra(Copy(aPalavra, i, 1), i);
  end;
  PnlLetras.Width := 100 * Length(aPalavra);
end;

procedure TFTelaJogo.btnNomeClick(Sender: TObject);
var
  vResposta: string;
begin
  ClienteSocket.Host := edtHost.Text;
  ClienteSocket.Connect;
  ClienteSocket.Socket.WriteLn('iniciarJogo');
  vResposta := ClienteSocket.Socket.ReadLn;
  ClienteSocket.Socket.WriteLn(edtNome.Text);
  vResposta := ClienteSocket.Socket.ReadLn;
  FJogador := edtNome.Text;
  GBNome.Enabled := False;
  ComunicaServer;
end;

procedure TFTelaJogo.btnRoletaClick(Sender: TObject);
var
  vResposta : String;
begin
  gpRoleta.Enabled := False;
  while FComunicando do begin
    sleep(10);
  end;
  FComunicando := True;
  ClienteSocket.Socket.WriteLn('rodouRoleta');
  vResposta := ClienteSocket.Socket.ReadLn;
  FComunicando := False;
  FPontosValendo := StrToInt(vResposta);
  lblPontoValendo.Text := 'Valendo ' + vResposta + ' pontos.';
  gpPalpite.Enabled := True;
  Updated;
end;

procedure TFTelaJogo.Button1Click(Sender: TObject);
var
  vResposta : String;
begin
  if edtLetra.Text = '' then  begin
    ShowMessage('Preencha a letra.');
    Exit;
  end;
  gpPalpite.Enabled := False;
  while FComunicando do begin
    sleep(10);
  end;
  FComunicando := True;
  ClienteSocket.Socket.WriteLn('palpiteLetra');
  vResposta := ClienteSocket.Socket.ReadLn;
  ClienteSocket.Socket.WriteLn(edtLetra.Text);
  vResposta := ClienteSocket.Socket.ReadLn;
  FComunicando := False;
  ShowMessage(vResposta);
  if vResposta = 'Letra correta' then begin
    lblPontoValendo.Text := 'Aguardando roleta.';
    gpRoleta.Enabled := True;
    GBJogar.Enabled := False;
  end else if vResposta = 'Letra nao encontrada.' then begin
    gpRoleta.Enabled := True;
    GBJogar.Enabled := False;
  end else begin
    gpPalpite.Enabled := True;
  end;
  edtLetra.Text := '';
  FJogadores.Values[FJogadores.Names[FIndiceJogadorAtual]] := AtualizaPontos(FIndiceJogadorAtual);
  Updated;
end;

procedure TFTelaJogo.Button2Click(Sender: TObject);
var
  vResposta : String;
begin
  if edtPalavra.Text = '' then begin
    ShowMessage('Preencha a palavra.');
    Exit;
  end;
  gpPalpite.Enabled := False;
  while FComunicando do begin
    sleep(10);
  end;
  FComunicando := True;
  ClienteSocket.Socket.WriteLn('palpitePalavra');
  vResposta := ClienteSocket.Socket.ReadLn;
  ClienteSocket.Socket.WriteLn(edtPalavra.Text);
  vResposta := ClienteSocket.Socket.ReadLn;
  FComunicando := False;
  ShowMessage(vResposta);
  if vResposta = 'Palavra correta' then begin
    lblPontoValendo.Text := 'Aguardando roleta.';
    gpRoleta.Enabled := True;
    GBJogar.Enabled := False;
  end;
  if vResposta = 'Palavra incorreta.' then begin
    gpRoleta.Enabled := True;
    GBJogar.Enabled := False;
  end;
  edtLetra.Text := '';
  Updated;
end;

procedure TFTelaJogo.Button3Click(Sender: TObject);
begin
  ShowMessage(AtualizaPontos(0));
end;

function TFTelaJogo.AtualizaPontos(aJogador : Integer) : String;
var transport : ITransport;
    protocol  : IProtocol;
    client    : TCalculator.Iface;
  begin
  try
    transport := TSocketImpl.Create( 'localhost', 9090);
    protocol  := TBinaryProtocolImpl.Create( transport);
    client    := TCalculator.TClient.Create( protocol);

    transport.Open();

    Result := IntToStr(client.pesquisaPontos(aJogador, 0));

    transport.Close();

  except
    on e : Exception
    do ShowMessage( e.ClassName+': '+e.Message);
  end;
end;

procedure TFTelaJogo.CriaLetra(aLetra: string; aIndice: Integer);
var
  vLetra: TEdit;
begin
  vLetra := TEdit.Create(PnlLetras);
  vLetra.Parent := PnlLetras;
  vLetra.Text := aLetra;
  vLetra.Visible := True;
  vLetra.Height := 125;
  vLetra.Position.X := (aIndice - 1) * 100;
  vLetra.Enabled := False;
  FLetras.AddObject(IntToStr(aIndice), vLetra);
end;

procedure TFTelaJogo.PopulaJogadores(aJogadores: string);
var
  vJogador: TJogador;
  vJog: string;
  vCorte: Integer;
  i: Integer;
  vJogadores: TStringList;
begin
  vJogadores := TStringList.Create;
  vJogadores.Text := aJogadores;
  LimpaLista(FJogadores);
  FJogadores.Clear;
  for i := 0 to vJogadores.Count - 1 do begin
    vJogador := TJogador.Create;
    vJog := vJogadores[i];
    vCorte := vJog.IndexOf('=');
    vJogador.Nome := Copy(vJog, 1, vCorte);
    vJogador.Pontos := StrToInt(Copy(vJog, vCorte + 2, length(vJog)));
    SGJogadores.Cells[0, i] := vJogador.Nome;
    SGJogadores.Cells[1, i] := IntToStr(vJogador.Pontos);
    FJogadores.AddObject(IntToStr(i), vJogador);
  end;
  vJogadores.Free;
end;

procedure TFTelaJogo.AtualizaTela;
var
  i: Integer;
  vLetra: TEdit;
begin
  if not FAtualizando then begin
    FAtualizando := True;
    PnlLetras.Visible := False;
    lblJogador.Text := 'Jogador atual: ' + TJogador(FJogadores.Objects[FIndiceJogadorAtual]).Nome;
    lblPontos.Text := 'Pontua��o: ' + IntToStr(TJogador(FJogadores.Objects[FIndiceJogadorAtual]).Pontos);
    if FPontosValendo > 0 then begin
      lblPontoValendo.Text := 'Valendo ' + IntToStr(FPontosValendo) + ' pontos.';
    end else begin
      lblPontoValendo.Text := '';
    end;

    if FAtualizaPalavra then begin
      GeraTela(FPalavraAtual);
      FAtualizaPalavra := False;
    end;
    for i := 0 to FLetras.Count - 1 do begin
      vLetra := TEdit(FLetras.Objects[i]);
      if FLetrasUtilizadas.IndexOf(vLetra.Text) >= 0 then
      begin
        vLetra.TextSettings := edtBaseDescoberto.TextSettings;
        vLetra.StyledSettings := edtBaseDescoberto.StyledSettings;
        vLetra.StyleLookup := edtBaseDescoberto.StyleLookup;
      end
      else
      begin
        vLetra.TextSettings := edtBaseOculto.TextSettings;
        vLetra.StyledSettings := edtBaseOculto.StyledSettings;
      end;
    end;
    GBJogar.Enabled := TJogador(FJogadores.Objects[FIndiceJogadorAtual]).Nome = FJogador;
    GPRoleta.Enabled := (TJogador(FJogadores.Objects[FIndiceJogadorAtual]).Nome = FJogador) and (not gpPalpite.Enabled);
    PnlLetras.Visible := True;
    FAtualizando := False;
    Updated;
  end;
end;

procedure TFTelaJogo.ComunicaServer;
var
  I: Integer;
begin
  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
      vRodando: Boolean;
      vResposta: string;
      vItem, vDados: string;
      vAtualizou: Boolean;
    begin
      vRodando := True;
      try
        while vRodando do
        begin
          if not FComunicando then begin
            FComunicando := True;
            ClienteSocket.Socket.WriteLn('AttDados');
            vResposta := ClienteSocket.Socket.ReadLn;
            vAtualizou := False;
            while vResposta <> 'fim' do begin
              vAtualizou := True;
              vItem := vResposta;
              ClienteSocket.Socket.WriteLn('manda');
              vResposta := StringReplace(ClienteSocket.Socket.ReadLn, '|QUEBRA|', #$D#$A, [rfReplaceAll]);
              vDados := vResposta;
              AtualizaDados(vItem, vDados);
              ClienteSocket.Socket.WriteLn('ok');
              vResposta := ClienteSocket.Socket.ReadLn;
              sleep(100);
            end;
            FComunicando := False;
            if vAtualizou then begin
              try
                AtualizaTela;
              except
                    //
              end;
            end;
          end;
          sleep(1000);
        end;
      except
        on E: Exception do
          showMessage(E.Message);
      end;
    end);
  FThread.OnTerminate := FinalizaThread;
  FThread.Start;
end;

procedure TFTelaJogo.AtualizaDados(aItem, aDados: string);
begin
  if aItem = 'FPalavraAtual' then begin
    if FPalavraAtual <> aDados then begin
      FAtualizaPalavra := True;
      FPalavraAtual := aDados;
    end;
    Exit;
  end;

  if aItem = 'FJogadores' then begin
    PopulaJogadores(aDados);
    Exit;
  end;

  if aItem = 'FPontosValendo' then begin
    FPontosValendo := StrToInt(aDados);
    Exit;
  end;

  if aItem = 'FLetrasUtilizadas' then begin
    FLetrasUtilizadas.Text := aDados;
    Exit;
  end;

  if aItem = 'FIndiceJogadorAtual' then begin
    FIndiceJogadorAtual := StrToInt(aDados);
    Exit;
  end;

end;

procedure TFTelaJogo.FinalizaThread(Sender: Tobject);
begin
  FThread.Terminate;
  FThread.Free;
  ClienteSocket.Disconnect;
end;

end.

