unit MeshGen;
// модуль генерации простейшей сетки
// внутри прямоугольной области.

interface

uses
  Windows, Math, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFMesh = class(TForm)
    Panel6: TPanel;
    Button1: TButton;
    grpcondensationmeshnodes: TGroupBox;
    chkLeft: TCheckBox;
    chkRight: TCheckBox;
    chkTop: TCheckBox;
    chkBottom: TCheckBox;
    lblLeft: TLabel;
    lblRight: TLabel;
    lblTop: TLabel;
    lblBottom: TLabel;
    edtEqleft: TEdit;
    edtEqRight: TEdit;
    edtEqTop: TEdit;
    edtEqBottom: TEdit;
    pnlmessage: TPanel;
    lbl1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }

    // поля
    bleft, bright : Boolean; // к каким стенкам делать сгущение
    qleft, qright : Real; // знаменатели геометрических прогрессий
    btop, bbottom : Boolean; // к каким стенкам делать сгущение
    qtop, qbottom : Real; // знаменатели геометрических прогрессий
    // методы
    // загружает некоторые сеточные данные из форм
    procedure loadmeshdata;

  public
    { Public declarations }
    // к этим методам можно обращаться из других модулей


     // создаёт массивы с координатами для новой сетки
     // Используется внутри модуля DisplayUnit
    procedure meshgenerator1;

  end;

var
  FMesh: TFMesh;

implementation

uses
   DisplayUnit, MainUnit, Unitaddmeshline, GridGenUnit, UnitLaunchMeshGen;

{$R *.dfm}

// загружает все необходимые данные
// из окошек форм в поля структур Form1 и FMesh;
procedure TFMesh.loadmeshdata;
begin
   (* возможны следующие варианты:
    * 1 - не выбран ни один CheckBox
    * 2 - в каждом из координатных направлений быбрано не более одного
    *     CheckBox`а
    * 3 - по какому либо из координатных направлений
    *     выбрано сразу два CheckBox`a
   *)
   bleft:=chkLeft.Checked; // признак сгущения к левой стенке
   bright:=chkRight.Checked; // признак сгущения к правой стенке
   btop:=chkTop.Checked;  // признак сгущения к верхней крышке
   bbottom:=chkBottom.Checked; // признак сгущения ко дну
end;


// Этот метод изменяет все необходимые параметры и генерирует расчётную сетку
// внутри расчётной области. Передаваемыми и изменяемыми параметрами являются:
// inxnew, inynew - количество узлов сетки (контрольных объёмов) по горизонтали и вертикали.
// Это значение может изменено в случае двухстороннего сгущения для симметризации расчётной сетки.
// Массивы xposnew, yposnew - это изменяемые массивы соддержащие положения сеточных линий.
procedure TFMesh.meshgenerator1;
var
   i : Integer; // счётчики
   ind2 : Integer; // половина
   ibuf : Integer; // целочисленный буффер
   dx, dy :  Real; // если без сгущения
   b1left, b1right : Real; // первые члены геометрической прогрессии
   b1top, b1bottom : Real; // первые члены геометрической прогрессии
   in1, in2, in1l, in2l : Integer; // сколько узлов сетки требуется добавить ?

begin

   if (not(frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked)) then
   begin
      // Здесь мы глобально запускаем заново
      // равномерный или неравномерный (но массовый)
      // сеточный генератор.
      // В тоже время могут возникнуть случаи когда такое переразбиение заново
      // делать не имеет смысла, а необходимо лишь локально улучшить сетку
      // добавив несколько новых избранных сеточных линий.
      // Итак здесь представлен внутри условия if массовый разбиватель, а после
      // ниже по коду представлен специальный улучшатель расчётной сетки.
      // Если мы не войдем в массовый алгоритм разбиения то мы окажемся в улучшателе
      // качества расчётной сетки.


   (* возможны следующие варианты:
    * 1 - не выбран ни один CheckBox
    * 2 - в каждом из координатных направлений быбрано не более одного
    *     CheckBox`а
    * 3 - по какому либо из координатных направлений
    *     выбрано сразу два CheckBox`a
   *)

   // сетка без сгущения
   // не выбрано ни одного CheckBox`a
   begin
      dx:= Form1.dLx/(Form1.inx-1);
      dy:= Form1.dLy/(Form1.iny-1);
      for i:=1 to Form1.inx do
      begin
         Form1.xpos[i]:=0+(i-1)*dx;
      end;
      for i:=1 to Form1.iny do
      begin
         Form1.ypos[i]:=0+(i-1)*dy;
      end;


   end;

   // сгущение слева и справа одновременно
   if (bleft and bright) then
   begin
      if (Form1.inx mod 2 = 0) then
      begin
         inc(Form1.inx); // особый случай для симметризации расчётной сетки
         SetLength(Form1.xpos, (Form1.inx+1));
      end;
      ind2:=(Form1.inx div 2);
      qleft:=StrToFloat(edtEqleft.Text); // считывание знаменателя геометрической прогрессии
      if (qleft <> 1) then
      begin
         b1left:=0.5*Form1.dLx*(qleft-1)/(power(qleft,ind2)-1);
      end
       else
      begin
         b1left:= 0.5*Form1.dLx/(ind2);
      end;
      Form1.xpos[1]:=0;
      for i:=2 to ind2+1 do
      begin
         Form1.xpos[i]:=Form1.xpos[i-1]+b1left*power(qleft,i-2);
      end;

      qright:=StrToFloat(edtEqright.Text); // считывание знаменателя геометрической прогрессии
      if (qright <> 1) then
      begin
         b1right:=0.5*Form1.dLx*(qright-1)/(power(qright,Form1.inx-ind2-1)-1);
      end
       else
      begin
         b1right:= 0.5*Form1.dLx/(Form1.inx-ind2-1);
      end;
      for i:=ind2+2 to Form1.inx do
      begin
         ibuf:=i-ind2-2+1;
         Form1.xpos[i]:=Form1.xpos[i-1]+b1right*power(qright,Form1.inx-ind2-1-ibuf);
      end;

   end
   else
   begin
      if (bleft) then
      begin
         // сгущение только слева
         qleft:=StrToFloat(edtEqleft.Text); // считывание знаменателя геометрической прогрессии
         if (qleft <> 1) then
         begin
            b1left:=Form1.dLx*(qleft-1)/(power(qleft,Form1.inx-1)-1);
         end
          else
         begin
            b1left:= Form1.dLx/(Form1.inx-1);
         end;
         Form1.xpos[1]:=0;
         for i:=2 to Form1.inx do
         begin
            Form1.xpos[i]:=Form1.xpos[i-1]+b1left*power(qleft,i-2);
         end;
      end;
      if (bright) then
      begin
         // сгущение только справа
         qright:=StrToFloat(edtEqright.Text); // считывание знаменателя геометрической прогрессии
         if (qright <> 1) then
         begin
            b1right:=Form1.dLx*(qright-1)/(power(qright,Form1.inx-1)-1);
         end
          else
         begin
            b1right:= Form1.dLx/(Form1.inx-1);
         end;
         Form1.xpos[1]:=0;
         for i:=2 to Form1.inx do
         begin
            Form1.xpos[i]:=Form1.xpos[i-1]+b1right*power(qright,Form1.inx-i);
         end;
      end;
   end;

   // сгущение сверху и снизу одновременно
   if (btop and bbottom) then
   begin
      if (Form1.iny mod 2 = 0) then // случай чётного количества узлов
      begin
         inc(Form1.iny);  // особый случай для симметризации расчётной сетки
         SetLength(Form1.ypos,Form1.iny+1);
      end;
      ind2:=(Form1.iny div 2);
      qbottom:=StrToFloat(edtEqBottom.Text); // считывание знаменателя геометрической прогрессии
      if (qbottom<>1) then
      begin
         b1bottom:=0.5*Form1.dLy*(qbottom-1)/(power(qbottom,ind2)-1);
      end
       else
      begin
         b1bottom:=0.5*Form1.dLy/(ind2);
      end;
      Form1.ypos[1]:=0;
      for i:=2 to ind2+1 do
      begin
         Form1.ypos[i]:=Form1.ypos[i-1]+b1bottom*power(qbottom,i-2);
      end;

      qtop:=StrToFloat(edtEqTop.Text); // считывание знаменателя геометрической прогрессии
      if (qtop<>1) then
      begin
         b1top:=0.5*Form1.dLy*(qtop-1)/(power(qtop,Form1.iny-ind2-1)-1);
      end
       else
      begin
         b1top:=0.5*Form1.dLy/(Form1.iny-ind2-1);
      end;
      for i:=ind2+2 to Form1.iny do
      begin
         ibuf:=i-ind2-2+1;
         Form1.ypos[i]:=Form1.ypos[i-1]+b1top*power(qtop,Form1.iny-ind2-1-ibuf);
      end;
   end
   else
   begin
      if (btop) then
      begin
         // сгущение к верхней крышке

         qtop:=StrToFloat(edtEqTop.Text); // считывание знаменателя геометрической прогрессии
          // определяем первый член геометрической прогрессии
          if (qtop <> 1) then
          begin  // случай неравномерной сетки
             b1top:=Form1.dLy*(qtop-1)/(power(qtop,Form1.iny-1)-1);
          end
          else
          begin  // случай равномерной сетки
             b1top:= Form1.dLy/(Form1.iny-1);
          end;
          Form1.ypos[1]:=0;
          for i:=2 to Form1.iny do
          begin
             Form1.ypos[i]:=Form1.ypos[i-1]+b1top*power(qtop,Form1.iny-i);
          end;
      end;
      if (bbottom) then
      begin
          // сгущение ко дну

          qbottom:=StrToFloat(edtEqBottom.Text); // считывание знаменателя геометрической прогрессии
          if (qbottom <> 1) then
          begin
             b1bottom:=Form1.dLy*(qbottom-1)/(power(qbottom,Form1.iny-1)-1);
          end
           else
          begin
             b1bottom:= Form1.dLy/(Form1.iny-1);
          end;
          Form1.ypos[1]:=0;
          for i:=2 to Form1.iny do
          begin
             Form1.ypos[i]:=Form1.ypos[i-1]+b1bottom*power(qbottom,i-2);
          end;
      end;
   end;

   end;

   // Ниженаписанный код в данной секции позволяет пользователю
      // добавить несколько новых сеточных линий в местах больших градиентов
      // чтобы несколько улучшить точность аппроксимации.
      // Идеально было бы локально сгущать расчётную сетку но данная возможность
      // требует локально измельчённых сеток и другой технологии сборки матриц.


      // сгущение сетки.
      Formaddmeshline.lstx.Items.Clear;
      for i:=1 to Form1.inx do
      begin
         Formaddmeshline.lstx.Items.Add(FloatToStr(Form1.xpos[i]));
      end;
      Formaddmeshline.lsty.Clear;
      for i:=1 to Form1.iny do
      begin
         Formaddmeshline.lsty.Items.Add(FloatToStr(Form1.ypos[i]));
      end;

      Formaddmeshline.ShowModal;

      in1:=0;
      if (Formaddmeshline.chkx1.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx2.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx3.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx4.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx5.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx6.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx7.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx8.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx9.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx10.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx11.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx12.Checked) then
      begin
         inc(in1);
      end;
      if (Formaddmeshline.chkx13.Checked) then
      begin
         inc(in1);
      end;
      in2:=0;
      if (Formaddmeshline.chky1.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky2.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky3.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky4.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky5.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky6.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky7.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky8.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky9.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky10.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky11.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky12.Checked) then
      begin
         inc(in2);
      end;
      if (Formaddmeshline.chky13.Checked) then
      begin
         inc(in2);
      end;

      SetLength(Form1.xpos,Form1.inx+1+in1);
      SetLength(Form1.ypos,Form1.iny+1+in2);
      in1l:=Form1.inx+1;
      in2l:=Form1.iny+1;
      if (Formaddmeshline.chkx1.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx1.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx2.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx2.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx3.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx3.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx4.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx4.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx5.Checked) then
      begin
        Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx5.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx6.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx6.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx7.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx7.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx8.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx8.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx9.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx9.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx10.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx10.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx11.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx11.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx12.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx12.Text);
         inc(in1l);
      end;
      if (Formaddmeshline.chkx13.Checked) then
      begin
         Form1.xpos[in1l]:=StrToFloat(Formaddmeshline.edtx13.Text);
      end;

      if (Formaddmeshline.chky1.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty1.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky2.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty2.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky3.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty3.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky4.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty4.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky5.Checked) then
      begin
        Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty5.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky6.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty6.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky7.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty7.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky8.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty8.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky9.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty9.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky10.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty10.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky11.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty11.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky12.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty12.Text);
         inc(in2l);
      end;
      if (Formaddmeshline.chky13.Checked) then
      begin
         Form1.ypos[in2l]:=StrToFloat(Formaddmeshline.edty13.Text);
      end;


      Form1.inx:=Form1.inx+in1;
      Form1.iny:=Form1.iny+in2;

      // сортировка по возрастанию !!!
      GridGenForm.myBubbleSort1(Form1.xpos,Form1.inx);
      GridGenForm.myBubbleSort1(Form1.ypos,Form1.iny);

   // именно в самом конце т.к. величина Form1.iny может меняться выше по коду.
    SetLength(Form1.yposfix,Form1.iny+1); // это для динамической сетки

end; // meshgenerator1

// Вызывает генератор расчётной сетки
procedure TFMesh.Button1Click(Sender: TObject);
var
  bOk : Boolean;
  r : Double;
begin
   bOk:=true;

  if (not TryStrToFloat(EdtEqLeft.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EdtEqLeft.Text+' left is incorrect value.');
  end;

  if (not TryStrToFloat(EdtEqTop.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EdtEqTop.Text+' top is incorrect value.');
  end;

  if (not TryStrToFloat(EdtEqRight.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EdtEqRight.Text+' right is incorrect value.');
  end;

  if (not TryStrToFloat(EdtEqBottom.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EdtEqBottom.Text+' bottom is incorrect value.');
  end;


   if (bOk) then
   begin

      loadmeshdata; // загружает данные в поля форм Form1 и FMesh

      if (not(frmLaunchGenerator.chkonlyadditionalunicalmeshline.Checked)) then
      begin
         SetLength(Form1.xpos,Form1.inx+1);
         SetLength(Form1.ypos,Form1.iny+1);
      end;

      (* возможны следующие варианты:
       * 1 - не выбран ни один CheckBox
       * 2 - в каждом из координатных направлений быбрано не более одного
       *     CheckBox`а
       * 3 - по какому либо из координатных направлений
       *     выбрано сразу два CheckBox`a
       *)

       meshgenerator1;  // генерация расчётной сетки
       FMesh.Close; // закрытие диалога
   end;
end;

// инициализация формы.
procedure TFMesh.FormCreate(Sender: TObject);
begin
   edtEqTop.Text:=FloatToStr(1.05);
   edtEqLeft.Text:=FloatToStr(1.05);
   edtEqRight.Text:=FloatToStr(1.05);
   edtEqBottom.Text:=FloatToStr(1.05);
end;

end.
