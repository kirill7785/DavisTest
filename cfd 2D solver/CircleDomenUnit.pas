unit CircleDomenUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TCircleDomenForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ExC: TEdit;
    EyC: TEdit;
    Label4: TLabel;
    Eradius: TEdit;
    Panel3: TPanel;
    Label5: TLabel;
    cbbCBSelectFunction: TComboBox;
    Label6: TLabel;
    Evalue: TEdit;
    Bpatch: TButton;
    Bclose: TButton;
    procedure BcloseClick(Sender: TObject);
    procedure BpatchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CircleDomenForm: TCircleDomenForm;

implementation
uses
     MainUnit; // использует главный модуль

{$R *.dfm}

// закрывает форму
procedure TCircleDomenForm.BcloseClick(Sender: TObject);
begin
   Close;
end;

// инициализирует круглую подобласть заданным значением функции для
// 1 - VOF метода.
procedure TCircleDomenForm.BpatchClick(Sender: TObject);
var
    xC, yC, rradius : Real; // координаты прямоугольника
    rvalue : Real; // значение функции
    k : Integer;
    bOk : Boolean;
    // корректность ввода.
    bOk2 : Boolean;
    r : Double;

begin
   bOk2:=True;

   if (not TryStrToFloat(ExC.Text,r)) then
   begin
       bOk2:=False;
       ShowMessage(ExC.Text+' is incorrect value.');
   end;
   if (not TryStrToFloat(EyC.Text,r)) then
   begin
       bOk2:=False;
       ShowMessage(EyC.Text+' is incorrect value.');
   end;
   if (not TryStrToFloat(Eradius.Text,r)) then
   begin
       bOk2:=False;
       ShowMessage(Eradius.Text+' is incorrect value.');
   end;
   if (Pos('$',Evalue.Text)=0) then
   begin
      // текстовое поле не содержит переменных.
      if (not TryStrToFloat(Evalue.Text,r)) then
      begin
         bOk2:=False;
         ShowMessage(Evalue.Text+' is incorrect value.');
      end;
   end;

   if (bOk2) then
   begin

      xC:=StrToFloat(ExC.Text);
      yC:=StrToFloat(EyC.Text);
      rradius:=StrToFloat(Eradius.Text);

   for k:=1 to Form1.imaxnumbernode do
   begin
      with Form1.mapPT[k] do
      begin
         if (itype<>0) then
         begin
            // только для узлов принадлежащих расчётной области

            if ((Form1.xpos[i]-xC)*(Form1.xpos[i]-xC) + (Form1.ypos[j]-yC)*(Form1.ypos[j]-yC) <= rradius*rradius) then
            begin
               case Form1.imaxUDM of
                 0 : begin
                        // изначально функция тока всюду
                        // равна нулю, включая границы
                        rvalue:=StrToFloat(Evalue.Text);
                        Form1.VOF[i+(j-1)*Form1.inx]:=rvalue;
                     end;
                 1 : begin
                        if (Form1.imodelEquation=5) then
                        begin
                           case cbbCBSelectFunction.ItemIndex of
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

                 2 : begin
                        if (Form1.imodelEquation=5) then
                        begin
                           case cbbCBSelectFunction.ItemIndex of
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
                              case cbbCBSelectFunction.ItemIndex of
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
                           case cbbCBSelectFunction.ItemIndex of
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
                           case cbbCBSelectFunction.ItemIndex of
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

end.
