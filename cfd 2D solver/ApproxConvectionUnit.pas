unit ApproxConvectionUnit;
// Этот модуль предоставляет удобную систему меню
// для выбора аппроксимации конвективного члена.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TApproxConvectionForm = class(TForm)
    Pmain: TPanel;
    Label1: TLabel;
    RadioGroup2: TRadioGroup;
    Bapply: TButton;
    grpGarber: TGroupBox;
    chkonGarber: TCheckBox;
    GroupBox1: TGroupBox;
    Labeludsindex: TLabel;
    ComboBoxudsindex: TComboBox;
    LabelScheme: TLabel;
    ComboBoxSchemeuds: TComboBox;
    GBVOFtransientformulation: TGroupBox;
    CBVOFtransientFormulation: TComboBox;
    GBFlowTransForm: TGroupBox;
    CBFlowTransientFormulation: TComboBox;
    GBTemperature: TGroupBox;
    CBTemperature: TComboBox;
    GBFlow: TGroupBox;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    CBFlow: TComboBox;
    Label4: TLabel;
    CBISezai: TCheckBox;
    GBTemperatureTransientFormulation: TGroupBox;
    CBTemperatureunsteadyformulation: TComboBox;
    CheckBoxISezainofabs: TCheckBox;
    CheckBoxKIvanovApprox: TCheckBox;
    procedure BapplyClick(Sender: TObject);
    procedure ComboBoxudsindexChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ApproxConvectionForm: TApproxConvectionForm;

implementation
uses
     MainUnit;
{$R *.dfm}

// выбор схемы аппроксимации конвективного члена
procedure TApproxConvectionForm.BapplyClick(Sender: TObject);
begin
   // усиление диагонального преобладания для стационарных задач.
   Form1.bISezai:=CBISezai.Checked;
   // по умолчанию стоит схема со степенным законом,
   // предложенная С. Патанкаром.
   if ((CBFlow.ItemIndex>=0) and (CBFlow.ItemIndex<=6)) then
   begin
       Form1.brealisticflow:=false;
       Form1.ishconv:=CBFlow.ItemIndex + 1;
   end
   else if (CBFlow.ItemIndex=7)  then
   begin
     //  if ((CBFlow.ItemIndex>=7) and (CBFlow.ItemIndex<=13))
      // реалистичное течение за счёт того что для аппроксимации
      // конвективного члена используется метод конечных разностей,
      // но неявно учитывается лишь противопоточная часть а улучшенная
      // аппроксимация входит в правую часть.
      Form1.brealisticflow:=true;
      Form1.ishconv:=CBFlow.ItemIndex-6;
   end
   else
   begin
      Form1.brealisticflow:=false;
      case CBFlow.ItemIndex of
            8 : begin
                    // QUICK
                    Form1.ishconv:=1000;
                 end;
             9 : begin
                    // LUS
                    Form1.ishconv:=1001;
                 end;
             10 : begin
                    // CUS
                    Form1.ishconv:=1002;
                 end;
             11: begin
                    // SMART
                    Form1.ishconv:=1003;
                 end;
             12 : begin
                    // H_QUICK
                    Form1.ishconv:=1004;
                 end;
             13 : begin
                     // UMIST
                     Form1.ishconv:=1005;
                 end;
             14 : begin
                     // CHARM
                     Form1.ishconv:=1006;
                 end;
             15 : begin
                     // MUSCL
                     Form1.ishconv:=1007;
                 end;
             16 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconv:=1008;
                 end;
             17 : begin
                     // OSPRE
                     Form1.ishconv:=1009;
                 end;
             18 : begin
                     // VAN_ALBADA
                     Form1.ishconv:=1010;
                 end;
             19 : begin
                     // SUPERBEE
                     Form1.ishconv:=1011;
                 end;
             20 : begin
                     // MINMOD
                     Form1.ishconv:=1012;
                 end;
             21 : begin
                     // H_CUS
                     Form1.ishconv:=1013;
                 end;
             22 : begin
                     // KOREN
                     Form1.ishconv:=1014;
                 end;
             23 : begin
                     // FROMM
                     Form1.ishconv:=1015;
                 end;
      end;
   end;
   // схема аппроксимации уравнения теплопередачи.
   if ((CBTemperature.ItemIndex>=0) and (CBTemperature.ItemIndex<=6)) then
   begin
      // стабильное течение.
      Form1.brealistictemperature:=false;
      Form1.ishconvtemp:=CBTemperature.ItemIndex + 1;
   end
     else if (CBTemperature.ItemIndex=7) then
   begin
     // if ((CBTemperature.ItemIndex>=7) and (CBTemperature.ItemIndex<=13))
      // реалистичное течение.
      Form1.brealistictemperature:=true;
      Form1.ishconvtemp:=CBTemperature.ItemIndex-6;
   end
   else
   begin
      Form1.brealistictemperature:=false;
      case CBTemperature.ItemIndex of
            8 : begin
                    // QUICK
                    Form1.ishconvtemp:=1000;
                 end;
             9 : begin
                    // LUS
                    Form1.ishconvtemp:=1001;
                 end;
             10 : begin
                    // CUS
                    Form1.ishconvtemp:=1002;
                 end;
             11: begin
                    // SMART
                    Form1.ishconvtemp:=1003;
                 end;
             12 : begin
                    // H_QUICK
                    Form1.ishconvtemp:=1004;
                 end;
             13 : begin
                     // UMIST
                     Form1.ishconvtemp:=1005;
                 end;
             14 : begin
                     // CHARM
                     Form1.ishconvtemp:=1006;
                 end;
             15 : begin
                     // MUSCL
                     Form1.ishconvtemp:=1007;
                 end;
             16 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconvtemp:=1008;
                 end;
             17 : begin
                     // OSPRE
                     Form1.ishconvtemp:=1009;
                 end;
             18 : begin
                     // VAN_ALBADA
                     Form1.ishconvtemp:=1010;
                 end;
             19 : begin
                     // SUPERBEE
                     Form1.ishconvtemp:=1011;
                 end;
             20 : begin
                     // MINMOD
                     Form1.ishconvtemp:=1012;
                 end;
             21 : begin
                     // H_CUS
                     Form1.ishconvtemp:=1013;
                 end;
             22 : begin
                     // KOREN
                     Form1.ishconvtemp:=1014;
                 end;
             23 : begin
                     // FROMM
                     Form1.ishconvtemp:=1015;
                 end;
      end;

   end;

   // установка алгоритма решения:
   case RadioGroup2.ItemIndex of
     0 : // SIMPLE
       begin
          Form1.bsimplec:=false;
          Form1.bsimpler:=false;
       end;
     1 : // SIMPLEC
       begin
          Form1.bsimplec:=true;
          Form1.bsimpler:=false;
       end;
     2 : // SIMPLER
       begin
          Form1.bsimplec:=false;
          Form1.bsimpler:=true;
       end;
   end;
   if (chkonGarber.Checked) then
   begin
     Form1.bGarberArtDiffusion:=True;
   end
   else
   begin
      Form1.bGarberArtDiffusion:=False;
   end;
   if (Form1.bVOFExplicit=false) then
   begin
      // неявная схема для VOF
      case CBVOFtransientFormulation.ItemIndex of
        0 : begin
               // схема Эйлера.
               Form1.bVOFsecondorder:=false;
            end;
        1 : begin
               // схема Пейре.
               Form1.bVOFsecondorder:=true;
            end;
      end;
   end;
   // схема по времени для течения.
   case CBFlowTransientFormulation.ItemIndex of
    0 : begin
           // Эйлер
           Form1.bsecondorderflow:=false;
        end;
    1 : begin
           // Пейре
           Form1.bsecondorderflow:=true;
        end;
   end;
   // схема по времени для температуры.
   case CBTemperatureunsteadyformulation.ItemIndex of
    0 : begin
           // Эйлер
           Form1.bsecondordertemp:=false;
        end;
    1 : begin
           // Пейре
           Form1.bsecondordertemp:=true;
        end;
   end;
   case ComboBoxudsindex.ItemIndex of
     0 : begin
            case ComboBoxSchemeuds.ItemIndex of
             0 : begin
                    // Центрально - разностная схема.
                    Form1.ishconv1:=1;
                 end;
             1 : begin
                    // First Order Upwind
                    Form1.ishconv1:=2;
                 end;
             2 : begin
                    Form1.ishconv1:=3;
                 end;
             3 : begin
                    Form1.ishconv1:=4;
                 end;
             4 : begin
                    Form1.ishconv1:=5;
                 end;
             5 : begin
                    // Схема Булгакова.
                    Form1.ishconv1:=6;
                 end;
             6 : begin
                    // Показательная схема.
                    Form1.ishconv1:=7;
                 end;
             7 : begin
                    // QUICK
                    Form1.ishconv1:=1000;
                 end;
             8 : begin
                    // LUS
                    Form1.ishconv1:=1001;
                 end;
             9 : begin
                    // CUS
                    Form1.ishconv1:=1002;
                 end;
             10: begin
                    // SMART
                    Form1.ishconv1:=1003;
                 end;
             11 : begin
                    // H_QUICK
                    Form1.ishconv1:=1004;
                 end;
             12 : begin
                     // UMIST
                     Form1.ishconv1:=1005;
                 end;
             13 : begin
                     // CHARM
                     Form1.ishconv1:=1006;
                 end;
             14 : begin
                     // MUSCL
                     Form1.ishconv1:=1007;
                 end;
             15 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconv1:=1008;
                 end;
             16 : begin
                     // OSPRE
                     Form1.ishconv1:=1009;
                 end;
             17 : begin
                     // VAN_ALBADA
                     Form1.ishconv1:=1010;
                 end;
             18 : begin
                     // SUPERBEE
                     Form1.ishconv1:=1011;
                 end;
             19 : begin
                     // MINMOD
                     Form1.ishconv1:=1012;
                 end;
             20 : begin
                     // H_CUS
                     Form1.ishconv1:=1013;
                 end;
             21 : begin
                     // KOREN
                     Form1.ishconv1:=1014;
                 end;
             22 : begin
                     // FROMM
                     Form1.ishconv1:=1015;
                 end;
            end;

         end;
     1 : begin
            case ComboBoxSchemeuds.ItemIndex of
             0 : begin
                    // Центрально - разностная схема.
                    Form1.ishconv2:=1;
                 end;
             1 : begin
                    // First Order Upwind
                    Form1.ishconv2:=2;
                 end;
             2 : begin
                    Form1.ishconv2:=3;
                 end;
             3 : begin
                    Form1.ishconv2:=4;
                 end;
             4 : begin
                    Form1.ishconv2:=5;
                 end;
             5 : begin
                    // Схема Булгакова.
                    Form1.ishconv2:=6;
                 end;
             6 : begin
                    // Показательная схема.
                    Form1.ishconv2:=7;
                 end;
             7 : begin
                    // QUICK
                    Form1.ishconv2:=1000;
                 end;
             8 : begin
                    // LUS
                    Form1.ishconv2:=1001;
                 end;
             9 : begin
                    // CUS
                    Form1.ishconv2:=1002;
                 end;
             10: begin
                    // SMART
                    Form1.ishconv2:=1003;
                 end;
             11 : begin
                    // H_QUICK
                    Form1.ishconv2:=1004;
                 end;
             12 : begin
                     // UMIST
                     Form1.ishconv2:=1005;
                 end;
             13 : begin
                     // CHARM
                     Form1.ishconv2:=1006;
                 end;
             14 : begin
                     // MUSCL
                     Form1.ishconv2:=1007;
                 end;
             15 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconv2:=1008;
                 end;
             16 : begin
                     // OSPRE
                     Form1.ishconv2:=1009;
                 end;
             17 : begin
                     // VAN_ALBADA
                     Form1.ishconv2:=1010;
                 end;
             18 : begin
                     // SUPERBEE
                     Form1.ishconv2:=1011;
                 end;
             19 : begin
                     // MINMOD
                     Form1.ishconv2:=1012;
                 end;
             20 : begin
                     // H_CUS
                     Form1.ishconv2:=1013;
                 end;
             21 : begin
                     // KOREN
                     Form1.ishconv2:=1014;
                 end;
             22 : begin
                     // FROMM
                     Form1.ishconv2:=1015;
                 end;
            end;

         end;
     2 : begin
            case ComboBoxSchemeuds.ItemIndex of
             0 : begin
                    // Центрально - разностная схема.
                    Form1.ishconv3:=1;
                 end;
             1 : begin
                    // First Order Upwind
                    Form1.ishconv3:=2;
                 end;
             2 : begin
                    Form1.ishconv3:=3;
                 end;
             3 : begin
                    Form1.ishconv3:=4;
                 end;
             4 : begin
                    Form1.ishconv3:=5;
                 end;
             5 : begin
                    // Схема Булгакова.
                    Form1.ishconv3:=6;
                 end;
             6 : begin
                    // Показательная схема.
                    Form1.ishconv3:=7;
                 end;
             7 : begin
                    // QUICK
                    Form1.ishconv3:=1000;
                 end;
             8 : begin
                    // LUS
                    Form1.ishconv3:=1001;
                 end;
             9 : begin
                    // CUS
                    Form1.ishconv3:=1002;
                 end;
             10: begin
                    // SMART
                    Form1.ishconv3:=1003;
                 end;
             11 : begin
                    // H_QUICK
                    Form1.ishconv3:=1004;
                 end;
             12 : begin
                     // UMIST
                     Form1.ishconv3:=1005;
                 end;
             13 : begin
                     // CHARM
                     Form1.ishconv3:=1006;
                 end;
             14 : begin
                     // MUSCL
                     Form1.ishconv3:=1007;
                 end;
             15 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconv3:=1008;
                 end;
             16 : begin
                     // OSPRE
                     Form1.ishconv3:=1009;
                 end;
             17 : begin
                     // VAN_ALBADA
                     Form1.ishconv3:=1010;
                 end;
             18 : begin
                     // SUPERBEE
                     Form1.ishconv3:=1011;
                 end;
             19 : begin
                     // MINMOD
                     Form1.ishconv3:=1012;
                 end;
             20 : begin
                     // H_CUS
                     Form1.ishconv3:=1013;
                 end;
             21 : begin
                     // KOREN
                     Form1.ishconv3:=1014;
                 end;
             22 : begin
                     // FROMM
                     Form1.ishconv3:=1015;
                 end;
            end;

         end;
     3 : begin
            case ComboBoxSchemeuds.ItemIndex of
             0 : begin
                    // Центрально - разностная схема.
                    Form1.ishconv4:=1;
                 end;
             1 : begin
                    // First Order Upwind
                    Form1.ishconv4:=2;
                 end;
             2 : begin
                    Form1.ishconv4:=3;
                 end;
             3 : begin
                    Form1.ishconv4:=4;
                 end;
             4 : begin
                    Form1.ishconv4:=5;
                 end;
             5 : begin
                    // Схема Булгакова.
                    Form1.ishconv4:=6;
                 end;
             6 : begin
                    // Показательная схема.
                    Form1.ishconv4:=7;
                 end;
             7 : begin
                    // QUICK
                    Form1.ishconv4:=1000;
                 end;
             8 : begin
                    // LUS
                    Form1.ishconv4:=1001;
                 end;
             9 : begin
                    // CUS
                    Form1.ishconv4:=1002;
                 end;
             10: begin
                    // SMART
                    Form1.ishconv4:=1003;
                 end;
             11 : begin
                    // H_QUICK
                    Form1.ishconv4:=1004;
                 end;
             12 : begin
                     // UMIST
                     Form1.ishconv4:=1005;
                 end;
             13 : begin
                     // CHARM
                     Form1.ishconv4:=1006;
                 end;
             14 : begin
                     // MUSCL
                     Form1.ishconv4:=1007;
                 end;
             15 : begin
                     // VAN_LEER_HARMONIC
                     Form1.ishconv4:=1008;
                 end;
             16 : begin
                     // OSPRE
                     Form1.ishconv4:=1009;
                 end;
             17 : begin
                     // VAN_ALBADA
                     Form1.ishconv4:=1010;
                 end;
             18 : begin
                     // SUPERBEE
                     Form1.ishconv4:=1011;
                 end;
             19 : begin
                     // MINMOD
                     Form1.ishconv4:=1012;
                 end;
             20 : begin
                     // H_CUS
                     Form1.ishconv4:=1013;
                 end;
             21 : begin
                     // KOREN
                     Form1.ishconv4:=1014;
                 end;
             22 : begin
                     // FROMM
                     Form1.ishconv4:=1015;
                 end;
            end;

         end;
   end;
end;

procedure TApproxConvectionForm.ComboBoxudsindexChange(Sender: TObject);
begin
   case ComboBoxudsindex.ItemIndex of
     0 : begin
            if ((Form1.ishconv1>=1) and (Form1.ishconv1<=7)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv1-1;
            end
            else  if ((Form1.ishconv1>=1000) and (Form1.ishconv1<=1015)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv1-1000+7;
            end;
         end;
     1 : begin
             if ((Form1.ishconv2>=1) and (Form1.ishconv2<=7)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv2-1;
            end
             else  if ((Form1.ishconv2>=1000) and (Form1.ishconv2<=1015)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv2-1000+7;
            end;
         end;
     2 : begin
             if ((Form1.ishconv3>=1) and (Form1.ishconv3<=7)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv3-1;
            end
             else  if ((Form1.ishconv3>=1000) and (Form1.ishconv3<=1015)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv3-1000+7;
            end;
         end;
     3 : begin
             if ((Form1.ishconv4>=1) and (Form1.ishconv4<=7)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv4-1;
            end
             else  if ((Form1.ishconv4>=1000) and (Form1.ishconv4<=1015)) then
            begin
               ComboBoxSchemeuds.ItemIndex:=Form1.ishconv4-1000+7;
            end;
         end;
   end;
end;

end.
