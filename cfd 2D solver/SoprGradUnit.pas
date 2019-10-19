unit SoprGradUnit;
// выбор алгоритма сортировки при формировании матрицы СЛАУ.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TSoprGradForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadioGroup2: TRadioGroup;
    Bapply: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    procedure BapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SoprGradForm: TSoprGradForm;

implementation
   uses MainUnit; // использует главнывй модуль
{$R *.dfm}


// считывание настроек метода сопряжённых градиентов
// при нажатии на кнопку
procedure TSoprGradForm.BapplyClick(Sender: TObject);
begin
   // считывание настроек:
   // выбор алгоритма сортировки.
   // Всё сделано на основе CRS формата хранения разреженной матрицы.
   Form1.itypesorter:=RadioGroup2.ItemIndex+1;
end;

end.
