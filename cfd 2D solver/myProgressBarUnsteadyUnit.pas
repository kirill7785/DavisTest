unit myProgressBarUnsteadyUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TmyProgressBarUnsteadyForm = class(TForm)
    ProgressBar1: TProgressBar; // нестационарный
    ProgressBar2: TProgressBar; // на фиксированном временном слое
    Label1: TLabel;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  myProgressBarUnsteadyForm: TmyProgressBarUnsteadyForm;

implementation

{$R *.dfm}

    // В этом модуле нет кода, но есть два StatusBar
    // которые используюся для отображения хода
    // расчёта при нестационарном вычислении.
    // Вызов происходит из главного модуля MainUnit

end.
