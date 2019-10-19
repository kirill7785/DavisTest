unit RectangleDomenUnit;
// дополнительная инициализация, например, для VOF метода.
// только прямоугольные домены.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TRectangleDomenForm = class(TForm)
    Panel1: TPanel;
    PositionGroupBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ExS: TEdit;
    EyS: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    ExL: TEdit;
    EyL: TEdit;
    Panel2: TPanel;
    Label5: TLabel;
    Label7: TLabel;
    Evalue: TEdit;
    Bpatch: TButton;
    CBSelectFunction: TComboBox;
    Bclose: TButton;
    chkdeltay: TCheckBox;
    procedure BpatchClick(Sender: TObject);
    procedure BcloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RectangleDomenForm: TRectangleDomenForm;

implementation
uses
        MainUnit; // использует главный модуль
{$R *.dfm}

// инициализирует прямоугольную подобласть заданным значением функции для
// 1 - VOF метода.
procedure TRectangleDomenForm.BpatchClick(Sender: TObject);
var
    xS, yS, xL, yL : Real; // координаты прямоугольника
    rvalue : Real; // значение функции
    k : Integer;
    bOk : Boolean;
    // при включённом bdelta_y_layer
    // Внимание ! только для udm1.
    // профиль легирования по оси y напоминает
    // треугольник : границы основания треугольника
    // берутся из размеров инициализирующего прямоугольника,
    // значения в основании беруться на основе значений udm
    // на границах (горизонтльных прямоугольника), значение
    // в вершине треугольника, берётся по середине основания
    // и считывается из дополнительного текстового поля Evalue.Text.
    bdelta_y_layer : Boolean;
    udmtop, udmbottom : Real;
    a, b : Real; // коэффициенты уравнения прямой.
    k1 : Integer;
    bOk1 : Boolean;
    dr1 : Double;


begin
  bOk1:=True;

  if (not TryStrToFloat(ExS.Text,dr1)) then
  begin
     bOk1:=False;
     ShowMessage(ExS.Text+' is incorrect value');
  end;
  if (not TryStrToFloat(EyS.Text,dr1)) then
  begin
     bOk1:=False;
     ShowMessage(EyS.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(ExL.Text,dr1)) then
  begin
     bOk1:=False;
     ShowMessage(ExL.Text+' is incorrect value');
  end;
   if (not TryStrToFloat(EyL.Text,dr1)) then
  begin
     bOk1:=False;
     ShowMessage(EyL.Text+' is incorrect value');
  end;
  if (Pos('$',Evalue.Text)=0) then
  begin
      // переменных не содержит.
      if (not TryStrToFloat(Evalue.Text,dr1)) then
      begin
         bOk1:=False;
         ShowMessage(Evalue.Text+' is incorrect value');
      end;
  end;

  if (bOk1) then
  begin
     xS:=StrToFloat(ExS.Text);
     yS:=StrToFloat(EyS.Text);
     xL:=StrToFloat(ExL.Text);
     yL:=StrToFloat(EyL.Text);


   for k:=1 to Form1.imaxnumbernode do
   begin
      with Form1.mapPT[k] do
      begin
         if (itype<>0) then
         begin
            // только для узлов принадлежащих расчётной области

            if ((Form1.xpos[i]<=(xS+xL)) and (Form1.xpos[i]>=xS) and (Form1.ypos[j]>=yS) and (Form1.ypos[j]<=(yS+yL))) then
            begin
               case Form1.imaxUDM of
                 0 : begin
                        // инициализируем функцию цвета для
                        //  двухфазного моделирования.
                        rvalue:=StrToFloat(Evalue.Text);
                        Form1.VOF[i+(j-1)*Form1.inx]:=rvalue;
                     end;
                 1 : begin
                        if (Form1.imodelEquation=5) then
                        begin
                           case CBSelectFunction.ItemIndex of
                               0 : begin
                                      // VOF
                                      rvalue:=StrToFloat(Evalue.Text);
                                      Form1.VOF[i+(j-1)*Form1.inx]:=rvalue;
                                   end;
                               1 : begin
                                      // UDM1
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                           end;
                        end
                         else
                        begin
                           // инициализировать ли треугольный профиль с горизонтальными основаниями.
                           bdelta_y_layer:=chkdeltay.Checked;
                           if (bdelta_y_layer) then
                           begin
                              // шаг 1. вычислить udmtop и udmbottom.
                              // Вычисление опорных величин для дельта легирования.
                              // Вычисляем udmtop :
                              for k1:=1 to Form1.iny do
                              begin
                                 if (Form1.ypos[k1]>yS+yL) then
                                 begin
                                    udmtop:=Form1.UDM1[i+(k1-1+1)*Form1.inx];
                                    break;
                                 end;
                              end;
                              // Вычисляем udmbottom :
                              for k1:=Form1.iny downto 1 do
                              begin
                                 if (Form1.ypos[k1]<yS) then
                                 begin
                                    udmbottom:=Form1.UDM1[i+(k1-1-1)*Form1.inx];
                                    break;
                                 end;
                              end;



                              Form1.ivar:=1; // одна переменная x.
                              SetLength(Form1.parametric,Form1.ivar);
                              Form1.parametric[0].svar:='$x';
                              Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                              bOk:=true;
                              if (Form1.ypos[j]>=yS+0.5*yL) then
                              begin
                                 // верхняя половина.
                                 // шаг 2. вычисление с использованием udmtop.
                                 a:=2.0*(udmtop-Form1.my_real_convert(Evalue.Text,bOk))/yL;
                                 b:=udmtop-2.0*(yS+yL)*(udmtop-Form1.my_real_convert(Evalue.Text,bOk))/yL;
                                 Form1.UDM1[i+(j-1)*Form1.inx]:=a*Form1.ypos[j]+b;
                              end
                               else
                              begin
                                 // нижняя половина.
                                 // шаг 2. вычисление с использованием udmbottom.
                                 a:=2.0*(Form1.my_real_convert(Evalue.Text,bOk)-udmbottom)/yL;
                                 b:=udmbottom-2.0*(Form1.my_real_convert(Evalue.Text,bOk)-udmbottom)*yS/yL;
                                 Form1.UDM1[i+(j-1)*Form1.inx]:=a*Form1.ypos[j]+b;
                              end;
                           end
                             else
                           begin
                              // UDM1
                              Form1.ivar:=2; // 2 переменные x и y
                              SetLength(Form1.parametric,Form1.ivar);
                              Form1.parametric[0].svar:='$x';
                              Form1.parametric[1].svar:='$y';
                              Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                              Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                              bOk:=true;
                              Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                           end;
                        end;
                     end;

                 2 : begin
                        if (Form1.imodelEquation=5) then
                        begin
                           case CBSelectFunction.ItemIndex of
                               0 : begin
                                      // VOF
                                      rvalue:=StrToFloat(Evalue.Text);
                                      Form1.VOF[i+(j-1)*Form1.inx]:=rvalue;
                                   end;
                               1 : begin
                                      // UDM1
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               2 : begin
                                      // UDM2
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM2[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                           end;
                        end
                            else
                           begin
                              case CBSelectFunction.ItemIndex of
                               0 : begin
                                      // UDM1
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               1 : begin
                                      // UDM2
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM2[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                              end;


                           end;
                        end;
                 3 : begin
                        if (Form1.imodelEquation=5) then
                        begin
                           case CBSelectFunction.ItemIndex of
                               0 : begin
                                      // VOF
                                      rvalue:=StrToFloat(Evalue.Text);
                                      Form1.VOF[i+(j-1)*Form1.inx]:=rvalue;
                                   end;
                               1 : begin
                                      // UDM1
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               2 : begin
                                      // UDM2
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM2[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               3 : begin
                                      // UDM3
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM3[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                           end;
                        end
                         else
                        begin
                           case CBSelectFunction.ItemIndex of
                               0 : begin
                                      // UDM1
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                     Form1.UDM1[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               1 : begin
                                      // UDM2
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM2[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                               2 : begin
                                      // UDM3
                                      Form1.ivar:=2; // 2 переменные x и y
                                      SetLength(Form1.parametric,Form1.ivar);
                                      Form1.parametric[0].svar:='$x';
                                      Form1.parametric[1].svar:='$y';
                                      Form1.parametric[0].sval:=FloatToStr(Form1.xpos[i]);
                                      Form1.parametric[1].sval:=FloatToStr(Form1.ypos[j]);
                                      bOk:=true;
                                      Form1.UDM3[i+(j-1)*Form1.inx]:=Form1.my_real_convert(Evalue.Text,bOk);
                                   end;
                           end;
                        end;
                     end;
               end;


            end;
         end;
     end;
   end;
   if (Form1.imodelEquation=5) then
   begin
      Form1.RememberVOF; // запоминаем функцию цвета при переходе на следующий шаг по времени.
      Form1.rememberDensity; // запоминание плотности с предыдущего временного слоя
   end;
   Application.MessageBox('инициализация прошла успешно','initialization',MB_OK);
   end;
end;

// закрывает форму
procedure TRectangleDomenForm.BcloseClick(Sender: TObject);
begin
   Close;
end;

end.
