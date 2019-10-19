unit BoundaryConditionUnit;
// модуль где задаются граничные условия

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Unitdeclar;

type
  TBoundaryConditionForm = class(TForm)
    Panel2: TPanel;
    PselectBoundary: TPanel;
    LselectBoundary: TLabel;
    LselectBoundarycontin: TLabel;
    EdgeComboBox: TComboBox;
    Bapply: TButton;
    TabControl1: TTabControl;
    PanelTemperature: TPanel;
    RadioGroupTemperature: TRadioGroup;
    GroupBoxvalueTemperature: TGroupBox;
    Etemperature: TEdit;
    GroupBoxVelocity: TGroupBox;
    RadioGroupVelocity: TRadioGroup;
    PanelsetVelocity: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Exvel: TEdit;
    Eyvel: TEdit;
    GroupBoxStreamFunction: TGroupBox;
    ComboBox1: TComboBox;
    Editsfvalue: TEdit;
    LSFValue: TLabel;
    Label4: TLabel;
    pnlvof: TPanel;
    rgvof: TRadioGroup;
    pnlvofvalue: TPanel;
    lblvof: TLabel;
    cbbvof: TComboBox;
    pnluds: TPanel;
    rguds: TRadioGroup;
    lbludsind: TLabel;
    cbbudsindex: TComboBox;
    grpvalue: TGroupBox;
    edtvaluds: TEdit;
    LabelUnitTemperature: TLabel;
    procedure BapplyClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure RadioGroupTemperatureClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure rgvofClick(Sender: TObject);
    procedure cbbudsindexChange(Sender: TObject);
    procedure rgudsClick(Sender: TObject);
    procedure EdgeComboBoxChange(Sender: TObject);
    procedure RadioGroupVelocityClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BoundaryConditionForm: TBoundaryConditionForm;

implementation

uses
    MainUnit, GridGenUnit; // использует главный модуль

{$R *.dfm}

// задаёт граничное условие на выбранном ребре
procedure TBoundaryConditionForm.BapplyClick(Sender: TObject);
var
   ind,i1 : Integer; // какая граница выбрана
   // r : Float; // значение на границе.
   bOk : Boolean; // успешность работы интерпритатора.

   // проверка корректности ввода:
   bOk2 : Boolean;
   r : Double;

begin
   // код задания граничного условия
   // порядок нумерации границ
   // левая верхняя самая первая, а дальше
   // против часовой стрелки.
   ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы
   if (ind>0) then
   begin
      case TabControl1.TabIndex of
      0 : begin
             // Temperature - температура
             bOk2:=True;

             if (not TryStrToFloat(Etemperature.Text,r)) then
             begin
                bOk2:=False;
             end;

             if (bOk2) then
             begin
                GridGenForm.edgelist[ind].temperaturecondition:=StrToFloat(Etemperature.Text); // температура
             end
             else
             begin
                ShowMessage('Temperature value is incorrect.');
             end;
             // определение типа граничного условия
             case RadioGroupTemperature.ItemIndex of
             0 : begin
                    // первого рода
                    // Задано значение температуры на границе
                    GridGenForm.edgelist[ind].temperatureclan:=1;
                    //GridGenForm.edgelist[ind].bsimmetry:=false;
                    //GridGenForm.edgelist[ind].boutflow:=false;
                    //GridGenForm.edgelist[ind].bpressure:=false;
                 end;
             1 : begin
                    // второго рода
                    // Задан тепловой поток на границе
                    GridGenForm.edgelist[ind].temperatureclan:=2;
                    //GridGenForm.edgelist[ind].bsimmetry:=false;
                    //GridGenForm.edgelist[ind].boutflow:=false;
                    //GridGenForm.edgelist[ind].bpressure:=false;
                 end;
              2 : begin
                     // выходная граница
                     // ставятся мягкие условия :
                     // T[i]=2T[i-1]-T[i-2];
                     GridGenForm.edgelist[ind].temperatureclan:=3;
                     //GridGenForm.edgelist[ind].bsimmetry:=false;
                     //GridGenForm.edgelist[ind].boutflow:=false;
                     //GridGenForm.edgelist[ind].bpressure:=true;
                  end;
              3 : begin
                     // граница симметрии
                     // внешняя нормаль равняется нулю
                     // T[i]=T[i-1]
                     GridGenForm.edgelist[ind].temperatureclan:=4;
                     //GridGenForm.edgelist[ind].bsimmetry:=true;
                     //GridGenForm.edgelist[ind].boutflow:=false;
                     //GridGenForm.edgelist[ind].bpressure:=false;
                  end;
             end;  // case
          end;
      1 : begin
             // Flow - скорость и давление
             case RadioGroupVelocity.ItemIndex of
             0 : begin
                    bOk2:=True;

                    if (not TryStrToFloat(Exvel.Text,r)) then
                    begin
                       bOk2:=False;
                       ShowMessage('x-velocity value is incorrect.');
                    end;

                    if (not TryStrToFloat(Eyvel.Text,r)) then
                    begin
                       bOk2:=False;
                       ShowMessage('y-velocity value is incorrect.');
                    end;

                    if (bOk2) then
                    begin
                       // заданы компоненты скорости
                       GridGenForm.edgelist[ind].Vx:=StrToFloat(Exvel.Text); // горизонтальная скорость
                       GridGenForm.edgelist[ind].Vy:=StrToFloat(Eyvel.Text); // вртикальная скорость
                       GridGenForm.edgelist[ind].bsimmetry:=false;
                       GridGenForm.edgelist[ind].bpressure:=false;
                       GridGenForm.edgelist[ind].boutflow:=false;
                       GridGenForm.edgelist[ind].bMarangoni:=false;
                    end;
                 end;
             1 : begin
                    // выходная граница потока
                    GridGenForm.edgelist[ind].bsimmetry:=false;
                    GridGenForm.edgelist[ind].bpressure:=false;
                    GridGenForm.edgelist[ind].boutflow:=true;
                    GridGenForm.edgelist[ind].bMarangoni:=false;
                    GridGenForm.edgelist[ind].Vx:=0.0;
                    GridGenForm.edgelist[ind].Vy:=0.0;
                 end;
             2 : begin
                    // граница симмметрии
                    GridGenForm.edgelist[ind].bsimmetry:=true;
                    GridGenForm.edgelist[ind].bpressure:=false;
                    GridGenForm.edgelist[ind].boutflow:=false;
                    GridGenForm.edgelist[ind].bMarangoni:=false;
                 end;
             3 : begin
                    // задано давление на границе
                    GridGenForm.edgelist[ind].bsimmetry:=false;
                    GridGenForm.edgelist[ind].bpressure:=true;
                    GridGenForm.edgelist[ind].boutflow:=false;
                    bOk2:=True;

                    if (not TryStrToFloat(Exvel.Text,r)) then
                    begin
                       bOk2:=False;
                    end;

                    if (bOk2) then
                    begin
                       GridGenForm.edgelist[ind].rpressure:=StrToFloat(Exvel.Text); // значение давления на границе
                    end
                     else
                    begin
                        ShowMessage('Pressure value is incorrect.');
                    end;
                    GridGenForm.edgelist[ind].bMarangoni:=false;
                 end;
             4 : begin
                    // задан Marangoni Stress
                    // Компоненты скорости пока неизвестны :
                    GridGenForm.edgelist[ind].Vx:=0.0; // горизонтальная скорость
                    GridGenForm.edgelist[ind].Vy:=0.0; // вртикальная скорость
                    // Они станут известны как только будет известен градиент температуры.
                    GridGenForm.edgelist[ind].bsimmetry:=false;
                    GridGenForm.edgelist[ind].bpressure:=false;
                    GridGenForm.edgelist[ind].boutflow:=false;
                    GridGenForm.edgelist[ind].bMarangoni:=true; // Marangoni Stress
                    bOk2:=True;

                    if (not TryStrToFloat(Exvel.Text,r)) then
                    begin
                       bOk2:=False;
                    end;

                     if (bOk2) then
                     begin
                        GridGenForm.edgelist[ind].surfaceTensionGradient:=StrToFloat(Exvel.Text);
                     end
                      else
                     begin
                        ShowMessage('Gradient Surface Tension value is incorrect.');
                     end;
                 end;
             end; // case

             // краевые условия для функции тока
             case ComboBox1.ItemIndex of
              0 : // const
                 begin
                     bOk2:=True;

                    if (not TryStrToFloat(Editsfvalue.Text,r)) then
                    begin
                       bOk2:=False;
                       ShowMessage('stream function value is incorrect.');
                    end;

                    if (bOk2) then
                    begin
                       GridGenForm.edgelist[ind].chSFval:='c';
                       GridGenForm.edgelist[ind].rSFval:=StrToFloat(Editsfvalue.Text);
                    end;
                 end;
              1 : // x
                 begin
                    GridGenForm.edgelist[ind].chSFval:='x';
                 end;
              2 : // y
                 begin
                    GridGenForm.edgelist[ind].chSFval:='y';
                 end;
              3 : // neiman
                 begin
                    GridGenForm.edgelist[ind].chSFval:='n';
                    GridGenForm.edgelist[ind].rSFval:=StrToFloat(Editsfvalue.Text);
                 end;
              end; // case

          end;
      3 : begin
             // User-Define Scalar
             case rguds.ItemIndex of
             0 : begin
                    // Проверка на допустимость переменных:
                    // Дело в том что может появится новая переменная которую надо обработать в parametric trials.

                    Form1.ivar:=15+Form1.ivar_trial;
                    SetLength(Form1.parametric,Form1.ivar);
                    Form1.parametric[0].svar:='$x';
                    Form1.parametric[1].svar:='$y';
                    Form1.parametric[2].svar:='$d'; // расстояние от граничного узла до ближайшего внутреннего
                    Form1.parametric[3].svar:='$uds1w'; // значение UDS1 на стенке.
                    Form1.parametric[4].svar:='$uds2w'; // значение UDS2 на стенке.
                    Form1.parametric[5].svar:='$uds3w'; // значение UDS3 на стенке.
                    Form1.parametric[6].svar:='$uds4w'; // значение UDS4 на стенке.
                    Form1.parametric[7].svar:='$uds1i'; // значение UDS1 в ближайшем внутреннем узле.
                    Form1.parametric[8].svar:='$uds2i'; // значение UDS2 в ближайшем внутреннем узле.
                    Form1.parametric[9].svar:='$uds3i'; // значение UDS3 в ближайшем внутреннем узле.
                    Form1.parametric[10].svar:='$uds4i'; // значение UDS4 в ближайшем внутреннем узле.
                    Form1.parametric[11].svar:='$uds1ii'; // значение UDS1 во 2  ближайшем внутреннем узле.
                    Form1.parametric[12].svar:='$uds2ii'; // значение UDS2 во 2  ближайшем внутреннем узле.
                    Form1.parametric[13].svar:='$uds3ii'; // значение UDS3 во 2 ближайшем внутреннем узле.
                    Form1.parametric[14].svar:='$uds4ii'; // значение UDS4 во 2 ближайшем внутреннем узле.
                    Form1.parametric[0].sval:='0.5';
                    Form1.parametric[1].sval:='0.5';
                    Form1.parametric[2].sval:='1.0'; // расстояние от граничного узла до ближайшего внутреннего
                    Form1.parametric[3].sval:='0.0'; // значение UDS1 на стенке.
                    Form1.parametric[4].sval:='0.0'; // значение UDS2 на стенке.
                    Form1.parametric[5].sval:='0.0'; // значение UDS3 на стенке.
                    Form1.parametric[6].sval:='0.0'; // значение UDS4 на стенке.
                    Form1.parametric[7].sval:='0.0'; // значение UDS1 в ближайшем внутреннем узле.
                    Form1.parametric[8].sval:='0.0'; // значение UDS2 в ближайшем внутреннем узле.
                    Form1.parametric[9].sval:='0.0'; // значение UDS3 в ближайшем внутреннем узле.
                    Form1.parametric[10].sval:='0.0'; // значение UDS4 в ближайшем внутреннем узле.
                    Form1.parametric[11].sval:='0.0'; // значение UDS1 во 2  ближайшем внутреннем узле.
                    Form1.parametric[12].sval:='0.0'; // значение UDS2 во 2  ближайшем внутреннем узле.
                    Form1.parametric[13].sval:='0.0'; // значение UDS3 во 2 ближайшем внутреннем узле.
                    Form1.parametric[14].sval:='0.0'; // значение UDS4 во 2 ближайшем внутреннем узле.
                    for i1:=1 to Form1.ivar_trial do
                    begin
                       Form1.parametric[14+i1].svar:=Form1.base_value_trial[i1-1].svar;
                       Form1.parametric[14+i1].sval:=Form1.base_value_trial[i1-1].sval;
                    end;
                    bOk:=True;
                    if ((Pos('free',Trim(edtvaluds.Text))=1) and (Length(Trim(edtvaluds.Text))=4)) then
                    begin
                       // специальное условие : граница металла с диэлектриком, причём значение потенциала на металле
                       // не задано.
                       // Единственное условие касательная составляющая напряжённости электрического поля равна нулю.
                       // Порядок обхода границы против часовой стрелки.
                       case  cbbudsindex.ItemIndex of
                        0 : begin
                               GridGenForm.edgelist[ind].uds1clan:=5;
                               GridGenForm.edgelist[ind].uds1condition:='metall_free';
                            end;
                        1 : begin
                               GridGenForm.edgelist[ind].uds2clan:=5;
                               GridGenForm.edgelist[ind].uds2condition:='metall_free';
                            end;
                        2 : begin
                               GridGenForm.edgelist[ind].uds3clan:=5;
                               GridGenForm.edgelist[ind].uds3condition:='metall_free';
                            end;
                        3 : begin
                               GridGenForm.edgelist[ind].uds4clan:=5;
                               GridGenForm.edgelist[ind].uds4condition:='metall_free';
                            end;
                       end;
                    end
                    else
                    begin
                    // r:=;
                    Form1.my_real_convert(edtvaluds.Text,bOk);

                    // Теперь поддерживаются граничные условия в параметризованном пользователем виде.
                    // Дирихле.
                    case  cbbudsindex.ItemIndex of
                     0 : begin
                            GridGenForm.edgelist[ind].uds1clan:=1;
                            GridGenForm.edgelist[ind].uds1condition:=edtvaluds.Text;
                         end;
                     1 : begin
                            GridGenForm.edgelist[ind].uds2clan:=1;
                            GridGenForm.edgelist[ind].uds2condition:=edtvaluds.Text;
                         end;
                     2 : begin
                            GridGenForm.edgelist[ind].uds3clan:=1;
                            GridGenForm.edgelist[ind].uds3condition:=edtvaluds.Text;
                         end;
                     3 : begin
                            GridGenForm.edgelist[ind].uds4clan:=1;
                            GridGenForm.edgelist[ind].uds4condition:=edtvaluds.Text;
                         end;
                    end;
                    end;
                 end;
             1 : begin
                    // Теперь поддерживаются граничные условия в параметризованном пользователем виде.

                    // Нейман.
                    case  cbbudsindex.ItemIndex of
                     0 : begin
                            GridGenForm.edgelist[ind].uds1clan:=2;
                            GridGenForm.edgelist[ind].uds1condition:=edtvaluds.Text;
                         end;
                     1 : begin
                            GridGenForm.edgelist[ind].uds2clan:=2;
                            GridGenForm.edgelist[ind].uds2condition:=edtvaluds.Text;
                         end;
                     2 : begin
                            GridGenForm.edgelist[ind].uds3clan:=2;
                            GridGenForm.edgelist[ind].uds3condition:=edtvaluds.Text;
                         end;
                     3 : begin
                            GridGenForm.edgelist[ind].uds4clan:=2;
                            GridGenForm.edgelist[ind].uds4condition:=edtvaluds.Text;
                         end;
                    end;
                 end;
             2 : begin
                    // Нулевой нормальный полный ток.
                    case  cbbudsindex.ItemIndex of
                     0 : begin
                            GridGenForm.edgelist[ind].uds1clan:=3;
                         end;
                     1 : begin
                            GridGenForm.edgelist[ind].uds2clan:=3;
                         end;
                     2 : begin
                            GridGenForm.edgelist[ind].uds3clan:=3;
                         end;
                     3 : begin
                            GridGenForm.edgelist[ind].uds4clan:=3;
                         end;
                    end;
                 end;
              3 : begin
                    // нулевой нормальный диффузионный ток.
                    case  cbbudsindex.ItemIndex of
                     0 : begin
                            GridGenForm.edgelist[ind].uds1clan:=4;
                         end;
                     1 : begin
                            GridGenForm.edgelist[ind].uds2clan:=4;
                         end;
                     2 : begin
                            GridGenForm.edgelist[ind].uds3clan:=4;
                         end;
                     3 : begin
                            GridGenForm.edgelist[ind].uds4clan:=4;
                         end;
                    end;
                 end;
             end;
          end;
      end;

   end;
end; // задание граничного условия первого рода

(*
// выбрана граница
procedure TBoundaryConditionForm.OnSelect(Sender: TObject);
var
   ind : Integer; // номер выбранной границы

begin
   // определяем номер выбранной границы
   ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы

   // выбрана анализируемая граница
   case TabControl1.TabIndex of
   0 : begin
          if (not (GridGenForm.edgelist[ind].boutflow) and
              not (GridGenForm.edgelist[ind].bpressure) and
              not (GridGenForm.edgelist[ind].bsimmetry) ) then
              begin
                 // условия по температуре
                 if (GridGenForm.edgelist[ind].temperatureclan=2) then
                      RadioGroup1.ItemIndex:=1  // второго рода
                  else RadioGroup1.ItemIndex:=0; // первого рода

                 GroupBox1.Visible:=true; // окошко где задаётся тепловой поток или температура
                 Etemperature.Text:=FloatToStr(GridGenForm.edgelist[ind].temperaturecondition); // температура
              end
               else
              begin
                 GroupBox1.Visible:=false; // окошко для ввода числового значения невидимо

                 if ((GridGenForm.edgelist[ind].boutflow) or
                    (GridGenForm.edgelist[ind].bpressure)) then
                       RadioGroup1.ItemIndex:=2; // выходная граница

                 if (GridGenForm.edgelist[ind].bsimmetry) then
                      RadioGroup1.ItemIndex:=3; // граница симметрии
              end;
       end;
   1 : begin
          // условия по скорости
          Exvel.Text:=FloatToStr(GridGenForm.edgelist[ind].Vx);  // горизонтальная скорость
          Eyvel.Text:=FloatToStr(GridGenForm.edgelist[ind].Vy);  // вертикальная скороть
          // функция тока.
          case GridGenForm.edgelist[ind].chSFval of
              'c' : begin
                       LSFValue.Visible:=true;
                       Editsfvalue.Visible:=True;
                       Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
                    end;
              'x' : begin
                       LSFValue.Visible:=False;
                        Editsfvalue.Visible:=false;
                    end;
              'y' : begin
                       LSFValue.Visible:=False;
                        Editsfvalue.Visible:=false;
                    end;
              'n' : begin
                       LSFValue.Visible:=true;
                       Editsfvalue.Visible:=True;
                       Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
                    end;
          end;
       end;
   end;
end; // данный метод вызывается в случае выбора границы
*)

// смена вкладки
procedure TBoundaryConditionForm.TabControl1Change(Sender: TObject);
begin
   case TabControl1.TabIndex of
   0 : begin
          if ((Form1.imodelEquation = 1) and (Form1.imodelEquation = 4)) then
          begin
             // условия по температуре делаем видимыми
             // а условия по скорости и функции цвета делаем невидимыми.
             PanelTemperature.Visible:=true;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=False;
             pnluds.Visible:=false;
          end
           else if (Form1.imodelEquation = 3) then
          begin
             // Flow
             TabControl1.TabIndex:=1;
          end
           else if (Form1.imodelEquation = 5) then
          begin
             // VOF
             TabControl1.TabIndex:=2;
          end
          else if ((Form1.imodelEquation = 2) and (Form1.imaxUDS>0)) then
          begin
             // UDS
             TabControl1.TabIndex:=3;
          end
           else
          begin
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=false;
             pnluds.Visible:=false;
             Application.MessageBox('создайте user define scalar','error',MB_OK);
          end;
       end;
   1 : begin
          if (Form1.imodelEquation>2) then
          begin
             // Набор решаемых уравнений включает уравнения Навье-Стокса
             // Условия по температуре невидимы, а условия по скорости видимы.
             // вкладка для задания граничных условий для функции цвета также невидима.
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=true;
             pnlvof.Visible:=false;
             pnluds.Visible:=false;
          end
           else if (Form1.imodelEquation=1) then
          begin
             // Температура.
             TabControl1.TabIndex:=0;
          end
          else if ((Form1.imodelEquation=2) and (Form1.imaxUDS>0)) then
          begin
             // UDS
             TabControl1.TabIndex:=3;
          end
           else
           begin
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=false;
             pnluds.Visible:=false;
             Application.MessageBox('создайте user define scalar','error',MB_OK);
          end;
       end;
   2 : begin
          // Вкладка функции цвета.

          if (Form1.imodelEquation=5) then
          begin
              // Вкладка задания граничных условий по температуре невидима,
              // вкладка задания граничных условий по гидродинамиеской составляющей невидима,
              // вкладка задания граничных условий для функции цвета видима.
              PanelTemperature.Visible:=false;
              GroupBoxVelocity.Visible:=false;
              pnlvof.Visible:=true;
              pnluds.Visible:=false;
          end
          else if (Form1.imodelEquation=3) then
          begin
             // Flow
             TabControl1.TabIndex:=1;
          end
           else if ((Form1.imodelEquation=1) or (Form1.imodelEquation=4)) then
          begin
             // теплопередача или гидродинамика и теплопередача.

             // Temperature
             TabControl1.TabIndex:=0;
          end
           else if ((Form1.imodelEquation=2) and (Form1.imaxUDS>0)) then
          begin
             TabControl1.TabIndex:=3; // UDS
          end
           else
          begin
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=false;
             pnluds.Visible:=false;
             Application.MessageBox('создайте user define scalar','error',MB_OK);
          end;
       end;
   3 : begin
          if (Form1.imaxUDS>0) then
          begin
             // User-Defined Scalar
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=false;
             pnluds.Visible:=True;
          end
           else  if (Form1.imodelEquation=3) then
          begin
             // Flow
             TabControl1.TabIndex:=1;
          end
          else  if ((Form1.imodelEquation=1) or (Form1.imodelEquation=4)) then
          begin
             // Temperature
             TabControl1.TabIndex:=0;
          end
           else if (Form1.imodelEquation=5) then
          begin
             // VOF
             TabControl1.TabIndex:=2;
          end
           else
          begin
             PanelTemperature.Visible:=false;
             GroupBoxVelocity.Visible:=false;
             pnlvof.Visible:=false;
             pnluds.Visible:=false;
             Application.MessageBox('создайте user define scalar','error',MB_OK);
          end;
       end;
   end;
   EdgeComboBoxChange(Sender); // инициализация при смене вкладки.
end;


procedure TBoundaryConditionForm.RadioGroupTemperatureClick(Sender: TObject);
begin
   if (RadioGroupTemperature.ItemIndex>=2) then GroupBoxvalueTemperature.Visible:=false
   else GroupBoxvalueTemperature.Visible:=true;
   if (RadioGroupTemperature.ItemIndex=0) then
   begin
      // условие Дирихле
      LabelUnitTemperature.Visible:=true;
      LabelUnitTemperature.Caption:='K';
   end
   else if (RadioGroupTemperature.ItemIndex=1) then
   begin
      // Тепловой поток.
      LabelUnitTemperature.Visible:=true;
      LabelUnitTemperature.Caption:='W/(m!2)';
   end
   else
   begin
      LabelUnitTemperature.Visible:=false;
   end;
end;

// Граничное условие для функции тока.
procedure TBoundaryConditionForm.ComboBox1Change(Sender: TObject);
var
   ind : Integer; // номер выбранной границы
begin
    // определяем номер выбранной границы
   ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы

   // графическая визуализация выбора
   case ComboBox1.ItemIndex of
    0 : // const
       begin
          LSFValue.Visible:=true;
          Editsfvalue.Visible:=true;
          Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
       end;
    1 : // x
       begin
          LSFValue.Visible:=false;
          Editsfvalue.Visible:=false;
       end;
    2 : // y
       begin
          LSFValue.Visible:=false;
          Editsfvalue.Visible:=false;
       end;
    3 : // neiman
       begin
          LSFValue.Visible:=true;
          Editsfvalue.Visible:=true;
          Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
       end;
   end;
end;


// смена типа граничных условий для функции цвета.
procedure TBoundaryConditionForm.rgvofClick(Sender: TObject);
begin
   rgvof.ItemIndex:=1;
   Application.MessageBox('реализованы только однородные условия Неймана','warning');
end;

// смена User-Defined Scalar`а
procedure TBoundaryConditionForm.cbbudsindexChange(Sender: TObject);
var
    ind : Integer;
begin
    // определяем номер выбранной границы
    ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы

    case cbbudsindex.ItemIndex of
       0 : begin
              rguds.ItemIndex:=GridGenForm.edgelist[ind].uds1clan-1;
              edtvaluds.Text:=GridGenForm.edgelist[ind].uds1condition;
           end;
       1 : begin
              rguds.ItemIndex:=GridGenForm.edgelist[ind].uds2clan-1;
              edtvaluds.Text:=GridGenForm.edgelist[ind].uds2condition;
           end;
       2 : begin
              rguds.ItemIndex:=GridGenForm.edgelist[ind].uds3clan-1;
              edtvaluds.Text:=GridGenForm.edgelist[ind].uds3condition;
           end;
       3 : begin
              rguds.ItemIndex:=GridGenForm.edgelist[ind].uds4clan-1;
              edtvaluds.Text:=GridGenForm.edgelist[ind].uds4condition;
           end;
    end;
end;

procedure TBoundaryConditionForm.rgudsClick(Sender: TObject);
begin
   case rguds.ItemIndex of
     0 : begin
            grpvalue.Visible:=True;
            grpvalue.Caption:='numerical value';
         end;
     1 : begin
            grpvalue.Visible:=True;
            grpvalue.Caption:='numerical value';
         end;
     2 : begin
            grpvalue.Visible:=False;
            grpvalue.Caption:='numerical value';
         end;
     3 : begin
            grpvalue.Visible:=False;
            grpvalue.Caption:='numerical value';
         end;
   end;
end;

// Смена границы в селекторе, или установка границы из вне (из главного модуля).
procedure TBoundaryConditionForm.EdgeComboBoxChange(Sender: TObject);
var
   ind : Integer; // номер выбранной границы
begin
   // определяем номер выбранной границы
   ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы

   if (TabControl1.TabIndex=1) then
   begin
      // Flow вкладка.


      // Набор решаемых уравнений включает уравнения Навье-Стокса
      // Условия по температуре невидимы, а условия по скорости видимы.
      PanelTemperature.Visible:=false;
      GroupBoxVelocity.Visible:=true;
      pnluds.Visible:=False;
      pnlvof.Visible:=False;

      if (GridGenForm.edgelist[ind].bsimmetry) then
      begin
         RadioGroupVelocity.ItemIndex:=2; // граница симметрии.
      end
       else  if (GridGenForm.edgelist[ind].boutflow) then
      begin
         RadioGroupVelocity.ItemIndex:=1; // выходная граница.
      end
       else if (GridGenForm.edgelist[ind].bpressure) then
      begin
         RadioGroupVelocity.ItemIndex:=3; // задано давление.
      end
       else if (GridGenForm.edgelist[ind].bMarangoni) then
      begin
         RadioGroupVelocity.ItemIndex:=4; // задано условие Марангони.
      end
        else
      begin
         // заданы компоненты скорости.
         RadioGroupVelocity.ItemIndex:=0;
      end;
      RadioGroupVelocityClick(Sender);

       // функция тока.
      case GridGenForm.edgelist[ind].chSFval of
        'c' : begin
                 BoundaryConditionForm.ComboBox1.ItemIndex:=0;
                 LSFValue.Visible:=true;
                 Editsfvalue.Visible:=true;
                 Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
              end;
        'x' : begin
                 BoundaryConditionForm.ComboBox1.ItemIndex:=1;
                 LSFValue.Visible:=false;
                 Editsfvalue.Visible:=false;
              end;
        'y' : begin
                 BoundaryConditionForm.ComboBox1.ItemIndex:=2;
                 LSFValue.Visible:=false;
                 Editsfvalue.Visible:=false;
              end;
        'n' : begin
                 BoundaryConditionForm.ComboBox1.ItemIndex:=3;
                 LSFValue.Visible:=true;
                 Editsfvalue.Visible:=true;
                 Editsfvalue.Text:=FloatToStr(GridGenForm.edgelist[ind].rSFval);
              end;
      end;

   end
    else if (TabControl1.TabIndex=0) then
   begin
      // Температура.

      // условия по температуре делаем видимыми
      // а условия по скорости делаем невидимыми.
      PanelTemperature.Visible:=true;
      GroupBoxVelocity.Visible:=false;
      pnluds.Visible:=False;
      pnlvof.Visible:=False;

      RadioGroupTemperature.ItemIndex:=GridGenForm.edgelist[ind].temperatureclan-1;
      if (RadioGroupTemperature.ItemIndex=0) then
      begin
         // задана температура
         Etemperature.Text:=FloatToStr(GridGenForm.edgelist[ind].temperaturecondition);
         LabelUnitTemperature.Visible:=true;
         LabelUnitTemperature.Caption:='K';
      end;
      if (RadioGroupTemperature.ItemIndex=1) then
      begin
         // задан тепловой поток.
         Etemperature.Text:=FloatToStr(GridGenForm.edgelist[ind].temperaturecondition);
         LabelUnitTemperature.Visible:=true;
         LabelUnitTemperature.Caption:='W/(m!2)';
      end;
      if (RadioGroupTemperature.ItemIndex>1) then
      begin
         LabelUnitTemperature.Visible:=false;
      end;
      if (RadioGroupTemperature.ItemIndex>1) then
      begin
         GroupBoxValueTemperature.Visible:=False;
      end
      else
      begin
         GroupBoxvalueTemperature.Visible:=True;
      end;
   end
    else if (TabControl1.TabIndex=3) then
   begin
      PanelTemperature.Visible:=false;
      GroupBoxVelocity.Visible:=false;
      pnlvof.Visible:=False;
      pnluds.Visible:=True;
      // UDS
      case cbbudsindex.ItemIndex of
        0 : begin
               // UDS1

               rguds.ItemIndex:=GridGenForm.edgelist[ind].uds1clan-1;
               edtvaluds.Text:=GridGenForm.edgelist[ind].uds1condition;
            end;
        1 : begin
               // UDS2

               rguds.ItemIndex:=GridGenForm.edgelist[ind].uds2clan-1;
               edtvaluds.Text:=GridGenForm.edgelist[ind].uds2condition;
            end;
        2 : begin
               // UDS3

               rguds.ItemIndex:=GridGenForm.edgelist[ind].uds3clan-1;
               edtvaluds.Text:=GridGenForm.edgelist[ind].uds3condition;
            end;
        3 : begin
               // UDS4

               rguds.ItemIndex:=GridGenForm.edgelist[ind].uds4clan-1;
               edtvaluds.Text:=GridGenForm.edgelist[ind].uds4condition;
            end;
      end;
   end else if (TabControl1.TabIndex=2) then
   begin
      // VOF method
      PanelTemperature.Visible:=false;
      GroupBoxVelocity.Visible:=false;
      pnlvof.Visible:=True;
      pnluds.Visible:=False;
   end;

end;

// Реакция меню программы при задании граничных условий для течения
procedure TBoundaryConditionForm.RadioGroupVelocityClick(Sender: TObject);
var
   ind : Integer; // номер выбранной границы
begin
     // определяем номер выбранной границы
    ind:=EdgeComboBox.ItemIndex+1; // номер выбранной границы

    if ((RadioGroupVelocity.ItemIndex = 1) or (RadioGroupVelocity.ItemIndex = 2)) then
    begin
        // граница симметрии и надо скрыть вторую панель
        // symmetry and outflow
        PanelsetVelocity.Visible:=false;
    end
     else
    begin
       PanelsetVelocity.Visible:=true;
    end;
    if (RadioGroupVelocity.ItemIndex = 3) then
    begin
        // задаётся давление на границе
        Label1.Caption:='pressure';
        Label2.Caption:='on the boundary';
        Label3.Visible:=false;
        //Exvel.Text:='0'; // нулевое давление на выходной границе
        // 17 ноября 2014.
        Exvel.Text:=FloatToStr(GridGenForm.edgelist[ind].rpressure);
        Eyvel.Visible:=false;
    end
    else if (RadioGroupVelocity.ItemIndex = 4) then
    begin
        // задаётся давление на границе
        Label1.Caption:='Surface';
        Label2.Caption:='Tension Gradient';
        Label3.Visible:=false;
        // нулевое значение dSigma/dT
        Exvel.Text:=FloatToStr(GridGenForm.edgelist[ind].surfaceTensionGradient);
        Eyvel.Visible:=false;
    end
     else
    begin
       // задаёется скорость нормальная к границе
       Label1.Caption:='velocity';
       Label2.Caption:='x component';
       Exvel.Text:=FloatToStr(GridGenForm.edgelist[ind].Vx);
       Eyvel.Text:=FloatToStr(GridGenForm.edgelist[ind].Vy);
       Label3.Visible:=true;
       Eyvel.Visible:=true;
    end;
end;


end.
