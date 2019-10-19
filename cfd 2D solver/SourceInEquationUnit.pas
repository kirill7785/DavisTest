unit SourceInEquationUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Unitdeclar;

type
  TSourceInEquationForm = class(TForm)
    Panel1: TPanel;
    Ltitle: TLabel;
    Panel2: TPanel;
    LSc: TLabel;
    LSp: TLabel;
    ESc: TEdit;
    ESp: TEdit;
    Panel3: TPanel;
    Lnameequ: TLabel;
    EquationComboBox: TComboBox;
    Bapply: TButton;
    procedure BapplyClick(Sender: TObject);
    procedure OnSelect(Sender: TObject);
    procedure EquationComboBoxChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SourceInEquationForm: TSourceInEquationForm;

implementation
uses
    MainUnit; // использует главный модуль

{$R *.dfm}

// Задаёт источниковый член выбранного уравнения
procedure TSourceInEquationForm.BapplyClick(Sender: TObject);
var
   ind : Integer; // номер выбранного уравнения
   r : Real; // линеаризованная составляющая источнкового члена
   // Величины для случая предопределённого программистом шаблона.
   i1, i2 : Integer;
   x1 : Float;
   code1 : Integer;
   r1 : Double;
   bOk : Boolean;

procedure patch_edit();
var
  iscan : Integer;
  s : String;
begin
   s:=ESp.Text;
   for iscan:=1 to length(s) do
   begin
      if (FormatSettings.DecimalSeparator=',') then
      begin
         if (s[iscan]='.') then
         begin
            s[iscan]:=',';
         end;
      end;
       if (FormatSettings.DecimalSeparator='.') then
      begin
         if (s[iscan]=',') then
         begin
            s[iscan]:='.';
         end;
      end;
   end;
   ESp.Text:=s;
   s:=ESc.Text;
   for iscan:=1 to length(s) do
   begin
      if (FormatSettings.DecimalSeparator=',') then
      begin
         if (s[iscan]='.') then
         begin
            s[iscan]:=',';
         end;
      end;
       if (FormatSettings.DecimalSeparator='.') then
      begin
         if (s[iscan]=',') then
         begin
            s[iscan]:='.';
         end;
      end;
   end;
   ESc.Text:=s;
end;

begin
   patch_edit();  // решение проблемы разделителя

   ind:=EquationComboBox.ItemIndex;
   if (Form1.imodelEquation=1) then
   begin    

      // Теплопередача.
      case ind of
      0 :  // теплопроводность
          begin
             bOk:=true;

             if (not TryStrToFloat(ESp.Text,r1)) then
             begin
                bOk:=false;
                ShowMessage(ESp.Text+' value is incorrect');
             end;

             if (not TryStrToFloat(ESc.Text,r1)) then
             begin
                bOk:=false;
                ShowMessage(ESc.Text+' value is incorrect');
             end;

             if (bOk) then
      begin
             r:=StrToFloat(ESp.Text);
             if (r<=0) then
             begin
                // постоянная составляющая
                Form1.defmysource.Temperature.dSc:=StrToFloat(ESc.Text);
                // линеаризованная составляющая
                Form1.defmysource.Temperature.dSp:=r;
             end
             else
             begin
                // нужно сообщить что такие параметры не подходят
                // так как нарушено одно из правил С. Патанкара
                Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
             end;
             end;
          end;
      1 : // UDS1
      begin
         Form1.dsc1str:=Trim(ESc.Text);
         Form1.dsp1str:=Trim(ESp.Text);
      end;
      2 : // UDS2
      begin
         Form1.dsc2str:=Trim(ESc.Text);
         Form1.dsp2str:=Trim(ESp.Text);
      end;
      3 : // UDS3
      begin
         Form1.dsc3str:=Trim(ESc.Text);
         Form1.dsp3str:=Trim(ESp.Text);
      end;
      4 : // UDS4
      begin
         Form1.dsc4str:=Trim(ESc.Text);
         Form1.dsp4str:=Trim(ESp.Text);
      end;
      end;
   end
   else if (Form1.imodelEquation=2) then
   begin
      // User - Defined Segregated Solver
      case ind of
      0 : // UDS1
      begin
         Form1.idsc1type:=0;
         Form1.dsc1str:=Trim(ESc.Text);
         Form1.dsp1str:=Trim(ESp.Text);
         i1:=Pos('*(1.0-$uds2)',Form1.dsc1str);
         if ((i1>0) and (Length(Form1.dsc1str)=i1+11)) then
         begin
            //i2:=Length(Form1.dsc1str);
            Val(Copy(Form1.dsc1str,1,i1-1),x1,code1);
            if (code1=0) then
            begin
               Form1.idsc1type:=1;
               Form1.rdsc1K1:=x1; // константный множитель в формуле.
            end;
         end
          else
         begin
            i1:=Pos('$udm1-',Form1.dsc1str);
            i2:=Pos('*$uds2',Form1.dsc1str);
            if ((i1=1) and (i2>6)) then
            begin
                Val(Copy(Form1.dsc1str,7,i2-7),x1,code1);
                if (code1=0) then
                begin
                   Form1.idsc1type:=2;
                   Form1.rdsc1K1:=x1; // константный множитель в формуле.
                end;
            end;
         end;
      end;
      1 : // UDS2
      begin
         Form1.dsc2str:=ESc.Text;
         Form1.dsp2str:=ESp.Text;
      end;
      2 : // UDS3
      begin
         Form1.dsc3str:=ESc.Text;
         Form1.dsp3str:=ESp.Text;
      end;
      3 : // UDS4
      begin
         Form1.dsc4str:=ESc.Text;
         Form1.dsp4str:=ESp.Text;
      end;
      end;
   end
   else if (Form1.imodelEquation=3) then
   begin
      // Чистая гидродинамика
      case ind of
      0 : // горизонтальная компонента скорости
          begin
             r:=StrToFloat(ESp.Text);
             if (r<=0) then
             begin
                // постоянная составляющая
                Form1.defmysource.Vxvelocity.dSc:=StrToFloat(ESc.Text);
                // линеаризованная составляющая
                Form1.defmysource.Vxvelocity.dSp:=r;
             end
             else
             begin
                // нужно сообщить что такие параметры не подходят
                // так как нарушено одно из правил С. Патанкара
                Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
             end;
          end;
      1 : // вертикальная компонента скорости
          begin
              r:= StrToFloat(ESp.Text);
              if (r<=0) then
              begin
                 // постоянная составляющая
                 Form1.defmysource.Vyvelocity.dSc:=StrToFloat(ESc.Text);
                 // линеаризованная составляющая
                 Form1.defmysource.Vyvelocity.dSp:=r;
              end
              else
              begin
                 // нужно сообщить что такие параметры не подходят
                 // так как нарушено одно из правил С. Патанкара
                 Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
              end;
          end;
      2 : // UDS1
      begin
         Form1.dsc1str:=ESc.Text;
         Form1.dsp1str:=ESp.Text;
      end;
      3 : // UDS2
      begin
         Form1.dsc2str:=ESc.Text;
         Form1.dsp2str:=ESp.Text;
      end;
      4 : // UDS3
      begin
         Form1.dsc3str:=ESc.Text;
         Form1.dsp3str:=ESp.Text;
      end;
      5 : // UDS4
      begin
         Form1.dsc4str:=ESc.Text;
         Form1.dsp4str:=ESp.Text;
      end;
      end;
   end
   else if (Form1.imodelEquation=4) then
   begin
      // Теплопроводность и гидродинамика.
     case ind of
      0 : // теплопроводность
          begin
             r:=StrToFloat(ESp.Text);
             if (r<=0) then
             begin
                // постоянная составляющая
                Form1.defmysource.Temperature.dSc:=StrToFloat(ESc.Text);
                // линеаризованная составляющая
                Form1.defmysource.Temperature.dSp:=r;
             end
             else
             begin
                // нужно сообщить что такие параметры не подходят
                // так как нарушено одно из правил С. Патанкара
                Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
             end;
          end;
      1 : // горизонтальная компонента скорости
          begin
             r:=StrToFloat(ESp.Text);
             if (r<=0) then
             begin
                // постоянная составляющая
                Form1.defmysource.Vxvelocity.dSc:=StrToFloat(ESc.Text);
                // линеаризованная составляющая
                Form1.defmysource.Vxvelocity.dSp:=r;
             end
             else
             begin
                // нужно сообщить что такие параметры не подходят
                // так как нарушено одно из правил С. Патанкара
                Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
             end;
          end;
      2 : // вертикальная компонента скорости
          begin
              r:= StrToFloat(ESp.Text);
              if (r<=0) then
              begin
                 // постоянная составляющая
                 Form1.defmysource.Vyvelocity.dSc:=StrToFloat(ESc.Text);
                 // линеаризованная составляющая
                 Form1.defmysource.Vyvelocity.dSp:=r;
              end
              else
              begin
                 // нужно сообщить что такие параметры не подходят
                 // так как нарушено одно из правил С. Патанкара
                 Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
              end;
          end;
      3 : // UDS1
      begin
         Form1.dsc1str:=ESc.Text;
         Form1.dsp1str:=ESp.Text;
      end;
      4 : // UDS2
      begin
         Form1.dsc2str:=ESc.Text;
         Form1.dsp2str:=ESp.Text;
      end;
      5 : // UDS3
      begin
         Form1.dsc3str:=ESc.Text;
         Form1.dsp3str:=ESp.Text;
      end;
      6 : // UDS4
      begin
         Form1.dsc4str:=ESc.Text;
         Form1.dsp4str:=ESp.Text;
      end;
      end; // case
   end
   else if (Form1.imodelEquation=5) then
   begin
      case ind of
      0 : // горизонтальная компонента скорости
          begin
             r:=StrToFloat(ESp.Text);
             if (r<=0) then
             begin
                // постоянная составляющая
                Form1.defmysource.Vxvelocity.dSc:=StrToFloat(ESc.Text);
                // линеаризованная составляющая
                Form1.defmysource.Vxvelocity.dSp:=r;
             end
             else
             begin
                // нужно сообщить что такие параметры не подходят
                // так как нарушено одно из правил С. Патанкара
                Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
             end;
          end;
      1 : // вертикальная компонента скорости
          begin
              r:= StrToFloat(ESp.Text);
              if (r<=0) then
              begin
                 // постоянная составляющая
                 Form1.defmysource.Vyvelocity.dSc:=StrToFloat(ESc.Text);
                 // линеаризованная составляющая
                 Form1.defmysource.Vyvelocity.dSp:=r;
              end
              else
              begin
                 // нужно сообщить что такие параметры не подходят
                 // так как нарушено одно из правил С. Патанкара
                 Application.MessageBox('Возможно физический процесс может стать неустойчивым. Данные параметры не будут приняты.','',MB_OK);
              end;
          end;
      end;
   end;
end; // задание или изменение источникового члена

// выбрано конкретное уравнение
procedure TSourceInEquationForm.OnSelect(Sender: TObject);
var
   ind : Integer; // номер выбранного уравнения
begin
   ind:=EquationComboBox.ItemIndex;
   if (Form1.imodelEquation=1) then
   begin
      // Температура
      if (ind>=0) then
      begin
         case ind of
        0 : // теплопроводность
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Temperature.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Temperature.dSp);
            end;
        1 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        2 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        3 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        4 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=2) then
   begin
      if (ind>=0) then
      begin
      case ind of
        0 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        1 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        2 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        3 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=3) then
   begin
      if (ind>=0) then
      begin
      case ind of
        0 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        1 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
        2 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        3 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        4 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        5 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=4) then
   begin
      // теплопередача и гидродинамика.
      if (ind>=0) then
      begin
      case ind of
        0 : // теплопроводность
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Temperature.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Temperature.dSp);
            end;
        1 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        2 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
        3 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        4 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        5 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        6 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
    else if (Form1.imodelEquation=5) then
   begin
      if (ind >= 0) then
   begin
     case ind of
        0 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        1 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
     end; // case
   end; // if
   end;
end;

// смена уравнения
procedure TSourceInEquationForm.EquationComboBoxChange(Sender: TObject);
var
   ind : Integer; // номер выбранного уравнения
begin
   ind:=EquationComboBox.ItemIndex;
   if (Form1.imodelEquation=1) then
   begin
      // Температура
      if (ind>=0) then
      begin
         case ind of
        0 : // теплопроводность
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Temperature.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Temperature.dSp);
            end;
        1 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        2 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        3 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        4 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=2) then
   begin
      if (ind>=0) then
      begin
      case ind of
        0 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        1 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        2 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
         3 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=3) then
   begin
      if (ind>=0) then
      begin
      case ind of
        0 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        1 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
        2 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        3 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        4 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        5 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
   else if (Form1.imodelEquation=4) then
   begin
      // теплопередача и гидродинамика.
      if (ind>=0) then
      begin
      case ind of
        0 : // теплопроводность
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Temperature.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Temperature.dSp);
            end;
        1 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        2 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
        3 : begin
               // UDS1
               ESc.Text:=Form1.dsc1str;
               Esp.Text:=Form1.dsp1str;
            end;
        4 : begin
               // UDS2
               ESc.Text:=Form1.dsc2str;
               Esp.Text:=Form1.dsp2str;
            end;
        5 : begin
               // UDS3
               ESc.Text:=Form1.dsc3str;
               Esp.Text:=Form1.dsp3str;
            end;
        6 : begin
               // UDS4
               ESc.Text:=Form1.dsc4str;
               Esp.Text:=Form1.dsp4str;
            end;
        end;
      end;
   end
    else if (Form1.imodelEquation=5) then
   begin
      if (ind >= 0) then
   begin
     case ind of
        0 : // горизонтальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vxvelocity.dSp);
            end;
        1 : // вертикальная скорость
            begin
               ESc.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSc);
               ESp.Text:=FloatToStr(Form1.defmysource.Vyvelocity.dSp);
            end;
     end; // case
   end; // if
   end;
end;

end.
