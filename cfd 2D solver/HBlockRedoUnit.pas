unit HBlockRedoUnit;
// редактирование свойств выделенного hollow блока

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  THBlockRedoForm = class(TForm)
    GroupBox2: TGroupBox;
    BApply: TButton;
    GroupBox1: TGroupBox;
    Lxs: TLabel;
    LyS: TLabel;
    LxL: TLabel;
    LyL: TLabel;
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit2: TEdit;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    procedure BApplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HBlockRedoForm: THBlockRedoForm;

implementation
uses
      GridGenUnit, MainUnit;

{$R *.dfm}

procedure THBlockRedoForm.BApplyClick(Sender: TObject);
var
   i : Integer;
   bOk : Boolean;
   r : Double;
begin
   bOk:=True;

   if (not TryStrToFloat(Edit1.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Edit1.Text+' is incorrect value.');
   end;
    if (not TryStrToFloat(Edit2.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Edit2.Text+' is incorrect value.');
   end;
    if (not TryStrToFloat(Edit3.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Edit3.Text+' is incorrect value.');
   end;
    if (not TryStrToFloat(Edit4.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Edit4.Text+' is incorrect value.');
   end;

   if (bOk) then
   begin

      // редактирование существующего блока
      // поиск выделенного блока и заполнение его полей
      for i:=0 to GridGenForm.CheckListBox1.Items.Count-1 do
      begin
         if (GridGenForm.CheckListBox1.Checked[i]) then
         begin
            if (i=0) then
            begin
               // кабинет

               Form1.dLx:=StrToFloat(Edit3.Text); // ширина и высота
               Form1.dLy:=StrToFloat(Edit4.Text);
               GridGenForm.bricklist[i].xL:=StrToFloat(Edit3.Text);
               GridGenForm.bricklist[i].yL:=StrToFloat(Edit4.Text);
            end
             else
            begin
               // обычный блок

               // положение и геометрические размеры
               GridGenForm.bricklist[i].xS:=StrToFloat(Edit1.Text);
               GridGenForm.bricklist[i].yS:=StrToFloat(Edit2.Text);
               GridGenForm.bricklist[i].xL:=StrToFloat(Edit3.Text);
               GridGenForm.bricklist[i].yL:=StrToFloat(Edit4.Text);
               // пограничный слой
               GridGenForm.bricklist[i].bbl:=CheckBox1.Checked;
            end;
         end;
      end;
      Close;
   end;
end;

end.
