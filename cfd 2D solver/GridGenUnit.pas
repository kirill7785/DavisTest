unit GridGenUnit;
// Простейший сеточный генератор

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CheckLst, Unitdeclar;

type
  //Float = Extended;
  //Float = Real;

   // тип граница
   // сгущение сетки к границе.
   Tmybond = record
      fr : Float;
      bl : Boolean; // пограничный слой
   end;

  // описание прямоугольника
  mybrick = record
     xS, yS : Float; // стартовая позиция
     xL, yL : Float; // длина и ширина кирпича
     bbl : Boolean; // наличие пограничного слоя
  end;
  // описание типа сеточного узла
  typenodemesh = record
     // значения для типа узла:
     // 0 - точка не является точкой расчётной области,
     // 1 - внутренняя точка расчётной области
     // 2 - граничная точка расчётной области
     // 3 - повтор (дважды и более раз граничная),
     //     значит это либо внутренняя точка либо граничная.
     // 4 - угловая точка.
     itypenode : Integer; // тип узла
     // виды угловых точек
     // 0 - не угловая
     // 1 - левый нижний угол,
     // 2 - правый нижний угол,
     // 3 - левый верхний угол,
     // 4 - правый верхний угол
     // 5 - угол пятиточечный крест.
     iugol : Integer; // вид (тип) угловой точки
     // В случае когда тип узла равен 3 то нужно в дальнейшем
     // определить что это за узел. для этого нужно знать как
     // направлена граница на которой лежит узел: по x или по y.
     chdirect : Char; // направление (ориентация) границы.
     // точка принадлежит границе с номером:
     ibondary : Integer; // нумерация границ начинается с 1.
     // внутренняя нормаль к границе
     chnormal : Char; // внутренняя нормаль к границе
  end;

  // вершина
  // Эта структура данных нужна для следующей операции:
  // передаются вещественные координаты вершины а возвращаются
  // координаты сеточного узла.
  tmyvertex = record
     rx, ry : Float; // вещественные координаты узла
     ix, iy : Integer; // целочисленные координаты узла на некоторой сетке
     bnode : Boolean; // принадлежит ли узел расчётной области
  end;
  // вершины прямоугольника
  // для занесения информации о граничных узлах
  mrectanglepoint = record
      // пока считается что все узлы принадлежат внутренности кабинета.
      // если это ни так то возникнет ошибка приложения.
      ixLB, iyLB : Integer; // левый нижний угол (left bottom)
      ixRB, iyRB : Integer; // правый нижний угол (right bottom)
      ixLT, iyLT : Integer; // левый верхний угол (left bottom)
      ixRT, iyRT : Integer; // правый верхний угол (right top)
  end;
  // структура с описанием границы расчётной области.
  boundaryedge = record
     //  описание границы расчётной области
     boundaryname : String; // имя границы
     // направление вдоль границы
     chdirect : Char;
     idescriptor : Integer; // уникальный номер границы

     // Temperature :
     // на каждой из границ можно задать граничное условие
     // I рода.
     temperatureclan : Integer; // род граничных условий по температуре I или II
     temperaturecondition : Float; // значение температуры на границе или теплового потока на границе.

     // Velocity, Pressure CFD.
     Vx, Vy : Float; // компоненты скорости
     bsimmetry : Boolean; // граница симметрии
     boutflow : Boolean; // выходная граница расчётной области
     bpressure : Boolean; // задано ли давление на границе
     bMarangoni : Boolean; // Задано ли на границе условие Марангони.
     rpressure : Float; // заданное значение давления на границе
     surfaceTensionGradient : Float; // dSigma/dT коэффициент поверхностного натяжения в зависимости от температуры.
     // для функции тока
     rSFval : Float; // числовое значение для функции тока
     // один из трёх символов:
     // x - значения x на границе,
     // y - значения y на границе,
     // c - const - заданное числовое значение на границе.
     chSFval : Char; // символ см. выше.

     // физика полупроводников и не только.
     // User-Defined Scalars.
     // На границе можно задать условие дирихле или поток User-Defined скаляра.
     uds1clan : Integer; // род граничных условий по пользовательскому скаляру первый или второй.
     uds2clan : Integer;
     uds3clan : Integer;
     uds4clan : Integer;
     uds1condition : String; // значение скаляра или потока скаляра.
     uds2condition : String;
     uds3condition : String;
     uds4condition : String;

  end;  // граница расчётной области

  TGridGenForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    CabinetButton: TButton;
    AddBlockButton: TButton;
    GroupBox2: TGroupBox;
    GeomButton: TButton;
    MeshButton: TButton;
    Panel2: TPanel;
    CheckListBox1: TCheckListBox;
    BResize: TButton;
    BDel: TButton; // удалить пустой hollow блок
    Brename: TButton;
    GenerateMeshButton: TButton;
    ButtonBoundaryCondition: TButton;
    GroupBox3: TGroupBox;
    write: TButton; // записать файл с расчётной сеткой
    Read: TButton;  // прочитать файл с расчётной сеткой
    BClose: TButton; // закрыть форму
    OpenDialog1: TOpenDialog;
    GroupBox4: TGroupBox;
    PaintBox1: TPaintBox;
    btnShowMeshSize: TButton; // диалог открытия файла
    procedure FormResize(Sender: TObject);
    procedure GeomButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AddBlockButtonClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure GenerateMeshButtonClick(Sender: TObject);
    procedure MeshButtonClick(Sender: TObject);
    procedure CabinetButtonClick(Sender: TObject);
    procedure ButtonBoundaryConditionClick(Sender: TObject);
    procedure BDelClick(Sender: TObject);
    procedure BrenameClick(Sender: TObject);
    procedure BResizeClick(Sender: TObject);
    procedure writeClick(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure ReadClick(Sender: TObject);
    procedure btnShowMeshSizeClick(Sender: TObject);
  private
    { Private declarations }
    iwhatvisibleshadow : Integer;
  public
    { Public declarations }
    // что прорисовывать при вызове onPaint
    // по умолчанию прорисовка геометрии (значение 0)
    // если значение равно 1 то прорисовка сетки.
    // если 2 то прорисовка выделенных границ.
    iwhotvisible : Integer;
    // список hollow блоков (кирпичей).
    bricklist : array of mybrick;
    // число кирпичей в массиве
    // cabinet нумеруется 0.
    maxbrickelem : Integer;
    // список типов узлов сетки
    tnm : array of typenodemesh;
    // глобальный параметр : число границ
    inumboundary : Integer;
    // список границ расчётной области
    edgelist : array of boundaryedge;
    // переменная признак чтения параметров из текстового файла.
    bfileread : Boolean;

    // очистка фона белым
    procedure myfonclean;
    // процедура прорисовки геометрии
    procedure drawgeom;
    // Пузырьковая сортировка
    // передаётся динамический массив вещетвенных чисел и его размер.
    procedure myBubbleSort(var mya : array of Tmybond; inum : Integer);
    // Пузырьковая сортировка
    // передаётся динамический массив вещетвенных чисел и его размер.
    // упорядочивание по возрастанию.
    // нумерация начинается с единицы !!!
    procedure myBubbleSort1(var mya : array of Float;
                                    inum : Integer);
    // процедура генерации расчётной сетки
    procedure mysimplemeshgen;
    // процедура прорисовки сетки
    procedure drawmesh;
    // подсветка выбранных границ
    // уникальные номера подсвечиваемых границ указаны в целочисленном массиве
    procedure drawboundary(var ibon : array of Integer; ilength : Integer);
    // эвляется ли граничный узел
    // для которого поставлено условие неймана
    function isneiman(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
    // эвляется ли граничный узел
    // для которого поставлено условие неймана
    // здесь также передаётся значение теплового потока через границу.
    function isneimanqb(idescbon : Integer; chvariable : Char; var qbpot : Float): Boolean;
    // является ли граничный узел
    // для которого поставлено условие Дирихле
    // Прага 3 ноября 2014.
    function isDirichlet(idescbon : Integer; chvariable : Char; var DirichVal : Float): Boolean;
    // эвляется ли граничный узел
    // для которого поставлены мягкие граничные условия.
    function isoutflow(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
    // эвляется ли граничный узел
    // границей симметрии
    function issimm(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
    // процедура записи текущей сетки в файл
    procedure writeMesh(Sender: TObject; filename : string);
    //  считывает файл с расчётной сеткой
    procedure ReadMesh(filename : string);
    // является ли граничный узел
    // для которого поставлено условие неймана
    // здесь также передаётся значение потока через границу.
    // Для функции цвета.
    function isneimanVof(idescbon : Integer; var qbpot : Float; chnormal : Char): Boolean;
    // Возвращает истину если на всех границах для давления стоит однородное
    // условие Неймана.
    function bVabishevichPressureAvgZero() : Boolean;
    // Задан ли на границе ток равный нулю.
    function isCzerocurent(idescbon : Integer) : Boolean;
    // Задан ли на границе нулевой нормальный диффузионный ток ?
    function isCzeroDiff(idescbon : Integer) : Boolean;
    // свободный металл.
    function isFreeMetall(idescbon : Integer) : Boolean;
    // является ли граничный узел
    // узлом на котором поставлено условие Марангони по скорости.
    function isMarangoni(idescbon : Integer; var mstress : Float; chnormal : Char): Boolean;
    // распечатывает содержимое границ
    // в текстовый файл
    procedure PrintBoundaryDiagnostic;
    // Возвращает номер границы
    function iboundnum(k : Integer) : Integer;
  end;

var
  GridGenForm: TGridGenForm;

implementation

uses
     MainUnit, Math, AddBrickUnit, CabinetGlobalMeshUnit,
     Cabinet2DUnit, BonConRedoUnit, HBlockRedoUnit, MeshGen,
  UnitLaunchMeshGen, UnitOpenGL;

{$R *.dfm}

// очистка фона белым
procedure TGridGenForm.myfonclean;
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
procedure TGridGenForm.drawgeom;
const ih = 453;
var
    w,h,irh : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Real; // масштабирующий коэффициент
    i : Integer; // счётчик

begin
   // определение высоты и ширины расчётной
   // области в пикселах
   with GridGenForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    GridGenForm.Width:= 400 + 2*ibort + round(Form1.dLx*m);
    irh:= 76 + 2*ibort + round(Form1.dLy*m);
    GridGenForm.Height:=max(ih,irh);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with GridGenForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    myfonclean; // очистка фона
    pxs:=ibort;
    pxe:=ibort + round((bricklist[0].xS + bricklist[0].xL)*m);
    pys:=h - ibort;
    pye:=h - (ibort + round((bricklist[0].yS + bricklist[0].yL)*m));
    PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    for i:=1 to (maxbrickelem-1) do
    begin
         pxs:=ibort + round(bricklist[i].xS*m);
         pxe:=ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
         pys:=h -(ibort + round(bricklist[i].yS*m));
         pye:=h -(ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
         PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;
end; // прорисовка геометрии

// изменение размеров формы
procedure TGridGenForm.FormResize(Sender: TObject);
begin
   // Изменение размеров формы
   PaintBox1.Width:=Width - 400;
   PaintBox1.Height:=Height - 76;
end; // FormResize

// рисует геометрию
procedure TGridGenForm.GeomButtonClick(Sender : TObject);
begin
   iwhotvisible:=0;
   drawgeom; // прорисовка геометрии
end;

// вызывается при создании формы
procedure TGridGenForm.FormCreate(Sender: TObject);
begin
   bfileread:=false; // по умолчанию ничего из файла не читаем.
   iwhotvisible:=0;
   SetLength(bricklist,1);
   maxbrickelem:=1; // длина списка.
   // Нулевой элемент это кабинет
   bricklist[0].xS:=0.0; // начальная позиция
   bricklist[0].yS:=0.0;
   bricklist[0].xL:=Form1.dLx; // ширина и
   bricklist[0].yL:=Form1.dLy; // высота
end; // вызывается при создании формы

// добавляет элемент
procedure TGridGenForm.AddBlockButtonClick(Sender: TObject);
begin
    iwhotvisible:=0; // сброс настроек на прорисовку геометрии модели.
    AddbrickForm.Labelnumberhb.Caption:=IntToStr(maxbrickelem);
    // добавляет блок
    AddbrickForm.ShowModal;
    // после создания объекта автоматически прорисовывает геометрию
    drawgeom;
    if (Form1.actiVibr.bOn=True) then
    begin
       Form1.actiVibr.bOn:=False;
       Form1.actiVibr.bBridshmen:=False;
       Application.MessageBox('Был добавлен новый блок. Dynamic Mesh автоматически выключен. Если Вы хотите его использовать, то настройте заново.','',MB_OK);
    end;
end; // добавляет новый элемент в геометрию модели

// автоматически вызывается при перерисовке.
procedure TGridGenForm.FormPaint(Sender: TObject);
begin
   // вызывается при перерисовке
   case iwhotvisible of
     0 : drawgeom; // автоматом прорисовывает геометрию модели
     1 : drawmesh; // автоматом прорисовывает расчётную сетку модели
     2 : // прорисовка выделенных границ
       begin
          drawgeom; // автоматом прорисовывает геометрию модели
          drawboundary(BonConRedoForm.ibonunicalnumberfordisplay,BonConRedoForm.ibclength); // нарисуем выделенную границу
       end;
   end;
end; // onPaint

// Пузырьковая сортировка
// передаётся динамический массив вещетвенных чисел и его размер.
// упорядочивание по возрастанию.
procedure TGridGenForm.myBubbleSort(var mya : array of Tmybond;
                                    inum : Integer);
var
   i,j : Integer; // Счётчики
   xchange : Tmybond;  // буфер для обмена элементов массива

begin
   for i:=1 to inum do
   begin
      for j:=inum downto i do
      begin
          if (mya[j-1].fr > mya[j].fr) then
          begin
             // SWAP
             xchange.fr:=mya[j-1].fr;
             xchange.bl:=mya[j-1].bl;
             mya[j-1].fr:=mya[j].fr;
             mya[j-1].bl:=mya[j].bl;
             mya[j].fr:= xchange.fr;
             mya[j].bl:= xchange.bl;
          end;
      end;
   end;
end; // myBubbleSort


// Пузырьковая сортировка
// передаётся динамический массив вещетвенных чисел и его размер.
// упорядочивание по возрастанию.
// нумерация начинается с единицы !!!
procedure TGridGenForm.myBubbleSort1(var mya : array of Float;
                                    inum : Integer);
var
   i,j : Integer; // Счётчики
   xchange : Float;  // буфер для обмена элементов массива

begin
   for i:=2 to inum do
   begin
      for j:=inum downto i do
      begin
          if (mya[j-1] > mya[j]) then
          begin
             // SWAP
             xchange:=mya[j-1];
             mya[j-1]:=mya[j];
             mya[j]:= xchange;
          end;
      end;
   end;
end; // myBubbleSort1

// процедура генерации расчётной сетки
procedure TGridGenForm.mysimplemeshgen;
const
   epsilon = 1.0e-13; // точность определения границы
   epsilon2 = 1.0e-20;

var
   rxboundary, ryboundary : array of Tmybond; // уникальные границы.
   rbcandidate : Tmybond; // кандидат на добавление границы
   i,j,k : Integer; // счётчики.
   ixcol, iycol : Integer; // количество горионтальных границ.
   ixintervalcount, iyintervalcount : array of Integer;  // количество шагов сетки на интервале
   ixic2, inx2, ixnewstart : Integer;
   iyic2, iny2, iynewstart : Integer;
   dx, dy : Float; // шаги сетки
   xpos1, ypos1 : array of Float;
   iposmark : Integer; // маркер конца массива с узлами сетки
   alphascal : Float; // значение < 1 для генерации сетки.
   inowintervalcount : Integer; // значение количества узлов сетки для данного интервала.
   myvertex : tmyvertex; // узел сетки
   mrp : mrectanglepoint; // Для обнаружения границ области (хранятся 4 точки)
   indeks1, indeks2 : Integer; // типы узлов слева и справа от линии (для разрешения индекса 3)
   indeks3, indeks4 : Integer; // дополнительные два индекса которые могут понадобится на 6 шаге.
   i1, k1 : Integer; // дополнительные счётчики для определения границ.
   // inumboundaryy - очередной номер для вертикальной границы,
   // inumboundaryx - очередной номер для горизонтальной границы.
   b1flag : Boolean; // для поиска границ.
   kflag : Integer; // номер при котором был поднят флаг
   // проверяющий участок кода для отладки.
   f : TStrings; // для отладки заполнения формируемых матриц
   str : String; // для формирования отладочной информации
   icounterudm : Integer; // счётчик используемый при инициализации UDM.

// внутренняя процедура добавляющая вертикальную границу
// в случае если граница уникальна.
procedure addxboundary;
var
   bflag : Boolean; // признак нахождения уникальной границы
   j : Integer; // счётчик
begin
    bflag:=true; // граница  уникальна по умолчанию
    for j:=0 to ixcol do
    begin
       // поиск такой же границы в списке
       if  (abs(rbcandidate.fr - rxboundary[j].fr) < epsilon) then
       begin
          bflag:=false; // такая граница уже есть
          if (rbcandidate.bl) then  rxboundary[j].bl:=true; // наличие пограничного слоя
       end;
    end;
    if (bflag) then
    begin
      // добавление новой уникальной границы
      inc(ixcol);
      SetLength(rxboundary,ixcol+1);
      rxboundary[ixcol].fr:=rbcandidate.fr;
      rxboundary[ixcol].bl:=(rxboundary[ixcol].bl or rbcandidate.bl);
    end;
end;

// внутренняя процедура добавляющая горизонтальную границу
// в случае если граница уникальна.
procedure addyboundary;
var
   bflag : Boolean; // признак нахождения уникальной границы
   j : Integer; // счётчик
begin
    bflag:=true; // граница  уникальна по умолчанию
    for j:=0 to iycol do
    begin
       // поиск такой же границы в списке
       if  (abs(rbcandidate.fr - ryboundary[j].fr) < epsilon) then bflag:=false; // такая граница уже есть
    end;
    if (bflag) then
    begin
      // добавление новой уникальной границы
      inc(iycol);
      SetLength(ryboundary,iycol+1);
      ryboundary[iycol].fr:=rbcandidate.fr;
      ryboundary[iycol].bl:=(ryboundary[iycol].bl or rbcandidate.bl);
    end;
end;

// принадлежит ли точка одному из Hollow блоков
function inHollow(rxpos, rypos : Real) : Boolean;
var
    j : Integer;
    bflag : Boolean;
    bflagx, bflagy : Boolean;

begin
   bflag:=false;
   for j:=1 to (maxbrickelem-1) do
   begin
      bflagx:= ((rxpos > (bricklist[j].xS + epsilon)) and (rxpos < (bricklist[j].xS + bricklist[j].xL - epsilon)));
      bflagy:= ((rypos > (bricklist[j].yS + epsilon)) and (rypos < (bricklist[j].yS + bricklist[j].yL - epsilon)));
      if (bflagx and bflagy) then
      begin
         // принадлежит Hollow block
         bflag := true;
      end;
   end;
   Result := bflag;
end;

// поиск угловой точки
// по вещественным координатам возвращает дискретные координаты.
procedure ugolsearch(var markervertex : tmyvertex);
var
   i1, j1 : Integer;

begin
   markervertex.bnode:=false; // по умолчанию угловая точка не принадлежит расчётной области

   for i1:=1 to Form1.inx do
   begin
      for j1:=1 to Form1.iny do
      begin
         if ((abs(markervertex.rx - Form1.xpos[i1]) < epsilon) and (abs(markervertex.ry - Form1.ypos[j1]) < epsilon)) then
         begin
            // искомые координаты найдены с точностью epsilon
            markervertex.ix:=i1;
            markervertex.iy:=j1;
            markervertex.bnode:=true; // точка принадлежит расчётной области (принадлежит сетке).
         end;
      end;
   end;
   // вставка информации о угловой точке
   if (myvertex.bnode) then
   begin
      if (tnm[myvertex.ix + (myvertex.iy-1)*Form1.inx].itypenode = 1) then
      begin
         tnm[myvertex.ix + (myvertex.iy-1)*Form1.inx].itypenode:=4; // угловой узел
      end;
   end;
end;


begin
   if (not(bfileread)) then
   begin
      // Алгоритм:
   // 1. просмотр границ (в порядке прямоугольников)
   // 2. если данное значение граничного узла уникально с точностью до
   //    1e-5 то добавление нового граничного узла.
   // 3. сортировка узлов по возрастанию.
   // 4. генерация расчётной сетки с учётом расположения границ узлов.

   // горизонтальные границы кабинета
   SetLength(rxboundary,2);
   rxboundary[0].fr:=bricklist[0].xS;
   rxboundary[1].fr:=bricklist[0].xS + bricklist[0].xL;
   rxboundary[0].bl:=false;
   rxboundary[1].bl:=false;
   ixcol:=1;
   // вертикальные границы кабинета
   SetLength(ryboundary,2);
   ryboundary[0].fr:=bricklist[0].yS;
   ryboundary[1].fr:=bricklist[0].yS + bricklist[0].yL;
   iycol:=1;

   for i:=1 to (maxbrickelem-1) do
   begin
      // добавление новых уникальных границ
      rbcandidate.bl:= bricklist[i].bbl;
      rbcandidate.fr:=bricklist[i].xS;
      if (( rbcandidate.fr > rxboundary[0].fr ) and (rbcandidate.fr < rxboundary[1].fr )) then
      begin
         // только если вакантная граница находится внутри кабинета.
         addxboundary;
      end;

      rbcandidate.fr:=bricklist[i].xS + bricklist[i].xL;
      if (( rbcandidate.fr > rxboundary[0].fr) and (rbcandidate.fr < rxboundary[1].fr)) then
      begin
         // только если вакантная граница находится внутри кабинета.
         addxboundary;
      end;

      rbcandidate.fr:=bricklist[i].yS;
      if (( rbcandidate.fr > ryboundary[0].fr) and (rbcandidate.fr < ryboundary[1].fr)) then
      begin
         // только если вакантная граница находится внутри кабинета.
         addyboundary;
      end;

      rbcandidate.fr:=bricklist[i].yS + bricklist[i].yL;
      if (( rbcandidate.fr > ryboundary[0].fr) and (rbcandidate.fr < ryboundary[1].fr)) then
      begin
         // только если вакантная граница находится внутри кабинета.
         addyboundary;
      end;
   end;

   // Сортировка массивов
   // ixcol - индекс последнего элемента, нумерация начинается с нуля.
   myBubbleSort(rxboundary, ixcol); // пузырьковая сортировка
   // iycol - индекс последнего элемента, нумерация начинается с нуля.
   myBubbleSort(ryboundary, iycol); // т.к. размеры массивов очень малы (< 10).

   // Процедура генерации расчётной сетки:
   // Теперь когда границы узлов определены можно сгенерировать
   // равномерную в каждом интервале сетку, задав количество узлов в каждом
   // интервале.
   // Нужно предложить пользователю меню где он может указать
   // значение количества узов для каждого интервала по осям x и y.
   SetLength(ixintervalcount, ixcol); // интервалов на 1 меньше чем границ.
   SetLength(iyintervalcount, iycol); // интервалов на 1 меньше чем границ.
   // Здесь пользователю будет предложено только задать количество точек
   // по каждому из координатному направлению разбивающих кабинет.
   // инициализация диалога:
   if (not(frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked)) then
   begin
      CabinetGlobalMeshForm.Einx.Text:=IntToStr(Form1.inx);
      CabinetGlobalMeshForm.Einy.Text:=IntToStr(Form1.iny);
      CabinetGlobalMeshForm.ShowModal; // глобальное количество точек разбивающих
   end;
   // кабинет по каждому из направлений.
      if ((ixcol<2) and (iycol<2)) then
      begin
         // отсутствуют hollow блоки.

         if (frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked) then
         begin
            FMesh.grpcondensationmeshnodes.Visible:=False;
            FMesh.pnlmessage.Visible:=True;
            FMesh.Button1.Caption:='Continue';
         end
         else
         begin
            FMesh.grpcondensationmeshnodes.Visible:=True;
            FMesh.pnlmessage.Visible:=False;
            FMesh.Button1.Caption:='Create Mesh';
         end;

         // генерация неравномерной расчётной сетки
         FMesh.ShowModal;

      end
        else
      begin
         // Построение сетки в случае когда присутствует
         // хоть один hollow block

         // Вот эти массивы пользователь должен иметь возможность
         // редактировать (здесь пока всё создаётся по умолчанию):
         for i:=0 to (ixcol-1) do
         begin
            // смысл величины alphascal заключается
            // в том чтобы создать по возможности равномерную сетку,
            // зная только количество клеток во всей расчётной области
            // по каждой их осей.
            // для каждого интервала равномерного разбиения alphascal
            // это отношение длины этого интервала к длине всей расчётной области.
            // Таким образом alphascal < 1.  Теперь нужно знать только количество
            // точек приходящееся на Cabinet (кабинет).
            alphascal:=(rxboundary[i+1].fr-rxboundary[i].fr)/(rxboundary[ixcol].fr-rxboundary[0].fr);
            inowintervalcount:=round(alphascal*Form1.inx);
            if (inowintervalcount < 3) then  inowintervalcount:=3;
            ixintervalcount[i]:=inowintervalcount; // количество узлов сетки
            // между границами rxboundary[i+1] и rxboundary[i]
         end;
         for i:=0 to (iycol-1) do
         begin
            // alphascal - выполняет такую-же функцию.
            alphascal:=(ryboundary[i+1].fr-ryboundary[i].fr)/(ryboundary[iycol].fr-ryboundary[0].fr);
            inowintervalcount:=round(alphascal*Form1.iny);
            if (inowintervalcount < 3) then  inowintervalcount:=3;
            iyintervalcount[i]:=inowintervalcount; // количество узлов сетки
            // между границами ryboundary[i+1] и ryboundary[i]
         end;

         // теперь сама процедура генерации расчётной сетки:
         // вертикальные линии
         iposmark:=1;
         SetLength(xpos1,iposmark); // нумерация в массиве xpos[i] начинается с 1.
         for i:=0 to (ixcol-1) do
         begin
            dx:=(rxboundary[i+1].fr-rxboundary[i].fr)/(ixintervalcount[i]-1);
            SetLength(xpos1,iposmark + ixintervalcount[i]);
            for k:=iposmark to (iposmark + ixintervalcount[i]-2) do
            begin
               xpos1[k]:= rxboundary[i].fr + (k-iposmark)*dx;
            end;
            iposmark:= iposmark + ixintervalcount[i] - 1;
         end;
         // Добавление последнего узла на самой правой границе:
         SetLength(xpos1, iposmark+1);
         xpos1[iposmark]:=rxboundary[ixcol].fr;
         Form1.inx:=iposmark; // количество узлов сетки по горизонтали
         SetLength(Form1.xpos,Form1.inx+1);
         for i:=1 to Form1.inx do
         begin
            Form1.xpos[i]:=xpos1[i];
         end;

         // мелкая сетка пограничного слоя
         ixnewstart:=1;
         for i:=0 to (ixcol-1) do
         begin
            if (rxboundary[i].bl) then
            begin
               for j:=ixnewstart to Form1.inx do
               begin
                  if (abs(xpos1[j]-rxboundary[i].fr)<epsilon2) then
                  begin
                     // найден  внутренний  номер j
                     rxboundary[i].bl:=false;
                     ixic2:=5;
                     dx:=(xpos1[j]-xpos1[j-1])/(ixic2);
                     inx2:=Form1.inx-2+2*ixic2;
                     SetLength(Form1.xpos,inx2+1); // нумерация с 1 начинается
                     for k:=1 to j-2 do Form1.xpos[k]:=xpos1[k];
                     for k:=j-1 to (j-1+ixic2-1) do Form1.xpos[k]:=xpos1[j-1] + (k-j+1)*dx;
                     Form1.xpos[j-1+ixic2]:=xpos1[j];
                     dx:=(xpos1[j+1]-xpos1[j])/(ixic2);
                     for k:= (j-1+ixic2+1) to (j-1+2*ixic2) do Form1.xpos[k]:=xpos1[j]+(k-j-ixic2+1)*dx;
                     ixnewstart:=j+2*ixic2;
                     for k:=j+2 to Form1.inx do Form1.xpos[k-2+2*ixic2]:=xpos1[k];
                     Form1.inx:=inx2;
                     SetLength(xpos1,Form1.inx+1);
                     for k:=1 to Form1.inx do xpos1[k]:=Form1.xpos[k];
                     break; // принудительное прерывание цикла по j
                  end;

               end;
            end;
         end;


         // горизонтальные линии
         iposmark:=1;
         SetLength(ypos1,iposmark); // нумерация в массиве xpos[i] начинается с 1.
         for i:=0 to (iycol-1) do
         begin
            dy:=(ryboundary[i+1].fr-ryboundary[i].fr)/(iyintervalcount[i]-1);
            SetLength(ypos1,iposmark + iyintervalcount[i]);
            for k:=iposmark to (iposmark + iyintervalcount[i]-2) do
            begin
               ypos1[k]:= ryboundary[i].fr + (k-iposmark)*dy;
            end;
            iposmark:= iposmark + iyintervalcount[i] - 1;
         end;
         // Добавление последнего узла на самой правой границе:
         SetLength(ypos1, iposmark+1);
         ypos1[iposmark]:=ryboundary[iycol].fr;
         Form1.iny:=iposmark; // количество узлов сетки по вертикали
         // теперь ещё нужен массив связей.
         SetLength(Form1.ypos,Form1.iny+1); // нумерация в массиве xpos[i] начинается с 1.
         for i:=1 to Form1.iny do
         begin
            Form1.ypos[i]:=ypos1[i];
         end;

         // мелкая сетка пограничного слоя
         iynewstart:=1;
         for i:=0 to (iycol-1) do
         begin
            if (ryboundary[i].bl) then
            begin
               for j:=iynewstart to Form1.iny do
               begin
                  if (abs(ypos1[j]-ryboundary[i].fr)<epsilon2) then
                  begin
                     // найден  внутренний  номер j
                     ryboundary[i].bl:=false;
                     iyic2:=5;
                     dy:=(ypos1[j]-ypos1[j-1])/(iyic2);
                     iny2:=Form1.iny-2+2*iyic2;
                     SetLength(Form1.ypos,iny2+1); // нумерация с 1 начинается
                     for k:=1 to j-2 do Form1.ypos[k]:=ypos1[k];
                     for k:=j-1 to (j-1+iyic2-1) do Form1.ypos[k]:=ypos1[j-1] + (k-j+1)*dy;
                     Form1.ypos[j-1+iyic2]:=ypos1[j];
                     dy:=(ypos1[j+1]-ypos1[j])/(iyic2);
                     for k:= (j-1+iyic2+1) to (j-1+2*iyic2) do Form1.ypos[k]:=ypos1[j]+(k-j-iyic2+1)*dy;
                     iynewstart:=j+2*iyic2;
                     for k:=j+2 to Form1.iny do Form1.ypos[k-2+2*iyic2]:=ypos1[k];
                     Form1.iny:=iny2;
                     SetLength(ypos1,Form1.iny+1);
                     for k:=1 to Form1.iny do ypos1[k]:=Form1.ypos[k];
                     break; // принудительное прерывание цикла по j
                  end;

               end;
            end;
         end;

      end;

      SetLength(Form1.yposfix,Form1.iny+1); // для динамической сетки
      for i:=1 to Form1.iny do
      begin
         Form1.yposfix[i]:=Form1.ypos[i];
      end;
   end;
   // Алгоритм.
   // шаг 0. выделение оперативной памяти.
   // шаг 1. сначала все узлы будут считаться внутренними ( с индексом 1).
   // шаг 2. теперь определим узлы которые не принадлежат расчётной бласти (с индексом 0).
   //        примечание: это только самые внутренности hollow блоков без учёта границ.
   // шаг 3. определение угловых узлов (индекс 4). Присвоение узлу индекса 4 только в том случае если
   //        там до этого стоял индекс 1.
   // шаг 4. определение граничных точек (индекс 2). Записываются только в том случае если индекс был 1.
   //        Если индекс уже был равен 2 то присвоить индекс 3.
   // шаг 5. Индекс 3 впоследствии может стать как индексом 0. Так и индексом 2.
   // шаг 6. Некоторые граничные точки могут стать hollow точками индекса 0. Этот случай нужно предусмотреть.
   //        Если информация об угловых точках неважна то все индексы 4 заменить на 2.
   // шаг 7. Особая точка с индексом 5. Это узловая точка : общая вершина для двух прямоугольников,
   //        пересекающихся не более чем в одной этой узловой точке. Эта точка важна для правильного
   //        определения границ.

   // шаг 0.
   SetLength(tnm, Form1.inx*Form1.iny+1); // для каждого узла будет определён его тип
   // шаг 1.
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         // по умолчанию все узлы внутренние.
         tnm[i + (k-1)*Form1.inx].itypenode:=1; // внутренний
      end;
   end;
   // определение пустых узлов не принадлежащих расчётной области:
   // шаг 2.
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         if (inHollow(Form1.xpos[i], Form1.ypos[k])) then
         begin
            tnm[i + (k-1)*Form1.inx].itypenode:=0; // пустой
         end;
      end;
   end;

   (*
    // проверяющий участок кода.
   f:=TStringList.Create();
   for k:=1 to Form1.iny do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+IntToStr(tnm[i + (k-1)*Form1.inx].itypenode) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   // определение граничных узлов
   // шаг 3 и 4.
   // проход по всем прямоугольникам включая кабинет.
   for i:=0 to (maxbrickelem-1) do
   begin
      // шаг 3.
      // левый нижний угол
      myvertex.rx:=bricklist[i].xS;
      myvertex.ry:=bricklist[i].yS;
      ugolsearch(myvertex); // поиск углового узла и вставка информации о нём
      mrp.ixLB:=myvertex.ix;
      mrp.iyLB:=myvertex.iy;
      // правый нижний угол
      myvertex.rx:=bricklist[i].xS + bricklist[i].xL;
      myvertex.ry:=bricklist[i].yS;
      ugolsearch(myvertex); // поиск углового узла и вставка информации о нём
      mrp.ixRB:=myvertex.ix;
      mrp.iyRB:=myvertex.iy;
      // верхний левый угол
      myvertex.rx:=bricklist[i].xS;
      myvertex.ry:=bricklist[i].yS + bricklist[i].yL;
      ugolsearch(myvertex);  // поиск углового узла и вставка информации о нём
      mrp.ixLT:=myvertex.ix;
      mrp.iyLT:=myvertex.iy;
      // верхний правый угол
      myvertex.rx:=bricklist[i].xS + bricklist[i].xL;
      myvertex.ry:=bricklist[i].yS + bricklist[i].yL;
      ugolsearch(myvertex); // поиск углового узла и вставка информации о нём
      mrp.ixRT:=myvertex.ix;
      mrp.iyRT:=myvertex.iy;
      // шаг 4.
      // нижняя стенка:
      for k:=(mrp.ixLB+1) to (mrp.ixRB-1) do
      begin
         case (tnm[k + (mrp.iyLB-1)*Form1.inx].itypenode) of
            1 : // граничный
              begin
                 tnm[k + (mrp.iyLB-1)*Form1.inx].itypenode:=2; // граничный
                 tnm[k + (mrp.iyLB-1)*Form1.inx].chdirect:='x';
              end;
            2 : // повторно граничный (требует дальнейшего рассмотрения)
              begin
                 // этот узел может быть как граничным
                 // так и не принадлежать расчётной области
                 tnm[k + (mrp.iyLB-1)*Form1.inx].itypenode:=3;
              end;
         end;
      end;
      // верхняя стенка
      for k:=(mrp.ixLT+1) to (mrp.ixRT-1) do
      begin
         case (tnm[k + (mrp.iyLT-1)*Form1.inx].itypenode) of
            1 : // граничный
              begin
                 tnm[k + (mrp.iyLT-1)*Form1.inx].itypenode:=2; // граничный
                 tnm[k + (mrp.iyLT-1)*Form1.inx].chdirect:='x';
              end;
            2 : // повторно граничный (требует дальнейшего рассмотрения)
              begin
                 // этот узел может быть как граничным
                 // так и не принадлежать расчётной области
                 tnm[k + (mrp.iyLT-1)*Form1.inx].itypenode:=3;
              end;
         end;
      end;
      // левая стенка
      for k:=(mrp.iyLB+1) to (mrp.iyLT-1) do
      begin
         case (tnm[mrp.ixLB + (k-1)*Form1.inx].itypenode) of
            1 : // граничный
               begin
                  tnm[mrp.ixLB + (k-1)*Form1.inx].itypenode:=2; // граничный
                  tnm[mrp.ixLB + (k-1)*Form1.inx].chdirect:='y';
               end;
            2 : // повторно граничный (требует дальнейшего рассмотрения)
               begin
                  // этот узел может быть как граничным
                  // так и не принадлежать расчётной области
                  tnm[mrp.ixLB + (k-1)*Form1.inx].itypenode:=3;
               end;
         end;
      end;
      // правая стенка
      for k:=(mrp.iyRB+1) to (mrp.iyRT-1) do
      begin
         case (tnm[mrp.ixRB + (k-1)*Form1.inx].itypenode) of
             1 : // граничный узел
                begin
                   tnm[mrp.ixRB + (k-1)*Form1.inx].itypenode:=2; // граничный
                   tnm[mrp.ixRB + (k-1)*Form1.inx].chdirect:='y';
                end;
             2 : // повторно граничный (требует дальнейшего рассмотрения)
                begin
                   // этот узел может быть как граничным
                   // так и не принадлежать расчётной области
                   tnm[mrp.ixRB + (k-1)*Form1.inx].itypenode:=3;
                end;
         end;
      end;

   end;

   (*
   // проверка правильности определения
   // направления всех границ
   // прошла успешно.
   f:=TStringList.Create();
   for k:=Form1.iny downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+(tnm[i + (k-1)*Form1.inx].chdirect) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)


   // шаг 5.
   // обработка точек типа 3 (которые могут стать как hollow так и граничными).
   // Основная идея:
   // узел является граничным если у него с одной стороны от линии chdirect
   // находится hollow block а с другой обязательно внутренняя точка расчётной области.
   // узел принадлежит hollow block если у него с обоих сторон от chdirect находится
   // hollow block ( либо с одной стороны hollow Block а с другой вообще отсутствует внутренность кабинета).
   // Организуем цикл по всем узлам:
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         // если индекс узла равен 3:
         if (tnm[i + (k-1)*Form1.inx].itypenode = 3) then
         begin
            indeks1:=0; indeks2:=0; // по умолчнию hollow point.
            // определяем ориентацию границы:
            case (tnm[i + (k-1)*Form1.inx].chdirect) of
               'x' : // горизонтальная
                   begin
                      // низ
                      if ((k-1) >= 1) then
                      begin
                         indeks1:= tnm[i + (k-2)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks1:=0; // пустая точка
                      end;
                      // верх
                      if ((k+1)<= Form1.iny) then
                      begin
                         indeks2:= tnm[i + (k)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks2:=0; // пустая точка
                      end;
                   end;
               'y' : // вертикальная
                   begin
                      // лево
                      if ((i-1) >= 1) then
                      begin
                         indeks1:= tnm[(i-1) + (k-1)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks1:=0; // пустая точка
                      end;
                      // право
                      if ((i+1) <= Form1.inx) then
                      begin
                         indeks2:= tnm[(i+1) + (k-1)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks2:=0; // пустая точка
                      end;
                   end;
            end;
            if ((indeks1 = 0) and (indeks2 = 0)) then
            begin
               // если с обеих сторон от chdirect пустота
               // значит это пустой узел.
               tnm[i + (k-1)*Form1.inx].itypenode:=0; // пустой узел.
            end
             else
            begin
               // значит это граничный узел.
               // он в принципе может быть и угловым.
               tnm[i + (k-1)*Form1.inx].itypenode:=2; // граничный узел
            end;
         end;
      end;
   end;


   // шаг 6.
   // Некоторые граничные точки могут быть hollow point.
   // Граничная точка является точкой Hollow point в том случае
   // если её окружают четыре hollow point ( с четырёх сторон).
   // Организуем обход по всем граничным точкам:
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         if (tnm[i + (k-1)*Form1.inx].itypenode = 4) then
         begin
            // угловая точка

            // узел слева
            if ((i-1) >= 1) then
            begin
               indeks1:=tnm[(i-1) + (k-1)*Form1.inx].itypenode;
            end
             else
            begin
               indeks1:=0; // находится вне кабинета
            end;
            // узел справа
            if ((i+1) <= Form1.inx) then
            begin
               indeks2:=tnm[(i+1) + (k-1)*Form1.inx].itypenode;
            end
             else
            begin
               indeks2:=0; // находится вне кабинета
            end;
            // узел снизу
            if ((k-1) >= 1) then
            begin
               indeks3:=tnm[i + (k-2)*Form1.inx].itypenode;
            end
             else
            begin
               indeks3:=0; // находится вне кабинета
            end;
            // узел сверху
            if ((k+1) <= Form1.iny) then
            begin
               indeks4:=tnm[i + (k)*Form1.inx].itypenode;
            end
             else
            begin
               indeks4:=0; // находится вне кабинета
            end;
            // теперь вся необходимая информация собрана
            if ((indeks1=0) and (indeks2=0) and (indeks3=0) and (indeks4=0)) then
            begin
               tnm[i + (k-1)*Form1.inx].itypenode:=0; // это hollow point
            end;
         end;
      end;
   end;
   // теперь все угловые узлы сделаем граничыми
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         if (tnm[i + (k-1)*Form1.inx].itypenode = 4) then
         begin
            // угловая точка
            tnm[i + (k-1)*Form1.inx].itypenode:=2;
         end;
      end;
   end;
   // шаг 7.
   // Определение особой узловой точки :
   // единственная общая точка пересечения
   // двух прямоугольников (вершина обоих четырехугольников).
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         if (tnm[i + (k-1)*Form1.inx].itypenode = 2) then
         begin
            // если эта точка не принадлежит границая кабинета:
            if ((i>1) and (i<Form1.inx) and (k>1) and (k<Form1.iny)) then
            begin
               // плюс к тому что эта точка не принадлежит границам кабинета,
               // так ещё она именно та что надо, т.е. окружена с 4 сторон граничными точками:
               if ( (tnm[(i-1) + (k-1)*Form1.inx].itypenode = 2 ) and
                    (tnm[(i+1) + (k-1)*Form1.inx].itypenode = 2 ) and
                    (tnm[i + (k-2)*Form1.inx].itypenode = 2 ) and
                    (tnm[i + (k)*Form1.inx].itypenode = 2 )) then
               begin
                  // особая узловая точка
                  // единственная общая точка (вершина) пересечения двух прямоугольников
                  tnm[i + (k-1)*Form1.inx].itypenode:=5;
               end;
            end;
         end;
      end;
   end;

   // ***********************
   // Теперь для каждой узловой тчки определено какой она является:
   // 0 - не принадлежит расчётной области,
   // 1 - внутренняя точка расчётной области,
   // 2 - граничная точка расчётной области.
   // При этом допускаются довольно сложные взаимопересечения образующих
   // геометрию hollow block`ов.



   // Теперь надо определить границы на которых задаются значения
   // искомых функций:
   // Идея: граница это отрезок содержащий не меньше двух граничных точек,
   // граница располагается в каком-то одном направлении по какой-либо оси.
   // Каждой такой границе соответствует уникальный номер. Дальше границы
   // можно будет объединить в одну составную границу (при необходимости).
   // Совершим обход по всем точкам:

   // инициализация. В качестве номера границы присвоим очень большое число:
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         tnm[i + (k-1)*Form1.inx].ibondary:=1000000000; // трудно представить ситуацию в которой в расчётной области будет 10^4 границ
      end;
   end;
   kflag:=-50; // просто некое число
   b1flag:=false;
   inumboundary:=1; // глобальный внутри данного модуля параметр.
   // Сначала находим и определяем все вертикальные границы.
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         if (tnm[i + (k-1)*Form1.inx].itypenode = 2) then
         begin
            // обнаружена граничная точка надо поднять флаг.
            if (not(b1flag)) then
            begin
               b1flag:=true; // началась граница
               kflag:=k; // номер k при котором был поднят флаг
            end;
            tnm[i + (k-1)*Form1.inx].ibondary:=inumboundary;
         end
          else
         begin
            // Возможное окончание текущей вертикальной границы.
            // если флаг был поднят (мы заполняли текущую границу)
            if (b1flag) then
            begin
               b1flag:=false; // опускаем флаг
               if ((k-kflag) <> 1) then
               begin
                  // только в том случае если это действительно вертикальная граница
                  // иначе это просто граничная точка принадлежащая горизонтальной границе.
                  inc(inumboundary);
               end
                else
               begin
                  // точка принадлежащая горизонтальной границе
                  tnm[i + (kflag-1)*Form1.inx].ibondary:=1000000000;
               end;
            end;
         end;
      end;
      // если флаг был поднят (мы заполняли текущую границу)
      if (b1flag) then
      begin
         b1flag:=false; // опускаем флаг
         if (kflag <> Form1.iny) then
         begin
            // похоже это действительно вертикальная граница
            inc(inumboundary);
         end
          else
         begin
            // значит эта точка принадлежит горизонтальной границе
            tnm[i + (kflag-1)*Form1.inx].ibondary:=1000000000;
         end;
      end;
   end;
   // Теперь находим все горизонтальные границы.
   for k:=1 to Form1.iny do
   begin
      for i:=1 to Form1.inx do
      begin
         if (tnm[i + (k-1)*Form1.inx].itypenode = 2) then
         begin
            // обнаружена граничная точка надо поднять флаг.
            if (not(b1flag)) then
            begin
               b1flag:=true; // началась граница
               kflag:=i; // номер i при котором был поднят флаг
            end;
            if (tnm[i + (k-1)*Form1.inx].ibondary > inumboundary) then
            begin
               // только в том случае если эта точка ещё не принадлежала
               // какой-либо из вертикальных границ.
               tnm[i + (k-1)*Form1.inx].ibondary:=inumboundary;
            end;
         end
          else
         begin
            // Возможное окончание текущей вертикальной границы.
            // если флаг был поднят (мы заполняли текущую границу)
            if (b1flag) then
            begin
               if (tnm[i + (k-1)*Form1.inx].itypenode = 5) then
               begin
                  // Это особый случай единственная общая точка двух
                  // прямоугольников. Точка является вершиной обоих прямоугольников.

                  tnm[i + (k-1)*Form1.inx].itypenode:=2; // это узловая точка
                  tnm[i + (k-1)*Form1.inx].ibondary:=inumboundary;
                  inc(inumboundary);
                  // флаг остаётся поднятым, т.к. следующая граница
                  // начинается прямо сразу
                  kflag:=i+1; // маркер начала следующей границы
               end
                else
               begin
                  b1flag:=false; // опускаем флаг
                  if ((i-kflag) <> 1) then
                  begin
                     // только в том случае если это действительно горизонтальная граница
                     // иначе это просто граничная точка принадлежащая вертикальной границе.
                     inc(inumboundary);
                  end;
               end;
            end;
         end;
      end;
      // если флаг был поднят (мы заполняли текущую границу)
      if (b1flag) then
      begin
         b1flag:=false; // опускаем флаг
         if (kflag <> Form1.inx) then inc(inumboundary);
      end;
   end;
   dec(inumboundary);
   // Заполнение списка границ расчётной области
   SetLength(edgelist,inumboundary+1); // первая граница имеет индекс 1.
   for i:=1 to inumboundary do
   begin
      if (inumboundary=4) then
      begin
         case i of
          1 : begin
                 edgelist[i].boundaryname:='left';
              end;
          2 : begin
                 edgelist[i].boundaryname:='right';
              end;
          3 : begin
                 edgelist[i].boundaryname:='bottom';
              end;
          4 : begin
                 edgelist[i].boundaryname:='top';
              end;
              end;
      end
        else
      begin
        edgelist[i].boundaryname:='edge.'+IntToStr(i); // уникальное имя границы
      end;
      edgelist[i].idescriptor:=i; // уникальный номер границы
      edgelist[i].bsimmetry:=false; // не является границей симметрии
      edgelist[i].bpressure:=false; // на данной границе задаётся нормальная компонента скорости
      edgelist[i].boutflow:=false; // по умолчанию не является выходной границей потока
      edgelist[i].bMarangoni:=false; // условие Марангони не задано.
      edgelist[i].rpressure:=0.0; // давление на границе.
      // задание граничных условий по умолчанию:
      edgelist[i].Vx:=0.0; // условия прилипания:
      edgelist[i].Vy:=0.0; // вектор скорости на границе равен нулю.
      edgelist[i].surfaceTensionGradient:=0.0; // dSigma/dT
      edgelist[i].temperatureclan:=1; // граничные условия первого рода по температуре
      edgelist[i].temperaturecondition:=0.0; // температура равная нулю.
      // По умолчанию функция тока равна нулю на всех границах !
      edgelist[i].chSFval:='c';
      edgelist[i].rSFval:=0.0;
      // для User-Defined Segregated Solver`а.
      edgelist[i].uds1clan:=2; // граничные условия второго рода !
      edgelist[i].uds2clan:=2;
      edgelist[i].uds3clan:=2;
      edgelist[i].uds4clan:=2;
      edgelist[i].uds1condition:='0.0'; // однородные условия Неймана !!!
      edgelist[i].uds2condition:='0.0';
      edgelist[i].uds3condition:='0.0';
      edgelist[i].uds4condition:='0.0';
   end;
   // границы успешно созданы !!!
   Form1.bcreateboundary:=True;
   // Теперь каждой из inumboundary границ присвоен свой уникальный номер.
   // Проверка произведённая ниже подтверждает это.

   (*
   // уникальные идентификаторы границ в расчётной области
   // проверка проходит правильно.
   // проверяющий участок кода.
   f:=TStringList.Create();
   for k:=1 to Form1.iny do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         if (tnm[i + (k-1)*Form1.inx].ibondary<10000) then
         begin
            str:=str+IntToStr(tnm[i + (k-1)*Form1.inx].ibondary) + ' ';
         end
          else
         begin
            str:=str+'0'+' ';
         end;
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   //f.Free;
   // проверяющий участок кода.
    // как поисходит объединение границ
    //f:=TStringList.Create();
    str:='';
    for k:=1 to inumboundary do
    begin
       str:=str+IntToStr(GridGenForm.edgelist[k].idescriptor) + ' ';
    end;
    f.Add(str);
   f.SaveToFile('debug.txt');
   //f.Free;
   *)

   // передача данной информации в главный модуль:
   Form1.imaxnumbernode:=Form1.inx*Form1.iny;
   // определение угловых точек
   // Все угловые точки определяются,
   // классифицируются и отмечаются специальной пометкой (особым номером).
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         tnm[i + (k-1)*Form1.inx].iugol:=8; // инициализация
         if  (tnm[i + (k-1)*Form1.inx].itypenode=2) then
         begin
            // граничный узел
            tnm[i + (k-1)*Form1.inx].iugol:=0; // инициализация
            // для гарантированно внутренней точки
            if ((i<Form1.inx) and (i>1) and (k<Form1.iny) and (k>1)) then
            begin
               // левый нижний угол
               if ((tnm[i + (k)*Form1.inx].itypenode=2) and (tnm[(i+1) + (k-1)*Form1.inx].itypenode=2) and
               (tnm[(i-1) + (k-1)*Form1.inx].itypenode<>2) and (tnm[i + (k-2)*Form1.inx].itypenode<>2)) then
                begin
                   tnm[i + (k-1)*Form1.inx].iugol:=1; // левый нижний угол
                end;
                // правый нижний угол
                if ((tnm[i + (k)*Form1.inx].itypenode=2) and (tnm[(i-1) + (k-1)*Form1.inx].itypenode=2) and
               (tnm[(i+1) + (k-1)*Form1.inx].itypenode<>2) and (tnm[i + (k-2)*Form1.inx].itypenode<>2)) then
                begin
                   tnm[i + (k-1)*Form1.inx].iugol:=2; // правый нижний угол
                end;
                // верхний левый угол
                if ((tnm[i + (k-2)*Form1.inx].itypenode=2) and (tnm[(i+1) + (k-1)*Form1.inx].itypenode=2) and
                (tnm[(i-1) + (k-1)*Form1.inx].itypenode<>2) and (tnm[i + (k)*Form1.inx].itypenode<>2)) then
                begin
                   tnm[i + (k-1)*Form1.inx].iugol:=3; // верхний левый угол
                end;
                // правый верхний угол
                if ((tnm[i + (k-2)*Form1.inx].itypenode=2) and (tnm[(i-1) + (k-1)*Form1.inx].itypenode=2) and
               (tnm[(i+1) + (k-1)*Form1.inx].itypenode<>2) and (tnm[i + (k)*Form1.inx].itypenode<>2)) then
                begin
                   tnm[i + (k-1)*Form1.inx].iugol:=4; // правый верхний угол
                end;
                // пятиточечная звезда как особая угловая точка
                if ((tnm[i + (k-2)*Form1.inx].itypenode=2) and (tnm[(i-1) + (k-1)*Form1.inx].itypenode=2) and
               (tnm[(i+1) + (k-1)*Form1.inx].itypenode=2) and (tnm[i + (k)*Form1.inx].itypenode=2)) then
                begin
                   tnm[i + (k-1)*Form1.inx].iugol:=5; // пятиточечная звезда
                end;
            end
             else
            begin
                if (i=Form1.inx) then
               begin
                  // поиск углов вдоль правой стенки
                  if ( tnm[(i-1) + (k-1)*Form1.inx].itypenode=2) then
                  begin
                      if ((k<Form1.iny) and (tnm[i + (k)*Form1.inx].itypenode=2)) then
                      begin
                         // правый нижний угол
                         tnm[i + (k-1)*Form1.inx].iugol:=2;
                      end;
                      if ((k>1) and (tnm[i + (k-2)*Form1.inx].itypenode=2)) then
                      begin
                         // правый верхний угол
                         tnm[i + (k-1)*Form1.inx].iugol:=4;
                      end;
                  end;
               end;
                if (i=1) then
               begin
                  // поиск углов вдоль левой стенки
                  if ( tnm[(i+1) + (k-1)*Form1.inx].itypenode=2) then
                  begin
                      if ((k<Form1.iny) and (tnm[i + (k)*Form1.inx].itypenode=2)) then
                      begin
                         tnm[i + (k-1)*Form1.inx].iugol:=1;
                      end;
                      if ((k>1) and (tnm[i + (k-2)*Form1.inx].itypenode=2)) then
                      begin
                         tnm[i + (k-1)*Form1.inx].iugol:=3;
                      end;
                  end;
               end;
               if (k=Form1.iny) then
               begin
                  // поиск углов вдоль верхней стенки
                  if (tnm[i + (k-2)*Form1.inx].itypenode=2) then
                  begin
                     if ((i>1) and (tnm[(i-1) + (k-1)*Form1.inx].itypenode=2)) then
                     begin
                        // правый верхний угол
                        tnm[i + (k-1)*Form1.inx].iugol:=4;
                     end;
                     if ((i<Form1.inx) and (tnm[(i+1) + (k-1)*Form1.inx].itypenode=2)) then
                     begin
                        // левый верхний угол
                        tnm[i + (k-1)*Form1.inx].iugol:=3;
                     end;
                  end;
               end;
               if (k=1) then
               begin
                  // поиск углов вдоль нижней стенки
                  if (tnm[i + k*Form1.inx].itypenode=2) then
                  begin
                     if ((i>1) and (tnm[(i-1) + (k-1)*Form1.inx].itypenode=2)) then
                     begin
                        // правый нижний угол угол
                        tnm[i + (k-1)*Form1.inx].iugol:=2;
                     end;
                     if ((i<Form1.inx) and (tnm[(i+1) + (k-1)*Form1.inx].itypenode=2)) then
                     begin
                        // левый нижний угол
                        tnm[i + (k-1)*Form1.inx].iugol:=1;
                     end;
                  end;
               end;

            end;
         end;
       end;
   end;

   (*
   // проверка правильности определения всех
   // угловых точек.
   // в результате проверки точки определяются правильно.
   f:=TStringList.Create();
   for k:=Form1.iny downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+IntToStr(tnm[i + (k-1)*Form1.inx].iugol) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   // определение внутренней нормали к границе

    // Организуем цикл по всем узлам:
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         // если это участок границы между двух узловых точек
         if (tnm[i + (k-1)*Form1.inx].iugol = 0) then
         begin


            // определяем ориентацию границы:
            case (tnm[i + (k-1)*Form1.inx].chdirect) of
               'x' : // горизонтальная
                   begin
                      // низ
                      if ((k-1) >= 1) then
                      begin
                         indeks1:= tnm[i + (k-2)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks1:=0; // пустая точка
                      end;
                      // верх
                      if ((k+1)<= Form1.iny) then
                      begin
                         indeks2:= tnm[i + (k)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks2:=0; // пустая точка
                      end;
                      // вся необходимая информация для переопределения типа узла собрана.
                      // переопределение типа будет произведено ниже
                      if (not((indeks1 = 0) and (indeks2 = 0))) then
                      begin
                         if (indeks1<>0) then
                         begin
                            // низ => S
                            tnm[i + (k-1)*Form1.inx].chnormal:='S';
                         end
                          else
                         begin
                            tnm[i + (k-1)*Form1.inx].chnormal:='N';
                         end;
                      end;
                   end;
               'y' : // вертикальная
                   begin
                      // лево
                      if ((i-1) >= 1) then
                      begin
                         indeks1:= tnm[(i-1) + (k-1)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks1:=0; // пустая точка
                      end;
                      // право
                      if ((i+1) <= Form1.inx) then
                      begin
                         indeks2:= tnm[(i+1) + (k-1)*Form1.inx].itypenode;
                      end
                       else
                      begin
                         indeks2:=0; // пустая точка
                      end;
                      // вся необходимая информация для переопределения типа узла собрана.
                      // переопределение типа будет произведено ниже
                      if (not((indeks1 = 0) and (indeks2 = 0))) then
                      begin
                         if (indeks1<>0) then
                         begin
                            // лево => W
                            tnm[i + (k-1)*Form1.inx].chnormal:='W';
                         end
                          else
                         begin
                            // право => E
                            tnm[i + (k-1)*Form1.inx].chnormal:='E';
                         end;
                      end;
                   end;
            end;
         end;
      end;
    end;


   (*
   // проверка правильности определения всех
   // внутренних нормалей на границах
   // проверка пройдена успешно
   f:=TStringList.Create();
   for k:=Form1.iny downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+(tnm[i + (k-1)*Form1.inx].chnormal) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   // выделение оперативной памяти.
   SetLength(Form1.mapPT, Form1.imaxnumbernode+1);
   for i:=1 to Form1.inx do
   begin
      for k:=1 to Form1.iny do
      begin
         Form1.mapPT[i + (k-1)*Form1.inx].itype:=tnm[i + (k-1)*Form1.inx].itypenode;
         Form1.mapPT[i + (k-1)*Form1.inx].i:=i;
         Form1.mapPT[i + (k-1)*Form1.inx].j:=k;
         Form1.mapPT[i + (k-1)*Form1.inx].iboundary:=tnm[i + (k-1)*Form1.inx].ibondary; // номер границы
         Form1.mapPT[i + (k-1)*Form1.inx].chnormal:=tnm[i + (k-1)*Form1.inx].chnormal; // внутренняя нормаль
         Form1.mapPT[i + (k-1)*Form1.inx].iugol:=tnm[i + (k-1)*Form1.inx].iugol; // вид угловой точки
      end;
   end;
   // Form1.UpdateMap; // теперь UpdateMap влияет и на другие карты, например,  для Vx и Vy
   // поэтому её вызов будет произведён в конце.




   // шахматная сетка
   // горизонтальная скорость
   Form1.imaxnumbernodeVx:=(Form1.inx-1)*Form1.iny; // горизонтальных на одну меньше
   // при обходе карты горизонтальной скорости нумерация начинается с 1
   SetLength(Form1.mapVx,Form1.imaxnumbernodeVx+1); // выделение оперативной памяти
   for i:=1 to (Form1.inx-1) do
   begin
      for k:=1 to Form1.iny do
      begin
         // нужно рассмотреть в структуре tmn пары горизонтальных
         // узлов на одном уровне по к.
         if ((tnm[i+(k-1)*Form1.inx].itypenode=1) and(tnm[(i+1)+(k-1)*Form1.inx].itypenode=1)) then
         begin
            // между ними лежит внутренний узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].itype:=1; // внутренний узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].i:=i;
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].j:=k;
         end;
         if (((tnm[i+(k-1)*Form1.inx].itypenode=2) and (tnm[(i+1)+(k-1)*Form1.inx].itypenode=1))or ((tnm[i+(k-1)*Form1.inx].itypenode=1) and (tnm[(i+1)+(k-1)*Form1.inx].itypenode=2))) then
         begin
            // между ними лежит граничный узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].itype:=2; // граничный  узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].i:=i;
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].j:=k;
            // присваиваем уникальный номер границы
            if ( tnm[i+(k-1)*Form1.inx].itypenode=2) then
            begin
               // граница слева
               Form1.mapVx[i+(k-1)*(Form1.inx-1)].iboundary:=tnm[i+(k-1)*Form1.inx].ibondary;
               Form1.mapVx[i+(k-1)*(Form1.inx-1)].chnormal:='E'; // внутренняя нормаль на восток
            end
             else
            begin
               // граница справа
               Form1.mapVx[i+(k-1)*(Form1.inx-1)].iboundary:=tnm[(i+1)+(k-1)*Form1.inx].ibondary;
               Form1.mapVx[i+(k-1)*(Form1.inx-1)].chnormal:='W'; // внутренняя нормаль смотрит на запад
            end;
         end;
         if ((tnm[i+(k-1)*Form1.inx].itypenode=2) and(tnm[(i+1)+(k-1)*Form1.inx].itypenode=2)) then
         begin
            // между ними лежит внутренний узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].itype:=2; // граничный узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].i:=i;
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].j:=k;
            // левый номер границы
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].iboundary:=tnm[i+(k-1)*Form1.inx].ibondary;
            // ориентация нормали слевой стороны
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].chnormal:=tnm[i+(k-1)*Form1.inx].chnormal;
         end;
         if ((tnm[i+(k-1)*Form1.inx].itypenode=0) or (tnm[(i+1)+(k-1)*Form1.inx].itypenode=0)) then
         begin
            // между ними лежит пустой узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].itype:=0; // пустой узел
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].i:=i;
            Form1.mapVx[i+(k-1)*(Form1.inx-1)].j:=k;
         end;
      end;
   end;
   (*
   // проверка определения типов точек
   f:=TStringList.Create();
   for k:=Form1.iny downto 1 do
   begin
      str:='';
      for i:=1 to (Form1.inx-1) do
      begin
         str:=str+IntToStr(Form1.mapVx[i+(k-1)*(Form1.inx-1)].itype) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   Form1.ugoldetect(Form1.mapVx, Form1.inx-1, Form1.iny);
   (*
   // проверка правильности определения угловых точек
   f:=TStringList.Create();
   for k:=Form1.iny downto 1 do
   begin
      str:='';
      for i:=1 to (Form1.inx-1) do
      begin
         str:=str+(Form1.mapVx[i+(k-1)*(Form1.inx-1)].chnormal) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   // вертикальная скорость
   Form1.imaxnumbernodeVy:=Form1.inx*(Form1.iny-1); // вертикальных точек на одну меньше
   SetLength(Form1.mapVy, Form1.imaxnumbernodeVy+1); // при обходе нумерация начинается с 1
   for i:=1 to Form1.inx do
   begin
      for k:=1 to (Form1.iny-1) do
      begin
         // нужно рассмотреть в структуре tmn пары вертикальных
         // узлов на одной вертикали.
         if ((tnm[i+(k-1)*Form1.inx].itypenode=1) and (tnm[i+k*Form1.inx].itypenode=1)) then
         begin
            // между ними лежит внутренний узел
            Form1.mapVy[i+(k-1)*Form1.inx].itype:=1; // внутренний узел.
            Form1.mapVy[i+(k-1)*Form1.inx].i:=i;
            Form1.mapVy[i+(k-1)*Form1.inx].j:=k;
         end;
         if (((tnm[i+(k-1)*Form1.inx].itypenode=2) and (tnm[i+k*Form1.inx].itypenode=1)) or ((tnm[i+(k-1)*Form1.inx].itypenode=1) and (tnm[i+k*Form1.inx].itypenode=2))) then
         begin
            // между ними лежит граничный узел
            Form1.mapVy[i+(k-1)*Form1.inx].itype:=2; // граничный узел.
            Form1.mapVy[i+(k-1)*Form1.inx].i:=i;
            Form1.mapVy[i+(k-1)*Form1.inx].j:=k;
            if (tnm[i+(k-1)*Form1.inx].itypenode=2) then
            begin
               // граница снизу
               Form1.mapVy[i+(k-1)*Form1.inx].iboundary:=tnm[i+(k-1)*Form1.inx].ibondary; // уникальный номер границы
               Form1.mapVy[i+(k-1)*Form1.inx].chnormal:='N'; // внутренняя нормаль
            end
             else
            begin
               //граница сверху
               Form1.mapVy[i+(k-1)*Form1.inx].iboundary:=tnm[i+k*Form1.inx].ibondary; // уникальный номер границы
               Form1.mapVy[i+(k-1)*Form1.inx].chnormal:='S'; // внутренняя нормаль
            end;
         end;
         if ((tnm[i+(k-1)*Form1.inx].itypenode=2) and (tnm[i+k*Form1.inx].itypenode=2)) then
         begin
            // между ними лежит внутренний граничный узел
            Form1.mapVy[i+(k-1)*Form1.inx].itype:=2; // граничный узел.
            Form1.mapVy[i+(k-1)*Form1.inx].i:=i;
            Form1.mapVy[i+(k-1)*Form1.inx].j:=k;
            // номер нижней граничной точки
            Form1.mapVy[i+(k-1)*Form1.inx].iboundary:=tnm[i+(k-1)*Form1.inx].ibondary;
            Form1.mapVy[i+(k-1)*Form1.inx].chnormal:=tnm[i+(k-1)*Form1.inx].chnormal; // внутренняя нормаль
         end;
         if ((tnm[i+(k-1)*Form1.inx].itypenode=0) or (tnm[i+k*Form1.inx].itypenode=0)) then
         begin
            // между ними лежит пустой узел
            Form1.mapVy[i+(k-1)*Form1.inx].itype:=0; // пустой узел.
            Form1.mapVy[i+(k-1)*Form1.inx].i:=i;
            Form1.mapVy[i+(k-1)*Form1.inx].j:=k;
         end;
      end;
   end;

   (*
   // проверка определения типов точек
   f:=TStringList.Create();
   for k:=(Form1.iny-1) downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+IntToStr(Form1.mapVy[i+(k-1)*Form1.inx].itype) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   Form1.ugoldetect(Form1.mapVy, Form1.inx, Form1.iny-1);
   (*
   // проверка правильности определения угловых точек
   f:=TStringList.Create();
   for k:=(Form1.iny-1) downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+(Form1.mapVy[i+(k-1)*Form1.inx].chnormal) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

   Form1.UpdateMap; // расчёт вспомогательных парметров геометрического свойства  на всех картах

   (*// проверка правильности определения
   // уникальных номеров границ
   f:=TStringList.Create();
   for k:=(Form1.iny-1) downto 1 do
   begin
      str:='';
      for i:=1 to Form1.inx do
      begin
         str:=str+IntToStr(Form1.mapVy[i+(k-1)*Form1.inx].itype) + ' ';
      end;
      f.Add(str);
   end;
   f.SaveToFile('debug.txt');
   f.Free;
   *)

    // структура одной итерации алгоритма SIMPLE
   Form1.iterSimple.iterVxLin:=2;//10; // здесь будет
   Form1.iterSimple.iterVyLin:=2;//10; // нижняя релаксация
   Form1.iterSimple.iterVof:=2;//10;
   Form1.iterSimple.iterPamendment:=4;//Min(Form1.inx,Form1.iny); // для поправки давления
   Form1.iterSimple.iterPressure:=4;//Min(Form1.inx,Form1.iny); // для давления в алгоритме SIMPLER
   // в случае задач с учётом естественной конвекции
   // требуется решать также уравнение теплопроводности
   // здесь даётся оценка сверху для количества итераций
   // в предположении что используется полилинейный солвер.
   Form1.iterSimple.iterTemperature:=2;//Min(Form1.inx,Form1.iny);
   // нахождение функции тока происходит после окончания
   // работы алгоритма SIMPLE
   // максимальное число итераций оценивается равным 9*inx*iny, где 9 = ln(1e4).
   Form1.iterSimple.iterStreamFunction:=10*Min(Form1.inx,Form1.iny); // для нахождения функции тока
   if (not(bfileread)) then
   begin
      if (frmLaunchGenerator.chkfreeUDS.Checked) then
      begin
         // Количество итераций User-Define Scalar:
         Form1.iterSimple.iteruds1:=Min(Form1.inx,Form1.iny);
         Form1.iterSimple.iteruds2:=Min(Form1.inx,Form1.iny);
         Form1.iterSimple.iteruds3:=Min(Form1.inx,Form1.iny);
         Form1.iterSimple.iteruds4:=Min(Form1.inx,Form1.iny);
      end;
   end;
   // Так как сетка изменилась то сброс всех User-Defined Memory
   // если они есть конечно.
   if (Form1.imaxUDM<>0) then
   begin
      if (frmLaunchGenerator.chkrestartSettingUDM.Checked) then
      begin

         case Form1.imaxUDM of
            1 : begin
                   SetLength(Form1.UDM1,0);
                end;
            2 : begin
                   SetLength(Form1.UDM1,0);
                   SetLength(Form1.UDM2,0);
                end;
            3 : begin
                   SetLength(Form1.UDM1,0);
                   SetLength(Form1.UDM2,0);
                   SetLength(Form1.UDM3,0);
                end;
         end;
         if (Form1.imaxUDM>0) then
         begin
            Form1.MainMemo.Lines.Add('Уничтожены все User-Defined Memory. Определите их снова.');
            Application.MessageBox('Уничтожены все User-Defined Memory. Определите их снова.','warning',MB_OK);
         end;
         Form1.imaxUDM:=0; // нет пользовательских скаляров.
      end
      else
      begin
         // По новой выделим память и проинициализируем нулевым значением:
         case Form1.imaxUDM of
            1 : begin
                   SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
                   for icounterudm:=0 to Form1.inx*Form1.iny do
                   begin
                      Form1.UDM1[icounterudm]:=0.0;
                   end;
                end;
            2 : begin
                   SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
                   SetLength(Form1.UDM2,Form1.inx*Form1.iny+1);
                   for icounterudm:=0 to Form1.inx*Form1.iny do
                   begin
                      Form1.UDM1[icounterudm]:=0.0;
                      Form1.UDM2[icounterudm]:=0.0;
                   end;
                end;
            3 : begin
                   SetLength(Form1.UDM1,Form1.inx*Form1.iny+1);
                   SetLength(Form1.UDM2,Form1.inx*Form1.iny+1);
                   SetLength(Form1.UDM3,Form1.inx*Form1.iny+1);
                   for icounterudm:=0 to Form1.inx*Form1.iny do
                   begin
                      Form1.UDM1[icounterudm]:=0.0;
                      Form1.UDM2[icounterudm]:=0.0;
                      Form1.UDM3[icounterudm]:=0.0;
                   end;
                end;
         end;
      end;
   end;

   if (not(bfileread)) then
   begin
      if (frmLaunchGenerator.chkfreeUDS.Checked) then
      begin
         if (Form1.imaxUDS>0) then
         begin
            Form1.MainMemo.Lines.Add('Уничтожены все User-Defined Scalars. Определите их снова.');
            Application.MessageBox('Уничтожены все User-Defined Scalars. Определите их снова.','warning',MB_OK);
         end;
         Form1.imaxUDS:=0;
         // Конвективный член пока полностью выключен (отсутствует).
         Form1.itypemassFluxuds1:=0; // 0 нет конвективного члена (он тождественный ноль)
         Form1.itypemassFluxuds2:=0; // 1 - стандартный конвективный член на основе гидродинамических компонент скорости.
         Form1.itypemassFluxuds3:=0; // 2 - определённый пользователем вариант.
         Form1.itypemassFluxuds4:=0;
         // Нестационарный член :
         Form1.itypeuds1unsteadyfunction:=0; // 0 - стационарная задача.
         Form1.itypeuds2unsteadyfunction:=0; // 1 - стандартная нестационарная задача.
         Form1.itypeuds3unsteadyfunction:=0;
         Form1.itypeuds4unsteadyfunction:=0;
         // Постоянные коэффициенты диффузии :
         Form1.gamma1str:='1.0';
         Form1.gamma2str:='1.0';
         Form1.gamma3str:='1.0';
         Form1.gamma4str:='1.0';
         // Обнуляем источниковый член.
         Form1.dsp1str:='0.0';
         Form1.dsp2str:='0.0';
         Form1.dsp3str:='0.0';
         Form1.dsp4str:='0.0';
         Form1.dsc1str:='0.0';
         Form1.dsc2str:='0.0';
         Form1.dsc3str:='0.0';
         Form1.dsc4str:='0.0';
         // dbetaudsi
         Form1.dbetaUDS1:=0.0;
         Form1.dbetaUDS2:=0.0;
         Form1.dbetaUDS3:=0.0;
         Form1.dbetaUDS4:=0.0;

         // Источниковый член в первом уравнении для диффузионно-дрейфовой модели имеет стандартную форму и это надо
         // учесть для увеличения Быстродействия. ДДМ очень важна поэтому имеет смысл прилагать все усилия чтобы она быстро считала.
         // 0 - стандартный user-defined шаблон.
         // 1 - источниковый член в диффузионно дрейфовой модели (из двух уравнений первое для электрического потенциала, для
         // этого уравнения как раз и задаётся источниковый член, а второе уравнение для переноса электронного газа (именно электронного)).
         // вида K1*(1.0-$uds2), где K1=rdsc1K1 - заданная пользователем постоянная.
         // 2 - аналогично с 1 но источник имеет вид $udm1-K1*$uds2, здесь $udm1 - неоднородное легирование,
         // $uds2 - концентрация электронов, K1=rdsc1K1 - константа определённая пользователем.
         Form1.idsc1type:=0;
         Form1.rdsc1K1:=0.0;
         // Следующая булева переменная равна True только тогда когда в момент вычисления
         // для первого уравнения имеем константу dSpравную нулю тождественно, и константный коэффициент диффузии.
         // Значение True проверяется и в случае необходимости присваивается внутри simple algorithm`a
         // в ручную значение False здесь менять ни в коем случае нельзя !!!
         Form1.buds1coefconst:=False;
         Form1.diffuds1const:=1.0; // константный коэффициент диффузии для первого уравнения во всей расчётной области,
         // используется только при buds1coefconst=true;

         // Для конвективного члена определённого пользователем.
         // определяются на сетке для компонент скорости.
         // Можно использовать переменные :
         // $x и $y - декартовы координаты.
         // для горизонтальных скоростей можно использовать $gradxuds1, $gradxuds2, $gradxuds3.
         // для вертикальных скоростей можно использовать переменные $gradyuds1, $gradyuds2, $gradyuds3.
         Form1.Vxuds1str:='0.0';
         Form1.Vyuds1str:='0.0';
         Form1.Vxuds2str:='0.0';
         Form1.Vyuds2str:='0.0';
         Form1.Vxuds3str:='0.0';
         Form1.Vyuds3str:='0.0';
         Form1.Vxuds4str:='0.0';
         Form1.Vyuds4str:='0.0';

         // Плотность.
         // 0 - константа равная единице (потом можно сделать константу задаваемую пользователем),
         // гидродинамическая плотность задаваемая пользователем для гидродинамики в частности и для VOF метода.
         Form1.iuds1typerho:=0;
         Form1.iuds2typerho:=0;
         Form1.iuds3typerho:=0;
         Form1.iuds4typerho:=0;
         // Записано ли уравнение для User-Defined Scalar`a на маске или нет.
         // Узлы не принадлежащие маске заморожены в момент инициализации.
         Form1.imaskuds1:=0; // рассчитывать ли uds1 используюя маску 0 - нет (вся расчётная область), 1 - использовать маску.
         Form1.imaskuds2:=0; // по умолчанию вся расчётная область.
         Form1.imaskuds3:=0;
         Form1.imaskuds4:=0;

         // Началные значения :
         Form1.InitVal.UDS1Init:='0.0';
         Form1.InitVal.UDS2Init:='0.0';
         Form1.InitVal.UDS3Init:='0.0';
         Form1.InitVal.UDS4Init:='0.0';
         // Схема аппроксимации для UDS.
         Form1.ishconv1:=6; // схема Булгакова.
         Form1.ishconv2:=6; // схема Булгакова.
         Form1.ishconv3:=6; // схема Булгакова.
         Form1.ishconv4:=6; // схема Булгакова.

         // тип Решающего устройства
         // 1 - поточечный метод Гаусса-Зейделя.
         Form1.itypesolver.iuds1:=1;
         Form1.itypesolver.iuds2:=1;
         Form1.itypesolver.iuds3:=1;
         Form1.itypesolver.iuds4:=1;

         // контроль сходимости
         // вычислительного процесса
         Form1.rcs.uds1:=1.0e-9;
         Form1.rcs.uds2:=1.0e-9;
         Form1.rcs.uds3:=1.0e-9;
         Form1.rcs.uds4:=1.0e-9;
      end;
   end;

      // Сброс всех пользовательских переменных.
      // нет parametric trial.
      Form1.ivar_trial:=0; // количество переменных  для parametric trial
      SetLength(Form1.base_value_trial,0);
      Application.MessageBox('Сброшены все parametric trials.','warning',MB_OK);

      // при объединении границ это должно отразится на картах mapVx, mapVy.
      iwhotvisible:=1; // прорисовка сетки
      drawmesh;

end;

// Возвращает истину если на всех границах для давления стоит однородное
// условие Неймана.
function TGridGenForm.bVabishevichPressureAvgZero() : Boolean;
var
   i : Integer;
   bret : Boolean;
begin
   bret:=True;
   for i:=1 to inumboundary do
   begin
      // bret - false нулевое давление на границе
      // bret - true условие Неймана для давления
      if (edgelist[i].bpressure) then bret:=false
      else if (edgelist[i].boutflow) then bret := false;
   end;
   Result:=bret;
end;


// эвляется ли граничный узел узлом
// для которого поставлено условие Неймана.
function TGridGenForm.isneiman(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
// внутрь передаётся уникальный дескриптор границы
var
   bret : Boolean;
   i : Integer;

begin
   bret:=false;
   case chvariable of
   'O' : begin
            // все другие переменные
             bret:=false; // условие I рода
         end;
   'P' : begin
            for i:=1 to inumboundary do
            begin
                if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   // bret - false нулевое давление на границе
                   // bret - true условие Неймана для давления
                   if (edgelist[i].bpressure) then bret:=false
                   else if (edgelist[i].boutflow) then bret := false
                   else bret:=true;
                end;
            end;
         end;
     'S' : begin
            // функция тока
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   if (edgelist[i].chSFval='n') then
                   begin
                      bret:=true; // условие Неймана
                   end;
                end;
            end;
         end;
     'T' : begin
            // температура
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   if (edgelist[i].temperatureclan=2) then
                   begin
                      bret:=true; // условие Неймана
                   end;
                end;
            end;
         end;
      'C' : begin
            // User-Defined Scalar
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   case Form1.icurentuds of
                     1 : begin
                            if (edgelist[i].uds1clan=2) then
                            begin
                               bret:=true; // условие Неймана
                            end;
                         end;
                     2 : begin
                            if (edgelist[i].uds2clan=2) then
                            begin
                               bret:=true; // условие Неймана
                            end;
                         end;
                     3 : begin
                            if (edgelist[i].uds3clan=2) then
                            begin
                               bret:=true; // условие Неймана
                            end;
                         end;
                     4 : begin
                            if (edgelist[i].uds4clan=2) then
                            begin
                               bret:=true; // условие Неймана
                            end;
                         end;
                   end;

                end;
            end;
         end;
     end;
     Result:=bret;
end;

// эвляется ли граничный узел
// для которого поставлены мягкие граничные условия.
function TGridGenForm.isoutflow(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
// внутрь передаётся уникальный дескриптор границы
var
   bret : Boolean;
   i : Integer;

begin
   bret:=false;
   case chvariable of
   'T' : begin
            // температура
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   if (edgelist[i].temperatureclan=3) then
                   begin
                      // мягкие граничный условия выходная граница потока
                      bret:=true;
                   end;
                end;
            end;
         end;
    'U' : begin
             // горизонтальная скорость
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   if ((edgelist[i].boutflow) or (edgelist[i].bpressure)) then
                   begin
                      bret:=true;
                   end;
                end;
            end;
          end;
    'V' : begin
             // вертикальная скорость
            for i:=1 to inumboundary do
            begin
                if (edgelist[i].idescriptor = idescbon)  then
                begin
                   // граница найдена
                   if ((edgelist[i].boutflow) or (edgelist[i].bpressure)) then
                   begin
                      bret:=true;
                   end;
                end;
            end;
         end;
     'P' : begin
              // поправка давления
              for i:=1 to inumboundary do
            begin
                if (edgelist[i].idescriptor = idescbon)  then
                begin
                   // граница найдена
                   if ((edgelist[i].boutflow)) then
                   begin
                      bret:=true;
                   end;
                end;
            end;
           end;
   end; // case

   Result:=bret; // возвращаемое значение

end;

// является ли граничный узел
// узлом на котором поставлено условие Марангони по скорости.
function TGridGenForm.isMarangoni(idescbon : Integer; var mstress : Float; chnormal : Char): Boolean;
// внутрь передаётся уникальный дескриптор границы
var
   bret : Boolean;
   i : Integer;

begin
   bret:=false;
   mstress:=0.0; // Surface Tension Gradient

   for i:=1 to inumboundary do
   begin
      if (edgelist[i].idescriptor = idescbon) then
      begin
         // граница найдена
         if (edgelist[i].bMarangoni) then
         begin
            bret:=true;
            mstress:=edgelist[i].surfaceTensionGradient; // dsigma/dTemperature.
         end;
      end;
   end;

   Result:=bret;
end;

// эвляется ли граничный узел
// границей симметрии
function TGridGenForm.issimm(idescbon : Integer; chvariable : Char; chnormal : Char): Boolean;
// внутрь передаётся уникальный дескриптор границы
var
   bret : Boolean;
   i : Integer;

begin
   bret:=false;
   case chvariable of
   'T' : begin
            // температура
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   // граница найдена
                   if (edgelist[i].temperatureclan=4) then
                   begin
                      // граница симметрии
                      bret:=true;
                   end;
                end;
            end;
         end;
   'U' : begin
            // горизонтальная скорость
            for i:=1 to inumboundary do
            begin
               if (edgelist[i].idescriptor = idescbon) then
                begin
                   if (edgelist[i].bsimmetry) then
                   begin
                      bret:=true;
                   end;
                end;
            end;
         end;
   'V' : begin
            // вертикальная скорость
            for i:=1 to inumboundary do
            begin
                if (edgelist[i].idescriptor = idescbon)  then
                begin
                   // граница найдена
                   if (edgelist[i].bsimmetry) then
                   begin
                      bret:=true;
                   end;
                end;
            end;
         end;

     end;  // case
     Result:=bret;
end;

// является ли граничный узел
// для которого поставлено условие неймана
// здесь также передаётся значение потока через границу.
// Для функции цвета.
function TGridGenForm.isneimanVof(idescbon : Integer; var qbpot : Float; chnormal : Char): Boolean;
begin
   isneimanVof:=true; // на всей границе однородные условия Неймана.
   qbpot:=0.0;
end;

// является ли граничный узел
// для которого поставлено условие неймана
// здесь также передаётся значение теплового потока через границу.
function TGridGenForm.isneimanqb(idescbon : Integer; chvariable : Char; var qbpot : Float): Boolean;
var
   bret : Boolean;
   i : Integer;
   //bOk : Boolean;
begin
   bret:=false;
   case (chvariable) of
    'T' : // температура
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // граница найдена
                 if (edgelist[i].temperatureclan=2) then
                 begin
                    // Задан тепловой поток.
                    bret:=true;
                    qbpot:=edgelist[i].temperaturecondition; // значение теплового потока через границу
                 end
                 else if (edgelist[i].temperatureclan=4) then
                 begin
                    // Граница симметрии.
                    // Задан нулевой тепловой поток.
                    bret:=true;
                    qbpot:=0.0; // значение теплового потока через границу
                 end
                  else if (edgelist[i].temperatureclan=3) then
                 begin
                    // Выходная граница, Uipi=2*Ui-Uii.
                    bret:=false;
                    //qbpot:=0.0; // значение теплового потока через границу
                 end;
              end;
           end;
        end;
    'S' : // функция тока
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // граница найдена
                 if (edgelist[i].chSFval='n') then
                 begin
                    bret:=true;
                    qbpot:=edgelist[i].rSFval; // значение "теплового потока" через границу
                 end;
              end;
           end;
        end;
    'C' : // User-Defined Scalar
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // Предполагается, что условие Неймана не параметризовано !!!.

                 // граница найдена
                 case Form1.icurentuds of
                 1 : begin
                        if (edgelist[i].uds1clan=2) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds1condition,bOk); // значение теплового потока через границу
                           qbpot:=StrToFloat(edgelist[i].uds1condition);
                        end;
                     end;
                 2 : begin
                        if (edgelist[i].uds2clan=2) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds2condition,bOk); // значение теплового потока через границу
                           qbpot:=StrToFloat(edgelist[i].uds2condition);
                        end;
                     end;
                 3 : begin
                        if (edgelist[i].uds3clan=2) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds3condition,bOk); // значение теплового потока через границу
                           qbpot:=StrToFloat(edgelist[i].uds3condition);
                        end;
                     end;
                 4 : begin
                        if (edgelist[i].uds4clan=2) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds4condition,bOk); // значение теплового потока через границу
                           qbpot:=StrToFloat(edgelist[i].uds4condition);
                        end;
                     end;
                 end;
              end;
           end;
        end;
   end; // case
    Result:=bret;
end;


// является ли граничный узел
// для которого поставлено условие Дирихле
function TGridGenForm.isDirichlet(idescbon : Integer; chvariable : Char; var DirichVal : Float): Boolean;
var
   bret : Boolean;
   i : Integer;
   //bOk : Boolean;
begin

  if ( chvariable='S') then
  begin
     ShowMessage('случай не предусмотрен программистом!');
  end;

  // DirichVal возвращает значение Дирхле на границе РО.
   bret:=false;
   case (chvariable) of
    'T' : // температура
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // граница найдена
                 if (edgelist[i].temperatureclan=1) then
                 begin
                    // Задан тепловой поток.
                    bret:=true;
                    DirichVal:=edgelist[i].temperaturecondition;
                 end;
              end;
           end;
        end;
        (*
    'S' : // функция тока
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // граница найдена
                 if (edgelist[i].chSFval='n') then
                 begin
                    bret:=true;
                    qbpot:=edgelist[i].rSFval; // значение "теплового потока" через границу
                 end;
              end;
           end;
        end;        *)
    'C' : // User-Defined Scalar
        begin
           for i:=1 to inumboundary do
           begin
              // если дескриптор узла совпал с дискриптором границы
              if (edgelist[i].idescriptor = idescbon) then
              begin
                 // Предполагается, что условие Неймана не параметризовано !!!.

                 // граница найдена
                 case Form1.icurentuds of
                 1 : begin
                        if (edgelist[i].uds1clan=1) then
                        begin
                           // Задано значение функции.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds1condition,bOk); // значение теплового потока через границу
                           DirichVal:=StrToFloat(edgelist[i].uds1condition);
                        end;
                     end;
                 2 : begin
                        if (edgelist[i].uds2clan=1) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds2condition,bOk); // значение теплового потока через границу
                           DirichVal:=StrToFloat(edgelist[i].uds2condition);
                        end;
                     end;
                 3 : begin
                        if (edgelist[i].uds3clan=1) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds3condition,bOk); // значение теплового потока через границу
                           DirichVal:=StrToFloat(edgelist[i].uds3condition);
                        end;
                     end;
                 4 : begin
                        if (edgelist[i].uds4clan=1) then
                        begin
                           // Задан тепловой поток.
                           bret:=true;
                           //bOk:=True;
                           //qbpot:=Form1.my_real_convert(edgelist[i].uds4condition,bOk); // значение теплового потока через границу
                           DirichVal:=StrToFloat(edgelist[i].uds4condition);
                        end;
                     end;
                 end;
              end;
           end;
        end;
   end; // case
    Result:=bret;
end;

// Задан ли на границе ток равный нулю.
function TGridGenForm.isCzerocurent(idescbon : Integer) : Boolean;
var
   bret : Boolean;
   i : Integer;

begin
  // User-Defined Scalar
  bret:=False;

  for i:=1 to inumboundary do
  begin
     // если дескриптор узла совпал с дискриптором границы
     if (edgelist[i].idescriptor = idescbon) then
     begin
        // граница найдена
        case Form1.icurentuds of
         1 : begin
                if (edgelist[i].uds1clan=3) then
                begin
                   // Задан ток равный нулю.
                   bret:=true;
                end;
             end;
        2 : begin
               if (edgelist[i].uds2clan=3) then
               begin
                 // Задан ток равный нулю.
                 bret:=true;
               end;
            end;
        3 : begin
               if (edgelist[i].uds3clan=3) then
               begin
                  // Задан ток равный нулю.
                  bret:=true;
               end;
            end;
        4 : begin
               if (edgelist[i].uds4clan=3) then
               begin
                  // Задан ток равный нулю.
                  bret:=true;
               end;
            end;
        end;
     end;
  end;

  Result:=bret;
end;

// Задан ли на границе нулевой нормальный диффузионный ток ?
function TGridGenForm.isCzeroDiff(idescbon : Integer) : Boolean;
var
   bret : Boolean;
   i : Integer;

begin
  // User-Defined Scalar
  bret:=False;

  for i:=1 to inumboundary do
  begin
     // если дескриптор узла совпал с дискриптором границы
     if (edgelist[i].idescriptor = idescbon) then
     begin
        // граница найдена
        case Form1.icurentuds of
         1 : begin
                if (edgelist[i].uds1clan=4) then
                begin
                   // Задан ток равный нулю.
                   bret:=true;
                end;
             end;
        2 : begin
               if (edgelist[i].uds2clan=4) then
               begin
                 // Задан ток равный нулю.
                 bret:=true;
               end;
            end;
        3 : begin
               if (edgelist[i].uds3clan=4) then
               begin
                  // Задан ток равный нулю.
                  bret:=true;
               end;
            end;
        4 : begin
               if (edgelist[i].uds4clan=4) then
               begin
                  // Задан ток равный нулю.
                  bret:=true;
               end;
            end;
        end;
     end;
  end;

  Result:=bret;
end;

// свободный металл.
function TGridGenForm.isFreeMetall(idescbon : Integer) : Boolean;
var
   bret : Boolean;
   i : Integer;

begin
  // User-Defined Scalar
  bret:=False;

  for i:=1 to inumboundary do
  begin
     // если дескриптор узла совпал с дискриптором границы
     if (edgelist[i].idescriptor = idescbon) then
     begin
        // граница найдена
        case Form1.icurentuds of
         1 : begin
                if (edgelist[i].uds1clan=5) then
                begin
                   // Задан металл с нефиксированным значением потенциала.
                   bret:=true;
                end;
             end;
        2 : begin
               if (edgelist[i].uds2clan=5) then
               begin
                 // Задан металл с нефиксированным значением потенциала.
                 bret:=true;
               end;
            end;
        3 : begin
               if (edgelist[i].uds3clan=5) then
               begin
                  // Задан металл с нефиксированным значением потенциала.
                  bret:=true;
               end;
            end;
        4 : begin
               if (edgelist[i].uds4clan=5) then
               begin
                  // Задан металл с нефиксированным значением потенциала.
                  bret:=true;
               end;
            end;
        end;
     end;
  end;
   Result:=bret;
end;

// простейший генератор расчётной сетки
procedure TGridGenForm.GenerateMeshButtonClick(Sender: TObject);
var
   iwhotvisiblemem : Integer; // на время построения сетки просрисовка не вызывается !!!
begin
   iwhotvisiblemem:=iwhotvisible;
   iwhotvisible:=-1; // рисуем геометрию.
   if (maxbrickelem=1) then
   begin
      frmLaunchGenerator.chkonlyadditionalunicalmeshline.Visible:=True;
   end
   else
   begin
      frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked:=False; // только обычный сеточный генератор.
      frmLaunchGenerator.chkonlyadditionalunicalmeshline.Visible:=False;
   end;
   frmLaunchGenerator.ShowModal;
   mysimplemeshgen; // генерация расчётной сетки
   // Проверка готовности алгоритма Федоренко !!!
   if (maxbrickelem=1) then
   begin
      // Если только прямоугольная область !!!
      if (((Form1.inx-1) mod Form1.sFedor.q = 0) and ((Form1.iny-1) mod Form1.sFedor.q = 0)) then
      begin
         Form1.sFedor.bready:=True;
         // размеры грубой сетки.
         Form1.sFedor.inxc:=Round((Form1.inx-1)/Form1.sFedor.q)+1;
         Form1.sFedor.inyc:=Round((Form1.iny-1)/Form1.sFedor.q)+1;
         Application.MessageBox('сетка поддерживает алгоритм Р.П.Федоренко 1961г.','УРА !!!',MB_OK);
      end
       else
      begin
         Form1.sFedor.bready:=False;
         Form1.sFedor.inxc:=0;
         Form1.sFedor.inyc:=0;
      end; 
   end;


   iwhotvisible:=iwhotvisiblemem;

   // сообщение об успешной генерации расчётной сетки.
   Application.MessageBox('сетка сгенерирована успешно','',MB_OK);
   if (Form1.actiVibr.bOn=True) then
   begin
      Form1.actiVibr.bOn:=False;
      Form1.actiVibr.bBridshmen:=False;
      Application.MessageBox('Dynamic Mesh автоматически выключен. Если Вы хотите его использовать, то настройте заново.','',MB_OK);
   end;
end;

// процедура прорисовки сетки
procedure TGridGenForm.drawmesh;
const
     ih = 453; // высота
var
    w,h,irh : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Real; // масштабирующий коэффициент
    i,j : Integer; // счётчик

begin
   // определение высоты и ширины расчётной
   // области в пикселах
   with GridGenForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    GridGenForm.Width:= 400 + 2*ibort + round(Form1.dLx*m);
    irh:= 76 + 2*ibort + round(Form1.dLy*m);
    GridGenForm.Height:= max(ih,irh);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with GridGenForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    myfonclean; // очистка фона
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
           // горизонтальные линии сетки
           PaintBox1.Canvas.MoveTo(ibort,h-(ibort+round(ypos[j]*m)));
           PaintBox1.Canvas.LineTo(ibort+round(dLx*m),h-(ibort+round(ypos[j]*m)));
       end;
    end; // with Form1


    // учёт расположения hollow block
    for i:=1 to (maxbrickelem-1) do
    begin
         pxs:= ibort + round(bricklist[i].xS*m);
         pxe:= ibort + round((bricklist[i].xS+ bricklist[i].xL)*m);
         pys:= h - (ibort + round(bricklist[i].yS*m));
         pye:= h - (ibort + round((bricklist[i].yS + bricklist[i].yL)*m));
         PaintBox1.Canvas.Rectangle(pxs,pys,pxe,pye);
    end;

    PaintBox1.Canvas.Pen.Color:=clBlack; // возвращаем цвет пера на чёрный
end; // прорисовка сетки

// прорисовка расчётной сетки
procedure TGridGenForm.MeshButtonClick(Sender: TObject);
begin
   iwhotvisible:=1;
   drawmesh; // прорисовка расчётной сетки
end;

// изменение размеров кабинета
procedure TGridGenForm.CabinetButtonClick(Sender: TObject);
begin
   // инициализация
   Cabinet2DForm.EdLx.Text:=FloatToStr(Form1.dLx); // длина
   Cabinet2DForm.EdLy.Text:=FloatToStr(Form1.dLy); // высота
   // вызов диалога
   Cabinet2DForm.ShowModal;
   iwhotvisible:=0; // сброс настроек на прорисовку геометрии модели.
   drawgeom; // прорисовка геометрии
end;

// простейший редактор граничных условий
procedure TGridGenForm.ButtonBoundaryConditionClick(Sender: TObject);
var
    i : Integer; // счётчик

begin
   BonConRedoForm.CheckListBoxBoundaryCondition.Items.Clear; // очистка списка границ

   for i:=1 to inumboundary do
   begin
      BonConRedoForm.CheckListBoxBoundaryCondition.Items.Add(edgelist[i].boundaryname);
   end;
   iwhatvisibleshadow:=iwhotvisible;
   BonConRedoForm.ShowModal;
   iwhotvisible:=iwhatvisibleshadow;
end;

// подсветка выбранных границ
// уникальные номера подсвечиваемых границ указаны в целочисленном массиве
procedure TGridGenForm.drawboundary(var ibon : array of Integer; ilength : Integer);
const
      ih = 453; // высота
var
    w,h : Integer;
    ibort : Integer; // бортик для отступа от краёв
    pxs, pxe, pys, pye : Integer; // края прямоугольника.
    m : Real; // масштабирующий коэффициент
    i,j,k,ihr : Integer; // счётчики
    b1, b2 : Boolean; // проверка данного узла

begin
   // Этот метод отмечает выделенные границы.
   // его надо вызывать после метода drawgeom.

   // определение высоты и ширины расчётной
   // области в пикселах
   with GridGenForm.PaintBox1 do
   begin
      w:=Width; // ширина в пикселах
      h:=Height;  // высота в пикселах
   end;

    ibort:=15; // бортик в 15 пикселей
    m:=min((h-2*ibort)/Form1.dLy,(w-2*ibort)/Form1.dLx); // масштабирующий коэффициент

    // изменение размеров окна отображения в соответствии с расчётной сеткой
    GridGenForm.Width:= 400 + 2*ibort + round(Form1.dLx*m);
    ihr:=76 + 2*ibort + round(Form1.dLy*m);
    GridGenForm.Height:=max(ih,ihr);
    // как тока размеры изменены, то генерируется событие изменение размеров PaintBox1
    with GridGenForm.PaintBox1 do
    begin
      h:=Height;  // высота в пикселах
    end;

    PaintBox1.Canvas.Brush.Color:=clRed;
    for k:=0 to (ilength-1) do
    begin
       for i:=1 to Form1.inx do
       begin
          for j:=1 to Form1.iny do
          begin
             b1:=false; // сброс условий
             b2:=false; // сброс условий
             if (tnm[i + (j-1)*Form1.inx].itypenode = 2) then
             begin
                // граничный узел
                b1:=true;
             end;
             if (tnm[i + (j-1)*Form1.inx].ibondary = ibon[k]) then
             begin
                // граничный узел с выделенной границы
                b2:=true;
             end;
             if (b1 and b2) then
             begin
                // xpos[i], ypos[j] - вещественные координаты граничного узла.
                pxs:= ibort + round(m*Form1.xpos[i]) - 5;
                pxe:= ibort + round(m*Form1.xpos[i]) + 5;
                pys:= h - (ibort + round(m*Form1.ypos[j]) - 5);
                pye:= h - (ibort + round(m*Form1.ypos[j]) + 5);
                PaintBox1.Canvas.Ellipse(pxs,pys,pxe,pye);
             end;
          end;
       end;
    end;
    PaintBox1.Canvas.Brush.Color:=clWhite; // возвращаем цвет кисти на белый
end;

// удаление выделенного hollow - блока
procedure TGridGenForm.BDelClick(Sender: TObject);
var
    i,j,k : Integer; // счётчики
    bricklistshadow : array of mybrick;
begin
    j:=-1;
   // запуск цикла по всем элементам списка
   for i:=0 to (CheckListBox1.Items.Count-1) do
   begin
      if CheckListBox1.Checked[i] then
      begin
         // i-ый элемент выделен
         j:=i; // запоминаем  номер выделенного элемента
      end;
   end;
   // Если j=0 то это кабинет а кабинет удалять нельзя !!!.
   if (j=0) then
   begin
      Application.MessageBox('Невозможно удалить кабинет. Для формирования нужной формы используйте hollow blockи','abort',MB_OK);
      Form1.MainMemo.Lines.Add('Невозможно удалить кабинет. Для формирования нужной формы используйте hollow blockи');
   end;
   if (j>0) then
   begin
      SetLength(bricklistshadow,maxbrickelem-1);
      k:=0;
      for i:=0 to maxbrickelem-1 do
      begin
         if (i<>j) then
         begin
            // формирование теневого списка
            // элементов в который входят
            // все элементы без выделенного.
            // присваивание структуры как единого целого.
            bricklistshadow[k]:=bricklist[i];
            inc(k);
         end;
      end;
      dec(maxbrickelem);
      SetLength(bricklist,maxbrickelem);
      CheckListBox1.Clear;
      for i:=0 to maxbrickelem-1 do
      begin
         bricklist[i].xS:=bricklistshadow[i].xS;
         bricklist[i].yS:=bricklistshadow[i].yS;
         bricklist[i].xL:=bricklistshadow[i].xL;
         bricklist[i].yL:=bricklistshadow[i].yL;
         bricklist[i].bbl:=bricklistshadow[i].bbl;
         if (i=0) then
         begin
            CheckListBox1.Items.Add('cabinet');
         end
          else
         begin
            CheckListBox1.Items.Add('block'+IntToStr(i+1));
         end;
      end;
      // прорисовка геометрии
      drawgeom;
      if (Form1.actiVibr.bOn=True) then
      begin
         Form1.actiVibr.bOn:=False;
         Form1.actiVibr.bBridshmen:=False;
         Application.MessageBox('Был удалён блок. Dynamic Mesh автоматически выключен. Если Вы хотите его использовать, то настройте заново.','',MB_OK);
      end;
   end;
end;

// По нажатию на кнопку будет происходить переименование выделенного блока
procedure TGridGenForm.BrenameClick(Sender: TObject);
var
    i : Integer; // Счётчик
    CaptionStr : String;

begin
   // переименование выделенного блока
   for i:=0 to CheckListBox1.Items.Count-1 do
   begin
      if (CheckListBox1.Checked[i]) then
      begin
         CaptionStr:=CheckListBox1.Items[i]; // инициализация
         if not InputQuery('Ввод имени', 'Введите уникальное имя блока', CaptionStr)
         then exit; // срочное завершение обрабтки данного события, т.к. имя не введено

         CheckListBox1.Items[i]:=CaptionStr;
         // добавление изменённого имени
      end;
   end;
end;

// редактирование, изменение размеров существующего блока.
procedure TGridGenForm.BResizeClick(Sender: TObject);
var
    i : Integer;
begin
   for i:=0 to CheckListBox1.Items.Count-1 do
   begin
      if (CheckListBox1.Checked[i]) then
      begin
        if (i=0) then
        begin
           // Cabinet
           HBlockRedoForm.Caption:='редактирование кабинета';
           HBlockRedoForm.GroupBox1.Caption:='размеры кабинета';
           HBlockRedoForm.GroupBox2.Caption:='редактирование кабинета';
           HBlockRedoForm.GroupBox3.Visible:=False;
           HBlockRedoForm.Edit1.Visible:=False;
           HBlockRedoForm.Edit2.Visible:=False;
        end
        else
        begin
           // Hollow block
           HBlockRedoForm.Caption:='редактирование hollow blocka';
           HBlockRedoForm.GroupBox1.Caption:='размеры и положение блока';
           HBlockRedoForm.GroupBox2.Caption:='редактирование hollow блока';
           HBlockRedoForm.GroupBox3.Visible:=True;
           HBlockRedoForm.Edit1.Visible:=True;
           HBlockRedoForm.Edit2.Visible:=True;
        end;
         // загрузить в окошко текущие размеры
         HBlockRedoForm.Edit1.Text:=FloatToStr(bricklist[i].xS);
         HBlockRedoForm.Edit2.Text:=FloatToStr(bricklist[i].yS);
         HBlockRedoForm.Edit3.Text:=FloatToStr(bricklist[i].xL);
         HBlockRedoForm.Edit4.Text:=FloatToStr(bricklist[i].yL);
         // наличие пограничного слоя
         HBlockRedoForm.CheckBox1.Checked:=bricklist[i].bbl;
         // вызов окошка с параметрами для редактирования
         HBlockRedoForm.ShowModal;
         drawgeom; // прорисовка изменённой геометрии
      end;
   end;
end;

// процедура записи текущей сетки в файл
procedure TGridGenForm.writeMesh(Sender: TObject; filename : string);
const
   epsilon = 1e-35; // для определения вещественного нуля
var
   f : TStrings; // переменная типа объект TStringList
   s : string; // записываемая строка и имя записываемого файла
   i,i1,j1 : Integer; // счётчики
   ic1, ic2, ic3 : Integer; // количество граничных узлов для каждой из границ на разных картах.

begin
   f:=TStringList.Create();
   // Запишем информацию об UDS
   s:=IntToStr(Form1.imaxUDS)+': '+IntToStr(Form1.itypemassFluxuds1)+': '+
   IntToStr(Form1.itypemassFluxuds2)+': '+
   IntToStr(Form1.itypemassFluxuds3)+': '+
   IntToStr(Form1.itypemassFluxuds4)+': ';
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[0].drho)+': '; // плотность
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[0].dlambda)+': '; // теплопроводность
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[0].dcp)+': '; // теплоёмкость при постоянном давлении
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[0].dmu)+': '; // динамическая вязкость
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[0].beta)+': '; // коэффициент линейного температурного расширения
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[1].drho)+': '; // плотность
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[1].dlambda)+': '; // теплопроводность
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[1].dcp)+': '; // теплоёмкость при постоянном давлении
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[1].dmu)+': '; // динамическая вязкость
   s:=s+FormatFloat('#.#########E-0',Form1.matprop[1].beta)+': '; // коэффициент линейного температурного расширения
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.OperatingPressure)+': '; // опорное значение давления
   s:=s+FormatFloat('#.#########E-0',Form1.dgx)+': '; // сила тяжести по оси Ох
   s:=s+FormatFloat('#.#########E-0',Form1.dgy)+': '; // сила тяжести по оси Оу
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.Temperature.dSc)+': '; // постоянная составляющая источникового члена по температуре
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.Temperature.dSp)+': '; // линеаризованная часть источникового члена по температуре
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.VxVelocity.dSc)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.VxVelocity.dSp)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.VyVelocity.dSc)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.VyVelocity.dSp)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.Omega.dSc)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.defmysource.Omega.dSp)+': ';
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.rgravVib.Amplitude)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.rgravVib.Frequency)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.InitVal.TempInit)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.InitVal.XvelInit)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.InitVal.YvelInit)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.rsigma)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.InitVal.VofInit)+': ';
   f.Add(s);
   s:='';
   if (Form1.bBussinesk) then
   begin
      s:=s+'1: '; // приближение Обербека-Буссинеска.
   end
    else
   begin
      s:=s+'0: ';
   end;
   if (Form1.rgravVib.bOn) then
   begin
      s:=s+'1: '; // синусоидальное изменение силы тяжести.
   end
    else
   begin
      s:=s+'0: ';
   end;
    if (Form1.bWallAdhesion) then
   begin
      s:=s+'1: ';
   end
    else
   begin
      s:=s+'0: ';
   end;
   if (Form1.bCSF) then
   begin
      s:=s+'1: ';  // continuum surface force
   end
    else
   begin
      s:=s+'0: ';
   end;
   s:=s+Form1.rgravVib.chDirect+': ';
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.dbetaUDS1)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.dbetaUDS2)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.dbetaUDS3)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.dbetaUDS4)+': ';
   f.Add(s);
   s:='';
   s:=s+Form1.Vxuds1str+': '+Form1.Vyuds1str+': ';
   s:=s+Form1.Vxuds2str+': '+Form1.Vyuds2str+': ';
   s:=s+Form1.Vxuds3str+': '+Form1.Vyuds3str+': ';
   s:=s+Form1.Vxuds4str+': '+Form1.Vyuds4str+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.itypeuds1unsteadyfunction)+': '+
   IntToStr(Form1.itypeuds2unsteadyfunction)+': '+
   IntToStr(Form1.itypeuds3unsteadyfunction)+': '+
   IntToStr(Form1.itypeuds4unsteadyfunction)+': ';
   f.Add(s);
   s:='';
   s:=s+Form1.gamma1str+': '+Form1.gamma2str+': '+Form1.gamma3str+': '+Form1.gamma4str+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.itypesolver.iuds1)+': '+
   IntToStr(Form1.itypesolver.iuds2)+': '+
   IntToStr(Form1.itypesolver.iuds3)+': '+
   IntToStr(Form1.itypesolver.iuds4)+': ';
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.rcs.uds1)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.rcs.uds2)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.rcs.uds3)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.rcs.uds4)+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.iuds1typerho)+': '+
   IntToStr(Form1.iuds2typerho)+': '+
   IntToStr(Form1.iuds3typerho)+': '+
   IntToStr(Form1.iuds4typerho)+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.imaskuds1)+': '+
   IntToStr(Form1.imaskuds2)+': '+
   IntToStr(Form1.imaskuds3)+': '+
   IntToStr(Form1.imaskuds4)+': ';
   f.Add(s);
   s:='';
   s:=s+Form1.dsc1str+': '+Form1.dsc2str+': '+Form1.dsc3str+': '+Form1.dsc4str+': ';
   s:=s+Form1.dsp1str+': '+Form1.dsp2str+': '+Form1.dsp3str+': '+Form1.dsp4str+': ';
   f.Add(s);
   s:='';
   s:=s+Form1.InitVal.UDS1Init+': '+Form1.InitVal.UDS2Init+': '+Form1.InitVal.UDS3Init+': '+Form1.InitVal.UDS4Init+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.ishconv1)+': '+
   IntToStr(Form1.ishconv2)+': '+
   IntToStr(Form1.ishconv3)+': '+
   IntToStr(Form1.ishconv4)+': ';
   f.Add(s);
   // Информация для ускорения вычислений :
   s:='';
   s:=s+IntToStr(Form1.idsc1type)+': '+FormatFloat('#.#########E-0',Form1.rdsc1K1)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.ruds_silicon)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.ruds_GaAs_top)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.ruds_GaAs_bottom)+': ';
   if (Form1.buds1coefconst) then
   begin
      s:=s+'1: ';
   end
   else
   begin
      s:=s+'0: ';
   end;
   s:=s+FormatFloat('#.#########E-0',Form1.diffuds1const)+': ';
   f.Add(s);
   s:='';
   s:=s+IntToStr(Form1.imodelEquation)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.lengthscaleplot.xscale)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.lengthscaleplot.yscale)+': ';
   if (Form1.btimedepend) then
   begin
      s:=s+'1: ';  // Transient.
   end
   else
   begin
      s:=s+'0: ';  // Steady.
   end;
   f.Add(s);
   s:='';
   s:=s+FormatFloat('#.#########E-0',Form1.myrelaxfactors.uds1)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.myrelaxfactors.uds2)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.myrelaxfactors.uds3)+': ';
   s:=s+FormatFloat('#.#########E-0',Form1.myrelaxfactors.uds4)+': ';
   f.Add(s);
   s:='';
   s:=IntToStr(Form1.iterSimple.iteruds1)+': '+
   IntToStr(Form1.iterSimple.iteruds2)+': '+
   IntToStr(Form1.iterSimple.iteruds3)+': '+
   IntToStr(Form1.iterSimple.iteruds4)+': ';
   f.Add(s);
   // Запишем остальную информацию. Геометрического свойства.
   s:='inx='+IntToStr(Form1.inx);
   f.Add(s);
   s:='iny='+IntToStr(Form1.iny);
   f.Add(s);
   s:='xpos=';
   for i:=1 to Form1.inx do
   begin
      if (abs(Form1.xpos[i])<epsilon) then
      begin
         // фактический ноль
         s:=s+'0.0: ';
      end
       else
      begin
         s:=s+FormatFloat('#.#########E-0',Form1.xpos[i])+': ';
      end;
   end;
   f.Add(s);
   s:='ypos=';
   for i:=1 to Form1.iny do
   begin
       if (abs(Form1.ypos[i])<epsilon) then
      begin
         // фактический ноль
         s:=s+'0.0: ';
      end
       else
      begin
         s:=s+FormatFloat('#.#########E-0',Form1.ypos[i])+': ';
      end;
   end;
   f.Add(s);
   s:='cabinet='+FormatFloat('#.#########E-0',Form1.dLx)+': '+FormatFloat('#.#########E-0',Form1.dLy);
   f.Add(s);
   // число hollow блоков
   s:='blockcount='+IntToStr(maxbrickelem);
   f.Add(s);
   // запись информации о hollow блоках
   for i:=1 to (maxbrickelem-1) do
   begin
     s:='block'+IntToStr(i)+'='+FloatToStr(bricklist[i].xS)+': ';
     s:=s+ FloatToStr(bricklist[i].yS)+': '+FloatToStr(bricklist[i].xL)+': ';
     s:=s+FloatToStr(bricklist[i].yL);
     f.Add(s);
   end;
   // число границ
   s:='boundarycount='+IntToStr(inumboundary);
   f.Add(s);
   for i:=1 to inumboundary do
   begin
      s:=edgelist[i].boundaryname+'=';



      // Сохраняем информацию о граничных условиях для
      // User-Defined Scalar.

      s:=s+IntToStr(edgelist[i].uds1clan)+
           ': '+IntToStr(edgelist[i].uds2clan)+
           ': '+IntToStr(edgelist[i].uds3clan)+
           ': '+IntToStr(edgelist[i].uds4clan)+': ';
      s:=s+edgelist[i].uds1condition+': '+
           edgelist[i].uds2condition+': '+
           edgelist[i].uds3condition+': '+
           edgelist[i].uds4condition+': ';

       // Обычные данные для температур, скоростей и давлений.
       s:=s+IntToStr(edgelist[i].temperatureclan)+': '+
       FormatFloat('#.#########E-0',edgelist[i].Vx)+': '+
       FormatFloat('#.#########E-0',edgelist[i].Vy)+': '+
       FormatFloat('#.#########E-0',edgelist[i].rpressure)+': '+
       FormatFloat('#.#########E-0',edgelist[i].temperaturecondition)+': '+
       // функция тока :
       edgelist[i].chSFval+': '+
       FormatFloat('#.#########E-0',edgelist[i].rSFval)+': '+
       FormatFloat('#.#########E-0',edgelist[i].surfaceTensionGradient)+': ';
       // bsymmetry
       if (edgelist[i].bsimmetry) then
       begin
          s:=s+'1: ';
       end
       else
       begin
          s:=s+'0: ';
       end;
       // bpressure
       if (edgelist[i].bpressure) then
       begin
          s:=s+'1: ';
       end
       else
       begin
          s:=s+'0: ';
       end;
       // boutflow
       if (edgelist[i].boutflow) then
       begin
          s:=s+'1: ';
       end
       else
       begin
          s:=s+'0: ';
       end;
       // bMarangoni
       if (edgelist[i].bMarangoni) then
       begin
          s:=s+'1: ';
       end
       else
       begin
          s:=s+'0: ';
       end;
      // Возвращаемся к остальным данным.


      ic1:=0;
      ic2:=0;
      ic3:=0;
      for i1:=1 to Form1.inx do
      begin
         for j1:=1 to Form1.iny do
         begin
            if (Form1.mapPT[i1+(j1-1)*Form1.inx].iboundary=edgelist[i].idescriptor) then
            begin
               inc(ic1);
            end;
         end;
      end;
      for i1:=1 to (Form1.inx-1) do
      begin
         for j1:=1 to Form1.iny do
         begin
            if (Form1.mapVx[i1+(j1-1)*(Form1.inx-1)].iboundary=edgelist[i].idescriptor) then
            begin
               inc(ic2);
            end;
         end;
      end;
      for i1:=1 to Form1.inx do
      begin
         for j1:=1 to (Form1.iny-1) do
         begin
            if (Form1.mapVy[i1+(j1-1)*Form1.inx].iboundary=edgelist[i].idescriptor) then
            begin
               inc(ic3);
            end;
         end;
      end;

      // количество точек образующих границу для всех карт.
      s:=s+IntToStr(ic1)+
           ': '+IntToStr(ic2)+
           ': '+IntToStr(ic3)+': ';

      for i1:=1 to Form1.inx do
      begin
         for j1:=1 to Form1.iny do
         begin
            if (Form1.mapPT[i1+(j1-1)*Form1.inx].iboundary=edgelist[i].idescriptor) then
            begin
               // записывает номера точек на сетке принадлежащих границе
               s:=s+IntToStr(i1+(j1-1)*Form1.inx)+': ';
            end;
         end;
      end;

      for i1:=1 to (Form1.inx-1) do
      begin
         for j1:=1 to Form1.iny do
         begin
            if (Form1.mapVx[i1+(j1-1)*(Form1.inx-1)].iboundary=edgelist[i].idescriptor) then
            begin
               // записывает номера точек на сетке принадлежащих границе
               s:=s+IntToStr(i1+(j1-1)*(Form1.inx-1))+': ';
            end;
         end;
      end;

      for i1:=1 to Form1.inx do
      begin
         for j1:=1 to (Form1.iny-1) do
         begin
            if (Form1.mapVy[i1+(j1-1)*Form1.inx].iboundary=edgelist[i].idescriptor) then
            begin
               // записывает номера точек на сетке принадлежащих границе
               s:=s+IntToStr(i1+(j1-1)*Form1.inx)+': ';
            end;
         end;
      end;
      s:=s+'#'+IntToStr(edgelist[i].idescriptor); // уникальный номер границы
      f.Add(s);
   end;
   f.SaveToFile(filename);  // сохраняю результат
   f.Free;
   FormPaint(Sender);
end; // writeMesh

// запись в файл информации о текущей расчётной сетке
procedure TGridGenForm.writeClick(Sender: TObject);
var
   CaptionStr : string; //  имя записываемого файла
begin

   if not InputQuery('Input file name', 'Please, enter unical file name for writing solution setting...', CaptionStr)
         then exit; // срочное завершение обработки данного события, т.к. имя не введено
    if DirectoryExists('msh\') then
    begin
       CaptionStr:='msh\'+ CaptionStr+'.txt';
    end
    else
    begin
       CaptionStr:=CaptionStr+'.txt';
    end;
   writeMesh(Sender,CaptionStr);

end; // записывает информацию о сетке в текстовый файл.

// закрывает форму
procedure TGridGenForm.BCloseClick(Sender: TObject);
begin
   GridGenForm.Close;
end; // close

//  считывает файл с расчётной сеткой
procedure TGridGenForm.ReadMesh(filename : string);
//filename  имя открываемого файла
type
   Tedge = record
     icpt, icvx, icvy : Integer; // количество точек образующих границу на каждой из карт.
     AI : array of integer;
     AIvx : array of integer;
     AIvy : array of integer;
     name : string; // имя границы
     desc : Integer; // уникальный номер границы
     digit : set of 0..255; // множество уникальных индексов которые надо объеденить

     // Граничные условия для UDS:
     uds1clan, uds2clan, uds3clan, uds4clan : Integer; // тип граничного условия для каждого из скаляров.
     // сами граничные значения :
     uds1condition, uds2condition, uds3condition, uds4condition : string;

     // функция тока
     chSFval : Char;
     rsSFval :  Float;

     Vx, Vy,  rpressure, temperaturecondition, surfaceTensionGradient : Float;
     temperatureclan : Integer;
     bsymmetry, bpressure, boutflow, bMarangoni : Boolean;
   end;

var
   f : TStrings; // переменная типа объект TStringList.
   s : string; // рабочая строка и имя файла
   i,j,i1,j1, ipi : Integer; // счётчики
   ssub : string;
   inumboundaryloc : Integer; // локальное количество границ
   bonnum : array of Tedge;

// данный код решает проблему десятичного разделителя при
// считывании файла. 7 декабря 2014 года.
procedure check_str();
var
  iscan : Integer;
begin
   if (FormatSettings.DecimalSeparator='.') then
   begin
      for iscan:=1 to length(s) do
      begin
         if (s[iscan]=',') then
         begin
            s[iscan]:='.';
         end;
      end;
   end;
    if (FormatSettings.DecimalSeparator=',') then
   begin
      for iscan:=1 to length(s) do
      begin
         if (s[iscan]='.') then
         begin
            s[iscan]:=',';
         end;
      end;
   end;
end;

// данный код решает проблему десятичного разделителя при
// считывании файла. 7 декабря 2014 года.
procedure check_str2();
var
  iscan : Integer;
begin
   if (FormatSettings.DecimalSeparator='.') then
   begin
      for iscan:=1 to length(ssub) do
      begin
         if (ssub[iscan]=',') then
         begin
            ssub[iscan]:='.';
         end;
      end;
   end;
    if (FormatSettings.DecimalSeparator=',') then
   begin
      for iscan:=1 to length(ssub) do
      begin
         if (ssub[iscan]='.') then
         begin
            ssub[iscan]:=',';
         end;
      end;
   end;
end;


begin
   frmLaunchGenerator.chkrestartSettingUDM.Checked:=True; // установка на уничтожение всех UDM.
   frmLaunchGenerator.chkfreeUDS.Checked:=True; // установка на уничтожение всех UDS.
   // также установим возможность добавления новых сеточных линий без генерации равномерной сетки, а
   // используя лишь одиночные сеточные линии.
   //frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked:=True;

   // считывает файл с сеткой.
   f:=TStringList.Create();

   // Загружаем файл .
   f.LoadFromFile(filename);


   i:=0; // уникальный номер считываемой строки
   // imaxUDS, itypemassFluxudsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imaxUDS:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypemassFluxuds1:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypemassFluxuds2:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypemassFluxuds3:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypemassFluxuds4:=StrToInt(s);
   inc(i);
   // material properties phase1
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[0].drho:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[0].dlambda:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[0].dcp:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[0].dmu:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[0].beta:=StrToFloat(s);
   inc(i);

   // material properties phase2
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[1].drho:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[1].dlambda:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[1].dcp:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[1].dmu:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.matprop[1].beta:=StrToFloat(s);
   inc(i);

    // physical conditions
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.OperatingPressure:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dgx:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dgy:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.Temperature.dSc:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.Temperature.dSp:=StrToFloat(s);
   inc(i);

    // outwhere physical conditions
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.VxVelocity.dSc:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.VxVelocity.dSp:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.VyVelocity.dSc:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.VyVelocity.dSp:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.Omega.dSc:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.defmysource.Omega.dSp:=StrToFloat(s);
   inc(i);

     // outwhere physical conditions 2
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rgravVib.Amplitude:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rgravVib.Frequency:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.TempInit:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.XvelInit:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.YvelInit:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rsigma:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.VofInit:=StrToFloat(s);
   inc(i);

   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   if (StrToInt(s)=1) then
   begin
      Form1.bBussinesk:=true;
   end
   else
   begin
      Form1.bBussinesk:=false;
   end;
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   if (StrToInt(s)=1) then
   begin
      Form1.rgravVib.bOn:=true;
   end
   else
   begin
      Form1.rgravVib.bOn:=false;
   end;
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   if (StrToInt(s)=1) then
   begin
      Form1.bWallAdhesion:=true;
   end
   else
   begin
      Form1.bWallAdhesion:=false;
   end;
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   if (StrToInt(s)=1) then
   begin
      Form1.bCSF:=true;
   end
   else
   begin
      Form1.bCSF:=false;
   end;
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   s:=Trim(s);
   if (length(s)>0) then
   begin
      Form1.rgravVib.chDirect:=s[1];
   end
   else
   begin
      Form1.rgravVib.chDirect:='y';
   end;
   inc(i);

   // dbetaUDSi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dbetaUDS1:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dbetaUDS2:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dbetaUDS3:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dbetaUDS4:=StrToFloat(s);
   inc(i);
   // Vxudsistr, Vyudsistr
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vxuds1str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vyuds1str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vxuds2str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vyuds2str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vxuds3str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vyuds3str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vxuds4str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.Vyuds4str:=Trim(s);
   inc(i);
   // itypeudsiunsteadyfunction
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypeuds1unsteadyfunction:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypeuds2unsteadyfunction:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypeuds3unsteadyfunction:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypeuds4unsteadyfunction:=StrToInt(s);
   inc(i);
   // gammaistr
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.gamma1str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.gamma2str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.gamma3str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.gamma4str:=Trim(s);
   inc(i);
   // itypesolver.iudsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypesolver.iuds1:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypesolver.iuds2:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypesolver.iuds3:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.itypesolver.iuds4:=StrToInt(s);
   inc(i);
   // rcs.udsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rcs.uds1:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rcs.uds2:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rcs.uds3:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rcs.uds4:=StrToFloat(s);
   inc(i);
   // iudsityperho
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iuds1typerho:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iuds2typerho:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iuds3typerho:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iuds4typerho:=StrToInt(s);
   inc(i);
   // imaskudsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imaskuds1:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imaskuds2:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imaskuds3:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imaskuds4:=StrToInt(s);
   inc(i);
   // dscistr, dspistr
   s:=f.Strings[i];
    ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsc1str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsc2str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsc3str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsc4str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsp1str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsp2str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsp3str:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dsp4str:=Trim(s);
   inc(i);
   // InitVal.UDSiInit
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.UDS1Init:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.UDS2Init:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.UDS3Init:=Trim(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.InitVal.UDS4Init:=Trim(s);
   inc(i);
   // ishconvi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.ishconv1:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.ishconv2:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.ishconv3:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.ishconv4:=StrToInt(s);
   inc(i);
   // информация для ускорения вычислений.
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.idsc1type:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.rdsc1K1:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.ruds_silicon:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.ruds_GaAs_top:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.ruds_GaAs_bottom:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   j:=StrToInt(s);
   case (j) of
    0 : begin
           Form1.buds1coefconst:=False;
        end;
    1 : begin
           Form1.buds1coefconst:=True;
        end;
   end;
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.diffuds1const:=StrToFloat(s);
   inc(i);
   // imodelEquation, lengthscaleplot.*scale (* x, y)
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.imodelEquation:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.lengthscaleplot.xscale:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
    s:=Copy(ssub,1,Pos(':',ssub)-1);
    check_str();
   Form1.lengthscaleplot.yscale:=StrToFloat(s);
    ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   j:=StrToInt(s);
   case (j) of
    0 : begin
           Form1.btimedepend:=False;  // Stacionary
        end;
    1 : begin
           Form1.btimedepend:=True; // Transient
        end;
   end;
   inc(i);
   // myrelaxfactors.udsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.myrelaxfactors.uds1:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.myrelaxfactors.uds2:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.myrelaxfactors.uds3:=StrToFloat(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.myrelaxfactors.uds4:=StrToFloat(s);
   inc(i);
   // iterSimple.iterudsi
   s:=f.Strings[i];
   ssub:=s;
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iterSimple.iteruds1:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iterSimple.iteruds2:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iterSimple.iteruds3:=StrToInt(s);
   ssub:=Copy(ssub,Pos(':',ssub)+1,Length(ssub));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   Form1.iterSimple.iteruds4:=StrToInt(s);
   inc(i);

   // inx=
   s:=f.Strings[i];
   //Form1.mainMemo.Lines.Add(Copy(s,Pos('inx=',s)+4,length(s))); // debug
   Form1.inx:=StrToInt(Copy(s,Pos('inx=',s)+4,length(s)));
   // iny=
   inc(i); // уникальный номер считываемой строки
   s:=f.Strings[i];
   //Form1.mainMemo.Lines.Add(Copy(s,Pos('iny=',s)+4,length(s))); // debug
   Form1.iny:=StrToInt(Copy(s,Pos('iny=',s)+4,length(s)));
   // xpos=
   inc(i);
   s:=f.Strings[i]; // считывание очередной строки
   // ВАЖНО ! строка s заканчивается запятой.
   ssub:=Copy(s,Pos('xpos=',s)+5,length(s));
   SetLength(Form1.xpos,Form1.inx+1); // выделение оперативной памяти
   Form1.xpos[0]:=0.0; // первое не используемое значение
   // нумерация начинается с единицы
   for j:=1 to Form1.inx do
   begin
      s:=Copy(ssub,1,Pos(':',ssub)-1); // Pos ищет первое вхождение запятой
      check_str();
      Form1.xpos[j]:=StrToFloat(s);
      ssub:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
   end;
   // ypos=
   inc(i);  s:=f.Strings[i]; // считывание очередной строки
   // ВАЖНО ! строка s заканчивается запятой.
   ssub:=Copy(s,Pos('ypos=',s)+5,length(s));
   SetLength(Form1.ypos,Form1.iny+1); // выделение оперативной памяти
   Form1.ypos[0]:=0.0; // первое не используемое значение
   // нумерация начинается с единицы
   for j:=1 to Form1.iny do
   begin
      s:=Copy(ssub,1,Pos(':',ssub)-1); // Pos ищет первое вхождение запятой
      check_str();
      Form1.ypos[j]:=StrToFloat(s);
      ssub:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
   end;
   // cabinet=
   inc(i);  s:=f.Strings[i]; // считывание очередной строки
   ssub:=Copy(s,Pos('cabinet=',s)+8,length(s));
   s:=Copy(ssub,1,Pos(':',ssub)-1);
   check_str();
   Form1.dLx:=StrToFloat(s);
   s:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
   check_str();
   Form1.dLy:=StrToFloat(s);
   // blockcount=
   inc(i);  s:=f.Strings[i]; // считывание очередной строки
   maxbrickelem:=StrToInt(Copy(s,Pos('blockcount=',s)+11,length(s)));
   SetLength(bricklist,maxbrickelem+1); // выделение памяти под список hollow блоков
     // Нулевой элемент это кабинет
     CheckListBox1.Items.Clear; // очистка списка
     CheckListBox1.Items.Add('cabinet');
     bricklist[0].xS:=0.0; // начальная позиция
     bricklist[0].yS:=0.0;
     bricklist[0].xL:=Form1.dLx; // ширина и
     bricklist[0].yL:=Form1.dLy; // высота

   // определение всех hollow блоков:
   for j:=1 to (maxbrickelem-1) do
   begin
      inc(i);  s:=f.Strings[i]; // считывание очередной строки
      ssub:='block'+IntToStr(j)+'='; // уникальное имя блока
      ssub:=Copy(s,Pos(ssub,s)+length(ssub),length(s));
      s:=Copy(ssub,1,Pos(':',ssub)-1);
      check_str();
      bricklist[j].xS:=StrToFloat(s);
      ssub:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
      s:=Copy(ssub,1,Pos(':',ssub)-1);
      check_str();
      bricklist[j].yS:=StrToFloat(s);
      ssub:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
      s:=Copy(ssub,1,Pos(':',ssub)-1);
      check_str();
      bricklist[j].xL:=StrToFloat(s);
      ssub:=Copy(ssub,Pos(':',ssub)+1,length(ssub));
      s:=Trim(ssub);
      check_str();
      bricklist[j].yL:=StrToFloat(s);
      bricklist[j].bbl:=false;
      CheckListBox1.Items.Add('block'+IntToStr(j));
   end;
   // настало время сгенерировать карты
   bfileread:=true; // используется в mysimplemeshgen
   mysimplemeshgen;
   bfileread:=false; // по умолчанию ничего из файла не читаем.
   // boundarycount=
   inc(i);  s:=f.Strings[i]; // считывание очередной строки
   inumboundaryloc:=StrToInt(Copy(s,Pos('boundarycount=',s)+14,length(s)));
   SetLength(bonnum,inumboundaryloc+1);
   for i1:=1 to inumboundaryloc do
   begin
      inc(i);  s:=f.Strings[i]; // считывание очередной строки
      bonnum[i1].name:=Copy(s,1, Pos('=',s)-1);
      s:=Copy(s,Pos('=',s)+1, length(s));

      // Считывание граничных условий для User-Defined Scalar`ов
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].uds1clan:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].uds2clan:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].uds3clan:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].uds4clan:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].uds1condition:=ssub;
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].uds2condition:=ssub;
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].uds3condition:=ssub;
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].uds4condition:=ssub;



      // Обычные данные для температур, скоростей и давлений.
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].temperatureclan:=StrToInt(Trim(ssub));
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].Vx:=StrToFloat(Trim(ssub));
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].Vy:=StrToFloat(Trim(ssub));
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].rpressure:=StrToFloat(Trim(ssub));
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].temperaturecondition:=StrToFloat(Trim(ssub));
      // функция тока.
       ssub:=Trim(Copy(s,1,Pos(':',s)-1));
      s:=Trim(Copy(s,Pos(':',s)+1,length(s)));
      bonnum[i1].chSFval:=ssub[1];
       ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].rsSFval:=StrToFloat(Trim(ssub));
       ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      check_str2();
      bonnum[i1].surfaceTensionGradient:=StrToFloat(Trim(ssub));
      // bsymmetry
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      if (StrToInt(Trim(ssub))=1) then
      begin
         bonnum[i1].bsymmetry:=true;
      end
      else
      begin
         bonnum[i1].bsymmetry:=false;
      end;
      // bpressure
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      if (StrToInt(Trim(ssub))=1) then
      begin
         bonnum[i1].bpressure:=true;
      end
      else
      begin
         bonnum[i1].bpressure:=false;
      end;
      // boutflow
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      if (StrToInt(Trim(ssub))=1) then
      begin
         bonnum[i1].boutflow:=true;
      end
      else
      begin
         bonnum[i1].boutflow:=false;
      end;
      // bMarangoni
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      if (StrToInt(Trim(ssub))=1) then
      begin
         bonnum[i1].bMarangoni:=true;
      end
      else
      begin
         bonnum[i1].bMarangoni:=false;
      end;
      // Возвращаемся к остальным данным.


      // количество точек образующих границу на каждой из карт.
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].icpt:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].icvx:=StrToInt(ssub);
      ssub:=Copy(s,1,Pos(':',s)-1);
      s:=Copy(s,Pos(':',s)+1,length(s));
      bonnum[i1].icvy:=StrToInt(ssub);




      ssub:=Copy(s,1,Pos(':',s)-1);
      SetLength(bonnum[i1].AI,bonnum[i1].icpt+1);
      SetLength(bonnum[i1].AIvx,bonnum[i1].icvx+1);
      SetLength(bonnum[i1].AIvy,bonnum[i1].icvy+1);
      j:=0;
      while (Pos('#',ssub)=0) do
      begin
         inc(j);
         if (j<=bonnum[i1].icpt) then
         begin
            // нумерация начинается с единицы
            bonnum[i1].AI[j]:=StrToInt(ssub);
         end;
         if ((j>bonnum[i1].icpt) and (j<=bonnum[i1].icpt+bonnum[i1].icvx)) then
         begin
            // нумерация начинается с единицы
            bonnum[i1].AIvx[j-bonnum[i1].icpt]:=StrToInt(ssub);
         end;
         if (j>bonnum[i1].icpt+bonnum[i1].icvx) then
         begin
            // нумерация начинается с единицы
            bonnum[i1].AIvy[j-bonnum[i1].icpt-bonnum[i1].icvx]:=StrToInt(ssub);
         end;

         s:=Copy(s,Pos(':',s)+1,length(s));
         if (Pos(':',s)>0) then
         begin
            // впереди ещё есть номера узлов принадлежащих границе.
            ssub:=Copy(s,1,Pos(':',s)-1);
         end
          else
         begin
            // последний анализируемый символ,
            // уникальный номер границы.
            ssub:=s;
         end;
      end;
      s:=Copy(ssub,Pos('#',ssub)+1, length(ssub));
      bonnum[i1].desc:=StrToInt(s);
      bonnum[i1].AI[0]:=bonnum[i1].desc;
      bonnum[i1].AIvx[0]:=bonnum[i1].desc;
      bonnum[i1].AIvy[0]:=bonnum[i1].desc;
      Include(bonnum[i1].digit,bonnum[i1].desc);

   end;

   // граничные условия заполняются дефолтными значениями:

   // Заполнение списка границ расчётной области
   inumboundary:=inumboundaryloc;
   SetLength(edgelist,inumboundary+1); // первая граница имеет индекс 1.
   for i:=1 to inumboundary do
   begin
      edgelist[i].boundaryname:=bonnum[i].name; // уникальное имя границы
      edgelist[i].idescriptor:=bonnum[i].desc; // уникальный номер границы
      edgelist[i].bsimmetry:=bonnum[i].bsymmetry; // не является границей симметрии
      edgelist[i].bpressure:=bonnum[i].bpressure; // на данной границе задаётся нормальная компонента скорости
      edgelist[i].boutflow:=bonnum[i].boutflow; // по умолчанию не является выходной границей потока
      edgelist[i].bMarangoni:=bonnum[i].bMarangoni;  // термокапилярная конвекция
      edgelist[i].rpressure:=bonnum[i].rpressure; // давление на границе.
      // задание граничных условий по умолчанию:
      edgelist[i].Vx:=bonnum[i].Vx; // условия прилипания:
      edgelist[i].Vy:=bonnum[i].Vy; // вектор скорости на границе равен нулю.
      edgelist[i].surfaceTensionGradient:=bonnum[i].surfaceTensionGradient; // dSigma/dT
      edgelist[i].temperatureclan:=bonnum[i].temperatureclan; // граничные условия первого рода по температуре
      edgelist[i].temperaturecondition:=bonnum[i].temperaturecondition; // температура равная нулю.
      // По умолчанию функция тока равна нулю на всех границах !
      edgelist[i].chSFval:='c';
      edgelist[i].rSFval:=0.0;
      // для User-Defined Segregated Solver`а.
      {
      edgelist[i].uds1clan:=2; // граничные условия второго рода !
      edgelist[i].uds2clan:=2;
      edgelist[i].uds3clan:=2;
      edgelist[i].uds4clan:=2;
      edgelist[i].uds1condition:='0.0'; // однородные условия Неймана !!!
      edgelist[i].uds2condition:='0.0';
      edgelist[i].uds3condition:='0.0';
      edgelist[i].uds4condition:='0.0';
      }
      edgelist[i].uds1clan:=bonnum[i].uds1clan; // граничные условия второго рода !
      edgelist[i].uds2clan:=bonnum[i].uds2clan;
      edgelist[i].uds3clan:=bonnum[i].uds3clan;
      edgelist[i].uds4clan:=bonnum[i].uds4clan;
      edgelist[i].uds1condition:=bonnum[i].uds1condition; // однородные условия Неймана !!!
      edgelist[i].uds2condition:=bonnum[i].uds2condition;
      edgelist[i].uds3condition:=bonnum[i].uds3condition;
      edgelist[i].uds4condition:=bonnum[i].uds4condition;
   end;


   for i1:=1 to inumboundary do // проход по всем границам
   begin
      for j1:=1 to (length(bonnum[i1].AI)-1) do
      begin
         // подправляем карты
         for i:=1 to Form1.inx do
         begin
            for j:=1 to Form1.iny do
            begin
               ipi:=i+(j-1)*Form1.inx;
               if (ipi=bonnum[i1].AI[j1]) then
               begin
                  Include(bonnum[i1].digit,tnm[ipi].ibondary); // заносим уникальный номер в базу номеров
                  tnm[ipi].ibondary:=bonnum[i1].AI[0];
                  Form1.mapPT[ipi].iboundary:=bonnum[i1].AI[0];
               end;
            end;
         end;
      end;
   end;
   // подправляем карты
   // карта горизонтальной скорости.
   for i1:=1 to inumboundary do // проход по всем границам
   begin
      for j1:=1 to (length(bonnum[i1].AIvx)-1) do
      begin
         for i:=1 to (Form1.inx-1) do
         begin
            for j:=1 to Form1.iny do
            begin
               if (Form1.mapVx[i+(j-1)*(Form1.inx-1)].itype = 2) then
               begin
                  if (i+(j-1)*(Form1.inx-1)=bonnum[i1].AIvx[j1]) then
                  begin
                     Form1.mapVx[i+(j-1)*(Form1.inx-1)].iboundary:=bonnum[i1].AIvx[0];
                  end;
               end;
            end;
         end;
      end;
   end;
   // карта вертикальной скорости.
   for i1:=1 to inumboundary do // проход по всем границам
   begin
      for j1:=1 to (length(bonnum[i1].AIvy)-1) do
      begin
         for i:=1 to Form1.inx do
         begin
            for j:=1 to (Form1.iny-1) do
            begin
               if (Form1.mapVy[i+(j-1)*Form1.inx].itype = 2) then
               begin
                  if (i+(j-1)*Form1.inx = bonnum[i1].AIvy[j1]) then
                  begin
                     Form1.mapVy[i+(j-1)*Form1.inx].iboundary:=bonnum[i1].AIvy[0];
                  end;
               end;
            end;
         end;
      end;
   end;
   f.Free; // освобождение памяти
end; // считываает файл с расчётной сеткой

// считывает файл с сеткой
procedure TGridGenForm.ReadClick(Sender: TObject);
// var filename : string; // имя считываемого файла
begin
   // считывает файл с сеткой.

   OpenGLUnit.Timer1.Interval:=100000;
   OpenGLUnit.Close;

   (*
   if not InputQuery('Ввод имени считываемого файла', 'Введите уникальное имя считываемого файла', filename)
         then exit; // срочное завершение обработки данного события, т.к. имя не введено
   ReadMesh('msh\'+filename+'.txt');
   *)
   OpenDialog1.Filter := 'Текстовые файлы|*.txt';
   if OpenDialog1.Execute and FileExists(OpenDialog1.FileName) then
       // Результат успешный - пользователь выбрал файл.
       // Загружаем файл .
       ReadMesh(OpenDialog1.FileName);

    Application.MessageBox('файл считан успешно','считывание сетки',MB_OK);

    OpenGLUnit.Timer1.Interval:=1000;
end; // считывает текущую расчётную сетку

procedure TGridGenForm.btnShowMeshSizeClick(Sender: TObject);
begin
   // показывает целочисленные сеточные размеры расчётной области.
   Application.MessageBox(PChar('inx='+IntToStr(Form1.inx)+'; iny='+IntToStr(Form1.iny)+';'),PChar('Mesh Information'),MB_OK);
end;

// распечатывает содержимое границ
// в текстовый файл
procedure TGridGenForm.PrintBoundaryDiagnostic;
var
   f : TStrings;
   s : String;
   i,ic : Integer;
begin
   f:=TStringList.Create();
   for i:=1 to inumboundary do
   begin
      f.Add(edgelist[i].boundaryname);
      s:='chdirect vdol bound= '+ edgelist[i].chdirect;
      f.Add(s);
      s:='unic number bound=  ' + IntToStr(edgelist[i].idescriptor);
      f.Add(s);
      s:=' tempclan= '+IntToStr(edgelist[i].temperatureclan);
      f.Add(s);
      ic:=0; if (edgelist[i].bsimmetry) then ic:=1;
      s:=' simmetry= '+IntToStr(ic);
      ic:=0; if (edgelist[i].boutflow) then ic:=1;
      s:=s+' outflow= '+IntToStr(ic);
      ic:=0; if (edgelist[i].bpressure) then ic:=1;
      s:=s+' pressure= '+IntToStr(ic);
      f.Add(s);
      s:='Vx='+FloatToStr(edgelist[i].Vx)+' Vy='+FloatToStr(edgelist[i].Vy)+' P='+FloatToStr(edgelist[i].rpressure);
      s:=s+' T='+ FloatToStr(edgelist[i].temperaturecondition);
      f.Add(s);
      f.Add('');
   end;
   f.SaveToFile('diagnosticBoundary.txt');
   f.Free;
end;

// Возвращает номер границы
function TGridGenForm.iboundnum(k : Integer) : Integer;
var
    i,j : Integer;

begin
   j:=1; // по умолчанию первая грница
   // на вход подаётся k
   for i:=1 to inumboundary do
   begin
      if (edgelist[i].idescriptor=Form1.mapPT[k].iboundary) then
       j:=i;
   end;
   Result:=j; // возвращаемое значение
end;

end.
