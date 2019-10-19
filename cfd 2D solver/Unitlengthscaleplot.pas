unit Unitlengthscaleplot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormlengthscaleplot = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtlengthscalex: TEdit;
    edtlengthscaley: TEdit;
    btnapplyandcontinue: TButton;
    procedure btnapplyandcontinueClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Formlengthscaleplot: TFormlengthscaleplot;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormlengthscaleplot.btnapplyandcontinueClick(Sender: TObject);
var
   bOk : Boolean;
   r : Double;
begin
   bOk:=true;

   if (not TryStrToFloat(edtlengthscalex.Text,r)) then
   begin
      bOk:=false;
      ShowMessage('length scale for x is incorrect');
   end;

   if (not TryStrToFloat(edtlengthscaley.Text,r)) then
   begin
      bOk:=false;
      ShowMessage('length scale for y is incorrect');
   end;

   if (bOk) then
   begin
      // считывание масштабов длины которые будут применены в программе Tecplot360.
      Form1.lengthscaleplot.xscale:=StrToFloat(edtlengthscalex.Text);
      Form1.lengthscaleplot.yscale:=StrToFloat(edtlengthscaley.Text);
      // автоматическое закрытие формы и переход к следующей форме.
      Close;
   end;
end;

end.
