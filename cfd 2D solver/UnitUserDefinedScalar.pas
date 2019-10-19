unit UnitUserDefinedScalar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Unitdeclar;

type
  TFormUserDefinedScalar = class(TForm)
    lbluds: TLabel;
    cbbuds: TComboBox;
    grpuds: TGroupBox;
    lbludsindex: TLabel;
    cbbindex: TComboBox;
    lblsolutionzones: TLabel;
    cbbsolutionzones: TComboBox;
    lblFluxFunction: TLabel;
    cbbfluxfunction: TComboBox;
    lblunsteady: TLabel;
    cbbunsteadyfunction: TComboBox;
    btnapply: TButton;
    grpvelocitycomponent: TGroupBox;
    lblVx: TLabel;
    lblVy: TLabel;
    edtVx: TEdit;
    edtVy: TEdit;
    procedure cbbudsChange(Sender: TObject);
    procedure cbbindexChange(Sender: TObject);
    procedure btnapplyClick(Sender: TObject);
    procedure cbbfluxfunctionChange(Sender: TObject);
    // проверяет количество открывающих и закрывающих скобок.
    procedure proverka(s : String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormUserDefinedScalar: TFormUserDefinedScalar;

implementation

uses MainUnit;

{$R *.dfm}

// Задание количества User-Defined Scalar`ов.
procedure TFormUserDefinedScalar.cbbudsChange(Sender: TObject);
begin
   // задание количества User-Defined Scalar`ов
   // смена количества UDS скаляров.
   Form1.imaxUDS:=cbbuds.ItemIndex;
   case Form1.imaxUDS of
     0 : begin
            cbbindex.Clear;
         end;
     1 : begin
            cbbindex.Clear;
            cbbindex.AddItem('1',Sender);
         end;
     2 : begin
            cbbindex.Clear;
            cbbindex.AddItem('1',Sender);
            cbbindex.AddItem('2',Sender);
         end;
     3 : begin
            cbbindex.Clear;
            cbbindex.AddItem('1',Sender);
            cbbindex.AddItem('2',Sender);
            cbbindex.AddItem('3',Sender);
         end;
     4 : begin
            cbbindex.Clear;
            cbbindex.AddItem('1',Sender);
            cbbindex.AddItem('2',Sender);
            cbbindex.AddItem('3',Sender);
            cbbindex.AddItem('4',Sender);
         end;
   end;
   // Выделение памяти происходит при инициализации вычислительного процесса.

   // Теперь нужно заново задать все коэффициенты диффузии,
   // нестационарные члены, источниковые члены, конвективные члены.
   Form1.itypemassFluxuds1:=0; // none
   Form1.itypemassFluxuds2:=0;
   Form1.itypemassFluxuds3:=0;
   Form1.itypemassFluxuds4:=0;
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
   grpvelocitycomponent.Visible:=False;
   // нестационарный член.
   Form1.itypeuds1unsteadyfunction:=0; // none
   Form1.itypeuds2unsteadyfunction:=0;
   Form1.itypeuds3unsteadyfunction:=0;
   Form1.itypeuds4unsteadyfunction:=0;
   // Коэффициенты диффузии
   Form1.gamma1str:='1.0';
   Form1.gamma2str:='1.0';
   Form1.gamma3str:='1.0';
   Form1.gamma4str:='1.0';

   // Сброс показа невязок.
   Form1.imarker:=0;
   SetLength(Form1.myresplot,0);

   if (Form1.imaxUDS=0) then
   begin
      grpuds.Visible:=False;
      Application.MessageBox('UDS коэффициенты диффузии удалены.','warning',MB_OK);
   end
   else
   begin
      grpuds.Visible:=True;
      Application.MessageBox('UDS коэффициенты диффузии выставлены равными единице.','warning',MB_OK);
   end;
   cbbindex.ItemIndex:=0;
   cbbfluxfunction.ItemIndex:=0;
   cbbunsteadyfunction.ItemIndex:=0;
   Application.MessageBox('Изменено количество User-Defined Scalar`ов. Настройки сброшены на defoult','user-defined scalar',MB_OK);

end;

// смена User-Defined Скаляра.
procedure TFormUserDefinedScalar.cbbindexChange(Sender: TObject);
begin
   case cbbindex.ItemIndex of
     0 : begin
            cbbfluxfunction.ItemIndex:=Form1.itypemassFluxuds1;
            cbbunsteadyfunction.ItemIndex:=Form1.itypeuds1unsteadyfunction;
         end;
     1 : begin
            // В случае если
               // edtVx.Text = $gradxuds1, а
               // edtVy.Text = $gradyuds1 то
               // это случай ДДМ модели для электронного газа (обезразмеренный).
               // Его нужно очень быстро вычислять потомучто эта модель очень важна для Пульсара.
               // При распознании данной ситуации вынесем этот случай в особый вариант itypemassFluxuds2=3.

            if (Form1.itypemassFluxuds2>2) then // особый случай.
            begin
               cbbfluxfunction.ItemIndex:=2;
            end
              else
            begin
               cbbfluxfunction.ItemIndex:=Form1.itypemassFluxuds2;
            end;
            cbbunsteadyfunction.ItemIndex:=Form1.itypeuds2unsteadyfunction;
         end;
     2 : begin
            if (Form1.itypemassFluxuds3>2) then // особый случай.
            begin
               cbbfluxfunction.ItemIndex:=2;
            end
              else
            begin
               cbbfluxfunction.ItemIndex:=Form1.itypemassFluxuds3;
            end;
            cbbunsteadyfunction.ItemIndex:=Form1.itypeuds3unsteadyfunction;
         end;
     3 : begin
            cbbfluxfunction.ItemIndex:=Form1.itypemassFluxuds4;
            cbbunsteadyfunction.ItemIndex:=Form1.itypeuds4unsteadyfunction;
         end;
   end;
   if (cbbfluxfunction.ItemIndex=2) then
   begin
      grpvelocitycomponent.Visible:=True;

      case cbbindex.ItemIndex of
       0 : begin
              edtVx.Text:=Form1.Vxuds1str;
              edtVy.Text:=Form1.Vyuds1str;
           end;
       1 : begin
              edtVx.Text:=Form1.Vxuds2str;
              edtVy.Text:=Form1.Vyuds2str;
           end;
       2 : begin
              edtVx.Text:=Form1.Vxuds3str;
              edtVy.Text:=Form1.Vyuds3str;
           end;
       3 : begin
              edtVx.Text:=Form1.Vxuds4str;
              edtVy.Text:=Form1.Vyuds4str;
           end;
      end;
   end
    else
   begin
      grpvelocitycomponent.Visible:=False;
   end;
end;

// проверяет количество открывающих и закрывающих скобок.
procedure TFormUserDefinedScalar.proverka(s : String);
var
   i, i1, i2 : Integer;
begin
   i1:=0;
   i2:=0;
   for i:=1 to Length(s) do
   begin
      if (s[i]='(') then inc(i1);
      if (s[i]=')') then inc(i2);
   end;
   if (i1<>i2) then
   begin
      Application.MessageBox('не совпадает количество открывающих и закрывающих скобок.','error',MB_OK);
   end;
end;

// Ввод параметров
procedure TFormUserDefinedScalar.btnapplyClick(Sender: TObject);
var
   i1, i2, i3, i4, i5, i6 : Integer;
   c1, c2, c3, c4 : Integer;
   x1, x2, x3, x4 : Float;
begin
   proverka(edtVx.Text);
   proverka(edtVy.Text);
   case cbbindex.ItemIndex of
     0 : begin
            Form1.itypemassFluxuds1:=cbbfluxfunction.ItemIndex;
            if (Form1.itypemassFluxuds1=2) then
            begin
               // удаляем возможные начальные и конечные пробелы !!!
               edtVx.Text:=Trim(edtVx.Text);
               edtVy.Text:=Trim(edtVy.Text);

               Form1.Vxuds1str:=edtVx.Text;
               Form1.Vyuds1str:=edtVy.Text;

               if ((Pos('6.282*sin(3.141*$x)*sin(3.141*$x)*sin(3.141*$y)*cos(3.141*$y)',edtVx.Text)=1)and (Length(edtVx.Text)=61) and (Pos('-6.282*sin(3.141*$y)*sin(3.141*$y)*sin(3.141*$x)*cos(3.141*$x)',edtVy.Text)=1)and (Length(edtVy.Text)=62)) then
               begin
                  // аналитически заданный водоворот для тестирования
                  // уравнений конвекции-диффузии.
                  // Vx =  6.282*sin(3.141*$x)*sin(3.141*$x)*sin(3.141*$y)*cos(3.141*$y)
                  // Vy = -6.282*sin(3.141*$y)*sin(3.141*$y)*sin(3.141*$x)*cos(3.141*$x)

                  Form1.itypemassFluxuds1:=6; // особый случай.
               end;

               if ((Pos('6.282*sin(3.141*$x)*sin(3.141*$x)*sin(3.141*$y)*cos(3.141*$y)',edtVx.Text)=1)and (Length(edtVx.Text)=61) and (Pos('6.282*sin(3.141*$y)*sin(3.141*$y)*sin(3.141*$x)*cos(3.141*$x)',edtVy.Text)=1)and (Length(edtVy.Text)=61)) then
               begin
                  // аналитически заданный ток в левый верхний угол и в правывй нижний угол для тестирования
                  // уравнений конвекции-диффузии.
                  // Vx =  6.282*sin(3.141*$x)*sin(3.141*$x)*sin(3.141*$y)*cos(3.141*$y)
                  // Vy = 6.282*sin(3.141*$y)*sin(3.141*$y)*sin(3.141*$x)*cos(3.141*$x)

                  Form1.itypemassFluxuds1:=7; // особый случай.
               end;

            end;
            Form1.itypeuds1unsteadyfunction:=cbbunsteadyfunction.ItemIndex;
         end;
     1 : begin
            Form1.itypemassFluxuds2:=cbbfluxfunction.ItemIndex;
            if (Form1.itypemassFluxuds2=2) then
            begin
               // удаляем возможные начальные и конечные пробелы !!!
               edtVx.Text:=Trim(edtVx.Text);
               edtVy.Text:=Trim(edtVy.Text);

               Form1.Vxuds2str:=edtVx.Text;
               Form1.Vyuds2str:=edtVy.Text;
               // В случае если
               // edtVx.Text = $gradxuds1, а
               // edtVy.Text = $gradyuds1 то
               // это случай ДДМ модели для электронного газа (обезразмеренный).
               // Его нужно очень быстро вычислять потомучто эта модель очень важна для Пульсара.
               // При распознании данной ситуации вынесем этот случай в особый вариант itypemassFluxuds2=3.
               if ((Pos('-$gradyuds1',edtVx.Text)=1)and (Length(edtVx.Text)=11) and (Pos('$gradxuds1',edtVy.Text)=1)and (Length(edtVy.Text)=10)) then
               begin
                  // Скорость в уравнениях Навье-Стокса в терминах вихрь функция тока.
                  Form1.itypemassFluxuds2:=5; // особый случай.
               end
               else if ((Pos('$gradxuds1',edtVx.Text)=1)and (Length(edtVx.Text)=10) and (Pos('$gradyuds1',edtVy.Text)=1)and (Length(edtVy.Text)=10)) then
               begin
                  Form1.itypemassFluxuds2:=3; // особый случай.
               end
               else
               begin
                  // Характеристика Кремния.

                  i1:=Pos('$gradxuds1/(1.0+',edtVx.Text);
                  i2:=Pos('*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))',edtVx.Text);
                  i3:=Pos('$gradyuds1/(1.0+',edtVy.Text);
                  i4:=Pos('*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))',edtVy.Text);
                  if ((i1=1)and(i3=1)) then
                  begin
                     Val(Copy(edtVx.Text,17,i2-17),x1,c1);
                     Val(Copy(edtVy.Text,17,i4-17),x2,c2);
                     if ((c1=0) and (c2=0) and (Abs(x2-x1)<1.0e-30)) then
                     begin
                        // Задана полескоростная характеристика кремния.
                        Form1.ruds_silicon:=0.5*(x1+x2); // среднее арифметическое состоятельная оценка математического ожидания.
                        Form1.itypemassFluxuds2:=4; // особый случай.
                        Application.MessageBox('распознано Si','good',MB_OK);
                     end;
                  end;

                  // Характеристика Арсенида Галлия.




                  i1:=Pos('$gradxuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+',edtVx.Text);
                  i2:=Pos('*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+',edtVx.Text);
                  i3:=Pos('*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))',edtVx.Text);
                  i4:=Pos('$gradyuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+',edtVy.Text);
                  i5:=Pos('*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+',edtVy.Text);
                  i6:=Pos('*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))',edtVy.Text);
                  if ((i1=1)and(i4=1)and(i2>0)and(i3>i2+45)and(i5>0)and(i6>i5+45)) then
                  begin
                     Val(Copy(edtVx.Text,51,i2-51),x1,c1);
                     Val(Copy(edtVy.Text,51,i5-51),x2,c2);
                     Val(Copy(edtVx.Text,i2+44,i3-(i2+44)),x3,c3);
                     Val(Copy(edtVy.Text,i5+44,i6-(i5+44)),x4,c4);
                     if ((c1=0) and (c2=0) and (c3=0) and (c4=0) and (Abs(x2-x1)<1.0e-30) and (Abs(x4-x3)<1.0e-30)) then
                     begin
                        // Задана полескоростная характеристика GaAs.
                        Form1.ruds_GaAs_top:=0.5*(x1+x2);
                        Form1.ruds_GaAs_bottom:=0.5*(x3+x4);
                        Form1.itypemassFluxuds2:=8; // особый случай.
                        Application.MessageBox(PChar('распознано GaAs, K2='+FloatToStr(Form1.ruds_GaAs_top)+', K4='+FloatToStr(Form1.ruds_GaAs_bottom)),'good',MB_OK);
                     end;
                  end;


               end;
            end;
            Form1.itypeuds2unsteadyfunction:=cbbunsteadyfunction.ItemIndex;
         end;
     2 : begin
            Form1.itypemassFluxuds3:=cbbfluxfunction.ItemIndex;
            if (Form1.itypemassFluxuds3=2) then
            begin
               // удаляем возможные начальные и конечные пробелы !!!
               edtVx.Text:=Trim(edtVx.Text);
               edtVy.Text:=Trim(edtVy.Text);

               Form1.Vxuds3str:=edtVx.Text;
               Form1.Vyuds3str:=edtVy.Text;

               if ((Pos('-$gradyuds1',edtVx.Text)=1)and (Length(edtVx.Text)=11) and (Pos('$gradxuds1',edtVy.Text)=1)and (Length(edtVy.Text)=10)) then
               begin
                  // Скорость в уравнениях Навье-Стокса в терминах вихрь функция тока.
                  // Предполагается, что третье уравнение есть уравнение теплопередачи,
                  // и мы имеем дело с уравнениями Навье-Стокса в приближении Буссинеска.
                  Form1.itypemassFluxuds3:=5; // особый случай.
               end
            end;
            Form1.itypeuds3unsteadyfunction:=cbbunsteadyfunction.ItemIndex;
         end;
     3 : begin
            Form1.itypemassFluxuds4:=cbbfluxfunction.ItemIndex;
            if (Form1.itypemassFluxuds4=2) then
            begin
               Form1.Vxuds4str:=edtVx.Text;
               Form1.Vyuds4str:=edtVy.Text;
            end;
            Form1.itypeuds4unsteadyfunction:=cbbunsteadyfunction.ItemIndex;
         end;
   end;
end;

procedure TFormUserDefinedScalar.cbbfluxfunctionChange(Sender: TObject);
begin
   // Смена типа Flux Function
   case cbbfluxfunction.ItemIndex of
    0 : // none
        begin
           grpvelocitycomponent.Visible:=False;
        end;
    1 : // гидродинамические компоненты скорости
        begin
           if ((Form1.imodelEquation=3) or (Form1.imodelEquation=4) or (Form1.imodelEquation=5)) then
           begin
              grpvelocitycomponent.Visible:=False;
           end
            else
           begin
              // none
              cbbfluxfunction.ItemIndex:=0;
              grpvelocitycomponent.Visible:=False;
           end;
        end;
    2 : // User-Define Component
        begin
           case cbbindex.ItemIndex of
             0 : // UDS1
                begin
                   edtVx.Text:=Form1.Vxuds1str;
                   edtVy.Text:=Form1.Vyuds1str;
                end;
             1 : // UDS2
                begin
                   edtVx.Text:=Form1.Vxuds2str;
                   edtVy.Text:=Form1.Vyuds2str;
                end;
             2 : // UDS3
                begin
                   edtVx.Text:=Form1.Vxuds3str;
                   edtVy.Text:=Form1.Vyuds3str;
                end;
             3 : // UDS4
                begin
                   edtVx.Text:=Form1.Vxuds4str;
                   edtVy.Text:=Form1.Vyuds4str;
                end;
           end;
           grpvelocitycomponent.Visible:=True;
        end;
   end;
end;

end.
