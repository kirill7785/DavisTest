unit myGeneralSolver;
// информация о решателе и выбор нестационарного солвера.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TGeneral = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    Panel3: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Bapply: TButton;
    Panel4: TPanel;
    Label4: TLabel;
    Panel5: TPanel;
    Label5: TLabel;
    procedure BapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  General: TGeneral;

implementation
uses
   MainUnit;

{$R *.dfm}

// по нажатию на эту кнопку надо определить
// настройки решателя
// стационарный или нестационарный
// выбор схемы аппроксимации конвективного члена
procedure TGeneral.BapplyClick(Sender: TObject);
var
   i : Integer; // определитель стационарности
begin
   // тип солвера
   // стационарный или нестационарный
   i:=RadioGroup1.ItemIndex;
   case i of
      0 : begin
            Form1.btimedepend:=false;
          end;
      1 : begin
            Form1.btimedepend:=true;
          end;
   end; // case
   Close;
end;

end.

