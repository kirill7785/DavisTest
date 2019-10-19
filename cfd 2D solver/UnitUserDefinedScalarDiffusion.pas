unit UnitUserDefinedScalarDiffusion;
// Задаёт коэффициенты для UDS.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormUDSDiffusivity = class(TForm)
    lstuds: TListBox;
    lbl1: TLabel;
    lbl2: TLabel;
    edtdiffusivity: TEdit;
    btnApply: TButton;
    lblBoussinesq: TLabel;
    edtBoussinesq: TEdit;
    procedure btnApplyClick(Sender: TObject);
    procedure lstudsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormUDSDiffusivity: TFormUDSDiffusivity;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormUDSDiffusivity.btnApplyClick(Sender: TObject);
var
    bOk : Boolean;
    r : Double;
begin
  bOk:=True;
  if (Form1.bBussinesk) then
  begin
     if (not TryStrToFloat(edtBoussinesq.Text,r)) then
     begin
        bOk:=False;
        ShowMessage(edtBoussinesq.Text+' is incorrect value');
     end;
  end;
  if (bOk) then
  begin
     // Задание постоянного коэффициента диффузии
     case lstuds.ItemIndex of
      0 : begin
             Form1.gamma1str:=edtdiffusivity.Text;
             if (Form1.bBussinesk) then
             begin
                Form1.dbetaUDS1:=StrToFloat(edtBoussinesq.Text);
             end;
          end;
      1 : begin
             Form1.gamma2str:=edtdiffusivity.Text;
             if (Form1.bBussinesk) then
             begin
                Form1.dbetaUDS2:=StrToFloat(edtBoussinesq.Text);
             end;
          end;
      2 : begin
             Form1.gamma3str:=edtdiffusivity.Text;
             if (Form1.bBussinesk) then
             begin
                Form1.dbetaUDS3:=StrToFloat(edtBoussinesq.Text);
             end;
          end;
      3 : begin
             Form1.gamma4str:=edtdiffusivity.Text;
             if (Form1.bBussinesk) then
             begin
                Form1.dbetaUDS4:=StrToFloat(edtBoussinesq.Text);
             end;
          end;
     end;
  end;
end;

procedure TFormUDSDiffusivity.lstudsClick(Sender: TObject);
var
    bOk : Boolean;
    r : Double;
begin
  bOk:=True;
  if (Form1.bBussinesk) then
  begin
     if (not TryStrToFloat(edtBoussinesq.Text,r)) then
     begin
        bOk:=False;
        ShowMessage(edtBoussinesq.Text+' is incorrect value');
     end;
  end;
  if (bOk) then
  begin
     // смена UDS
     case lstuds.ItemIndex of
      0 : begin
             edtdiffusivity.Text:=Form1.gamma1str;
             if (Form1.bBussinesk) then
             begin
                edtBoussinesq.Text:=FloatToStr(Form1.dbetaUDS1);
             end;
          end;
      1 : begin
             edtdiffusivity.Text:=Form1.gamma2str;
             if (Form1.bBussinesk) then
             begin
                edtBoussinesq.Text:=FloatToStr(Form1.dbetaUDS2);
             end;
          end;
      2 : begin
             edtdiffusivity.Text:=Form1.gamma3str;
             if (Form1.bBussinesk) then
             begin
                edtBoussinesq.Text:=FloatToStr(Form1.dbetaUDS3);
             end;
          end;
      3 : begin
             edtdiffusivity.Text:=Form1.gamma4str;
             if (Form1.bBussinesk) then
             begin
                edtBoussinesq.Text:=FloatToStr(Form1.dbetaUDS4);
             end;
          end;
     end;
  end;
end;

end.
