unit TerminateProcessUnit;
// Заготовка для прерывания процесса вычислений по требованию

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TTerminateProcessForm = class(TForm)
    btnBTerminate: TButton;
    procedure btnBTerminateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TerminateProcessForm: TTerminateProcessForm;

implementation
uses
     MainUnit; // использует главный модуль
{$R *.dfm}

// по нажатию на кнопку
// меняет значение переменной в главном модуле
// что даёт установку корректно прервать процесс вычислений
procedure TTerminateProcessForm.btnBTerminateClick(Sender: TObject);
begin
   Form1.bweShouldContinue:=false;
end; // даёт установку прервать вычисления

end.
