unit myProgressBarUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls;

type
  TmyProgressBarForm = class(TForm)
    ProgressBar1: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  myProgressBarForm: TmyProgressBarForm;

implementation

{$R *.dfm}

// здесь нет кода, а есть элемент ProgreesBar к которому обращаются из
// главного модуля MainUnit

end.
