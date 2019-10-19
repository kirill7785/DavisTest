unit myRunmodule;
//  В этом модуле происходит запуск задачи на расчёт.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Unitdeclar;

type
  TmyRun = class(TForm)
    Panel2: TPanel;
    Label4: TLabel;
    Panel1: TPanel;
    Lrealtimenow: TLabel;
    Ltimestepnow: TLabel;
    Lnumbertimestep: TLabel;
    ErealFlowTimeVal: TEdit;
    Etimestep: TEdit;
    Enumbertimestep: TEdit;
    Biterate: TButton;
    Panel3: TPanel;
    Liternumber: TLabel;
    Eitercount: TEdit; // кнопка запуска задачи на решение
    procedure BiterateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    btheBeginingCalculation : Boolean;  // признак того были-ли запущены вычисления на выполнение

    // Мы будем запоминать значения введённые пользователем,
    // чтобы предложить ему ту информацию что он вводил раньше как
    // начальную.
    // Практика показывает, что это наиболее приемлемый подход.
    number_of_steps_for_the_period : Integer;
    number_of_periods_of_vibration : Integer;
    user_time_step_size : Float;
    number_of_time_steps : Integer;
    number_of_iteration : Integer;
  end;

var
  myRun: TmyRun;

implementation
uses
    MainUnit, TerminateProcessUnit;

{$R *.dfm}

// запускает расчёт на выполнение
procedure TmyRun.BiterateClick(Sender: TObject);
var
    bOk : Boolean;
    r : Double;
    ir : Integer;
begin
   bOk:=True;

   if (not TryStrToFloat(Etimestep.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Etimestep.Text+' time step size is incorrect value.');
   end;
    if (not TryStrToInt(Enumbertimestep.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(Enumbertimestep.Text+' number time step is incorrect value.');
   end;
    if (not TryStrToInt(Eitercount.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(Eitercount.Text+' number of iterations is incorrect value.');
   end;
    if (not TryStrToFloat(ErealFlowTimeVal.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(ErealFlowTimeVal.Text+' current time value is incorrect value.');
   end;


   if (bOk) then
   begin


      if (Form1.btimedepend = false) then // стационарный
      begin
         // Т.к. большинство процедур расчёта делаются
         // универсальными, т.е. один и тот же код работает
         // как в стационарном режиме так и при нестационарных расчётах,
         // то требование общности требует задания количества шагов
         // по времени в стационарном случае равным 1.
         // Это указывается явно следующей строчкой:
         Form1.inumbertimestep:=1; // количество шагов по времени
         Form1.dTimeStep:=1; // для совместимости стационарного и нестационарного решателя
         Form1.itercount:=StrToInt(Eitercount.Text); // количество итераций
         //number_of_iteration:=StrToInt(Eitercount.Text);

      end
       else // нестационарный
      begin
         if (Form1.actiVibr.bOn) then
         begin
            Form1.realFlowTime:=StrToFloat(ErealFlowTimeVal.Text); // текущее время
            Form1.inumberTimeStepDivisionPeriod:=StrToInt(Etimestep.Text); // число шагов за период
            number_of_steps_for_the_period:=StrToInt(Etimestep.Text);
            Form1.dTimeStep:=1/(Form1.actiVibr.Frequency*Form1.inumberTimeStepDivisionPeriod); // шаг по времени
            Form1.inumberPeriod:=StrToInt(Enumbertimestep.Text); // число периодов
            number_of_periods_of_vibration:=StrToInt(Enumbertimestep.Text);
            Form1.inumbertimestep:= Form1.inumberPeriod*Form1.inumberTimeStepDivisionPeriod; // число шагов по времени
            Form1.itercount:=StrToInt(Eitercount.Text); // количество итераций на одном шаге по времени
         end
          else
         begin
            Form1.realFlowTime:=StrToFloat(ErealFlowTimeVal.Text); // текущее время
            Form1.dTimeStep:=StrToFloat(Etimestep.Text); // постоянный шаг по времени
            user_time_step_size:=StrToFloat(Etimestep.Text);
            Form1.inumbertimestep:=StrToInt(Enumbertimestep.Text); // количество шагов по времени
            number_of_time_steps:=StrToInt(Enumbertimestep.Text);
            Form1.itercount:=StrToInt(Eitercount.Text); // количество итераций
            number_of_iteration:=StrToInt(Eitercount.Text);
         end;

      end;

      btheBeginingCalculation:=true; // вычисления запущены на выполнение
      Close; // закрывает форму и производит запуск расчёта по возвращении в код главного модуля.

   end;
end;

procedure TmyRun.FormCreate(Sender: TObject);
begin
   // При инициализации мы должны задать некие
   // входные значения.
   // А в дальнейшем в этих переменных будет храниться ввод пользователя.
   number_of_steps_for_the_period:=200;
   number_of_periods_of_vibration:=400;
   user_time_step_size:=0.1;
   number_of_time_steps:=10;
   number_of_iteration:=120;
end;

end.
