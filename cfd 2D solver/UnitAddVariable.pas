unit UnitAddVariable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Unitdeclar;

type
  TAddVariableForm = class(TForm)
    lblname: TLabel;
    edtvalue: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    btnsetvalue: TButton;
    procedure btnsetvalueClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    bcanclose : Boolean;
  end;

var
  AddVariableForm: TAddVariableForm;

implementation

{$R *.dfm}

procedure TAddVariableForm.btnsetvalueClick(Sender: TObject);
var
   code : Integer;
   c : Float;
   r : Double;
   bOk : Boolean;
begin
   bOk:=true;

   if (not TryStrToFloat(edtvalue.Text,r)) then
   begin
      bOk:=false; 
   end;

   if (bOk) then
   begin
      // обязательная проверка на допустимость значения переменной :
      val(edtvalue.Text,c,code);

   if (code=0) then
   begin
      // при закрытии формы значение переменной задаётся при возврате
      // в вызывающий фрагмент кода.
      bcanclose:=True;
      Close;
   end
   else
   begin
      Application.MessageBox('Diagnos: Incorrect variable value.','Error!',MB_OK);
      if (FormatSettings.DecimalSeparator='.') then
      begin
         edtvalue.Text:='0.0';
      end;
      if (FormatSettings.DecimalSeparator=',') then
      begin
         edtvalue.Text:='0,0';
      end;
   end;
   end
   else
   begin
      ShowMessage('Incorrect variable value');
   end;
end;

procedure TAddVariableForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   CanClose:=bcanclose;
end;

end.
