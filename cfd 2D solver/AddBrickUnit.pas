unit AddBrickUnit;
// Добавляет элемент в геометрию :
// Пустой Hollow Блок

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAddbrickForm = class(TForm)
    GroupBox2: TGroupBox;
    AddButton: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LnameHollowblock: TLabel;
    Labelnumberhb: TLabel;
    ExS: TEdit;
    EyS: TEdit;
    ExL: TEdit;
    EyL: TEdit;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    CheckBoxBL: TCheckBox;
    procedure AddButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddbrickForm: TAddbrickForm;

implementation

uses
     GridGenUnit;

{$R *.dfm}

procedure TAddbrickForm.AddButtonClick(Sender: TObject);
var
   bOk : Boolean;
   r : Double;
begin
  bOk:=True;
  if (not TryStrToFloat(ExS.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(ExS.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EyS.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EyS.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(ExL.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(ExL.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EyL.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EyL.Text+' is incorrect value.');
  end;
  if (bOk) then
  begin
     inc(GridGenForm.maxbrickelem);
     SetLength(GridGenForm.bricklist,GridGenForm.maxbrickelem); // увеличение размера массива
     GridGenForm.bricklist[GridGenForm.maxbrickelem -1].xS:=StrToFloat(ExS.Text);
     GridGenForm.bricklist[GridGenForm.maxbrickelem -1].yS:=StrToFloat(EyS.Text);
     GridGenForm.bricklist[GridGenForm.maxbrickelem -1].xL:=StrToFloat(ExL.Text);
     GridGenForm.bricklist[GridGenForm.maxbrickelem -1].yL:=StrToFloat(EyL.Text);
     // имя блока
     GridGenForm.CheckListBox1.Items.Add('block'+IntToStr(GridGenForm.maxbrickelem -1));
     // наличие пограничного слоя
     GridGenForm.bricklist[GridGenForm.maxbrickelem -1].bbl:=CheckBoxBL.Checked;
     Close; // закрывает диалог
   end;
end;

end.
