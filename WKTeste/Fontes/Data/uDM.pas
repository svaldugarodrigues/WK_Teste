unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.Phys.Intf,
  FireDAC.Dapt, FireDAC.Comp.DataSet, FireDAC.Phys.MySQL, FireDAC.Phys,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.VCLUI.Wait, System.IniFiles;

type
  TDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    procedure CarregaINI(const AIniFile: string);
    procedure CriarINI(const AIniFile: string);
  public
    procedure Connect;
    procedure Disconnect;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function PreparaQuery: TFDQuery;

    property DTransaction: TFDTransaction read FDTransaction write FDTransaction;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uModels, System.Variants;

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  //
end;

procedure TDM.AfterConstruction;
begin
  inherited;
  FDTransaction := TFDTransaction.Create(nil);
end;

procedure TDM.BeforeDestruction;
begin
  inherited;
  FreeAndNil(FDTransaction);
end;

procedure TDM.CarregaINI(const AIniFile: string);
var
  vIni: TIniFile;
  vDB, vUser, vPass, vServer, vPort, vLib: string;
begin
  CriarINI(AIniFile);
  vIni := TIniFile.Create(AIniFile);
  try
    if FileExists(AIniFile) then
    begin
      vDB := vIni.ReadString('Database', 'Database', '');
      vUser := vIni.ReadString('Database', 'Username', '');
      vPass := vIni.ReadString('Database', 'Password', '');
      vServer := vIni.ReadString('Database', 'Server', '');
      vPort := vIni.ReadString('Database', 'Port', '');
      vLib := vIni.ReadString('Database', 'LibPath', '');

      if FDPhysMySQLDriverLink = nil then
        FDPhysMySQLDriverLink := TFDPhysMySQLDriverLink.Create(Self);

      FDPhysMySQLDriverLink.VendorLib := vLib;

      if FDConnection = nil then
        FDConnection := TFDConnection.Create(Self);

      FDConnection.Params.Clear;
      FDConnection.Params.Add('DriverID=MySQL');
      FDConnection.Params.Add('Server=' + vServer);
      FDConnection.Params.Add('Database=' + vDB);
      FDConnection.Params.Add('User_Name=' + vUser);
      FDConnection.Params.Add('Password=' + vPass);
      FDConnection.Params.Add('Port=' + vPort);
      FDConnection.LoginPrompt := False;
    end;
  finally
    vIni.Free;
  end;
end;

procedure TDM.Connect;
begin
  CarregaINI(ExtractFilePath(ParamStr(0)) + 'config.ini');
  if not FDConnection.Connected then
    FDConnection.Open;
end;

procedure TDM.Disconnect;
begin
  if FDConnection.Connected then
    FDConnection.Close;
end;

function TDM.PreparaQuery: TFDQuery;
begin
  if FDTransaction = nil then
    FDTransaction := TFDTransaction.Create(Self);

  FDTransaction.Connection := FDConnection;

  result := TFDQuery.Create(nil);
  result.Connection := FDConnection;
end;

procedure TDM.CriarINI(const AIniFile: string);
var
  vArq: TextFile;
begin
  if not FileExists(AIniFile) then
  begin
    AssignFile(vArq, 'Config.ini');
    Rewrite(vArq);
    Writeln(vArq, '[DATABASE]');
    Writeln(vArq, 'Database=pedidos_db');
    Writeln(vArq, 'Username=root');
    Writeln(vArq, 'Password=12345678');
    Writeln(vArq, 'Server=127.0.0.1');
    Writeln(vArq, 'Port=3306');
    Writeln(vArq, 'LibPath=libmysql.dll');

    CloseFile(vArq);
    TInifile.Create(AIniFile);
  end;
end;

end.
