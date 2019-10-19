unit UnitInterpritatortest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids;

type
  TFormInterpritator = class(TForm)
    strngrdinterpritator: TStringGrid;
    grpanalisingstr: TGroupBox;
    edtanalis: TEdit;
    grpresult: TGroupBox;
    lblresult: TLabel;
    btnapply: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     bInterpretatortest : Boolean;
  end;

var
  FormInterpritator: TFormInterpritator;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormInterpritator.FormCreate(Sender: TObject);
var
   i : Integer;
begin
   for i:=1 to strngrdinterpritator.RowCount-1 do
   begin
      strngrdinterpritator.Cells[0,i]:=IntToStr(i);
   end;
   strngrdinterpritator.Cells[1,0]:='variable';
   strngrdinterpritator.Cells[2,0]:='value';
    bInterpretatortest:=False; // по умолчанию мы не находимся в режиме тестирования нтерпретатора.
end;

procedure TFormInterpritator.btnapplyClick(Sender: TObject);
var
   s : string;
   inum : Integer;
   i : Integer;
   bOk : Boolean;
begin
   inum:=0;
   for i:=1 to strngrdinterpritator.RowCount-1 do
   begin
      if ((Length(strngrdinterpritator.Cells[1,i])>0) and (Length(strngrdinterpritator.Cells[2,i])>0)) then
      begin
         inc(inum);
      end
      else
      begin
         Break;
      end;
   end;
   SetLength(Form1.parametric,inum);
   Form1.ivar:=inum;
   for i:=0 to inum-1 do
   begin
      Form1.parametric[i].svar:=Trim(strngrdinterpritator.Cells[1,i+1]);
      Form1.parametric[i].sval:=Trim(strngrdinterpritator.Cells[2,i+1]);
   end;
   s:=edtanalis.Text; // анализируемая строка.
   bOk:=True;
   bInterpretatortest:=True;
   // мы находимся в режиме тестирования интерпретатора.
   lblresult.Caption:=FloatToStr(Form1.my_real_convert(s,bOk));
   bInterpretatortest:=False;
   // Мы вышли из режима тестирования интерпретатора.
end;

end.
