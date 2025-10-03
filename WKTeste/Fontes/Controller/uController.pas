unit uController;

interface

uses
  System.SysUtils, uModels, System.Classes, uDM, Data.DB;

type
  TPedidosController = class
  private
    FDM: TDM;
  public
    constructor Create(ADM: TDM);
    function CarregaCliente(aCodigo: Integer; out ACliente: TCliente): Boolean;
    function CarregaProduto(aCodigo: Integer; out AProd: TProduto): Boolean;
    function SalvaPedido(APedido: TPedido): Integer;
    function CarregaPedido(aNumero: Integer; out APedido: TPedido): Boolean;
    function CancelPedido(aNumero: Integer): Boolean;
    function CriarPedido(const APedido: TObject): Integer;
  end;

implementation

{ TPedidosController }

uses
  FireDAC.Comp.Client,FireDAC.Stan.Param,FireDAC.Stan.Async;

constructor TPedidosController.Create(ADM: TDM);
begin
  inherited Create;
  FDM := ADM;
end;

function TPedidosController.CriarPedido(const APedido: TObject): Integer;
var
  vPedido: TPedido;
  i: Integer;
  vQuery: TFDQuery;
  vQueryItens: TFDQuery;
begin
  Result := 0;
  if not (APedido is TPedido) then
    Exit;
  vPedido := TPedido(APedido);
  vQuery := FDM.PreparaQuery;
  vQueryItens := FDM.PreparaQuery;
  try
    FDM.DTransaction.StartTransaction;
    try
      vQuery.Close;
      vQuery.SQL.Text := 'INSERT INTO pedidos (data_emissao, codigo_cliente, valor_total) VALUES (:data_emissao, :codigo_cliente, :valor_total)';
      vQuery.ParamByName('data_emissao').AsDateTime := vPedido.DataEmissao;
      vQuery.ParamByName('codigo_cliente').AsInteger := vPedido.CodigoCliente;
      vQuery.ParamByName('valor_total').AsCurrency := vPedido.ValorTotal;
      vQuery.ExecSQL;

      vQuery.SQL.Text := 'SELECT LAST_INSERT_ID() AS lastid';
      vQuery.Open;

      try
        vPedido.NumeroPedido := vQuery.FieldByName('lastid').AsInteger;
        Result := vPedido.NumeroPedido;
      finally
        vQuery.Close;
      end;

      vQueryItens.Close;
      vQueryItens.SQL.Text := 'INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, valor_unitario, valor_total) ' +
                         'VALUES (:numero_pedido, :codigo_produto, :quantidade, :valor_unitario, :valor_total)';
      for i := 0 to vPedido.Itens.Count - 1 do
      begin
        vQueryItens.ParamByName('numero_pedido').AsInteger := vPedido.NumeroPedido;
        vQueryItens.ParamByName('codigo_produto').AsInteger := vPedido.Itens[i].CodigoProduto;
        vQueryItens.ParamByName('quantidade').AsFloat := vPedido.Itens[i].Quantidade;
        vQueryItens.ParamByName('valor_unitario').AsCurrency := vPedido.Itens[i].ValorUnitario;
        vQueryItens.ParamByName('valor_total').AsCurrency := vPedido.Itens[i].ValorTotal;
        vQueryItens.ExecSQL;
      end;

      FDM.DTransaction.Commit;
    except
      on E: Exception do
      begin
        FDM.DTransaction.Rollback;
        raise;
      end;
    end;
  finally
    FreeAndNil(vQuery);
    FreeAndNil(vQueryItens);
  end;
end;

function TPedidosController.CarregaCliente(aCodigo: Integer; out ACliente: TCliente): Boolean;
var
  vQuery: TFDQuery;
begin
  Result := False;
  ACliente := nil;
  vQuery := FDM.PreparaQuery;
  try
    vQuery.Close;
    vQuery.SQL.Text := 'SELECT codigo, nome, cidade, uf FROM clientes WHERE codigo = :codigo';
    vQuery.ParamByName('codigo').AsInteger := aCodigo;
    vQuery.Open;
    if not vQuery.IsEmpty then
    begin
      ACliente := TCliente.Create;
      ACliente.Codigo := vQuery.FieldByName('codigo').AsInteger;
      ACliente.Nome := vQuery.FieldByName('nome').AsString;
      ACliente.Cidade := vQuery.FieldByName('cidade').AsString;
      ACliente.UF := vQuery.FieldByName('uf').AsString;
      Result := True;
    end;
  finally
    FreeAndNil(vQuery);
  end;
end;

function TPedidosController.CarregaProduto(aCodigo: Integer; out AProd: TProduto): Boolean;
var
  vQuery: TFDQuery;
begin
  Result := False;
  AProd := nil;
  vQuery := FDM.PreparaQuery;
  try
    vQuery.Close;
    vQuery.SQL.Text := 'SELECT codigo, descricao, preco_venda FROM produtos WHERE codigo = :codigo';
    vQuery.ParamByName('codigo').AsInteger := aCodigo;
    vQuery.Open;
    if not vQuery.IsEmpty then
    begin
      AProd := TProduto.Create;
      AProd.Codigo := vQuery.FieldByName('codigo').AsInteger;
      AProd.Descricao := vQuery.FieldByName('descricao').AsString;
      AProd.PrecoVenda := vQuery.FieldByName('preco_venda').AsCurrency;
      Result := True;
    end;
  finally
    FreeAndNil(vQuery);
  end;
end;

function TPedidosController.SalvaPedido(APedido: TPedido): Integer;
begin
  Result := CriarPedido(APedido);
end;

function TPedidosController.CarregaPedido(aNumero: Integer; out APedido: TPedido): Boolean;
var
  vItem: TPedidoItem;
  vQuery: TFDQuery;
  vQueryItens: TFDQuery;
begin
  APedido := TPedido.Create;
  vQuery := FDM.PreparaQuery;
  vQueryItens := FDM.PreparaQuery;
  try
    try
      result := False;
      vQuery.Close;
      vQuery.SQL.Text := 'SELECT numero_pedido, data_emissao, codigo_cliente, valor_total FROM pedidos WHERE numero_pedido = :n';
      vQuery.ParamByName('n').AsInteger := aNumero;
      vQuery.Open;
      if vQuery.IsEmpty then
      begin
        APedido.Free;
        Exit(False);
      end;
      APedido.NumeroPedido := vQuery.FieldByName('numero_pedido').AsInteger;
      APedido.DataEmissao := vQuery.FieldByName('data_emissao').AsDateTime;
      APedido.CodigoCliente := vQuery.FieldByName('codigo_cliente').AsInteger;
      APedido.ValorTotal := vQuery.FieldByName('valor_total').AsCurrency;

      vQueryItens.Close;
      vQueryItens.SQL.Text := 'SELECT '+
                             '  pp.codigo, '+
                             '  pp.codigo_produto, '+
                             '  p.descricao, '+
                             '  pp.quantidade, '+
                             '  pp.valor_unitario, '+
                             '  pp.valor_total '+
                             'FROM '+
                             '  pedidos_produtos pp '+
                             'JOIN ' +
                             '  produtos p ON p.codigo = pp.codigo_produto '+
                             'WHERE '+
                             '  numero_pedido = :n '+
                             'ORDER BY '+
                             ' codigo';
      vQueryItens.ParamByName('n').AsInteger := aNumero;
      vQueryItens.Open;
      while not vQueryItens.Eof do
      begin
        vItem := TPedidoItem.Create;
        vItem.codigo := vQueryItens.FieldByName('codigo').AsInteger;
        vItem.CodigoProduto := vQueryItens.FieldByName('codigo_produto').AsInteger;
        vItem.Descricao := vQueryItens.FieldByName('descricao').AsString;
        vItem.Quantidade := vQueryItens.FieldByName('quantidade').AsFloat;
        vItem.ValorUnitario := vQueryItens.FieldByName('valor_unitario').AsCurrency;
        vItem.ValorTotal := vQueryItens.FieldByName('valor_total').AsCurrency;
        APedido.Itens.Add(vItem);
        vQueryItens.Next;
      end;

      Result := True;
    except
      APedido.Free;
      raise;
    end;
  finally
    FreeAndNil(vQuery);
    FreeAndNil(vQueryItens);
  end;
end;

function TPedidosController.CancelPedido(aNumero: Integer): Boolean;
var
  vQuery: TFDQuery;
  vQueryItens: TFDQuery;
begin
  Result := False;
  vQuery := FDM.PreparaQuery;
  vQueryItens := FDM.PreparaQuery;
  try
    try
      FDM.DTransaction.StartTransaction;
      try
        vQueryItens.Close;
        vQueryItens.SQL.Text := 'DELETE FROM pedidos_produtos WHERE numero_pedido = :n';
        vQueryItens.ParamByName('n').AsInteger := aNumero;
        vQueryItens.ExecSQL;

        vQuery.Close;
        vQuery.SQL.Text := 'DELETE FROM pedidos WHERE numero_pedido = :n';
        vQuery.ParamByName('n').AsInteger := aNumero;
        vQuery.ExecSQL;

        FDM.DTransaction.Commit;
        Result := True;
      except
        FDM.DTransaction.Rollback;
        raise;
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    FreeAndNil(vQuery);
    FreeAndNil(vQueryItens);
  end;
end;

end.