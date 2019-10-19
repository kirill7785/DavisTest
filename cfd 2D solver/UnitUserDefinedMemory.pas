unit UnitUserDefinedMemory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormUDM = class(TForm)
    lbludm: TLabel;
    cbbudm: TComboBox;
    procedure cbbudmChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormUDM: TFormUDM;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormUDM.cbbudmChange(Sender: TObject);
var
    i : Integer; // счётчик цикла for.
begin
   // смена количества UDM функций.
   Form1.imaxUDM:=cbbudm.ItemIndex;
   case Form1.imaxUDM of
      0 : begin
             // Уничтожаем память.
             SetLength(Form1.UDM1,0);
             SetLength(Form1.UDM2,0);
             SetLength(Form1.UDM3,0);
             Application.MessageBox('UDM1, UDM2 и UDM3 память освобождена и их использовать нельзя !!!','user-defined memory',MB_OK);
          end;
      1 : begin
             // Выделяем память
             SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
             // инициализация.
             for i:=0 to Form1.inx*Form1.iny do
             begin
                 Form1.UDM1[i]:=0.0;
             end;
             // уничтожаем память.
             SetLength(Form1.UDM2,0);
             SetLength(Form1.UDM3,0);
             Application.MessageBox('UDM1 память выделена и она инициализированы нулём. UDM2  и UDM3 - использовать нельзя память из под них освобождена.','user-defined memory',MB_OK);
          end;
      2 : begin
             // Выделяем память
             SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
             SetLength(Form1.UDM2,Form1.inx*Form1.iny+1);
             // инициализация.
             for i:=0 to Form1.inx*Form1.iny do
             begin
                 Form1.UDM1[i]:=0.0;
                 Form1.UDM2[i]:=0.0;
             end;
             // уничтожаем память.
             SetLength(Form1.UDM3,0);
             Application.MessageBox('UDM1 и UDM2  память выделена и они инициализированы нулём. UDM3 - использовать нельзя она уничтожена.','user-defined memory',MB_OK);
          end;
      3 : begin
             // Выделяем память
             SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
             SetLength(Form1.UDM2,Form1.inx*Form1.iny+1);
             SetLength(Form1.UDM3,Form1.inx*Form1.iny+1);
             // инициализация.
             for i:=0 to Form1.inx*Form1.iny do
             begin
                 Form1.UDM1[i]:=0.0;
                 Form1.UDM2[i]:=0.0;
                 Form1.UDM3[i]:=0.0;
             end;
             Application.MessageBox('UDM1, UDM2 и UDM3 память выделена и они инициализированы нулём','user-defined memory',MB_OK);
          end;
   end;
end;

end.
