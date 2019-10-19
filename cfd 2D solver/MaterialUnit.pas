unit MaterialUnit;
// В данном модуле задаются параметры материалов

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TMaterialForm = class(TForm)
    Pmaterial: TPanel;
    Label1: TLabel;
    Panellambda: TPanel;
    Llambda: TLabel;     // название динамической вязкости
    Elambda: TEdit;
    PanelNusha: TPanel;
    Emu: TEdit;
    PanelCp: TPanel;
    Lcp: TLabel;
    Ecp: TEdit;
    GroupBoxDensity: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Erho: TEdit;
    ComboBox1: TComboBox;
    Label6: TLabel;
    materialComboBox: TComboBox;
    Bapplymaterial: TButton;
    PanelBeta: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    EbetaT: TEdit;
    lbluds: TLabel;
    btnuds: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton; // кнопка задания или изменения свойств материалов
    procedure BapplymaterialClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure materialComboBoxChange(Sender: TObject);
    procedure btnudsClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MaterialForm: TMaterialForm;

implementation
uses
    MainUnit, UnitUserDefinedScalarDiffusion;  // использует главный модуль

{$R *.dfm}

// задаёт или изменяет параметры материалов
// путём передачи информации в структуру
// MaterialProperties главной формы MainUnit.
procedure TMaterialForm.BapplymaterialClick(Sender: TObject);
var
  bOk : Boolean;
  r : Double;
begin
  bOk:=true;

   if (not TryStrToFloat(Elambda.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Elambda.Text+' lambda is incorrect value.');
  end;

  if (not TryStrToFloat(Erho.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Erho.Text+' rho is incorrect value.');
  end;

  if (not TryStrToFloat(Ecp.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Ecp.Text+' cp is incorrect value.');
  end;

  if (not TryStrToFloat(Emu.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Emu.Text+' mu is incorrect value.');
  end;

  if (ComboBox1.ItemIndex = 1) then
  begin
         if (not TryStrToFloat(EbetaT.Text,r)) then
         begin
            bOk:=False;
            ShowMessage(EbetaT.Text+' betaT is incorrect value.');
         end;
  end;

   if (bOk) then
   begin
      Form1.matprop[materialComboBox.ItemIndex].dlambda:=StrToFloat(Elambda.Text); // теплопроводность
      Form1.matprop[materialComboBox.ItemIndex].drho:=StrToFloat(Erho.Text); // плотность
      Form1.matprop[materialComboBox.ItemIndex].dcp:=StrToFloat(Ecp.Text); // теплоёмкость
      Form1.matprop[materialComboBox.ItemIndex].dmu:=StrToFloat(Emu.Text); // динамическая вязкость
      if (ComboBox1.ItemIndex = 1) then
      begin
         // приближение Буссинеска
         Form1.matprop[materialComboBox.ItemIndex].beta:=StrToFloat(EbetaT.Text); // коэффициент линейного температурного расширения
      end;
   end;
end; // параметры материалов

// изменение типа плотности
// константа или приближение Буссинеска rho0
procedure TMaterialForm.ComboBox1Change(Sender: TObject);
begin
   // выбор приближения Буссинеска или
   // отказ от него
   if ((Form1.imodelEquation = 4) and (ComboBox1.ItemIndex = 1)) then
   begin
      // приближение Буссинеска
      PanelBeta.Visible:=true;
      Form1.bBussinesk:=true;
   end
   else
   begin
      // обычная плотность
      PanelBeta.Visible:=false;
      Form1.bBussinesk:=false;
      ComboBox1.ItemIndex:=0; // только константная плотность.
   end;
end;

// смена свойств фаз.
procedure TMaterialForm.materialComboBoxChange(Sender: TObject);
begin
  if (Form1.imodelEquation = 5) then
  begin
     // смена фазы.
     Elambda.Text:=FloatToStr(Form1.matprop[materialComboBox.ItemIndex].dlambda); // теплопроводность
     Erho.Text:=FloatToStr(Form1.matprop[materialComboBox.ItemIndex].drho);  // плотность
     Ecp.Text:=FloatToStr(Form1.matprop[materialComboBox.ItemIndex].dcp); // теплоёмкость
     Emu.Text:=FloatToStr(Form1.matprop[materialComboBox.ItemIndex].dmu); // динамическая вязкость
     if (ComboBox1.ItemIndex = 1) then
     begin
        // приближение Буссинеска
        // коэффициент линейного температурного расширения
        EbetaT.Text:=FloatToStr(Form1.matprop[materialComboBox.ItemIndex].beta);
     end;
   end
    else
   begin
      materialComboBox.ItemIndex:=0; // только первая фаза.
   end;
end;

procedure TMaterialForm.btnudsClick(Sender: TObject);
var
   i : Integer;
begin

   if (Form1.imaxUDS>0) then
   begin
      FormUDSDiffusivity.lstuds.Clear;
      for i:=1 to Form1.imaxUDS do
      begin
         FormUDSDiffusivity.lstuds.AddItem('uds'+IntToStr(i),Sender);
      end;
      FormUDSDiffusivity.lstuds.ItemIndex:=0;
      FormUDSDiffusivity.edtdiffusivity.Text:=Form1.gamma1str;
      if (Form1.bBussinesk) then
      begin
         FormUDSDiffusivity.lblBoussinesq.Visible:=True;
         FormUDSDiffusivity.edtBoussinesq.Visible:=True;
         FormUDSDiffusivity.edtBoussinesq.Text:=FloatToStr(Form1.dbetaUDS1);
      end
      else
      begin
         FormUDSDiffusivity.lblBoussinesq.Visible:=False;
         FormUDSDiffusivity.edtBoussinesq.Visible:=False;
      end;
      FormUDSDiffusivity.ShowModal; // задаём коэффициенты диффузии.
   end;
end;

procedure TMaterialForm.SpeedButton1Click(Sender: TObject);
begin
    Label1.Caption:='water liquid';
   // загружает параметры воды в проект
   if (FormatSettings.DecimalSeparator='.') then
   begin
      Erho.Text:='998.2';
      Ecp.Text:='4187.0';
      Emu.Text:='1.003e-3';
      Elambda.Text:='0.618';
      EbetaT.Text:='3.02e-4';
   end;
   if (FormatSettings.DecimalSeparator=',') then
   begin
      Erho.Text:='998,2';
      Ecp.Text:='4187,0';
      Emu.Text:='1,003e-3';
      Elambda.Text:='0,618';
      EbetaT.Text:='3,02e-4';
   end;

   Form1.matprop[materialComboBox.ItemIndex].dlambda:=StrToFloat(Elambda.Text); // теплопроводность
   Form1.matprop[materialComboBox.ItemIndex].drho:=StrToFloat(Erho.Text); // плотность
   Form1.matprop[materialComboBox.ItemIndex].dcp:=StrToFloat(Ecp.Text); // теплоёмкость
   Form1.matprop[materialComboBox.ItemIndex].dmu:=StrToFloat(Emu.Text); // динамическая вязкость
   // приближение Буссинеска
   Form1.matprop[materialComboBox.ItemIndex].beta:=StrToFloat(EbetaT.Text); // коэффициент линейного температурного расширения
end;

procedure TMaterialForm.SpeedButton2Click(Sender: TObject);
begin
   Label1.Caption:='abstract fluid';
   // загружает единицы в качестве свойств материалов в проект
   if (FormatSettings.DecimalSeparator='.') then
   begin
      Erho.Text:='1.0';
      Ecp.Text:='1.0';
      Emu.Text:='1.0';
      Elambda.Text:='1.0';
      EbetaT.Text:='1.0';
   end;
   if (FormatSettings.DecimalSeparator=',') then
   begin
      Erho.Text:='1,0';
      Ecp.Text:='1,0';
      Emu.Text:='1,0';
      Elambda.Text:='1,0';
      EbetaT.Text:='1,0';
   end;

   Form1.matprop[materialComboBox.ItemIndex].dlambda:=StrToFloat(Elambda.Text); // теплопроводность
   Form1.matprop[materialComboBox.ItemIndex].drho:=StrToFloat(Erho.Text); // плотность
   Form1.matprop[materialComboBox.ItemIndex].dcp:=StrToFloat(Ecp.Text); // теплоёмкость
   Form1.matprop[materialComboBox.ItemIndex].dmu:=StrToFloat(Emu.Text); // динамическая вязкость
   // приближение Буссинеска
   Form1.matprop[materialComboBox.ItemIndex].beta:=StrToFloat(EbetaT.Text); // коэффициент линейного температурного расширения

end;

procedure TMaterialForm.SpeedButton3Click(Sender: TObject);
begin

   Label1.Caption:='air';
   // загружает параметры воздуха в проект
   if (FormatSettings.DecimalSeparator='.') then
   begin
      Erho.Text:='1.2047';
      Ecp.Text:='1006.0';
      Emu.Text:='17.2e-6';
      Elambda.Text:='0.025';
      EbetaT.Text:='3.67e-3';
   end;
   if (FormatSettings.DecimalSeparator=',') then
   begin
      Erho.Text:='1,2047';
      Ecp.Text:='1006,0';
      Emu.Text:='17,2e-6';
      Elambda.Text:='0,025';
      EbetaT.Text:='3,67e-3';
   end;

   Form1.matprop[materialComboBox.ItemIndex].dlambda:=StrToFloat(Elambda.Text); // теплопроводность
   Form1.matprop[materialComboBox.ItemIndex].drho:=StrToFloat(Erho.Text); // плотность
   Form1.matprop[materialComboBox.ItemIndex].dcp:=StrToFloat(Ecp.Text); // теплоёмкость
   Form1.matprop[materialComboBox.ItemIndex].dmu:=StrToFloat(Emu.Text); // динамическая вязкость
   // приближение Буссинеска
   Form1.matprop[materialComboBox.ItemIndex].beta:=StrToFloat(EbetaT.Text); // коэффициент линейного температурного расширения
end;





end.
