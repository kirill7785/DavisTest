unit PatchUnit;
// дополнительная инициализация, например, для
// VOF метода.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TPatchForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Llen: TLabel;
    Lhight: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    BrectangleCreate: TButton;
    Panel3: TPanel;
    Label4: TLabel;
    BcircleCreate: TButton;
    Label5: TLabel;
    procedure BrectangleCreateClick(Sender: TObject);
    procedure BcircleCreateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PatchForm: TPatchForm;

implementation
uses
      RectangleDomenUnit, CircleDomenUnit, MainUnit;

{$R *.dfm}

// прямоугольная инициализация
procedure TPatchForm.BrectangleCreateClick(Sender: TObject);
var
   bcall : Boolean;
begin
  bcall:=True; // вызывать ли метод инициализации.
  RectangleDomenForm.CBSelectFunction.Clear;
  case Form1.imaxUDM of
     0 : begin
            // нет User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('VOF',Sender);
               // дельта легирование в VOF методе ненужно.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end
             else
            begin
               bcall:=False;
            end;
         end;
     1 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('VOF',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               // дельта легирование в VOF методе ненужно.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end
             else
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               // в случае одной udm1 нам может потребоваться дельта
               // легирование так как мы можем моделировать ПТШ с дельта слоем.
               RectangleDomenForm.chkdeltay.Visible:=True;
            end;
         end;
     2 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('VOF',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM2',Sender);
               // если udm больше еденицы то возможность сделать дельта слой отключена.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end
             else
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM2',Sender);
               // если udm больше еденицы то возможность сделать дельта слой отключена.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end;
         end;
     3 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('VOF',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM2',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM3',Sender);
               // если udm больше еденицы то возможность сделать дельта слой отключена.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end
             else
            begin
               RectangleDomenForm.CBSelectFunction.AddItem('UDM1',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM2',Sender);
               RectangleDomenForm.CBSelectFunction.AddItem('UDM3',Sender);
               // если udm больше еденицы то возможность сделать дельта слой отключена.
               RectangleDomenForm.chkdeltay.Checked:=False;
               RectangleDomenForm.chkdeltay.Visible:=False;
            end;
         end;
  end;
  if (bcall) then
  begin
     RectangleDomenForm.ShowModal;
  end;
end;

// круглая инициализация
procedure TPatchForm.BcircleCreateClick(Sender: TObject);
var
   bcall : Boolean;
begin
   bcall:=True; // вызывать ли метод инициализации.
  CircleDomenForm.cbbCBSelectFunction.Clear;
  case Form1.imaxUDM of
     0 : begin
            // нет User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('VOF',Sender);
            end
             else
            begin
               bcall:=False;
            end;
         end;
     1 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('VOF',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
            end
             else
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
            end;
         end;
     2 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('VOF',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM2',Sender);
            end
             else
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM2',Sender);
            end;
         end;
     3 : begin
            // один User-Defined Memory !!!
            if (Form1.imodelEquation=5) then
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('VOF',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM2',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM3',Sender);
            end
             else
            begin
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM1',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM2',Sender);
               CircleDomenForm.cbbCBSelectFunction.AddItem('UDM3',Sender);
            end;
         end;
  end;
  if (bcall) then
  begin
     CircleDomenForm.ShowModal;
  end;
end;

end.
