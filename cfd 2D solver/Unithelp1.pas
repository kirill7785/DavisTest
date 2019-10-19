unit Unithelp1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormHelp = class(TForm)
    Memohelp: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormHelp: TFormHelp;

implementation

{$R *.dfm}

procedure TFormHelp.FormCreate(Sender: TObject);
begin
    // Условие ТОМА неподвижная стенка.
    Memohelp.Lines.Add('граничные условия Дирихле для вихря:');
    Memohelp.Lines.Add('условие ТОМА неподвижная стенка:');
    Memohelp.Lines.Add('$uds2w+0.7*(2.0*($uds1i-$uds1w)/($d*$d)-$uds2w)');
    Memohelp.Lines.Add('условие Йенсена неподвижная стенка. Внимание параметр нижней релаксации 0.125!!! :');
    Memohelp.Lines.Add('$uds2w+0.125*(0.5*(-7.0*$uds1w+8.0*$uds1i-$uds1ii)/($d*$d)-$uds2w)');
    Memohelp.Lines.Add('условие ТОМА стенка движущаяся по касательной вправо со скоростью 1:');
    Memohelp.Lines.Add('$uds2w+0.7*(2.0*($uds1i-$uds1w)/($d*$d)-2.0/$d-$uds2w)');
    Memohelp.Lines.Add('граница с условиями симметрии : вихрь равен нулю');
    Memohelp.Lines.Add('компоненты скорости в единичном квадрате: (водоворот против часовой стрелки)');
    Memohelp.Lines.Add('6.282*sin(3.141*$x)*sin(3.141*$x)*sin(3.141*$y)*cos(3.141*$y)');
    Memohelp.Lines.Add('-6.282*sin(3.141*$y)*sin(3.141*$y)*sin(3.141*$x)*cos(3.141*$x)');

    // памятка для VOF метода.
    Memohelp.Lines.Add('информация для прогона VOF method на реальной задаче:');
    Memohelp.Lines.Add('вода : плотность 998.2; дин. вязкость : 0.001003');
    Memohelp.Lines.Add('воздух : плотность 1.225; дин. вязкость : 1.7894e-5');
    Memohelp.Lines.Add('коэффициент поверхностного натяжения вода-воздух : 73.5e-3');
    Memohelp.Lines.Add('расчётная область 3.0e-5 x 3.8e-4. Шаг 1.0e-8с.');

    // Полескоростная характеристика для кремния
    Memohelp.Lines.Add(' полупроводниковое моделирование : РО 9x1.8 micron!2');
    Memohelp.Lines.Add('Width=36.7323E-4 Height=7.3465E-4 ');
    Memohelp.Lines.Add('Uvalue top : 0.22222 0.142857 0.333333 0.5 ');
    Memohelp.Lines.Add('silicon drift velocity : ');
    Memohelp.Lines.Add('$gradxuds1/(1.0+0.9821e-5*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))');
    Memohelp.Lines.Add('$gradyuds1/(1.0+0.9821e-5*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))');
    Memohelp.Lines.Add(' ugate=-29.07 udrain=290.7  nd=68.965e5  (-1V +10V 1e17 cm!-3)');
    Memohelp.Lines.Add(' Sc= $udm1 - 3858.5*$uds2, $udm1=266101.4525e5');
    Memohelp.Lines.Add('time step = 1e-5 ');
    // Полескоростная характеристика для GaAs :
    Memohelp.Lines.Add('GaAs drift velocity : ');
    Memohelp.Lines.Add('$gradxuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+2.8307137e-8*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+5.785855354e-10*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))');
    Memohelp.Lines.Add('$gradyuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+2.8307137e-8*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+5.785855354e-10*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))');

end;

end.
