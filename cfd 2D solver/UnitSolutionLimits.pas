unit UnitSolutionLimits;
// Задаёт принудительные пределы изменения каждой из UDS.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormSolutionLimits = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    btnapply: TButton;
    edtminuds1: TEdit;
    edtmaxuds1: TEdit;
    edtminuds2: TEdit;
    edtmaxuds2: TEdit;
    edtminuds3: TEdit;
    edtmaxuds3: TEdit;
    edtminuds4: TEdit;
    edtmaxuds4: TEdit;
    procedure btnapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSolutionLimits: TFormSolutionLimits;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormSolutionLimits.btnapplyClick(Sender: TObject);
var
  bOk : Boolean;
  r : Double;
begin
  bOk:=True;
  if (not TryStrToFloat(edtminuds1.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtminuds1.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtmaxuds1.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtmaxuds1.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtminuds2.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtminuds2.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtmaxuds2.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtmaxuds2.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtminuds3.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtminuds3.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtmaxuds3.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtmaxuds3.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtminuds4.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtminuds4.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(edtmaxuds4.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtmaxuds4.Text+' is incorrect value');
  end;
  if (bOk) then
  begin
     // Присваивание Solution Limits по требованию.
     Form1.sollimuds1min:=StrToFloat(edtminuds1.Text);
     Form1.sollimuds1max:=StrToFloat(edtmaxuds1.Text);
     Form1.sollimuds2min:=StrToFloat(edtminuds2.Text);
     Form1.sollimuds2max:=StrToFloat(edtmaxuds2.Text);
     Form1.sollimuds3min:=StrToFloat(edtminuds3.Text);
     Form1.sollimuds3max:=StrToFloat(edtmaxuds3.Text);
     Form1.sollimuds4min:=StrToFloat(edtminuds4.Text);
     Form1.sollimuds4max:=StrToFloat(edtmaxuds4.Text);
     Close;
  end;
end;

end.
