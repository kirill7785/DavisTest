unit RelaxFactorsUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Unitdeclar;

type
  TRelaxFactorsForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel; // параметр релаксации к давлению (пи добавлении поправки)
    Bapply: TButton;
    GroupBox3: TGroupBox;
    GroupBox1: TGroupBox;
    lblMomentum: TLabel;
    edtEMomentum: TEdit;
    GroupBoxPressure: TGroupBox;
    LPressure: TLabel;
    EPressure: TEdit;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    Label6: TLabel;
    ESORPamendment: TEdit;
    GroupBox5: TGroupBox;
    ESORTempretrure: TEdit;
    GroupBoxBussinesk: TGroupBox;
    EBodyForce: TEdit;
    Label2: TLabel;
    GBUDS: TGroupBox;
    CBUDS: TComboBox;
    Edituds: TEdit;
    SpeedButton1: TSpeedButton;
    procedure BapplyClick(Sender: TObject);
    procedure CBUDSChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RelaxFactorsForm: TRelaxFactorsForm;

implementation
uses
    MainUnit; // использует главный модуль
{$R *.dfm}

// задаёт параметры релаксации
procedure TRelaxFactorsForm.BapplyClick(Sender: TObject);
begin
   // задание параметров релаксации
   // для алгоритма SIMPLE
   Form1.myrelaxfactors.Momentum:=StrToFloat(edtEMomentum.Text); // уравнения сохранения импульса.
   if (not(Form1.bsimplec)) then
   begin
      // только в том случае если используется алгоритм SIMPLE
      Form1.myrelaxfactors.PressureRelax:=StrToFloat(EPressure.Text); // для давления
   end;
   // для решения уравнения для поправки давления методом SOR:
   // последовательной верхней релаксации:
   Form1.myrelaxfactors.pSORPressure:=StrToFloat(ESORPamendment.Text); // SOR для поправки давления.
   Form1.myrelaxfactors.pSORTempreture:=StrToFloat(ESORTempretrure.Text); // SOR для температуры
   if (Form1.bBussinesk) then
   begin
      // При численном моделировании естественной конвекции
      // при больших числах Рэлея во избежании расходимости
      // желательно замедлить изменение источникового члена от итерации к итерации,
      // для этого используется нижняя релаксация:
      Form1.myrelaxfactors.prelaxBodyForce:=StrToFloat(EBodyForce.Text); // нижняя релаксация
   end;
   case CBUDS.ItemIndex of
      0 : begin
             Form1.myrelaxfactors.uds1:=StrToFloat(EditUDS.Text);
          end;
      1 : begin
             Form1.myrelaxfactors.uds2:=StrToFloat(EditUDS.Text);
          end;
      2 : begin
             Form1.myrelaxfactors.uds3:=StrToFloat(EditUDS.Text);
          end;
      3 : begin
             Form1.myrelaxfactors.uds4:=StrToFloat(EditUDS.Text);
          end;
   end;
end;  // задаёт параметры релаксации

procedure TRelaxFactorsForm.CBUDSChange(Sender: TObject);
begin
    case CBUDS.ItemIndex of
      0 : begin
             EditUDS.Text:=FloatToStr(Form1.myrelaxfactors.uds1);
          end;
      1 : begin
             EditUDS.Text:=FloatToStr(Form1.myrelaxfactors.uds2);
          end;
      2 : begin
             EditUDS.Text:=FloatToStr(Form1.myrelaxfactors.uds3);
          end;
      3 : begin
             EditUDS.Text:=FloatToStr(Form1.myrelaxfactors.uds4);
          end;
    end;
end;

procedure TRelaxFactorsForm.SpeedButton1Click(Sender: TObject);
var
    beta,ksi,r : Float;
begin
    // только равномерная сетка, прямоугольная область и только
    // условия Дирихле.
    // оптимальный параметр релаксации по книге Роуча стр. 183.
    beta:=(Form1.xpos[2]-Form1.xpos[1])/(Form1.ypos[2]-Form1.ypos[1]);
    ksi:=(cos(3.141/(Form1.inx-1))+beta*beta*cos(3.141/(Form1.iny-1)))/(1.0+beta*beta);
    ksi:=ksi*ksi;
    r:=2.0*(1.0-sqrt(1.0-ksi))/ksi;
    ESORPamendment.Text:=FloatToStr(r);
end;

end.
