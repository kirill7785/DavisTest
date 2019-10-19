unit UnitLaunchMeshGen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmLaunchGenerator = class(TForm)
    btnContinue: TButton;
    chkfreeUDS: TCheckBox;
    chkrestartSettingUDM: TCheckBox;
    chkonlyadditionalunicalmeshline: TCheckBox;
    procedure btnContinueClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLaunchGenerator: TfrmLaunchGenerator;

implementation

{$R *.dfm}

procedure TfrmLaunchGenerator.btnContinueClick(Sender: TObject);
begin
   // Закрываем форму и переходим к следующим диалогам.
   Close;
end;

end.
