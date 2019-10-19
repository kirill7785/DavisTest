unit UnitDefineTrials;
{ Данный модуль позволяет настроить параметрический, многовариантный
расчёт или оптимизацию на основе введённых пользователем переменных.
Сделано по образцу программы ANSYS Icepak.
Параметрический расчёт необходим для нахождения ВАХ.
В то же время параметризация должна быть сделана без потери общности.
Что немаловажно, параметрический расчёт надо выполнить так, чтобы его
всегда можно было отключить.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Unitdeclar;

type

  // При многопараметрическом моделировании,
  // после решения каждой отдельно взятой задачи
  // автоматическим образом будет формироваться
  // отчёт о каждом проделанном вычислении.
  TTrialReport = record
    // Отчёт основанный на вычислении поверхностного интеграла.
    ibound : Integer; // номер границы >= 1 and <= inumboundary.
    icff : Integer; // порядковый номер custom field function 0..9.
    itypereport : Integer; // 0 - Area, 1 - Integral, 2 - Vertex Average, 3 - Vertex Minimum, 4 - Vertex Maximum.
    reportname : String; // название отчёта.
    multiplyer : Float; // множитель на который домножается безразмерное значение.
    bactive : Boolean; // вычислять отчёт или нет.
    resultreport : Float; // результирующие вычисленное значение отчёта.
  end;

  TFormDefineTrials = class(TForm)
    tbcdefinetrialsmain: TTabControl;
    btnApply: TButton;
    rgtrialtype: TRadioGroup;
    lblvariable: TLabel;
    cbbvariable: TComboBox;
    mmoserialvalues: TMemo;
    lbluserwarningmemo: TLabel;
    pnlFunctions: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lblnum1: TLabel;
    lblnum2: TLabel;
    lblnum3: TLabel;
    lblnum4: TLabel;
    lblnum5: TLabel;
    btnaddreport: TButton;
    lblname1: TLabel;
    lblname2: TLabel;
    lblname3: TLabel;
    lblname4: TLabel;
    lblname5: TLabel;
    lblm1: TLabel;
    lblm2: TLabel;
    lblm3: TLabel;
    lblm4: TLabel;
    lblm5: TLabel;
    btndeletereport: TButton;
    procedure tbcdefinetrialsmainChange(Sender: TObject);
    procedure cbbvariableChange(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnaddreportClick(Sender: TObject);
    procedure btndeletereportClick(Sender: TObject);
  private
    { Private declarations }
    fex : T2myDynArray;
  public
    { Public declarations }
    mylistreport : array[0..4] of TTrialReport;
    imaxreport : Integer;

    // вычисляет отчёт после того как текущая задача решена.
    procedure calculationreports;
  end;

var
  FormDefineTrials: TFormDefineTrials;

implementation

uses MainUnit, UnitSurfaceIntegralReport, GridGenUnit;

{$R *.dfm}

// Смена вкладки на главной из таблиц.
procedure TFormDefineTrials.tbcdefinetrialsmainChange(Sender: TObject);
var
   i1 : Integer;
begin
   case tbcdefinetrialsmain.TabIndex of
     0 : // Setup
     begin
        rgtrialtype.Visible:=True;
        lblvariable.Visible:=False;
        cbbvariable.Visible:=False;
        lbluserwarningmemo.Visible:=False;
        mmoserialvalues.Visible:=False;
        pnlFunctions.Visible:=False;
     end;
     1 : // Design variables
     begin
        pnlFunctions.Visible:=False;
        rgtrialtype.Visible:=False;
        lblvariable.Visible:=True;
        if (rgtrialtype.ItemIndex=0) then
        begin
           // текущие значения,
           // список значений для редактирования недоступен.
           lbluserwarningmemo.Visible:=False;
           mmoserialvalues.Visible:=False;
        end;
        if (rgtrialtype.ItemIndex=1) then
        begin
           // список значений подлежащих моделированию.
           lbluserwarningmemo.Visible:=True;
           mmoserialvalues.Visible:=True;
        end;

        if (Form1.ivar_trial>0) then
        begin
           cbbvariable.Clear;
           for i1:=1 to Form1.ivar_trial do
           begin
              cbbvariable.Items.Add(Form1.base_value_trial[i1-1].svar);
           end;
           cbbvariable.Visible:=True;
           cbbvariable.ItemIndex:=0; // порядковый номер переменной минус 1.
           if (rgtrialtype.ItemIndex=1) then
           begin
              // Только если мы находимся в режиме многопараметрического моделирования
              // нужно загрузить список значений переменной для редактирования.
              mmoserialvalues.Clear;
              for i1:=0 to High(Form1.series_value_of_the_variable[0]) do
              begin
                 mmoserialvalues.Lines.Add(FloatToStr(Form1.series_value_of_the_variable[0][i1]));
              end;
           end;
        end
         else
        begin
           // нет переменных.
           cbbvariable.Clear;
           cbbvariable.Visible:=False;
           mmoserialvalues.Clear;
           lbluserwarningmemo.Visible:=False;
           mmoserialvalues.Visible:=False;
        end;
     end;
     2 : // Functions
     begin
        rgtrialtype.Visible:=False;
        lblvariable.Visible:=False;
        cbbvariable.Visible:=False;
        lbluserwarningmemo.Visible:=False;
        mmoserialvalues.Visible:=False;
        pnlFunctions.Visible:=True;
     end;
     3 : // Trials
     begin
        rgtrialtype.Visible:=False;
        lblvariable.Visible:=False;
        cbbvariable.Visible:=False;
        lbluserwarningmemo.Visible:=False;
        mmoserialvalues.Visible:=False;
        pnlFunctions.Visible:=False;
     end;
   end;
end;

// вычисляет отчёт после того как текущая задача решена.
procedure TFormDefineTrials.calculationreports;
var
   i : Integer; // счётчик.
   inx, iny : Integer;
   k : Integer;
   sum : Float;
   rmin, rmax : Float;
   icount : Integer;
begin
   if ((imaxreport>-1) and (imaxreport<5)) then
   begin
      // Препроцессинг, нужно вычислить все полевые величины
      // которые интересуют пользователя.
      inx:=Form1.inx;
      iny:=Form1.iny;
      // Custom Field Functions
      SetLength(fex,10);
      for i:=0 to 9 do
      begin
         SetLength(fex[i],inx*iny+1);
      end;
      // Вычисляет всё необходимое.
      Form1.getreadycalc(fex);

      for i:=0 to imaxreport do
      begin
         if (mylistreport[i].bactive) then
         begin
            // если отчёт активен, т.е. подлежит вычислению.
            // Вычисление.
            // 1. определить тип отчёта, границу и field variable  для вычисления.
            // 2. произвести вычисление и напечатать результат.
            sum:=0.0;
            rmin:=1.0e+30;
            rmax:=-1.0e+30;
            icount:=0; // счётчик количества узлов.
            for k:=1 to Form1.imaxnumbernode do
            begin
               if (Form1.mapPT[k].itype=2) then
               begin
                  if (Form1.mapPT[k].iboundary=GridGenForm.edgelist[mylistreport[i].ibound].idescriptor) then
                  begin
                     // данная граница выбрана в селекторе.
                     case Form1.mapPT[k].chnormal of
                       'E', 'W' : begin
                                     if (mylistreport[i].itypereport=0) then
                                     begin
                                        // Area.
                                        sum:=sum+Form1.mapPT[k].dy;
                                     end;
                                     if (mylistreport[i].itypereport=1) then
                                     begin
                                        sum:=sum+fex[mylistreport[i].icff][k]*Form1.mapPT[k].dy;
                                     end;
                                     if (mylistreport[i].itypereport=2) then
                                     begin
                                        Inc(icount);
                                        sum:=sum+fex[mylistreport[i].icff][k];
                                     end;
                                     if (mylistreport[i].itypereport=3) then
                                     begin
                                        if (fex[mylistreport[i].icff][k]<rmin) then
                                        begin
                                           rmin:=fex[mylistreport[i].icff][k];
                                        end;
                                     end;
                                     if (mylistreport[i].itypereport=4) then
                                     begin
                                        if (fex[mylistreport[i].icff][k]>rmax) then
                                        begin
                                           rmax:=fex[mylistreport[i].icff][k];
                                        end;
                                     end;
                                  end;
                       'N', 'S' : begin
                                     if (mylistreport[i].itypereport=0) then
                                     begin
                                        // Area.
                                        sum:=sum+Form1.mapPT[k].dx;
                                     end;
                                     if (mylistreport[i].itypereport=1) then
                                     begin
                                        sum:=sum+fex[mylistreport[i].icff][k]*Form1.mapPT[k].dx;
                                     end;
                                     if (mylistreport[i].itypereport=2) then
                                     begin
                                        sum:=sum+fex[mylistreport[i].icff][k];
                                        Inc(icount);
                                     end;
                                     if (mylistreport[i].itypereport=3) then
                                     begin
                                        if (fex[mylistreport[i].icff][k]<rmin) then
                                        begin
                                           rmin:=fex[mylistreport[i].icff][k];
                                        end;
                                     end;
                                     if (mylistreport[i].itypereport=4) then
                                     begin
                                        if (fex[mylistreport[i].icff][k]>rmax) then
                                        begin
                                           rmax:=fex[mylistreport[i].icff][k];
                                        end;
                                     end;
                                  end;
                     end;
                  end;
               end;
            end;
            if ((mylistreport[i].itypereport=0) or (mylistreport[i].itypereport=1)) then
            begin
               mylistreport[i].resultreport:=mylistreport[i].multiplyer*sum;
            end;
            if (mylistreport[i].itypereport=2) then
            begin
               // Vertex Average
               sum:=sum/icount;
               mylistreport[i].resultreport:=mylistreport[i].multiplyer*sum;
            end;
            if (mylistreport[i].itypereport=3) then
            begin
               // Минимальное значение.
               mylistreport[i].resultreport:=mylistreport[i].multiplyer*rmin;
            end;
            if (mylistreport[i].itypereport=4) then
            begin
               // Максимальное значение.
                mylistreport[i].resultreport:=mylistreport[i].multiplyer*rmax;
            end;
         end;
      end;
   end;
end;

// Смена переменной в списке переменных :
// нужно загрузить список значений которые принимает эта переменная
// для редактирования.
procedure TFormDefineTrials.cbbvariableChange(Sender: TObject);
var
   i : Integer; // счётчик.
begin
   if ((tbcdefinetrialsmain.TabIndex=1) and (Form1.ivar_trial>0)) then
   begin
      // если переменые присутствуют.
      // и мы находимся на вкладке где задаётся список значений для каждой переменной.

      if (rgtrialtype.ItemIndex=1) then
      begin
         // Только если мы находимся в режиме многопараметрического моделирования
         // нужно загрузить список значений переменной для редактирования.
         // cbbvariable.ItemIndex - порядковый номер переменной минус 1.

         mmoserialvalues.Clear;
         for i:=0 to High(Form1.series_value_of_the_variable[cbbvariable.ItemIndex]) do
         begin
            mmoserialvalues.Lines.Add(FloatToStr(Form1.series_value_of_the_variable[cbbvariable.ItemIndex][i]));
         end;
      end;
   end;
end;

// Осуществим ввод значений которые принимает выбранная переменная.
procedure TFormDefineTrials.btnApplyClick(Sender: TObject);
var
   i, size : Integer; // Счётчик
   
begin
   if ((tbcdefinetrialsmain.TabIndex=1) and (Form1.ivar_trial>0)) then
   begin
      // если переменые присутствуют.
      // и мы находимся на вкладке где задаётся список значений для каждой переменной.

      if (rgtrialtype.ItemIndex=1) then
      begin
         // Только если мы находимся в режиме многопараметрического моделирования
         // нужно загрузить список значений переменной для редактирования.
         // cbbvariable.ItemIndex - порядковый номер переменной минус 1.

         size:=0; // количество непустых строк до первой пустой.
         for i:=0 to mmoserialvalues.Lines.Count-1 do
         begin
            if (Length(mmoserialvalues.Lines[i])>0) then
            begin
               inc(size);
            end
             else
            begin
               Break; // досрочно выйдем из цикла если нам встретися пустая строка.
            end;
         end;

         SetLength(Form1.series_value_of_the_variable[cbbvariable.ItemIndex],size);
         for i:=0 to size-1 do
         begin
            Form1.series_value_of_the_variable[cbbvariable.ItemIndex][i]:=StrToFloat(mmoserialvalues.Lines[i]);
         end;
      end;
   end;
end;

// инициализация при создании формы.
procedure TFormDefineTrials.FormCreate(Sender: TObject);
var
   i : Integer; // счётчик отчётов.
begin
   // как только форма создана у нас нет ни одного репорта
   // из пяти возможных.
   pnlFunctions.Visible:=False;
   lblnum1.Caption:='';
   lblnum2.Caption:='';
   lblnum3.Caption:='';
   lblnum4.Caption:='';
   lblnum5.Caption:='';
   lblname1.Caption:='';
   lblname2.Caption:='';
   lblname3.Caption:='';
   lblname4.Caption:='';
   lblname5.Caption:='';
   lblm1.Caption:='';
   lblm2.Caption:='';
   lblm3.Caption:='';
   lblm4.Caption:='';
   lblm5.Caption:='';
   // инициализация информации об отчёте,
   // по умолчанию все отчёты неактивны.
   imaxreport:=-1; // пока нет ни одного репорта.
   for i:=0 to 4 do
   begin
      mylistreport[i].ibound:=1; // первая граница из списка.
      mylistreport[i].icff:=0; // первая custom field function.
      mylistreport[i].itypereport:=0; // Area.
      mylistreport[i].reportname:='report'+IntToStr(i); // имя отчёта.
      mylistreport[i].multiplyer:=1.0; // множитель не задан, по умолчанию в программных безразмерных единицах.
      mylistreport[i].bactive:=False; // не вычислять report.
      mylistreport[i].resultreport:=0.0; // изначально нет результата отчёта так как вычисление ещё не произведено.
   end;
end;

// добавляет отчёт.
procedure TFormDefineTrials.btnaddreportClick(Sender: TObject);
var
   i : Integer; // счётчик.

begin
   if (imaxreport<4) then
   begin
      inc(imaxreport); // переходим к формированию нового отчёта.


      // Выполним запрос у пользователя чтобы он ввёл
      // атрибуты отчёта.
      // инициализация формы :

      // устанавливаем тип отчёта.
      FormAutoReportSurfInt.cbbreporttype.ItemIndex:=mylistreport[imaxreport].itypereport;
      // имя отчёта :
      FormAutoReportSurfInt.edtreportname.Text:=mylistreport[imaxreport].reportname;
      // домножающий множитель перевода из безразмерных единиц в размерные :
      FormAutoReportSurfInt.edtmultiplyer.Text:=FloatToStr(mylistreport[imaxreport].multiplyer);

      // подготовка границ.
      FormAutoReportSurfInt.cbbboundary.Clear; // очистка списка границ
      for i:=1 to GridGenForm.inumboundary do
      begin
         FormAutoReportSurfInt.cbbboundary.Items.Add(GridGenForm.edgelist[i].boundaryname);
      end;
      if (GridGenForm.inumboundary>0) then
      begin
         FormAutoReportSurfInt.cbbboundary.ItemIndex:=mylistreport[imaxreport].ibound-1; // выбранная пользователем граница.
      end;

      // подготовка полевых величин.
      FormAutoReportSurfInt.cbbfieldvariable.Clear;
      case Form1.inumCFF of
       1 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
           end;
       2 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
           end;
       3 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
           end;
       4 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
           end;
       5 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
           end;
       6 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff6name);
           end;
       7 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff6name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff7name);
           end;
       8 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff6name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff7name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff8name);
           end;
       9 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff6name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff7name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff8name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff9name);
           end;
      10 : begin
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff1name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff2name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff3name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff4name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff5name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff6name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff7name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff8name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff9name);
              FormAutoReportSurfInt.cbbfieldvariable.Items.Add(Form1.cff10name);
           end;
      end;
      FormAutoReportSurfInt.cbbfieldvariable.ItemIndex:=mylistreport[imaxreport].icff;

      // запуск формы :
      FormAutoReportSurfInt.ShowModal;

      mylistreport[imaxreport].bactive:=True;
      case imaxreport of
        0 : begin
               lblnum1.Caption:='1.';
               lblname1.Caption:=mylistreport[imaxreport].reportname;
               lblm1.Caption:=FloatToStr(mylistreport[imaxreport].multiplyer);
            end;
        1 : begin
               lblnum2.Caption:='2.';
               lblname2.Caption:=mylistreport[imaxreport].reportname;
               lblm2.Caption:=FloatToStr(mylistreport[imaxreport].multiplyer);
            end;
        2 : begin
               lblnum3.Caption:='3.';
               lblname3.Caption:=mylistreport[imaxreport].reportname;
               lblm3.Caption:=FloatToStr(mylistreport[imaxreport].multiplyer);
            end;
        3 : begin
               lblnum4.Caption:='4.';
               lblname4.Caption:=mylistreport[imaxreport].reportname;
               lblm4.Caption:=FloatToStr(mylistreport[imaxreport].multiplyer);
            end;
        4 : begin
               lblnum5.Caption:='5.';
               lblname5.Caption:=mylistreport[imaxreport].reportname;
               lblm5.Caption:=FloatToStr(mylistreport[imaxreport].multiplyer);
            end;
      end;
   end;
end;

// удаляет отчёт.
procedure TFormDefineTrials.btndeletereportClick(Sender: TObject);
begin
   if (imaxreport>=0) then
   begin
      mylistreport[imaxreport].bactive:=False;

      case imaxreport of
        0 : begin
               lblnum1.Caption:='';
               lblname1.Caption:='';
               lblm1.Caption:='';
            end;
        1 : begin
               lblnum2.Caption:='';
               lblname2.Caption:='';
               lblm2.Caption:='';
            end;
        2 : begin
               lblnum3.Caption:='';
               lblname3.Caption:='';
               lblm3.Caption:='';
            end;
        3 : begin
               lblnum4.Caption:='';
               lblname4.Caption:='';
               lblm4.Caption:='';
            end;
        4 : begin
               lblnum5.Caption:='';
               lblname5.Caption:='';
               lblm5.Caption:='';
            end;
      end;
      Dec(imaxreport);
   end;
end;

end.
