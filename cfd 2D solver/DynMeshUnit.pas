unit DynMeshUnit;
// простейшая динамическая сетка


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Unitdeclar;





type
    // Декларация типов теперь содержится в модуле UnitDeclar
     //Float = Real;
       //Float = Extended;

  TDynMeshForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Ejde: TEdit;
    Ejds: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Ejupend: TEdit;
    Ejupstart: TEdit;
    Binput: TButton;
    Label5: TLabel;
    Panel2: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    EAmplityde: TEdit;
    EFreq: TEdit;
    BDrawMesh: TButton;
    Ljupend: TLabel;
    Ljupst: TLabel;
    Ljdend: TLabel;
    Ljdstart: TLabel;
    GroupBox4: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    ECount: TEdit;
    Label12: TLabel;
    Label11: TLabel;
    EcountT: TEdit;
    BAnimate: TButton;
    Button1: TButton;
    GroupBox5: TGroupBox;
    ComboBox1: TComboBox;
    Label8: TLabel;
    Bmemory: TButton;
    BDraw: TButton;
    BClose: TButton;
    GroupBox6: TGroupBox;
    PaintBox1: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure BinputClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BDrawMeshClick(Sender: TObject);
    procedure BAnimateClick(Sender: TObject);
    procedure DMFormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BmemoryClick(Sender: TObject);
    procedure BDrawClick(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
  private
    { Private declarations }
    // были ли загружены значения
    // параметров деформируемых слоёв
    bdouwnload : Boolean;
    // что прорисовывать
    iwhotvisibledm : Integer;
    // глобальное время не должно изменяться при анимации
    FlowTimeAnimatememory : Float;

  public
    { Public declarations }
    // позиция блока
    rblockpos : Float;
    // верхний контактирующий блок в методе Бриджмена
    rblockpositionBridgmen : Float;
     // очистка фона белым
    procedure myDMfonclean;
    // процедура прорисовки геометрии
    procedure myDMdrawgeom;
    // процедура прорисовки сетки
    procedure myDMdrawmesh;
    // подсветка выбранных границ
    // уникальные номера подсвечиваемых границ указаны в целочисленном массиве
    procedure myDMdrawboundary(idesck : Integer);
  end;

var
  DynMeshForm: TDynMeshForm;

implementation

uses MainUnit, GridGenUnit, Math;  // использует главный модуль


{$R *.dfm}

// очистка фона белым
procedure TDynMeshForm.myDMfonclean;
var
   w,h : Integer; // ширина и высота области в пикселах
begin
   // очистка фона белым
   with PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
      Canvas.Brush.Color:=clWhite;
      Canvas.Rectangle(0,0,w,h);
   end; // with  GridGenForm.PaintBox1
end; // очистка фона белым

// процедура прорисовки геометрии
procedure TDynMeshForm.myDMdrawgeom;
const ih = 453;
var
    w,h,irh : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Float; // масштабирующий коэффициент
    i : Integer; // счётчик

begin
   // определение высоты и ширины расчётной
   // области в пикселах
   with PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    Width:= 520 + 2*ibort + round(Form1.dLx*m);
    irh:= 76 + 2*ibort + round(Form1.dLy*m);
    Height:=max(ih,irh);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    myDMfonclean; // очистка фона
    with GridGenForm do
    begin
       pxs:=ibort;
       pxe:=ibort + round((bricklist[0].xS + bricklist[0].xL)*m);
       pys:=h - ibort;
       pye:=h - (ibort + round((bricklist[0].yS + bricklist[0].yL)*m));
    end;
    PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    for i:=1 to (GridGenForm.maxbrickelem-1) do
    begin
        with GridGenForm do
        begin
           pxs:=ibort + round(bricklist[i].xS*m);
           pxe:=ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
           pys:=h -(ibort + round(bricklist[i].yS*m));
           pye:=h -(ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
        end; // with
         PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;
end; // прорисовка геометрии

// прорисовка геометрии
procedure TDynMeshForm.Button1Click(Sender: TObject);
begin
    iwhotvisibledm:=0; // запоминаем что прорисовывать
    DMFormPaint(Sender);
end;

// считывание вибрационнных параметров
procedure TDynMeshForm.BinputClick(Sender: TObject);
var
   dist1, dist2 : Float; // для проверки правильности определения амплитуды.
   ibuf : Integer;
   ir : Integer;
   r : Double;
begin
   try
     with Form1.actiVibr do
     begin
         bOn:=false; // ещё надо указать вибрирующий объект
         bOn2:=false; // вибрирующий объект ещё не определён
         if (length(Ejds.Text)>0) then
         begin
            if (not TryStrToInt(Ejds.Text,ir)) then
            begin
               jdstart:=0;
            end
            else
            begin
               jdstart:=StrToInt(Ejds.Text);
            end;
         end
          else
         begin
            jdstart:=0;
         end;
         if (length(Ejde.Text)>0) then
         begin
            if (not TryStrToInt(Ejde.Text,ir)) then
            begin
               jdend:=0;
            end
             else
            begin
               jdend:=StrToInt(Ejde.Text);
            end;
         end
          else
         begin
            jdend:=0;
         end;
         if (length(Ejupstart.Text)>0) then
         begin
             if (not TryStrToInt(Ejupstart.Text,ir)) then
            begin
               jupstart:=Form1.iny+1;
            end
            else
            begin
               jupstart:=StrToInt(Ejupstart.Text);
            end;
         end
          else
         begin
            jupstart:=Form1.iny+1;
         end;
         if (length(Ejupend.Text)>0) then
         begin
            if (not TryStrToInt(Ejupend.Text,ir)) then
            begin
               jupend:=Form1.iny+1;
            end
             else
            begin
               jupend:=StrToInt(Ejupend.Text);
            end;
         end
          else
         begin
            jupend:=Form1.iny+1;
         end;
         if (jupend>Form1.iny) then
         begin
            MessageBox(0,'warning ! jupend > iny-1','warning', MB_OK);
            jupend:=Form1.iny-round(0.125*Form1.iny);
            Ejupend.Text:=IntToStr(jupend);
         end;
         if (jupstart>Form1.iny) then
         begin
            MessageBox(0,'warning ! jupstart > iny-1','warning', MB_OK);
            jupstart:=Form1.iny-round(0.375*Form1.iny);
            Ejupstart.Text:=IntToStr(jupstart);
         end;
         if (jdend<1) then
         begin
            MessageBox(0,'warning ! jdend < 1','warning', MB_OK);
            jdend:=round(0.375*Form1.iny);
            Ejde.Text:=IntToStr(jdend);
         end;
         if (jdstart<1) then
         begin
            MessageBox(0,'warning ! jdstart < 1','warning', MB_OK);
            jdstart:=round(0.125*Form1.iny);
            Ejds.Text:=IntToStr(jdstart);
         end;

         dist1:=Form1.ypos[jdend]-Form1.ypos[jdstart];
         if (dist1<0.0) then
         begin
            MessageBox(0,'warning ! jdend < jdstart','warning', MB_OK);
            ibuf:=jdend;
            jdend:=jdstart;
            jdstart:=ibuf;
            Ejde.Text:=IntToStr(jdend);
            Ejds.Text:=IntToStr(jdstart);
            dist1:=-dist1;
         end;

         dist2:=Form1.ypos[jupend]-Form1.ypos[jupstart];
         if (dist2<0.0) then
         begin
            MessageBox(0,'warning ! jupend < jupstart','warning', MB_OK);
            ibuf:=jdend;
            jdend:=jdstart;
            jdstart:=ibuf;
            Ejupend.Text:=IntToStr(jupend);
            Ejupstart.Text:=IntToStr(jupstart);
            dist2:=-dist2;
         end;

         if (dist2<dist1) then
         begin
            dist1:=dist2;
         end;

         if (length(EAmplityde.Text)>0) then
         begin
            if (not TryStrToFloat(EAmplityde.Text,r)) then
            begin
               Amplitude:=0.25*dist1;
               EAmplityde.Text:=FloatToStr(Amplitude);
               ShowMessage('warning : Amplitude change.');
            end
            else
            begin
               Amplitude:=StrToFloat(EAmplityde.Text);
            end;
         end
         else
         begin
            Amplitude:=0.25*dist1;
            EAmplityde.Text:=FloatToStr(Amplitude);
         end;
         // проверка амплитуды:
         // Амплитуда должна быть меньше чем толщины прослоек.
         if (0.8*dist1<Amplitude) then
         begin
            Amplitude:=0.8*dist1;
            MessageBox(0,'warning ! Amplitude > 80% dist','warning', MB_OK);
            EAmplityde.Text:=FloatToStr(Amplitude);
         end;

         if (length(EFreq.Text)>0) then
         begin
            Frequency:=StrToFloat(EFreq.Text);
         end
          else
         begin
             Frequency:=20.0; // 20 Гц.
             EFreq.Text:=FloatToStr(Frequency);
         end;
     end; // with
     bdouwnload:=true;
   except
      bdouwnload:=false;
      MessageBox(0,'параметры введены неправильно','Ошибка',  MB_OK);
   end;
   if (bdouwnload) then
   begin
      iwhotvisibledm:=1; // запоминаем что прорисовывать
      DMFormPaint(Sender);
   end;
end;


// изменение размеров формы
procedure TDynMeshForm.FormResize(Sender: TObject);
begin
    // Изменение размеров формы
   PaintBox1.Width:=Width - 520;
   PaintBox1.Height:=Height - 76;
end;

// процедура прорисовки сетки
procedure TDynMeshForm.myDMdrawmesh;
const
     ih = 453; // высота
var
    w,h,irh : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Float; // масштабирующий коэффициент
    i,j : Integer; // счётчик

begin
   // определение высоты и ширины расчётной
   // области в пикселах
   with PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    if ((abs(Form1.dLy)<1.0e-20) or (abs(Form1.dLx)<1.0e-20)) then
    begin
       m:=0.0;
    end
    else
    begin
       m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент
    end;

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    Width:= 520 + 2*ibort + round(Form1.dLx*m);
    irh:= 76 + 2*ibort + round(Form1.dLy*m);
    Height:= max(ih,irh);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

     myDMfonclean; // очистка фона
    // прорисовка узлов сетки

    PaintBox1.Canvas.Pen.Color:=clGreen;
    with Form1 do
     begin
       for i:=1 to inx do
       begin
            // вертикальные линии сетки
            PaintBox1.Canvas.MoveTo(ibort+round(xpos[i]*m),h-ibort);
            PaintBox1.Canvas.LineTo(ibort+round(xpos[i]*m),h-(ibort+round(dLy*m)));
       end;
       for j:=1 to iny do
       begin
           if (bdouwnload and (j <= actiVibr.jdend) and (j >= actiVibr.jdstart)) then
           begin
              PaintBox1.Canvas.Pen.Color:=clRed;
           end
            else if (bdouwnload and (j <= actiVibr.jupend) and (j >= actiVibr.jupstart)) then
           begin
              PaintBox1.Canvas.Pen.Color:=clRed;
           end
            else
           begin
              PaintBox1.Canvas.Pen.Color:=clGreen;
           end;

           // горизонтальные линии сетки
           PaintBox1.Canvas.MoveTo(ibort,h-(ibort+round(ypos[j]*m)));
           PaintBox1.Canvas.LineTo(ibort+round(dLx*m),h-(ibort+round(ypos[j]*m)));
       end;
    end; // with Form1


    if ((Form1.inx<>0)and(Form1.iny<>0)) then
    begin
       // Если приложение ещё не завершено.

    // учёт расположения hollow block
    for i:=1 to (GridGenForm.maxbrickelem-1) do
    begin
         with GridGenForm do
         begin
            pxs:= ibort + round(bricklist[i].xS*m);
            pxe:= ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
            pys:= h - (ibort + round(bricklist[i].yS*m));
            pye:= h - (ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
         end; // with
         PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;
    end;

    PaintBox1.Canvas.Pen.Color:=clBlack; // возвращаем цвет пера на чёрный
end; // прорисовка сетки

// прорисовывает сетку
procedure TDynMeshForm.BDrawMeshClick(Sender: TObject);
begin
   iwhotvisibledm:=1; // запоминаем что прорисовывать
   DMFormPaint(Sender);
end;

// анимация перестроения сетки
// запускается только в том случае если все параметры  уже заданы
procedure TDynMeshForm.BAnimateClick(Sender: TObject);
var
    deltat : Float;
    icount1, icount2 : Integer;
    i : Integer; // счётчик

begin
   // Анимация перестроения сетки
   // Всё это работает если только все значения введены правильно

       if ((bdouwnload) and (Form1.actiVibr.bOn)) then
       begin
          // не забываем выделять память для вертикальной скорости, т.к. мы её будем апдейтить
          // в функци Form1.mymovingmesh; главной формы.
          SetLength(Form1.Vy,Form1.inx*(Form1.iny-1)+1); // Vy на смещённой по оси y сетке

          // запоминаем текущее глобальное время
          FlowTimeAnimatememory:=Form1.realFlowTime;
          SetLength(Form1.yposfix,Form1.iny+1); // выделение памяти под текущубю сетку
          // запоминаем текущую сетку
          Form1.yposfix[0]:=Form1.ypos[0];
          for i:=1 to Form1.iny do
          begin
             Form1.yposfix[i]:=Form1.ypos[i];
          end;
          // запоминаем стартовую координату подвижного блока.
          rblockpos:=GridGenForm.bricklist[Form1.actiVibr.unickbricknum].yS;
          if (Form1.actiVibr.bBridshmen) then
          begin
             rblockpositionBridgmen:=GridGenForm.bricklist[Form1.actiVibr.uniccontacktupbricknum].yS;
          end;
          icount1:=StrToInt(ECount.Text); // число шагов за период
          Form1.realFlowTime:=0.0;
          deltat:=1/(Form1.actiVibr.Frequency*icount1); // шаг по времени
          icount2:=StrToInt(EcountT.Text); // продолжительность - число периодов.
          // Анимация :
          for i:=0 to (icount1*icount2) do
          begin
             iwhotvisibledm:=1;
             DynMeshForm.DMFormPaint(Sender); // прорисовка подвижной сетки
             Sleep(100); // пауза
             Form1.realFlowTime:=Form1.realFlowTime+deltat;
             Form1.mymovingmesh;
          end;

          iwhotvisibledm:=1;
          DynMeshForm.DMFormPaint(Sender); // прорисовка подвижной сетки
          // откат назад сохранение исходной сетки
          // сохранение исходной сетки после анимации.
          for i:=1 to Form1.iny do
          begin
             Form1.ypos[i]:=Form1.yposfix[i];
          end;
          // возвращение подвижного блока в исходную позицию.
          GridGenForm.bricklist[Form1.actiVibr.unickbricknum].yS:=rblockpos;
          if (Form1.actiVibr.bBridshmen) then
          begin
             GridGenForm.bricklist[Form1.actiVibr.uniccontacktupbricknum].yS:=rblockpositionBridgmen;
             GridGenForm.bricklist[Form1.actiVibr.uniccontacktupbricknum].yL:=Form1.dLy-rblockpositionBridgmen;
          end;
          // возвращение глобального времени в начало.
          Form1.realFlowTime:=FlowTimeAnimatememory;
          MessageBox(0,'после анимации движения сетки исходная сетка не портиться.','сообщение о сетке',MB_OK);
       end
        else
       begin
          MessageBox(0,'Вы должны осуществить ввод всех параметров','ошибка ввода',MB_OK);
       end;
end; // анимация перестройки сетки.

procedure TDynMeshForm.DMFormPaint(Sender: TObject);
begin
   case iwhotvisibledm of
    0 : // прорисовка геометрии
      begin
         myDMfonclean;
         myDMdrawgeom;
      end;
    1 : // прорисовка сетки
      begin
         myDMfonclean;
         myDMdrawmesh;
      end;
    end; // case
    with Form1.actiVibr do
    begin
       if (bOn2) then
       begin
          myDMdrawboundary(unicalidentifire); // прорисовка подвижной границы
       end;
    end;
end;

procedure TDynMeshForm.FormCreate(Sender: TObject);
begin
   iwhotvisibledm:=0; // прорисовка геометрии по умолчанию
end;

// выбор вибрирующей границы
procedure TDynMeshForm.BmemoryClick(Sender: TObject);
const
    epsilon = 1e-15; // точность определения подвижного блока
var
    fxS, fyS, fxE, fyE, fxL, fyL : Float; // параметры по которым можно найти блок
    k : Integer;
    iedgeselect : Integer;
    str : String;
    //pstr  : PChar; // указатель на строку

function fabs( r : Float) : Float;
begin
   if (r<0.0) then
   begin
      fabs:=-r;
   end
    else
   begin
      fabs:=r;
   end;
end;

begin
    // инициализация
     fxS:=0.0; fyS:=0.0; fxE:=0.0; fyE:=0.0;
    // запоминаем уникальный идентификатор вибрирующей границы
    with Form1 do
    begin
       iedgeselect:=ComboBox1.ItemIndex+1;
       actiVibr.unicalidentifire:=GridGenForm.edgelist[iedgeselect].idescriptor;
       actiVibr.bOn2:=true;
       DMFormPaint(Sender); // именно процедура DynamicMesh формы. См префикс DM.
       for k:=1 to  imaxnumbernode do
       begin
           if (mapPT[k].itype = 2) then
           begin // граничная точка
              if (mapPT[k].iboundary = actiVibr.unicalidentifire) then
              begin // с подходящим идентификатором
                 case mapPT[k].iugol of
                   1 : begin
                          // левый нижний угол
                          fxS:=xpos[mapPT[k].i];
                          fyS:=ypos[mapPT[k].j];
                       end;
                   4 : begin
                          // верхний правый угол
                          fxE:=xpos[mapPT[k].i];
                          fyE:=ypos[mapPT[k].j];
                       end;
                  end; // case
              end;
           end;
        end;
    end; // with
    // нужно определить автоматом блок
    // который приводится в движение
    fxL:=fxE-fxS; fyL:=fyE-fyS; // ширина и высота этого блока
    with GridGenForm do
    begin
       for k:=1 to (maxbrickelem-1) do
       begin
          if ((fabs(bricklist[k].xS-fxS)<epsilon) and (fabs(bricklist[k].yS-fyS)<epsilon) and
              (fabs(bricklist[k].xL-fxL)<epsilon) and (fabs(bricklist[k].yL-fyL)<epsilon)) then
              begin
                 // запоминаем номер k.
                 Form1.actiVibr.unickbricknum:=k;
                 Form1.actiVibr.bOn:=true;
              end;
       end;
    end; // with
    // в позиции fyE могут находится ещё две yS`тарт  узловые точки
    Form1.actiVibr.bBridshmen:=false;
    // Это случай Бриджмена.
    with GridGenForm do
    begin
       for k:=1 to (maxbrickelem-1) do
       begin
          if ((fabs(bricklist[k].yS-fyE)<epsilon) and
          (bricklist[k].xS>fxS) and
          ((bricklist[k].xS+bricklist[k].xL)<fxE)) then
           begin
              // запоминаем номер k.
              Form1.actiVibr.uniccontacktupbricknum:=k;
              Form1.actiVibr.bBridshmen:=true;
           end;
       end;
    end; // with
    if (Form1.actiVibr.bOn) then
    begin
       // устанавливаем нестационарный решатель
       Form1.btimedepend:=true;
       MessageBox(0,'решатель переведён на нестационарный','операция',MB_OK);
       str:='вибрирующий блок '+IntToStr(Form1.actiVibr.unickbricknum);
       str:=str+' распознан';
       //pstr:=PChar(str);
       MessageBox(0,PChar('операция'),PChar(str),MB_OK);
       if (Form1.actiVibr.bBridshmen) then
       begin
          str:='добавочный блок ' + IntToStr(Form1.actiVibr.uniccontacktupbricknum);
          str:=str + ' в методе Бриджмена распознан';
          //pstr:=PChar(str);
          MessageBox(0,PChar('операция'),PChar(str),MB_OK);
       end;
    end;
end;

// подсветка выбранных границ
// уникальные номера подсвечиваемых границ указаны в целочисленном массиве
procedure TDynMeshForm.myDMdrawboundary( idesck : Integer);
const
      ih = 453; // высота
var
    w,h : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Float; // масштабирующий коэффициент
    i,j,ihr : Integer; // счётчики

begin
   // Этот метод отмечает выделенные границы.
   // его надо вызывать после метода drawgeom.

   // определение высоты и ширины расчётной
   // области в пикселах
   with PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    Width:= 520 + 2*ibort + round(Form1.dLx*m);
    ihr:= 76 + 2*ibort + round(Form1.dLy*m);
    Height:=max(ih,ihr);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with DynMeshForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    PaintBox1.Canvas.Brush.Color:=clRed;
     with Form1 do
     begin
       for i:=1 to inx do
       begin
          for j:=1 to iny do
          begin
             if (mapPT[i + (j-1)*inx].itype=2) then
             begin
                // это граничная точка с уникальным идентификатором
                // границы.
                if (mapPT[i + (j-1)*inx].iboundary = idesck) then
                begin
                   // xpos[i], ypos[j] - вещественные координаты граничного узла.
                   pxs:= ibort + round(m*xpos[i]) - 5;
                   pxe:= ibort + round(m*xpos[i]) + 5;
                   pys:= h - (ibort + round(m*ypos[j]) - 5);
                   pye:= h - (ibort + round(m*ypos[j]) + 5);
                   PaintBox1.Canvas.Ellipse(pxs,pys,pxe,pye);
                end;
             end;
          end;
       end;
     end; // with
    PaintBox1.Canvas.Brush.Color:=clWhite; // возвращаем цвет кисти на белый
end;

procedure TDynMeshForm.BDrawClick(Sender: TObject);
var
   iselectboundary : Integer; // выделенная граница
   iunicdisk : Integer; // уникальный дискриптор выделенной границы
begin
   iselectboundary:=ComboBox1.ItemIndex+1; // нумерация начинается с 1
   iunicdisk:=GridGenForm.edgelist[iselectboundary].idescriptor;
   myDMdrawboundary(iunicdisk);
end;

// закрывает форму
procedure TDynMeshForm.BCloseClick(Sender: TObject);
begin
    Close;
end;

end.
