unit InitializeUnit;
// модуль инициализации.
// Здесь выделяется оперативная память и переменным присваиваются
// определённые значения.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Unitdeclar;

type
  TmyInitialize = class(TForm)
    PAllFunction: TPanel;
    Label1: TLabel;
    // панель на которой располагаются переменные для
    PFlow: TPanel; // расчёта поля течения
    Lxvel: TLabel; // метка с названием горизонтальной скорости
    Lyvel: TLabel; // метка с названием давления
    PTempreture: TPanel; // панель для поля температур
    Ltempreture: TLabel; // метка с названием температуры
    // текстовое поле для:
    EinitTemp: TEdit;  // инициализации температуры
    EinitXvel: TEdit;  // горизонтальной скорости
    EinitYvel: TEdit;  // вертикальной скорости
    Binitialize: TButton;
    PanelVof: TPanel;
    LabelVOF: TLabel;
    cbbvof: TComboBox;
    grpuds1: TGroupBox;
    edtuds1: TEdit;
    grpuds2: TGroupBox;
    edtuds2: TEdit;
    grpuds3: TGroupBox;
    edtuds3: TEdit;
    grpuds4: TGroupBox;
    edtuds4: TEdit; // кнопка вызывающая инициализацию
    procedure BinitializeClick(Sender: TObject); // метод передачи информации о инициализации
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  myInitialize: TmyInitialize;

implementation
uses
    MainUnit, GridGenUnit, Math;

{$R *.dfm}

function fabs(r1 : Real) : Real;
begin
   if  (r1<0.0) then
   begin
      fabs:=-r1;
   end
   else
   begin
      fabs:=r1;
   end;
end;

// данный метод по нажатию на
// кнопку инициализации
// передаёт введённые параметры
// в структуру данных InitValue
// главного модуля  MainUnit
procedure TmyInitialize.BinitializeClick(Sender: TObject);
var
   i : Integer;
   deltatemp,tmin,tmax : Float;
   Ux_inf,Uy_inf : Float; // скорость набегающего потока на бесконечности
   xmin, ymin, CurantNumber : Float; // минимальные размеры ячейки по осям x и y.
   // корректность ввода.
   bOk : Boolean;
   r : Double;

begin
    bOk:=True;

    if (not TryStrToFloat(EinitTemp.Text,r)) then
    begin
       bOk:=False;
       ShowMessage(EinitTemp.Text+' is incorrect value.');
    end;

    if (not TryStrToFloat(EinitXvel.Text,r)) then
    begin
       bOk:=False;
       ShowMessage(EinitXvel.Text+' is incorrect value.');
    end;

    if (not TryStrToFloat(EinitYvel.Text,r)) then
    begin
       bOk:=False;
       ShowMessage(EinitYvel.Text+' is incorrect value.');
    end;

    case Form1.imaxUDS of
       1 : begin
              if (not TryStrToFloat(edtuds1.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds1.Text+' UDS1 is incorrect value.');
              end;
           end;
       2 : begin
              if (not TryStrToFloat(edtuds1.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds1.Text+' UDS1 is incorrect value.');
              end;
              if (not TryStrToFloat(edtuds2.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds2.Text+' UDS2 is incorrect value.');
              end;
           end;
       3 : begin
               if (not TryStrToFloat(edtuds1.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds1.Text+' UDS1 is incorrect value.');
              end;
              if (not TryStrToFloat(edtuds2.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds2.Text+' UDS2 is incorrect value.');
              end;
              if (not TryStrToFloat(edtuds3.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds3.Text+' UDS3 is incorrect value.');
              end;
           end;
       4 : begin
              if (not TryStrToFloat(edtuds1.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds1.Text+' UDS1 is incorrect value.');
              end;
               if (not TryStrToFloat(edtuds2.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds2.Text+' UDS2 is incorrect value.');
              end;
              if (not TryStrToFloat(edtuds3.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds3.Text+' UDS3 is incorrect value.');
              end;
              if (not TryStrToFloat(edtuds4.Text,r)) then
              begin
                 bOk:=False;
                 ShowMessage(edtuds4.Text+' UDS4 is incorrect value.');
              end;
           end;
    end;


    if (bOk) then
    begin


   // температура
   Form1.InitVal.TempInit:=StrToFloat(EinitTemp.Text);
   // горизонтальная скорость
   Form1.InitVal.XvelInit:=StrToFloat(EinitXvel.Text);
   // вертикальная скорость
   Form1.InitVal.YvelInit:=StrToFloat(EinitYvel.Text);
   // функция цвета.
   case cbbvof.ItemIndex of
   0 : begin
          Form1.InitVal.VofInit:=0.0;
       end;
   1 : begin
          Form1.InitVal.VofInit:=1.0;
       end;
   end;
   case Form1.imaxUDS of
       1 : begin
              Form1.InitVal.UDS1Init:=edtuds1.Text;
           end;
       2 : begin
              Form1.InitVal.UDS1Init:=edtuds1.Text;
              Form1.InitVal.UDS2Init:=edtuds2.Text;
           end;
       3 : begin
              Form1.InitVal.UDS1Init:=edtuds1.Text;
              Form1.InitVal.UDS2Init:=edtuds2.Text;
              Form1.InitVal.UDS3Init:=edtuds3.Text;
           end;
       4 : begin
              Form1.InitVal.UDS1Init:=edtuds1.Text;
              Form1.InitVal.UDS2Init:=edtuds2.Text;
              Form1.InitVal.UDS3Init:=edtuds3.Text;
              Form1.InitVal.UDS4Init:=edtuds4.Text;
           end;
   end;

   // здесь надо вызывать некий код производящий инициаизацию.
   case Form1.imodelEquation of
     1 :  // чистая теплопроводность
        begin
           Form1.initparamSIMPLE(true);
           Form1.initparam; // инициализирует данные
           if (Form1.btimedepend) then
           begin
              // выделяем память для хранения поля температур с прошлого временного слоя
              // эта память выделяется в процедуре initparam. См. initparam.
              // запоминаем поле температур с предыдущего временного слоя в переменной ToldTimeStep
              Form1.RememberTOldTimeStep(true); // инициализация
           end;
           // инициализация параметров для UDS.
           Form1.inituds();
           Form1.myInitializationRestart; // всё придётся инициализировать заново: выделение памяти и присвоение значений.
           // кроме случая чистой теплопроводности.
           Form1.bweShouldInitialize[1]:=false; // инициализация выполнена.
        end;
     2 :  // определённый пользователем User-Defined Segregated Solver.
        begin
            Form1.initparamSIMPLE(true);
           // инициализация параметров для UDS.
           Form1.inituds();
           Form1.myInitializationRestart; // всё придётся инициализировать заново: выделение памяти и присвоение значений.
           // кроме User-Defined Segrageted Solver.
           Form1.bweShouldInitialize[2]:=false; // инициализация выполнена.
        end;
     3 : // чистая гидродинамика
        begin
           Form1.initparamSIMPLE(true);
           // инициализация параметров для UDS.
           Form1.inituds();
           Form1.myInitializationRestart; // всё придётся инициализировать заново: выделение памяти и присвоение значений.
           // кроме случая чистой гидродинамики.
           Form1.bweShouldInitialize[3]:=false; // инициализация выполнена.
        end;
     4 : // гидродинамика с учётом теплопроводности
        begin
           Form1.initparamSIMPLE(true);
           // инициализация параметров для UDS.
           Form1.inituds();
           Form1.myInitializationRestart; // всё придётся инициализировать заново: выделение памяти и присвоение значений.
           // кроме случая гидродинамики с учётом конвективного члена.
           Form1.bweShouldInitialize[4]:=false; // инициализация выполнена.
        end;
     5 : // чистая гидродинамика и VOF метод.
        begin
           Form1.initparamSIMPLE(true);
           // инициализация параметров для UDS.
           Form1.inituds();
           Form1.myInitializationRestart; // всё придётся инициализировать заново: выделение памяти и присвоение значений.
           // кроме случая чистой гидродинамики.
           Form1.bweShouldInitialize[5]:=false; // инициализация выполнена.
        end;
   end;

   Form1.iglobalnumberiteration:=1; // глобальный номер итераций присваивается при инициализации

   if (Form1.imodelEquation <> 3) then
   begin
      // Число Прандтля
      Form1.MainMemo.Lines.Add('Число Прандтля Pr= '+ FloatToStr(Form1.matprop[0].dmu*Form1.matprop[0].dcp/Form1.matprop[0].dlambda));
   end;
   if (Form1.actiVibr.bOn) then
   begin
      // вибрационнное число Рейнольдса
      Form1.MainMemo.Lines.Add('Вибрационное число Рейнольдса Re_vibr= '+ FloatToStr(2*Pi*Form1.actiVibr.Amplitude*Form1.actiVibr.Frequency*0.5*(Form1.dLx+Form1.dLy)*Form1.matprop[0].drho/Form1.matprop[0].dmu));
   end;
   if (Form1.bBussinesk) then
   begin
      tmin:=1.0e300;
      tmax:=-1.0e300;
      // характерная разность температур
      for i:=1 to GridGenForm.inumboundary do
      begin
       if ( GridGenForm.edgelist[i].temperatureclan=1) then
       begin
          if (GridGenForm.edgelist[i].temperaturecondition<tmin) then
          tmin:=GridGenForm.edgelist[i].temperaturecondition;
          if (GridGenForm.edgelist[i].temperaturecondition>tmax) then
          tmax:=GridGenForm.edgelist[i].temperaturecondition;
       end;
      end;
      deltatemp:=tmax-tmin;
      // число Рэлея
      Form1.MainMemo.Lines.Add('Число Рэлея Ra= '+ FloatToStr((Form1.matprop[0].drho*Form1.matprop[0].drho*Form1.matprop[0].dcp*(0.5*(Form1.dLx+Form1.dLy))*(0.5*(Form1.dLx+Form1.dLy))*(0.5*(Form1.dLx+Form1.dLy))*Form1.dbeta*sqrt(Form1.dgx*Form1.dgx+Form1.dgy*form1.dgy)*deltatemp)/(Form1.matprop[0].dmu*Form1.matprop[0].dlambda)));
   end
    else
   begin
      if (Form1.imodelEquation = 3) then
      begin
         // Число Рейнольдса
         Ux_inf:=-1e300; // скорость набегающего потока на бесконечности
         Uy_inf:=-1e300;
         for i:=1 to GridGenForm.inumboundary do
         begin // определение максимальной скорости
            if ( abs(GridGenForm.edgelist[i].Vx) > Ux_inf) then
            begin
               Ux_inf:=abs(GridGenForm.edgelist[i].Vx);
            end;
            if ( abs(GridGenForm.edgelist[i].Vy) > Uy_inf) then
            begin
               Uy_inf:=abs(GridGenForm.edgelist[i].Vy);
            end;
         end;
         // число Рейнольдса
         Form1.MainMemo.Lines.Add('Число Рейнольдса Re= '+ FloatToStr(Form1.matprop[0].drho*max(Ux_inf,Uy_inf)*0.5*(Form1.dLx+Form1.dLy)/Form1.matprop[0].dmu));
         if (Form1.matprop[0].drho*max(Ux_inf,Uy_inf)*0.5*(Form1.dLx+Form1.dLy)/Form1.matprop[0].dmu>2100.0) then
         begin
            // Число Рейнольдса больше 2100 нужно включить нестационарный решатель.
            if (Form1.btimedepend=False) then
            begin
               Form1.btimedepend:=True;
               Application.MessageBox('Re>2100 решатель переведён на нестационарный','очень большое число Рейнольдса',MB_OK);
               Application.MessageBox('Выберите разумный шаг по времени иначе АВОСТ!!!','warning',MB_OK);
            end;
         end;
         // условие  Куранта-Фридрихса-Леви
         xmin:=1e300; // очень большое число
         for i:=2 to Form1.inx do
         begin
            if ((Form1.xpos[i]-Form1.xpos[i-1]) < xmin) then xmin:=Form1.xpos[i]-Form1.xpos[i-1];
         end;
         ymin:=1e300; // очень большое число
         for i:=2 to Form1.iny do
         begin
            if ((Form1.ypos[i]-Form1.ypos[i-1]) < ymin) then ymin:=Form1.ypos[i]-Form1.ypos[i-1];
         end;
         CurantNumber:=0.5; // Число Куранта
         if ((fabs(Ux_inf)<1.0e-6) and (fabs(Uy_inf)<1.0e-6)) then
         begin
            Form1.MainMemo.Lines.Add('условие CFL dt < infinity');
         end
         else
         begin
            Form1.MainMemo.Lines.Add('условие CFL dt < '+ FloatToStr(CurantNumber/(Ux_inf/xmin+Uy_inf/ymin)));
         end;
      end;
   end;

   Form1.imarker:=0; // сброс показа невязки
   // записывает заголовок для анимации.
   Form1.writeanimationTitle();
   Form1.MainMemo.Lines.Add('initialization complete...');
   Form1.MainMemo.Lines.Add('К записи анимации в tecplot 360 готов...');
   Application.MessageBox('initialization complete...','',MB_OK);

   // Если инициализация выполнена для какого-то одного случая то для всех остальных
   // случаев такая инициализация не подходит.
   // Взаимозависимости сейчас не учитываются. Хотя иногда инициализация и решение
   // для какого-то одного imodelEquation может служить начальным приближением для
   // какого-то другого значения imodelEquation.

   end;

end; // инициализация

end.
