unit uModels;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, Data.DB;

type
  TCliente = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
  end;

  TProduto = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FPrecoVenda: Currency;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
  end;

  TPedidoItem = class
  private
    FCodigo: Integer;
    FCodigoProduto: Integer;
    FDescricao: string;
    FQuantidade: Double;
    FValorUnitario: Currency;
    FValorTotal: Currency;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property Descricao: string read FDescricao write FDescricao;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
  end;

  TPedido = class
  private
    FNumeroPedido: Integer;
    FDataEmissao: TDateTime;
    FCodigoCliente: Integer;
    FValorTotal: Currency;
    FItens: TObjectList<TPedidoItem>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property Itens: TObjectList<TPedidoItem> read FItens;
  end;

implementation

{ TPedido }

constructor TPedido.Create;
begin
  inherited;
  FItens := TObjectList<TPedidoItem>.Create(True);
  FDataEmissao := Now;
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TPedido.Clear;
begin
  FItens.Clear;
  FNumeroPedido := 0;
  FDataEmissao := Now;
  FCodigoCliente := 0;
  FValorTotal := 0;
end;

end.