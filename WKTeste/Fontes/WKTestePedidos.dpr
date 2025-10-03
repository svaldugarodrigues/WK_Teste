program WKTestePedidos;

uses
  Vcl.Forms,
  uController in 'Controller\uController.pas',
  uDM in 'Data\uDM.pas' {DM: TDataModule},
  uModels in 'Model\uModels.pas',
  uFormPedidos in 'View\uFormPedidos.pas' {FormPedidos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormPedidos, FormPedidos);
  Application.Run;
end.
