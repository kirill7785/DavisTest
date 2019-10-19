unit DisplayUnit;
// Модуль визуализации:
// включает в себя: прорисовку расчётной сетки, прорисовку передаваемой полевой величины,
// возможную интерполяцию (щас не работает), метод заливки (очистки фона), и метод изменения размеров окна.


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TDisplayForm = class(TForm)
    PaintBox1: TPaintBox;
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Buffer : TBitmap; // двойная буферизация против мерцания !!!
  public
    { Public declarations }
    b13 : Boolean; // показывает каким сплайном делать ресемплирование
    // переменная которая хранит что надо прорисовывать  при изменении размера окна
    iwhotvisible : Integer;

    // очистка фона белым
    procedure myfonclean;
    // рисует сетку
    procedure displaymesh;
    // показывает поле температур
    // ступенчатая функция в контрольных объёмах
    procedure displayTempreture;
    // показывает поле температур аппроксимированное сплайном
    procedure displayTempreturebicubicsplane;
    // рисует геометрию
    procedure displaygeom;

  end;

var
  DisplayForm: TDisplayForm;

implementation

uses
     MainUnit, Math,  MeshGen, GridGenUnit; (*spline2d, Ap,*)

{$R *.dfm}

// очистка фона белым
procedure TDisplayForm.myfonclean;
var
  w,h : Integer; // ширина и высота области в пикселах
begin
  // очистка фона белым
   with DisplayForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
      Canvas.Brush.Color:=clWhite;
      Canvas.Rectangle(0,0,w,h);
    end; // with  DisplayForm.PaintBox1
end;

// рисует сетку
procedure TDisplayForm.displaymesh;
var
  w,h : Integer; // ширина и высота области в пикселах
  ibort : Integer; // бортик
  m : Real; // масштабирующий коэффициент
  i,j : Integer; // счётчики
  pxs, pxe, pys, pye : Integer; // края прямоугольника.
  
begin
   // очистка фона
   myfonclean;
   // определение высоты и ширины расчётной
   // области в пикселах
   with DisplayForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    DisplayForm.Width:=38 + 2*ibort + round(Form1.dLx*m);
    DisplayForm.Height:=65 + 2*ibort + round(Form1.dLy*m);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with DisplayForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;
    DisplayForm.PaintBox1.Canvas.Pen.Color:=clGreen;
    with Form1 do
     begin
       for i:=1 to inx do
       begin
            // вертикальные линии сетки
            DisplayForm.PaintBox1.Canvas.MoveTo(ibort+round(xpos[i]*m),h-ibort);
            DisplayForm.PaintBox1.Canvas.LineTo(ibort+round(xpos[i]*m),h-(ibort+round(dLy*m)));
       end;
       for j:=1 to iny do
       begin
           // горизонтальные линии сетки
           DisplayForm.PaintBox1.Canvas.MoveTo(ibort,h-(ibort+round(ypos[j]*m)));
           DisplayForm.PaintBox1.Canvas.LineTo(ibort+round(dLx*m),h-(ibort+round(ypos[j]*m)));
       end;
    end; // with Form1

    DisplayForm.PaintBox1.Canvas.Pen.Color:=clBlack;
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
         DisplayForm.PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;

end;  // конец процедуры прорисовки сетки

// рисует геометрию
procedure TDisplayForm.displaygeom;
var
  w,h : Integer; // ширина и высота области в пикселах
  ibort, i : Integer; // бортик и счётчик
  m : Real; // масштабирующий коэффициент
  pxs, pxe, pys, pye : Integer; // края прямоугольника.

begin
   // очистка фона
   myfonclean;
   // определение высоты и ширины расчётной
   // области в пикселах
   with DisplayForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    DisplayForm.Width:=38 + 2*ibort + round(Form1.dLx*m);
    DisplayForm.Height:=65 + 2*ibort + round(Form1.dLy*m);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with DisplayForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    DisplayForm.PaintBox1.Canvas.Rectangle(ibort,ibort,ibort+round(Form1.dLx*m),h-ibort);
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
         DisplayForm.PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;
end;  // конец процедуры прорисовки геометрии

// показывает поле температур в
// в контрольных объёмах.
procedure TDisplayForm.displayTempreture;
var
   minD, maxD : Real; // минимальные и максимальные значения отображаемой величины
   i,j : Integer; // Счётчики
   w,h : Integer; // ширина и высота области в пикселах
   ibort, icol : Integer; // бортик, цвет
   m : Real; // масштабирующий коэффициент
   ini,isi,iei,iwi : Integer; // координаты текущего прямоугольника в пикселах
   pxs, pxe, pys, pye : Integer; // края прямоугольника.

begin
   // очистка фона
  // myfonclean;


   if ((Form1.D<>nil) and (Form1.D2=nil) and (Form1.D3=nil)) then
   begin


      // определение высоты и ширины расчётной
      // области в пикселах
      with DisplayForm.PaintBox1 do
      begin
         w:=Width; // ширина в пикселах
         h:=Height;  // высота в пикселах
      end;


      // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin

         for i:=1 to inx*iny do
         begin
            if (D[i]>maxD) then maxD:=D[i];
            if (D[i]<minD) then minD:=D[i];
         end;



         //****
         ibort:=15; // бортик в 15 пикселей
         m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for i:=1 to inx do
         begin
            for j:=1 to iny do
            begin
               // выбор цвета
               icol:=0; // синий по умолчанию
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol:=round(1020*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
               end;
               if ((0 <=icol) and (icol <= 255)) then
               begin   // синий голубой
                  Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                  Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
               end
                else if ((256 <=icol) and (icol <= 510)) then
               begin   // голубой зелёный
                  Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                  Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
               end
                 else if ((511 <=icol) and (icol <= 765)) then
               begin   // зелёный жёлтый
                  Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                  Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
               end
                else if ((766 <=icol) and (icol <= 1020)) then
               begin   // жёлтый красный
                  Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                  Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
               end;

               // прорисовка прямоугольника
               if (i<>1) then
               begin   // внутренний контрольный объём
                  iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
               end
                else
               begin  // краевой контрольный объём
                  iwi:=ibort+round(xpos[i]*m);
               end;
               if (i<> inx) then
               begin   // внутренний контрольный объём
                  iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
               end
                 else
               begin   // краевой контрольный объём
                  iei:=ibort+round(xpos[i]*m);
               end;
               if (j<>1) then
               begin  // внутренний контрольный объём
                  isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
               end
                else
               begin  // краевой контрольный объём
                  isi:=ibort+round(ypos[j]*m);
               end;
               if (j<>iny) then
               begin  // внутренний контрольный объём
                  ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
               end
                else
               begin  // краевой контрольный объём
                  ini:=ibort+round(ypos[j]*m);
               end;
               // к краям добавляется плюс минус один пиксел
               // для того чтобы не было белых полосок при визуализации.
               Buffer.Canvas.Rectangle(iwi-1,h-ini-1,iei+1,h-isi+1);
            end;
         end;
      end;

      Buffer.Canvas.Brush.Color:=clWhite;
      Buffer.Canvas.Pen.Color:=clBlack;
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
         Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
      end;

      // двойная буферизация, защита от мерцания.
      DisplayForm.PaintBox1.Canvas.Draw(0,0,Buffer);

   end
    else if ((Form1.D<>nil)and(Form1.D2<>nil)and(Form1.D3=nil)) then
   begin
       // вывод на эран сразу двух функций.
       // определение высоты и ширины расчётной
       // области в пикселах
       with DisplayForm.PaintBox1 do
       begin
          w:=Width; // ширина в пикселах
          h:=Height div 2;  // высота в пикселах
       end;
       // нужно вычислить максимальные и минимальные значения температуры
       maxD:=-1e+300;
       minD:=1e+300;

       with Form1 do
       begin

          for i:=1 to inx*iny do
          begin
             if (D[i]>maxD) then maxD:=D[i];
             if (D[i]<minD) then minD:=D[i];
          end;


          //****
          ibort:=15; // бортик в 15 пикселей
          m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
          // нужно нарисовать закрашенные контрольные объёмы
          // обход снизу вверх, слева направо
          for i:=1 to inx do
          begin
             for j:=1 to iny do
             begin
                // выбор цвета
                icol:=0; // синий по умолчанию
                if (abs(maxD-minD)>1e-300) then
                begin
                   // maxD <> minD
                   icol:=round(1020*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
                end;
                if ((0 <=icol) and (icol <= 255)) then
                begin   // синий голубой
                   Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                   Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
                end
                 else if ((256 <=icol) and (icol <= 510)) then
                begin   // голубой зелёный
                   Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                   Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
                end
                 else if ((511 <=icol) and (icol <= 765)) then
                begin   // зелёный жёлтый
                   Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                   Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
                end
                 else if ((766 <=icol) and (icol <= 1020)) then
                begin   // жёлтый красный
                   Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                   Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
                end;

                // прорисовка прямоугольника
                if (i<>1) then
                begin   // внутренний контрольный объём
                   iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
                end
                 else
                begin  // краевой контрольный объём
                   iwi:=ibort+round(xpos[i]*m);
                end;
                if (i<> inx) then
                begin   // внутренний контрольный объём
                   iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
                end
                 else
                begin   // краевой контрольный объём
                   iei:=ibort+round(xpos[i]*m);
                end;
                if (j<>1) then
                begin  // внутренний контрольный объём
                   isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
                end
                  else
                begin  // краевой контрольный объём
                   isi:=ibort+round(ypos[j]*m);
                end;
                if (j<>iny) then
                begin  // внутренний контрольный объём
                   ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
                end
                  else
                begin  // краевой контрольный объём
                   ini:=ibort+round(ypos[j]*m);
                end;
                // к краям добавляется плюс минус один пиксел
                // для того чтобы не было белых полосок при визуализации.
                Buffer.Canvas.Rectangle(iwi-1,h-ini-1,iei+1,h-isi+1);
             end;
          end;
       end;

       Buffer.Canvas.Brush.Color:=clWhite;
       Buffer.Canvas.Pen.Color:=clBlack;
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
          Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
       end;

       // нужно вычислить максимальные и минимальные значения температуры
       maxD:=-1e+300;
       minD:=1e+300;

       with Form1 do
       begin

          for i:=1 to inx*iny do
          begin
             if (D2[i]>maxD) then maxD:=D2[i];
             if (D2[i]<minD) then minD:=D2[i];
          end;


          //****
          ibort:=15; // бортик в 15 пикселей
          m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
          // нужно нарисовать закрашенные контрольные объёмы
          // обход снизу вверх, слева направо
          for i:=1 to inx do
          begin
             for j:=1 to iny do
             begin
                // выбор цвета
                icol:=0; // синий по умолчанию
                if (abs(maxD-minD)>1e-300) then
                begin
                   // maxD <> minD
                   icol:=round(1020*((D2[i+(j-1)*inx]-minD)/(maxD-minD)));
                end;
                if ((0 <=icol) and (icol <= 255)) then
                begin   // синий голубой
                   Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                   Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
                end
                 else if ((256 <=icol) and (icol <= 510)) then
                begin   // голубой зелёный
                   Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                   Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
                end
                 else if ((511 <=icol) and (icol <= 765)) then
                begin   // зелёный жёлтый
                   Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                   Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
                end
                 else if ((766 <=icol) and (icol <= 1020)) then
                begin   // жёлтый красный
                   Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                   Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
                end;

                // прорисовка прямоугольника
                if (i<>1) then
                begin   // внутренний контрольный объём
                   iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
                end
                 else
                begin  // краевой контрольный объём
                   iwi:=ibort+round(xpos[i]*m);
                end;
                if (i<> inx) then
                begin   // внутренний контрольный объём
                   iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
                end
                 else
                begin   // краевой контрольный объём
                   iei:=ibort+round(xpos[i]*m);
                end;
                if (j<>1) then
                begin  // внутренний контрольный объём
                   isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
                end
                  else
                begin  // краевой контрольный объём
                   isi:=ibort+round(ypos[j]*m);
                end;
                if (j<>iny) then
                begin  // внутренний контрольный объём
                   ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
                end
                  else
                begin  // краевой контрольный объём
                   ini:=ibort+round(ypos[j]*m);
                end;
                // к краям добавляется плюс минус один пиксел
                // для того чтобы не было белых полосок при визуализации.
                Buffer.Canvas.Rectangle(iwi-1,2*h-ini-1,iei+1,2*h-isi+1);
             end;
          end;
       end;

       Buffer.Canvas.Brush.Color:=clWhite;
       Buffer.Canvas.Pen.Color:=clBlack;
       // учёт расположения hollow block
       for i:=1 to (GridGenForm.maxbrickelem-1) do
       begin
          with GridGenForm do
          begin
             pxs:= ibort + round(bricklist[i].xS*m);
             pxe:= ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
             pys:= 2*h - (ibort + round(bricklist[i].yS*m));
             pye:= 2*h - (ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
          end; // with
          Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
       end;

       // двойная буферизация, защита от мерцания.
       DisplayForm.PaintBox1.Canvas.Draw(0,0,Buffer);

    end
    else if ((Form1.D<>nil)and(Form1.D2<>nil)and(Form1.D3<>nil)) then
   begin
       // вывод на эран сразу двух функций.
       // определение высоты и ширины расчётной
       // области в пикселах
       with DisplayForm.PaintBox1 do
       begin
          w:=Width div 2; // ширина в пикселах
          h:=Height div 2;  // высота в пикселах
       end;
       // нужно вычислить максимальные и минимальные значения температуры
       maxD:=-1e+300;
       minD:=1e+300;

       with Form1 do
       begin

          for i:=1 to inx*iny do
          begin
             if (D[i]>maxD) then maxD:=D[i];
             if (D[i]<minD) then minD:=D[i];
          end;


          //****
          ibort:=15; // бортик в 15 пикселей
          m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
          // нужно нарисовать закрашенные контрольные объёмы
          // обход снизу вверх, слева направо
          for i:=1 to inx do
          begin
             for j:=1 to iny do
             begin
                // выбор цвета
                icol:=0; // синий по умолчанию
                if (abs(maxD-minD)>1e-300) then
                begin
                   // maxD <> minD
                   icol:=round(1020*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
                end;
                if ((0 <=icol) and (icol <= 255)) then
                begin   // синий голубой
                   Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                   Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
                end
                 else if ((256 <=icol) and (icol <= 510)) then
                begin   // голубой зелёный
                   Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                   Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
                end
                 else if ((511 <=icol) and (icol <= 765)) then
                begin   // зелёный жёлтый
                   Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                   Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
                end
                 else if ((766 <=icol) and (icol <= 1020)) then
                begin   // жёлтый красный
                   Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                   Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
                end;

                // прорисовка прямоугольника
                if (i<>1) then
                begin   // внутренний контрольный объём
                   iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
                end
                 else
                begin  // краевой контрольный объём
                   iwi:=ibort+round(xpos[i]*m);
                end;
                if (i<> inx) then
                begin   // внутренний контрольный объём
                   iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
                end
                 else
                begin   // краевой контрольный объём
                   iei:=ibort+round(xpos[i]*m);
                end;
                if (j<>1) then
                begin  // внутренний контрольный объём
                   isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
                end
                  else
                begin  // краевой контрольный объём
                   isi:=ibort+round(ypos[j]*m);
                end;
                if (j<>iny) then
                begin  // внутренний контрольный объём
                   ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
                end
                  else
                begin  // краевой контрольный объём
                   ini:=ibort+round(ypos[j]*m);
                end;
                // к краям добавляется плюс минус один пиксел
                // для того чтобы не было белых полосок при визуализации.
                Buffer.Canvas.Rectangle(iwi-1,h-ini-1,iei+1,h-isi+1);
             end;
          end;
       end;

       Buffer.Canvas.Brush.Color:=clWhite;
       Buffer.Canvas.Pen.Color:=clBlack;
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
          Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
       end;

       // нужно вычислить максимальные и минимальные значения температуры
       maxD:=-1e+300;
       minD:=1e+300;

       with Form1 do
       begin

          for i:=1 to inx*iny do
          begin
             if (D2[i]>maxD) then maxD:=D2[i];
             if (D2[i]<minD) then minD:=D2[i];
          end;


          //****
          ibort:=15; // бортик в 15 пикселей
          m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
          // нужно нарисовать закрашенные контрольные объёмы
          // обход снизу вверх, слева направо
          for i:=1 to inx do
          begin
             for j:=1 to iny do
             begin
                // выбор цвета
                icol:=0; // синий по умолчанию
                if (abs(maxD-minD)>1e-300) then
                begin
                   // maxD <> minD
                   icol:=round(1020*((D2[i+(j-1)*inx]-minD)/(maxD-minD)));
                end;
                if ((0 <=icol) and (icol <= 255)) then
                begin   // синий голубой
                   Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                   Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
                end
                 else if ((256 <=icol) and (icol <= 510)) then
                begin   // голубой зелёный
                   Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                   Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
                end
                 else if ((511 <=icol) and (icol <= 765)) then
                begin   // зелёный жёлтый
                   Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                   Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
                end
                 else if ((766 <=icol) and (icol <= 1020)) then
                begin   // жёлтый красный
                   Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                   Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
                end;

                // прорисовка прямоугольника
                if (i<>1) then
                begin   // внутренний контрольный объём
                   iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
                end
                 else
                begin  // краевой контрольный объём
                   iwi:=ibort+round(xpos[i]*m);
                end;
                if (i<> inx) then
                begin   // внутренний контрольный объём
                   iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
                end
                 else
                begin   // краевой контрольный объём
                   iei:=ibort+round(xpos[i]*m);
                end;
                if (j<>1) then
                begin  // внутренний контрольный объём
                   isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
                end
                  else
                begin  // краевой контрольный объём
                   isi:=ibort+round(ypos[j]*m);
                end;
                if (j<>iny) then
                begin  // внутренний контрольный объём
                   ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
                end
                  else
                begin  // краевой контрольный объём
                   ini:=ibort+round(ypos[j]*m);
                end;
                // к краям добавляется плюс минус один пиксел
                // для того чтобы не было белых полосок при визуализации.
                Buffer.Canvas.Rectangle(iwi-1,2*h-ini-1,iei+1,2*h-isi+1);
             end;
          end;
       end;

       Buffer.Canvas.Brush.Color:=clWhite;
       Buffer.Canvas.Pen.Color:=clBlack;
       // учёт расположения hollow block
       for i:=1 to (GridGenForm.maxbrickelem-1) do
       begin
          with GridGenForm do
          begin
             pxs:= ibort + round(bricklist[i].xS*m);
             pxe:= ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
             pys:= 2*h - (ibort + round(bricklist[i].yS*m));
             pye:= 2*h - (ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
          end; // with
          Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
       end;

       // нужно вычислить максимальные и минимальные значения температуры
       maxD:=-1e+300;
       minD:=1e+300;

       with Form1 do
       begin

          for i:=1 to inx*iny do
          begin
             if (D3[i]>maxD) then maxD:=D3[i];
             if (D3[i]<minD) then minD:=D3[i];
          end;


          //****
          ibort:=15; // бортик в 15 пикселей
          m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
          // нужно нарисовать закрашенные контрольные объёмы
          // обход снизу вверх, слева направо
          for i:=1 to inx do
          begin
             for j:=1 to iny do
             begin
                // выбор цвета
                icol:=0; // синий по умолчанию
                if (abs(maxD-minD)>1e-300) then
                begin
                   // maxD <> minD
                   icol:=round(1020*((D3[i+(j-1)*inx]-minD)/(maxD-minD)));
                end;
                if ((0 <=icol) and (icol <= 255)) then
                begin   // синий голубой
                   Buffer.Canvas.Brush.Color:=RGB(0,0+icol,255);
                   Buffer.Canvas.Pen.Color:=RGB(0,0+icol,255);
                end
                 else if ((256 <=icol) and (icol <= 510)) then
                begin   // голубой зелёный
                   Buffer.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
                   Buffer.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
                end
                 else if ((511 <=icol) and (icol <= 765)) then
                begin   // зелёный жёлтый
                   Buffer.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
                   Buffer.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
                end
                 else if ((766 <=icol) and (icol <= 1020)) then
                begin   // жёлтый красный
                   Buffer.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
                   Buffer.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
                end;

                // прорисовка прямоугольника
                if (i<>1) then
                begin   // внутренний контрольный объём
                   iwi:=ibort+round(xpos[i]*m)-round(0.5*(xpos[i]-xpos[i-1])*m);
                end
                 else
                begin  // краевой контрольный объём
                   iwi:=ibort+round(xpos[i]*m);
                end;
                if (i<> inx) then
                begin   // внутренний контрольный объём
                   iei:=ibort+round(xpos[i]*m)+round(0.5*(xpos[i+1]-xpos[i])*m);
                end
                 else
                begin   // краевой контрольный объём
                   iei:=ibort+round(xpos[i]*m);
                end;
                if (j<>1) then
                begin  // внутренний контрольный объём
                   isi:=ibort+round(ypos[j]*m)-round(0.5*(ypos[j]-ypos[j-1])*m);
                end
                  else
                begin  // краевой контрольный объём
                   isi:=ibort+round(ypos[j]*m);
                end;
                if (j<>iny) then
                begin  // внутренний контрольный объём
                   ini:=ibort+round(ypos[j]*m)+round(0.5*(ypos[j+1]-ypos[j])*m);
                end
                  else
                begin  // краевой контрольный объём
                   ini:=ibort+round(ypos[j]*m);
                end;
                // к краям добавляется плюс минус один пиксел
                // для того чтобы не было белых полосок при визуализации.
                Buffer.Canvas.Rectangle(w+iwi-1,h-ini-1,w+iei+1,h-isi+1);
             end;
          end;
       end;

       Buffer.Canvas.Brush.Color:=clWhite;
       Buffer.Canvas.Pen.Color:=clBlack;
       // учёт расположения hollow block
       for i:=1 to (GridGenForm.maxbrickelem-1) do
       begin
          with GridGenForm do
          begin
             pxs:= w+ibort + round(bricklist[i].xS*m);
             pxe:= w+ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
             pys:= h - (ibort + round(bricklist[i].yS*m));
             pye:= h - (ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
          end; // with
          Buffer.Canvas.Rectangle(pxs,pys,pxe,pye);
       end;


       // двойная буферизация, защита от мерцания.
       DisplayForm.PaintBox1.Canvas.Draw(0,0,Buffer);

    end;

end;

// Идея этого метода заключается в следующем:
// Пусть имеем расчитанное поле температур на грубой сетке 20 на 20.
// Далее путём интерполяции получаем поле температур на достаточно подробной сетке,
// скажем 100 на 100. И визуализируем это поле температур обычным способом. Вот и всё.
// Для интерполяции используем встроенную процедуру из OpenSource модуля найденного в интернете.
// показывает поле температур аппроксимированное сплайном
procedure TDisplayForm.displayTempreturebicubicsplane;
(*var
   minD, maxD : Real; // минимальные и максимальные значения визуализируемой величины
   w,h : Integer; // ширина и высота области в пикселах
   A, B : TReal2DArray; // массивы для бикубической интерполяции
   i,j : Integer; // счётчики
   inxnew, inynew : Integer; // новые размеры сетки
   ibort, icol : Integer; // бортик, цвет
   m : Real; // масштабирующий коэффициент
   ini,isi,iei,iwi : Integer; // координаты текущего прямоугольника в пикселах
   xposn, yposn : array of Real; // интерполяционная сетка
   *)
   
begin
   Application.MessageBox('работа метода стала невозможна 8 января 2010 года','',MB_OK);
   (*
   // очистка фона
   myfonclean;
   // определение высоты и ширины расчётной
   // области в пикселах
   with DisplayForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;
   // нужно вычислить максимальные и минимальные значения температуры
   maxD:=-1e+300;
   minD:=1e+300;
   with Form1 do
   begin
      for i:=1 to inx*iny do
      begin
         if (D[i]>maxD) then maxD:=D[i];
         if (D[i]<minD) then minD:=D[i];
      end;
      SetLength(A,inx,iny); // выделение памяти
      for i:=1 to inx do
      begin
         for j:=1 to iny do
         begin
            A[i-1][j-1]:=D[i+(j-1)*inx];
         end;
      end;

      // должно быть нечётное значение
      inxnew:=201; // размеры нового массива чётко
      inynew:=201; // фиксированы
      // интерполяционная сетка должна быть равномерной 201x201
      // с неравномерными сетками метод не работает


      // нужно сгенерировать новую интерполяционную сетку
      SetLength(xposn,inxnew+1);  // выделение памяти
      SetLength(yposn,inynew+1);  // выделение памяти
      // Метод используемый ниже полностью переделан поэтому его вызов невозможен.
      // FMesh.meshgenerator1(inxnew, inynew, xposn, yposn);
      // Нужно сообщить об ошибке приложения


      // заполнение интерполяционного массива данными
      if (b13) then
      begin
         // билинейный
         //Application.MessageBox('билинейный','',MB_OK);
         BilinearResampleCartesian(A,iny,inx,B,inynew,inxnew);
      end
      else
      begin
         // бикубический
         //Application.MessageBox('бикубический','',MB_OK);
         BicubicResampleCartesian(A,iny,inx,B,inynew,inxnew);
      end;
      ibort:=15; // бортик в 15 пикселей
      m:=min((h-2*ibort)/dLy,(w-2*ibort)/dLx); // масштабирующий коэффициент
    end;
    // нужно нарисовать закрашенные контрольные объёмы
   // обход снизу вверх слева направо
   for i:=1 to inxnew do
   begin
      for j:=1 to inynew do
      begin
         // выбор цвета
         icol:=0; // синий по умолчанию
         if (abs(maxD-minD)>1e-300) then
         begin
            // maxD<>minD
            icol:=round(1020*((B[i-1][j-1]-minD)/(maxD-minD)));
         end;
         if ((0 <=icol) and (icol <= 255)) then
         begin   // синий голубой
           DisplayForm.PaintBox1.Canvas.Brush.Color:=RGB(0,0+icol,255);
           DisplayForm.PaintBox1.Canvas.Pen.Color:=RGB(0,0+icol,255);
         end
         else if ((256 <=icol) and (icol <= 510)) then
         begin   // голубой зелёный
           DisplayForm.PaintBox1.Canvas.Brush.Color:=RGB(0,255,255-(icol-255));
           DisplayForm.PaintBox1.Canvas.Pen.Color:=RGB(0,255,255-(icol-255));
         end
         else if ((511 <=icol) and (icol <= 765)) then
         begin   // зелёный жёлтый
           DisplayForm.PaintBox1.Canvas.Brush.Color:=RGB(0+(icol-510),255,0);
           DisplayForm.PaintBox1.Canvas.Pen.Color:=RGB(0+(icol-510),255,0);
         end
         else if ((766 <=icol) and (icol <= 1020)) then
         begin   // жёлтый красный
           DisplayForm.PaintBox1.Canvas.Brush.Color:=RGB(255,255-(icol-765),0);
           DisplayForm.PaintBox1.Canvas.Pen.Color:=RGB(255,255-(icol-765),0);
         end;

         // чтобы модуль интерполяции заработал на неравномерных сетках
         // нужно во первых инкапсулировать модуль генерации сетки,
         // так чтобы он работал автономно и можно было быстро сгенерировать
         // неравномерную интерполяционную расчётную сетку.

         // прорисовка прямоугольника
         if (i<>1) then
         begin   // внутренний контрольный объём
            iwi:=ibort+round(xposn[i]*m)-round(0.5*(xposn[i]-xposn[i-1])*m);
         end
         else
         begin  // краевой контрольный объём
            iwi:=ibort+round(xposn[i]*m);
         end;
         if (i <> inxnew) then
         begin   // внутренний контрольный объём
            iei:=ibort+round(xposn[i]*m)+round(0.5*(xposn[i+1]-xposn[i])*m);
         end
         else
         begin   // краевой контрольный объём
            iei:=ibort+round(xposn[i]*m);
         end;
         if (j<>1) then
         begin  // внутренний контрольный объём
            isi:=ibort+round(yposn[j]*m)-round(0.5*(yposn[j]-yposn[j-1])*m);
         end
         else
         begin  // краевой контрольный объём
            isi:=ibort+round(yposn[j]*m);
         end;
         if (j<>inynew) then
         begin  // внутренний контрольный объём
            ini:=ibort+round(yposn[j]*m)+round(0.5*(yposn[j+1]-yposn[j])*m);
         end
         else
         begin  // краевой контрольный объём
            ini:=ibort+round(yposn[j]*m);
         end;
         // к краям добавляется плюс минус один пиксел
         // для того чтобы не было белых полосок при визуализации.
         DisplayForm.PaintBox1.Canvas.Rectangle(iwi-1,h-ini-1,iei+1,h-isi+1);

      end; // j
   end; // i
   *)
end;


// отклик на изменение размеров экранной формы
procedure TDisplayForm.FormResize(Sender: TObject);
begin
   DisplayForm.PaintBox1.Width:=DisplayForm.Width-38;
   DisplayForm.PaintBox1.Height:=DisplayForm.Height-65;
   myfonclean;
   with DisplayForm.PaintBox1 do
   begin
      Buffer.Width:=Width;
      Buffer.Height:=Height;
      //Buffer.Transparent:=True;
      //Buffer.TransparentColor:=clWhite;
      Buffer.Canvas.Brush.Color:=clWhite;
      Buffer.Canvas.Rectangle(0,0,Width,Height);
   end;

end; // FormResize

// после изменения размеров экранной формы вызывается метод
// прорисовки
procedure TDisplayForm.FormPaint(Sender: TObject);
begin
   case iwhotvisible of
   1 : begin
         displaymesh;
       end;
   2 : begin
         displayTempreture;
       end;
   3 : begin
          displayTempreturebicubicsplane;
       end;
   4 : begin
          displayTempreturebicubicsplane;
       end;
   end; // case
end; // FormPaint

procedure TDisplayForm.FormCreate(Sender: TObject);
begin
   // создание буфера для двойной буферизации.
   Buffer:=TBitmap.Create;
end;

procedure TDisplayForm.FormDestroy(Sender: TObject);
begin
   Buffer.Free;
end;

end.
