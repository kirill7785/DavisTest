﻿unit BonConRedoUnit;
// Простейший редактор границ расчётной области:
// Объединение границ и переименование границ.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst;

type
  TBonConRedoForm = class(TForm)
    GroupBox1: TGroupBox;
    CheckListBoxBoundaryCondition: TCheckListBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    RenameButton: TButton;
    Label4: TLabel;
    UnitBoundaryButton: TButton;
    Label5: TLabel;
    Label6: TLabel;
    EUvalue: TEdit;
    Label7: TLabel;
    Button2: TButton;
    procedure MyDraw;
    procedure Button1Click(Sender: TObject);
    procedure UnitBoundaryButtonClick(Sender: TObject);
    procedure RenameButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckListBoxBoundaryConditionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }
    ibonunicalnumberfordisplay : array of Integer; // массив номеров выделенных границ
    ibclength : Integer; // размер массива  границ

  end;

var
  BonConRedoForm: TBonConRedoForm;

implementation
uses
     GridGenUnit, MainUnit, Math;

{$R *.dfm}

procedure TBonConRedoForm.MyDraw;
var
    i,j : Integer; // счётчики

begin
   j:=0; // пока массив ibon пустой
   // нарисовать выделенные границы
   for i:=0 to CheckListBoxBoundaryCondition.Items.Count-1 do
   begin
      if (CheckListBoxBoundaryCondition.Checked[i]) then inc(j);
   end;
   if (j>0) then
   begin
      // какие-то элементы списка выделены
      ibclength:=j;
      SetLength(ibonunicalnumberfordisplay,ibclength);
      j:=0;
      for i:=0 to CheckListBoxBoundaryCondition.Items.Count-1 do
      begin
         if (CheckListBoxBoundaryCondition.Checked[i]) then
         begin
             // GridGenForm.edgelist[i+1].idescriptor - уникальный идентификатор выделенной границы
            ibonunicalnumberfordisplay[j]:=GridGenForm.edgelist[i+1].idescriptor;
            inc(j);
         end;
      end;
   end;
   GridGenForm.iwhotvisible:=2;
   GridGenForm.drawgeom; // нарисуем геометрию
   GridGenForm.drawboundary(ibonunicalnumberfordisplay,j); // нарисуем выделенную границу
end;

// Визуализирует выделенные границы.
procedure TBonConRedoForm.Button1Click(Sender: TObject);
begin
   MyDraw;
end;

// объединение нескольких выделенных границ в одну.
// При объединении границ временно формируется ещё один список границ
// в который входят только границы которые не подлежат объединению,
// а также одна граница вместо объединяемых границ в списке.
procedure TBonConRedoForm.UnitBoundaryButtonClick(Sender: TObject);
var
   i,j : Integer; // счётчики
   icol : Integer; // количество выделенных границ
   unicalnumberboundary : Integer; // уникальный номер границы
   k : Integer; // счётчик
   edgelistbuf : array of boundaryedge; // для переформирования списка границ при объединении некоторых границ
   bflag, bfirstpushflag : Boolean; // флаг для переформирования границ
   // проверяющий участок кода для отладки.
   //f : TStrings; // для отладки заполнения формируемых матриц
   //str : String; // для формирования отладочной информации

begin
   // Объединение выделенных границ.
   // Алгоритм.
   // шаг 1. проверить какие границы выделены, попутно
   // формирую список выделенных границ.
   // шаг 2. Всем граничным точкам на выделенных границах
   // присвоить идентификатор первой выделеной границы в списке,
   // а всем выделенным границам после первой присвоить имя первой выделенной границы.
   // шаг 3. Отразить изменения в интерфейсной части.

   icol:=0; // пока массив ibon пустой
   // определяем сколько границ выделено
   for i:=0 to CheckListBoxBoundaryCondition.Items.Count-1 do
   begin
      if (CheckListBoxBoundaryCondition.Checked[i]) then inc(icol);
   end;
   if (icol > 0) then
   begin
      // какие-то элементы списка выделены
      ibclength:=icol;
      // формируем новый список уникальных границ.
      SetLength(ibonunicalnumberfordisplay,ibclength);
      j:=0;
      // цикл по всем границам в списке границ
      for i:=0 to (CheckListBoxBoundaryCondition.Items.Count-1) do
      begin
         // если граница выделена
         if (CheckListBoxBoundaryCondition.Checked[i]) then
         begin
             // GridGenForm.edgelist[i+1].idescriptor - уникальный идентификатор выделенной границы.
             // GridGenForm.edgelist[i+1] - список границ у каждой из которых свой уникальный идентификатор.
             // В этом массиве в порядке очерёдности i перечислены уникальные идентификаторы  границ.
             // ibonunicalnumberfordisplay[j] - глобальный массив к котором хранятся уникальные
             // идентификаторы выделенных границ.
            ibonunicalnumberfordisplay[j]:=GridGenForm.edgelist[i+1].idescriptor;
            inc(j);
         end;
      end;
      // уникальный номер первой границы из списка выделенных границ.
      unicalnumberboundary:=ibonunicalnumberfordisplay[0];
      ibclength:=j; // количество выделенных границ. Это же равно icol.
      // идентификаторы j выделенных границ определены
      // после объединения границ всего станет (inumboundary - icol + 1).
      // Проход по всем узловым точкам расчётной области для
      // присваивания нужных уникальных номеров границ.
      for i:=1 to Form1.inx do
      begin
         for j:=1 to Form1.iny do
         begin
            // если узел граничный
            // идентификатор граничного узла равен 2.
            if (GridGenForm.tnm[i + (j-1)*Form1.inx].itypenode = 2) then
            begin
               // если уникальный номер данной границы
               // находится в списке ibonunicalnumberfordisplay
               // значит номер данной границы надо заменить на unicalnumberboundary.
               for k:=0 to  (ibclength-1) do
               begin
                  if (GridGenForm.tnm[i + (j-1)*Form1.inx].ibondary = ibonunicalnumberfordisplay[k]) then
                  begin
                     GridGenForm.tnm[i + (j-1)*Form1.inx].ibondary:=unicalnumberboundary;
                  end;
               end;
            end;
         end;
      end;

      // отображение изменений на структуре mynodesequence
      for i:=1 to Form1.inx do
      begin
         for k:=1 to Form1.iny do
         begin
            // занесение информации только о объединённых границ
            Form1.mapPT[i + (k-1)*Form1.inx].iboundary:=GridGenForm.tnm[i + (k-1)*Form1.inx].ibondary; // номер границы
         end;
      end;

      // для горизонтальной скорости
      for i:=1 to (Form1.inx-1) do
      begin
         for j:=1 to Form1.iny do
         begin
            for k:=0 to  (ibclength-1) do
            begin
               if (Form1.mapVx[i + (j-1)*(Form1.inx-1)].iboundary = ibonunicalnumberfordisplay[k]) then
               begin
                  Form1.mapVx[i + (j-1)*(Form1.inx-1)].iboundary:=unicalnumberboundary;
               end;
            end;
         end;
      end;

      // для вертикальной скорости
      for i:=1 to Form1.inx do
      begin
         for j:=1 to (Form1.iny-1) do
         begin
            for k:=0 to  (ibclength-1) do
            begin
               if (Form1.mapVy[i + (j-1)*Form1.inx].iboundary = ibonunicalnumberfordisplay[k]) then
               begin
                  Form1.mapVy[i + (j-1)*Form1.inx].iboundary:=unicalnumberboundary;
               end;
            end;
         end;
      end;

      SetLength(edgelistbuf, GridGenForm.inumboundary - icol + 1 +1); // нумерация начинается с 1
      // проход по всем границам. При этом
      bfirstpushflag:=false;
      k:=1; // счётчик добавляемых границ
      // Цикл по всем границам в списке
      for i:=1 to GridGenForm.inumboundary do
      begin
         bflag:=false; // найдена ли граница в списке границ
         // проверка условия:
         // принадлежит ли граница списку объединяемых границ.
         for j:=0 to (ibclength-1) do
         begin
             if (GridGenForm.edgelist[i].idescriptor = ibonunicalnumberfordisplay[j]) then
            begin
               // граница обнаружена в списке границ подлежащих объединению
               bflag:=true;
            end;
         end;
          if (not(bflag)) then
         begin
            // граница не найдена в списке объединяемых границ
            edgelistbuf[k].boundaryname:=GridGenForm.edgelist[i].boundaryname;
            edgelistbuf[k].idescriptor:=GridGenForm.edgelist[i].idescriptor;
            // копирование граничных условий.
            edgelistbuf[k].temperatureclan:=GridGenForm.edgelist[i].temperatureclan;
            edgelistbuf[k].temperaturecondition:=GridGenForm.edgelist[i].temperaturecondition;
            edgelistbuf[k].Vx:=GridGenForm.edgelist[i].Vx;
            edgelistbuf[k].Vy:=GridGenForm.edgelist[i].Vy;
            edgelistbuf[k].bsimmetry:=GridGenForm.edgelist[i].bsimmetry;
            edgelistbuf[k].bpressure:=GridGenForm.edgelist[i].bpressure;
            edgelistbuf[k].rpressure:=GridGenForm.edgelist[i].rpressure;
            edgelistbuf[k].uds1clan:=GridGenForm.edgelist[i].uds1clan;
            edgelistbuf[k].uds2clan:=GridGenForm.edgelist[i].uds2clan;
            edgelistbuf[k].uds3clan:=GridGenForm.edgelist[i].uds3clan;
            edgelistbuf[k].uds4clan:=GridGenForm.edgelist[i].uds4clan;
            edgelistbuf[k].uds1condition:=GridGenForm.edgelist[i].uds1condition;
            edgelistbuf[k].uds2condition:=GridGenForm.edgelist[i].uds2condition;
            edgelistbuf[k].uds3condition:=GridGenForm.edgelist[i].uds3condition;
            edgelistbuf[k].uds4condition:=GridGenForm.edgelist[i].uds4condition;
            edgelistbuf[k].rSFval:=GridGenForm.edgelist[i].rSFval;
            edgelistbuf[k].chSFval:=GridGenForm.edgelist[i].chSFval;
            inc(k);
         end
          else
         begin
            // граница найдена в списке объединяемых границ.
             if (not (bfirstpushflag)) then
            begin
               // граница найдена первый раз
               // в списке границ подлежащих объединению.
               edgelistbuf[k].boundaryname:=GridGenForm.edgelist[i].boundaryname;
               edgelistbuf[k].idescriptor:=unicalnumberboundary;
               // копирование граничных условий
               edgelistbuf[k].temperatureclan:=GridGenForm.edgelist[i].temperatureclan;
               edgelistbuf[k].temperaturecondition:=GridGenForm.edgelist[i].temperaturecondition;
               edgelistbuf[k].Vx:=GridGenForm.edgelist[i].Vx;
               edgelistbuf[k].Vy:=GridGenForm.edgelist[i].Vy;
               edgelistbuf[k].bsimmetry:=GridGenForm.edgelist[i].bsimmetry;
               edgelistbuf[k].bpressure:=GridGenForm.edgelist[i].bpressure;
               edgelistbuf[k].rpressure:=GridGenForm.edgelist[i].rpressure;
               edgelistbuf[k].uds1clan:=GridGenForm.edgelist[i].uds1clan;
               edgelistbuf[k].uds2clan:=GridGenForm.edgelist[i].uds2clan;
               edgelistbuf[k].uds3clan:=GridGenForm.edgelist[i].uds3clan;
               edgelistbuf[k].uds4clan:=GridGenForm.edgelist[i].uds4clan;
               edgelistbuf[k].uds1condition:=GridGenForm.edgelist[i].uds1condition;
               edgelistbuf[k].uds2condition:=GridGenForm.edgelist[i].uds2condition;
               edgelistbuf[k].uds3condition:=GridGenForm.edgelist[i].uds3condition;
               edgelistbuf[k].uds4condition:=GridGenForm.edgelist[i].uds4condition;
               edgelistbuf[k].rSFval:=GridGenForm.edgelist[i].rSFval;
               edgelistbuf[k].chSFval:=GridGenForm.edgelist[i].chSFval;
               inc(k);
               bfirstpushflag:=true; // граница уже обнаружена
            end;
         end;
      end;

      GridGenForm.inumboundary:= GridGenForm.inumboundary - icol + 1; // обновляем количество границ.
      SetLength(GridGenForm.edgelist, GridGenForm.inumboundary + 1); // снова выделяем нужное количество памяти
      CheckListBoxBoundaryCondition.Clear; // очистка списка границ для реакции интерфейса пользователя.
      for i:=1 to GridGenForm.inumboundary do
      begin
         GridGenForm.edgelist[i].boundaryname:= edgelistbuf[i].boundaryname;
         GridGenForm.edgelist[i].idescriptor:= edgelistbuf[i].idescriptor;
         // копирование граничных условий для границы.
         GridGenForm.edgelist[i].temperatureclan:= edgelistbuf[i].temperatureclan;
         GridGenForm.edgelist[i].temperaturecondition:= edgelistbuf[i].temperaturecondition;
         GridGenForm.edgelist[i].Vx:= edgelistbuf[i].Vx;
         GridGenForm.edgelist[i].Vy:= edgelistbuf[i].Vy;
         GridGenForm.edgelist[i].bsimmetry:= edgelistbuf[i].bsimmetry;
         GridGenForm.edgelist[i].bpressure:= edgelistbuf[i].bpressure;
         GridGenForm.edgelist[i].rpressure:= edgelistbuf[i].rpressure;
         GridGenForm.edgelist[i].chSFval:=edgelistbuf[i].chSFval;
         GridGenForm.edgelist[i].rSFval:=edgelistbuf[i].rSFval;
         GridGenForm.edgelist[i].uds1clan:=edgelistbuf[i].uds1clan;
         GridGenForm.edgelist[i].uds2clan:=edgelistbuf[i].uds2clan;
         GridGenForm.edgelist[i].uds3clan:=edgelistbuf[i].uds3clan;
         GridGenForm.edgelist[i].uds4clan:=edgelistbuf[i].uds4clan;
         GridGenForm.edgelist[i].uds1condition:=edgelistbuf[i].uds1condition;
         GridGenForm.edgelist[i].uds2condition:=edgelistbuf[i].uds2condition;
         GridGenForm.edgelist[i].uds3condition:=edgelistbuf[i].uds3condition;
         GridGenForm.edgelist[i].uds4condition:=edgelistbuf[i].uds4condition;
         // теперь отображаем изменения в интерфейсе пользователя
         CheckListBoxBoundaryCondition.Items.Add(GridGenForm.edgelist[i].boundaryname);
      end;
   end;

   (*
   // проверяющий участок кода.
   // как выглядит расчётная область покрытая уникальными
   // идентификаторами границ после объединения границ
   // проверку проходит правильно.
   f:=TStringList.Create();
   for k:=1 to Form1.iny do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         if (GridGenForm.tnm[i + (k-1)*Form1.inx].ibondary<10000) then
         begin
            str:=str+IntToStr(GridGenForm.tnm[i + (k-1)*Form1.inx].ibondary) + ' ';
         end
          else
         begin
            str:=str+'0'+' ';
         end;
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug1.txt');
    // проверяющий участок кода.
    // как поисходит объединение границ
    //f:=TStringList.Create();
    str:='';
    for j:=1 to GridGenForm.inumboundary do
    begin
       str:=str+IntToStr(GridGenForm.edgelist[j].idescriptor) + ' ';
    end;
    f.Add(str);
   f.SaveToFile('debug1.txt');
   f.Free;
   *)

    // нужно вызвать процедуру прорисовки
   MyDraw;
end;

// По нажатию на кнопку будет происходить переименование выделенной границы.
procedure TBonConRedoForm.RenameButtonClick(Sender: TObject);
var
    i : Integer; // Счётчик
    CaptionStr : String;

begin
   // переименование выделенной границы
   for i:=0 to CheckListBoxBoundaryCondition.Items.Count-1 do
   begin
      if (CheckListBoxBoundaryCondition.Checked[i]) then
      begin
         CaptionStr:=CheckListBoxBoundaryCondition.Items[i]; // инициализация
         if not InputQuery('Ввод имени', 'Введите уникальное имя границы', CaptionStr)
         then exit; // срочное завершение обрабтки данного события, т.к. имя не введено

         CheckListBoxBoundaryCondition.Items[i]:=CaptionStr;
         GridGenForm.edgelist[i+1].boundaryname:=CaptionStr;
         MyDraw;
      end;
   end;

end;

// разбиение ребра на две части
procedure TBonConRedoForm.Button2Click(Sender: TObject);
var
    uval : Real;
    i,j : Integer;
    iunicalnumber, newunicalnumber : Integer; // уникальный номер границы
    imarker : Integer;
    imaxpoint : Integer; // количество узлов на разбиваемом ребре
    // корректность ввода.
    bOk : Boolean;
    r : Double;
begin
  bOk:=True;

  if (not TryStrToFloat(EUvalue.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EUvalue.Text+' is incorrect value.');
  end;

  if (bOk) then
  begin
     uval:=StrToFloat(EUvalue.Text);
     if ((uval>1.0) or (uval<0.0)) then
     begin
        bOk:=False;
        ShowMessage(EUvalue.Text+' is incorrect value.');
     end;
  end;

  if (bOk) then
  begin
     // разбивает ребро на две части
     uval:=StrToFloat(EUvalue.Text);
     if ((uval>1) or (uval<0)) then exit;
     imarker:=0; iunicalnumber:=-1; // инициализация
     for i:=0 to CheckListBoxBoundaryCondition.Items.Count-1 do
     begin
        if (CheckListBoxBoundaryCondition.Checked[i]) then
        begin
           iunicalnumber:=GridGenForm.edgelist[i+1].idescriptor;
           imarker:=i+1; // номер ребра в списке рёбер
        end;
     end;
     newunicalnumber:=1;
     imaxpoint:=0;
     for i:=1 to Form1.imaxnumbernode do
     begin
        if (Form1.mapPT[i].itype=2) then
        begin
           // строго только для граничных узлов.
           newunicalnumber:=max(newunicalnumber,Form1.mapPT[i].iboundary);
           // подсчитываем количество точек принадлежащих границе.
           if (Form1.mapPT[i].iboundary = iunicalnumber) then inc(imaxpoint);
        end;
     end;
     inc(newunicalnumber); // новая граница будет иметь дискриптор на единицу больше.
     imaxpoint:=round(imaxpoint*uval);  // количество точек на первом отрезке разделяемой границы.
     j:=1;
     for i:=1 to Form1.imaxnumbernode do
     begin
        if (Form1.mapPT[i].iboundary = iunicalnumber) then
        begin
           if (j <= imaxpoint) then
           begin
              inc(j);
           end
            else
           begin
              Form1.mapPT[i].iboundary:=newunicalnumber;
              GridGenForm.tnm[i].ibondary:=newunicalnumber;
           end;
        end;
     end;

     j:=1; // сброс счётчика узлов искомой границы на первый узел
     for i:=1 to Form1.imaxnumbernodeVx do
     begin
        if (Form1.mapVx[i].iboundary = iunicalnumber) then
        begin
           if ((Form1.mapVx[i].chnormal='S') or (Form1.mapVx[i].chnormal='N')) then
           begin
              // горизонтальная граница.
              if (j < imaxpoint) then
              begin
                 inc(j);
              end
               else
              begin
                 Form1.mapVx[i].iboundary:=newunicalnumber;
              end;
           end
            else
           begin
              // вертикальная граница.
              if (j <= imaxpoint) then
              begin
                 inc(j);
              end
               else
              begin
                 Form1.mapVx[i].iboundary:=newunicalnumber;
              end;
           end;
        end;
     end;
     j:=1; // сброс счётчика узлов искомой границы на первый узел
     for i:=1 to Form1.imaxnumbernodeVy do
     begin
        if (Form1.mapVy[i].iboundary = iunicalnumber) then
        begin
           if ((Form1.mapVy[i].chnormal='S') or (Form1.mapVy[i].chnormal='N')) then
           begin
              // горизонттальная граница
              if (j <= imaxpoint) then
              begin
                 inc(j);
              end
               else
              begin
                 Form1.mapVy[i].iboundary:=newunicalnumber;
              end;
           end
            else
           begin
              // вертикальная граница.
              if (j < imaxpoint) then
              begin
                 inc(j);
              end
               else
              begin
                 Form1.mapVy[i].iboundary:=newunicalnumber;
              end;
           end;

        end;
     end;
     inc(GridGenForm.inumboundary);
     SetLength(GridGenForm.edgelist,GridGenForm.inumboundary+1);
     j:=GridGenForm.inumboundary;
     GridGenForm.edgelist[j].boundaryname:='edge.'+IntToStr(j);
     GridGenForm.edgelist[j].idescriptor:=newunicalnumber;
     GridGenForm.edgelist[j].temperatureclan:=GridGenForm.edgelist[imarker].temperatureclan;
     GridGenForm.edgelist[j].temperaturecondition:=GridGenForm.edgelist[imarker].temperaturecondition;
     GridGenForm.edgelist[j].Vx:=GridGenForm.edgelist[imarker].Vx;
     GridGenForm.edgelist[j].Vy:=GridGenForm.edgelist[imarker].Vy;
     GridGenForm.edgelist[j].bsimmetry:=GridGenForm.edgelist[imarker].bsimmetry;
     GridGenForm.edgelist[j].boutflow:=GridGenForm.edgelist[imarker].boutflow;
     GridGenForm.edgelist[j].bpressure:=GridGenForm.edgelist[imarker].bpressure;
     GridGenForm.edgelist[j].rpressure:=GridGenForm.edgelist[imarker].rpressure;
     GridGenForm.edgelist[j].chdirect:=GridGenForm.edgelist[imarker].chdirect;
     GridGenForm.edgelist[j].rSFval:=GridGenForm.edgelist[imarker].rSFval;
     GridGenForm.edgelist[j].chSFval:=GridGenForm.edgelist[imarker].chSFval;
     GridGenForm.edgelist[j].uds1clan:=GridGenForm.edgelist[imarker].uds1clan;
     GridGenForm.edgelist[j].uds2clan:=GridGenForm.edgelist[imarker].uds2clan;
     GridGenForm.edgelist[j].uds3clan:=GridGenForm.edgelist[imarker].uds3clan;
     GridGenForm.edgelist[j].uds4clan:=GridGenForm.edgelist[imarker].uds4clan;
     GridGenForm.edgelist[j].uds1condition:=GridGenForm.edgelist[imarker].uds1condition;
     GridGenForm.edgelist[j].uds2condition:=GridGenForm.edgelist[imarker].uds2condition;
     GridGenForm.edgelist[j].uds3condition:=GridGenForm.edgelist[imarker].uds3condition;
     GridGenForm.edgelist[j].uds4condition:=GridGenForm.edgelist[imarker].uds4condition;
     CheckListBoxBoundaryCondition.Items.Add('edge.'+IntToStr(j));

     // нужно вызвать процедуру прорисовки
     MyDraw;
   end;
end;

procedure TBonConRedoForm.CheckListBoxBoundaryConditionClick(
  Sender: TObject);
begin
   // нужно вызвать процедуру прорисовки
   MyDraw;
end;

procedure TBonConRedoForm.FormCreate(Sender: TObject);
begin
   if (FormatSettings.DecimalSeparator='.') then
   begin
      EUvalue.Text:='0.2';
   end;
   if (FormatSettings.DecimalSeparator=',') then
   begin
      EUvalue.Text:='0,2';
   end;
end;

end.
