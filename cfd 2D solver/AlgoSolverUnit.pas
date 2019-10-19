unit AlgoSolverUnit;
// выбор алгоритма солвера

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TAlgoSolver = class(TForm)
    Panel1: TPanel;
    tbc1: TTabControl;
    Bapply: TButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    RadioGroup3: TRadioGroup;
    btncghelp: TButton;
    grpuds: TGroupBox;
    lbluds: TLabel;
    cbbuds: TComboBox;
    rguds: TRadioGroup;
    procedure BapplyClick(Sender: TObject);
    procedure tbc1Change(Sender: TObject);

    procedure RadioGroup1Click(Sender: TObject);
    procedure btncghelpClick(Sender: TObject);
    procedure cbbudsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AlgoSolver: TAlgoSolver;

implementation
uses
    MainUnit, GridGenUnit, Unithelpcg; // использует главный модуль
{$R *.dfm}

//  по нажатию на эту кнопку надо
//  передать информацию о выбранном солвере в главную форму
procedure TAlgoSolver.BapplyClick(Sender: TObject);
begin
   case tbc1.TabIndex of
     0 : // теплопроводность
       begin
          // запоминаем выбранный алгоритм солвера
          Form1.itypesolver.itemperature:=RadioGroup1.ItemIndex+1;
       end;
     1 : // компоненты скорости
       begin
          // запоминаем выбранный алгоритм солвера
          Form1.itypesolver.ivelocity:=RadioGroup2.ItemIndex+1;
       end;
     2 : // попрака давления
       begin
           Form1.itypesolver.ipamendment:=RadioGroup3.ItemIndex+1;
       end;
     3 : // User-Define Scalar
       begin
          case cbbuds.ItemIndex of
            0 : begin
                    Form1.itypesolver.iuds1:=rguds.ItemIndex+1;
                end;
            1 : begin
                   Form1.itypesolver.iuds2:=rguds.ItemIndex+1;
                end;
            2 : begin
                   Form1.itypesolver.iuds3:=rguds.ItemIndex+1;
                end;
            3 : begin
                   Form1.itypesolver.iuds4:=rguds.ItemIndex+1;
                end;
          end;
       end;
   end;

end; // выбор алгоритма солвера

// при изменении вкладки нужно
// показать нужную форму
procedure TAlgoSolver.tbc1Change(Sender: TObject);
begin
   // делаем всё невидимым
   RadioGroup1.Visible:=false;
   RadioGroup2.Visible:=false;
   RadioGroup3.Visible:=false;
   grpuds.Visible:=False;

   // делаем нужную форму видимой
   case tbc1.TabIndex of
     0 : begin
            RadioGroup1.Visible:=true;
            btncghelp.Visible:=False;
         end;
     1 : begin
            RadioGroup2.Visible:=true;
            btncghelp.Visible:=False;
         end;
     2 : begin
            RadioGroup3.Visible:=true;
            btncghelp.Visible:=True;
         end;
     3 : begin
            // User-Defined Scalar
            grpuds.Visible:=True;
            btncghelp.Visible:=False;
         end;
   end;
end;



procedure TAlgoSolver.RadioGroup1Click(Sender: TObject);
   var
    i : Integer;
    bonlySeidel : Boolean; // можно использовать только метод Зейделя.
begin
    bonlySeidel:=False;
   // Смена солвера для теплопередачи.
   for i:=1 to GridGenForm.inumboundary do
   begin
       if (GridGenForm.edgelist[i].temperatureclan=3) then
       begin
          // Найдена выходная граница потока и на ней особое трёхточечное граничное условие.
          // Поскольку трёхточечное условие на границе нельзя записать в матрицу
          //  (из за ограничения на пятидиагональность матрицы) то прямые методы здесь непригодны.
          // Непригоден и метод Сопряжённых градиентов, ему придётся постоянно переформировывть правую часть на каждой итерации.
          // В общем остаётся только метод Зейделя, где эта возможность реализована.
          bonlySeidel:=True;
       end;
   end;
   if (bonlySeidel) then
   begin
     ShowMessage('Трёхточечное условие на границе для температуры : равенство нулю второй производной, делает возможным использование только метода Зейделя без вариантов.');
     RadioGroup1.ItemIndex:=0; // Только солвер Зейделя.
   end;
end;

procedure TAlgoSolver.btncghelpClick(Sender: TObject);
begin
   FormCGhelp.ShowModal;
end;

procedure TAlgoSolver.cbbudsChange(Sender: TObject);
begin
   case cbbuds.ItemIndex of
     0 : begin
            rguds.ItemIndex:=Form1.itypesolver.iuds1-1;
         end;
     1 : begin
            rguds.ItemIndex:=Form1.itypesolver.iuds2-1;
         end;
     2 : begin
            rguds.ItemIndex:=Form1.itypesolver.iuds3-1;
         end;
     3 : begin
            rguds.ItemIndex:=Form1.itypesolver.iuds4-1;
         end;
   end;
end;

end.
