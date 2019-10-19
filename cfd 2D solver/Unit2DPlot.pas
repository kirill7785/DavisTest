unit Unit2DPlot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm2DPlot = class(TForm)
    Bapply: TButton;
    GroupBox1: TGroupBox;
    ComboBoxCategori: TComboBox;
    GroupBoxFunction: TGroupBox;
    ComboBoxFunction: TComboBox;
    procedure BapplyClick(Sender: TObject);
    procedure ComboBoxCategoriChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2DPlot: TForm2DPlot;

implementation
uses
    MainUnit; // использует главный модуль

{$R *.dfm}

// формирует матицу визуализации D
// и передаёт её модулю визуализации.
procedure TForm2DPlot.BapplyClick(Sender: TObject);
var
   ind : Integer; // содержит номер визуализируемой функции
begin
   if (ComboBoxCategori.ItemIndex=0) then
   begin
      ind:=ComboBoxFunction.ItemIndex;
      case ind of
         0 : // температура
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         1 : // горизонтальная скорость
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         2 : // вертикальная скорость
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         3 : // вихрь
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         4 : // функция тока
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         5 : // поправка давления
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         6 : // Давление
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         7 : // источниковый член в уравнении теплопередачи.
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         8 : // Модуль скорости
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         9 : // Градиент температуры по х
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         10 : // Градиент температуры по y
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;
         11 :  // Модуль градиента температуры
             begin
                Form1.DisplayUniversalInternal(ind+1,false);
             end;

        end; // case
   end;
   if (ComboBoxCategori.ItemIndex=1) then
   begin
      // Volume of Fluid
      Form1.DisplayUniversalInternal(13,false);
   end;
   if (ComboBoxCategori.ItemIndex=2) then
   begin
       // User Defined Scalar
       ind:=ComboBoxFunction.ItemIndex;
      case ind of
         0 : // UDS1
             begin
                Form1.DisplayUniversalInternal(ind+13,false);
             end;
         1 : // UDS2
             begin
                Form1.DisplayUniversalInternal(ind+13,false);
             end;
         2 : // UDS3
             begin
                Form1.DisplayUniversalInternal(ind+13,false);
             end;
         3 : // UDS4
             begin
                Form1.DisplayUniversalInternal(ind+13,false);
             end;
         end;
   end;
end;

procedure TForm2DPlot.ComboBoxCategoriChange(Sender: TObject);
begin
   case ComboBoxCategori.ItemIndex of
      0 : begin
              // Standart Flow.
             ComboBoxFunction.Clear;
             ComboBoxFunction.Items.Add('temperature');
             ComboBoxFunction.Items.Add('horisontal velocity');
             ComboBoxFunction.Items.Add('vertical velocity');
             ComboBoxFunction.Items.Add('curl');
             ComboBoxFunction.Items.Add('stream function');
             ComboBoxFunction.Items.Add('pressure amendment');
             ComboBoxFunction.Items.Add('pressure');
             ComboBoxFunction.Items.Add('Sc term temperature equation');
             ComboBoxFunction.Items.Add('velocity magnitude');
             ComboBoxFunction.Items.Add('grad x temperature');
             ComboBoxFunction.Items.Add('grad y temperature');
             ComboBoxFunction.Items.Add('magnitude grad temperature');
          end;
      1 : begin
             // Volume Of Fluid
             ComboBoxFunction.Clear;
             ComboBoxFunction.Items.Add('VOF');
          end;
       2 : begin
             // User Defined Scalar
             ComboBoxFunction.Clear;
             ComboBoxFunction.Items.Add('UDS1');
             ComboBoxFunction.Items.Add('UDS2');
             ComboBoxFunction.Items.Add('UDS3');
             ComboBoxFunction.Items.Add('UDS4');
          end;
   end;
end;

end.
