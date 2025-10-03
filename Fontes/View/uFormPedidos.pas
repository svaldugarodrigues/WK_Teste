unit uFormPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, uModels, uController, uDM, System.Generics.Collections;

type
  TFormPedidos = class(TForm)
    PanelCliente: TPanel;
    Label1: TLabel;
    edtCodigoCliente: TEdit;
    edtNomeCliente: TEdit;
    btnBuscarCliente: TButton;
    GroupBoxProduto: TGroupBox;
    edtCodigoProduto: TEdit;
    edtDescricaoProduto: TEdit;
    edtQuantidade: TEdit;
    edtValorUnitario: TEdit;
    btnInserirProduto: TButton;
    StringGridItens: TStringGrid;
    PanelBottom: TPanel;
    LabelTotal: TLabel;
    btnGravarPedido: TButton;
    btnCarregarPedido: TButton;
    btnCancelarPedido: TButton;
    GroupBoxCliente: TGroupBox;
    Label2: TLabel;
    PanelProduto: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClienteClick(Sender: TObject);
    procedure btnInserirProdutoClick(Sender: TObject);
    procedure StringGridItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure btnCarregarPedidoClick(Sender: TObject);
    procedure btnCancelarPedidoClick(Sender: TObject);
    procedure StringGridItensDblClick(Sender: TObject);
    procedure StringGridItensDrawCell(Sender: TObject; ACol, ARow: LongInt;
      Rect: TRect; State: TGridDrawState);
    procedure edtCodigoProdutoExit(Sender: TObject);
    procedure edtCodigoProdutoChange(Sender: TObject);
    procedure edtValorUnitarioKeyPress(Sender: TObject; var Key: Char);
    procedure edtValorUnitarioExit(Sender: TObject);
    procedure edtCodigoClienteChange(Sender: TObject);
  private
    FController: TPedidosController;
    FPedido: TPedido;
    FDM: TDM;
    FEditandoProduto: Integer;
    procedure AtualizarGridTotais;
    procedure AtualizarGrid;
    procedure NovoPedido;
    procedure EditarProduto(ALinha: Integer);
    procedure LimpaProduto(ALimpaCodigo: Boolean);
    procedure AplicarMarcaraPreco;
  public
  end;

var
  FormPedidos: TFormPedidos;

implementation

{$R *.dfm}

uses
  System.StrUtils,System.UITypes;

procedure TFormPedidos.FormCreate(Sender: TObject);
begin
  FDM := TDM.Create(Self);
  FDM.DataModuleCreate(FDM);
  try
    FDM.Connect;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar ao banco: ' + E.Message);
  end;
  FController := TPedidosController.Create(FDM);
  FPedido := TPedido.Create;
  FEditandoProduto := -1;

  StringGridItens.RowCount := 2;
  StringGridItens.ColCount := 5;
  StringGridItens.Cells[0,0] := 'Código';
  StringGridItens.Cells[1,0] := 'Descrição';
  StringGridItens.ColWidths[1] := 300;
  StringGridItens.Cells[2,0] := 'Quantidade';
  StringGridItens.Cells[3,0] := 'Vlr.Unit';
  StringGridItens.Cells[4,0] := 'Vlr.Total';

  NovoPedido;
end;

procedure TFormPedidos.LimpaProduto(ALimpaCodigo: Boolean);
begin
  if ALimpaCodigo then
    edtCodigoProduto.Clear;
  edtDescricaoProduto.Clear;
  edtQuantidade.Clear;
  edtValorUnitario.Clear;
end;

procedure TFormPedidos.NovoPedido;
begin
  FPedido.Clear;
  AtualizarGrid;
  AtualizarGridTotais;
  edtCodigoCliente.Text := '';
  edtNomeCliente.Text := '';
  edtCodigoProduto.Text := '';
  edtDescricaoProduto.Text := '';
  edtQuantidade.Text := '';
  edtValorUnitario.Text := '';
  FEditandoProduto := -1;
end;

procedure TFormPedidos.btnBuscarClienteClick(Sender: TObject);
var
  codigo: Integer;
  cli: TCliente;
begin
  if TryStrToInt(edtCodigoCliente.Text, codigo) then
  begin
    if FController.CarregaCliente(codigo, cli) then
    begin
      edtNomeCliente.Text := cli.Nome;
      FPedido.CodigoCliente := cli.Codigo;
      cli.Free;
    end
    else
      ShowMessage('Cliente não encontrado');
  end
  else
    ShowMessage('Informe um código de cliente válido');
end;

procedure TFormPedidos.btnInserirProdutoClick(Sender: TObject);
var
  vprod: TProduto;
  vCodigo, vLinha: Integer;
  vQtd, vUnit: Double;
  vTotal: Currency;
  vItem: TPedidoItem;
begin
  if not TryStrToInt(edtCodigoProduto.Text, vCodigo) then
  begin
    ShowMessage('Código de produto inválido');
    Exit;
  end;

  if not FController.CarregaProduto(vCodigo, vProd) then
  begin
    ShowMessage('Produto não encontrado');
    Exit;
  end;

  if not TryStrToFloat(edtQuantidade.Text, vQtd) then
  begin
    ShowMessage('Quantidade inválida');
    vProd.Free;
    Exit;
  end;

  if not TryStrToFloat(edtValorUnitario.Text, vunit) then
  begin
    vunit := vProd.PrecoVenda;
  end;

  vTotal := vUnit * vQtd;

  if FEditandoProduto >= 1 then
  begin
    vLinha := FEditandoProduto;
    vItem := FPedido.Itens[vLinha-1];
    vItem.CodigoProduto := vCodigo;
    vItem.Descricao := vProd.Descricao;
    vItem.Quantidade := vQtd;
    vItem.ValorUnitario := vunit;
    vItem.ValorTotal := vtotal;
    FEditandoProduto := -1;
  end
  else
  begin
    vItem := TPedidoItem.Create;
    vItem.CodigoProduto := vCodigo;
    vItem.Descricao := vProd.Descricao;
    vItem.Quantidade := vQtd;
    vItem.ValorUnitario := vunit;
    vItem.ValorTotal := vtotal;
    FPedido.Itens.Add(vItem);
  end;

  vProd.Free;
  AtualizarGrid;
  AtualizarGridTotais;

  edtCodigoProduto.Text := '';
  edtDescricaoProduto.Text := '';
  edtQuantidade.Text := '';
  edtValorUnitario.Text := '';
end;

procedure TFormPedidos.EditarProduto(ALinha: Integer);
var
  vItem: TPedidoItem;
begin
  ALinha := StringGridItens.Row;
  if (ALinha >= 1) and (ALinha <= FPedido.Itens.Count) then
  begin
    vItem := FPedido.Itens[ALinha-1];
    edtCodigoProduto.Text := IntToStr(vItem.CodigoProduto);
    edtDescricaoProduto.Text := vItem.Descricao;
    edtQuantidade.Text := FloatToStr(vItem.Quantidade);
    edtValorUnitario.Text := CurrToStr(vItem.ValorUnitario);
    AplicarMarcaraPreco;
    FEditandoProduto := ALinha;
  end;
end;

procedure TFormPedidos.edtCodigoClienteChange(Sender: TObject);
begin
  btnCarregarPedido.Visible := edtCodigoCliente.Text = '';
  btnCancelarPedido.Visible := edtCodigoCliente.Text = '';
end;

procedure TFormPedidos.edtCodigoProdutoChange(Sender: TObject);
begin
  if Length(edtDescricaoProduto.Text) > 0 then
    LimpaProduto(False);
end;

procedure TFormPedidos.edtCodigoProdutoExit(Sender: TObject);
var
  vCodigo: Integer;
  vprod: TProduto;
begin
  if Length(edtCodigoProduto.Text) > 0 then
  begin
    if not TryStrToInt(edtCodigoProduto.Text, vCodigo) then
      exit;

    if not FController.CarregaProduto(vCodigo, vProd) then
      exit;

    edtDescricaoProduto.Text := vProd.Descricao;
    edtValorUnitario.Text := CurrToStr(vProd.PrecoVenda);
    edtQuantidade.Text := '1';
    AplicarMarcaraPreco;
    if FEditandoProduto > 0 then
      FEditandoProduto := -1;
  end;
end;

procedure TFormPedidos.edtValorUnitarioExit(Sender: TObject);
begin
  AplicarMarcaraPreco;
end;

procedure TFormPedidos.edtValorUnitarioKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', ',', #8]) then
    Key := #0;
end;

procedure TFormPedidos.AplicarMarcaraPreco;
var
  vValor: Currency;
begin
  if TryStrToCurr(edtValorUnitario.Text, vValor) then
    edtValorUnitario.Text := FormatCurr('#,##0.00', vValor)
  else
    edtValorUnitario.Text := '0,00';
end;

procedure TFormPedidos.AtualizarGrid;
var
  i, r: Integer;
begin
  StringGridItens.RowCount := FPedido.Itens.Count + 1;
  for i := 0 to FPedido.Itens.Count - 1 do
  begin
    r := i + 1;
    StringGridItens.Cells[0, r] := IntToStr(FPedido.Itens[i].CodigoProduto);
    StringGridItens.Cells[1, r] := FPedido.Itens[i].Descricao;
    StringGridItens.Cells[2, r] := FormatFloat('#,##0.00', FPedido.Itens[i].Quantidade);
    StringGridItens.Cells[3, r] := FormatFloat('#,##0.00', FPedido.Itens[i].ValorUnitario);
    StringGridItens.Cells[4, r] := FormatFloat('#,##0.00', FPedido.Itens[i].ValorTotal);
  end;
end;

procedure TFormPedidos.AtualizarGridTotais;
var
  i: Integer;
  tot: Currency;
begin
  tot := 0;
  for i := 0 to FPedido.Itens.Count - 1 do
    tot := tot + FPedido.Itens[i].ValorTotal;
  FPedido.ValorTotal := tot;
  LabelTotal.Caption := FormatFloat('#,##0.00', tot);
end;

procedure TFormPedidos.StringGridItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  vLinha: Integer;
  vResp: Integer;
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then
    Exit;

  if Key = VK_DELETE then
  begin
    vLinha := StringGridItens.Row;
    if (vLinha >= 1) and (vLinha <= FPedido.Itens.Count) then
    begin
      vResp := MessageDlg('Deseja realmente excluir o item selecionado?', mtConfirmation, [mbYes, mbNo], 0);
      if vResp = mrYes then
      begin
        FPedido.Itens.Delete(vLinha-1);
        AtualizarGrid;
        AtualizarGridTotais;
      end;
    end;
  end
  else if Key = VK_RETURN then
  begin
    EditarProduto(StringGridItens.Row)
  end;
end;

procedure TFormPedidos.StringGridItensDblClick(Sender: TObject);
begin
  EditarProduto(StringGridItens.Row)
end;

procedure TFormPedidos.StringGridItensDrawCell(Sender: TObject; ACol,
  ARow: LongInt; Rect: TRect; State: TGridDrawState);
var
  Txt: string;
  TxtFormat: Integer;
begin
  if (ACol in [2, 3, 4]) and (ARow > 0) then
  begin
    Txt := TStringGrid(Sender).Cells[ACol, ARow];

    with TStringGrid(Sender).Canvas do
    begin
      FillRect(Rect);

      TxtFormat := DT_RIGHT or DT_VCENTER or DT_SINGLELINE;
      DrawText(Handle, PChar(Txt), Length(Txt), Rect, TxtFormat);
    end;
  end;
end;

procedure TFormPedidos.btnGravarPedidoClick(Sender: TObject);
var
  numeroGerado: Integer;
begin
  if FPedido.Itens.Count = 0 then
  begin
    ShowMessage('Inclua ao menos um item no pedido.');
    Exit;
  end;
  if FPedido.CodigoCliente = 0 then
  begin
    ShowMessage('Informe o cliente antes de gravar.');
    Exit;
  end;

  try
    numeroGerado := FController.SalvaPedido(FPedido);
    ShowMessage('Pedido gravado com sucesso. Número: ' + IntToStr(numeroGerado));
    NovoPedido;
  except
    on E: Exception do
      ShowMessage('Erro ao gravar pedido: ' + E.Message);
  end;
end;

procedure TFormPedidos.btnCarregarPedidoClick(Sender: TObject);
var
  vNumS: string;
  vNumI: Integer;
  vPedidoCarregado: TPedido;
  vCliente: TCliente;
begin

  vNumS := InputBox('Carregar Pedido', 'Número do pedido', '');
  if vNumS = '' then
    Exit;

  if not TryStrToInt(vNumS, vNumI) then
  begin
    ShowMessage('Número inválido');
    Exit;
  end;
  if FController.CarregaPedido(vNumI, vPedidoCarregado) then
  begin
    try
      vCliente := TCliente.Create;
      edtCodigoCliente.Text := IntToStr(vPedidoCarregado.CodigoCliente);
      try
        if FController.CarregaCliente(vPedidoCarregado.CodigoCliente, vCliente) then
          edtNomeCliente.Text := vCliente.Nome;
      finally
        vCliente.Free
      end;

      FPedido.Clear;
      FPedido.NumeroPedido := vPedidoCarregado.NumeroPedido;
      FPedido.DataEmissao := vPedidoCarregado.DataEmissao;
      FPedido.CodigoCliente := vPedidoCarregado.CodigoCliente;
      for var it in vPedidoCarregado.Itens do
        FPedido.Itens.Add(TPedidoItem.Create);

      for var i := 0 to vPedidoCarregado.Itens.Count -1 do
      begin
        FPedido.Itens[i].Codigo := vPedidoCarregado.Itens[i].Codigo;
        FPedido.Itens[i].CodigoProduto := vPedidoCarregado.Itens[i].CodigoProduto;
        FPedido.Itens[i].Descricao := vPedidoCarregado.Itens[i].Descricao;
        FPedido.Itens[i].Quantidade := vPedidoCarregado.Itens[i].Quantidade;
        FPedido.Itens[i].ValorUnitario := vPedidoCarregado.Itens[i].ValorUnitario;
        FPedido.Itens[i].ValorTotal := vPedidoCarregado.Itens[i].ValorTotal;
      end;

      AtualizarGrid;
      AtualizarGridTotais;
      LimpaProduto(True);
    finally
      vPedidoCarregado.Free;
    end;
  end
  else
    ShowMessage('Pedido não encontrado');
end;

procedure TFormPedidos.btnCancelarPedidoClick(Sender: TObject);
var
  vNumS: string;
  vNumI: Integer;
  vContinuar: Boolean;
begin
  vNumS := InputBox('Cancelar Pedido', 'Número do pedido', '');
  if vNumS = '' then
    Exit;

  if not TryStrToInt(vNumS, vNumI) then
  begin
    ShowMessage('Número inválido');
    Exit;
  end;
  vContinuar := MessageDlg('Confirma cancelamento do pedido ' + IntToStr(vNumI) + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
  if not vContinuar then
    Exit;

  try
    if FController.CancelPedido(vNumI) then
      ShowMessage('Pedido cancelado com sucesso')
    else
      ShowMessage('Não foi possível cancelar o pedido');
  except
    on E: Exception do
      ShowMessage('Erro ao cancelar: ' + E.Message);
  end;
end;

procedure TFormPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FPedido.Free;
  FController.Free;
  FDM.Disconnect;
  FDM.Free;
end;

end.