﻿unit ExportTecplotUnit;
// модуль экспорта картинки в программу tecplot

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TExportTecplotForm = class(TForm)
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    Bapply: TButton;
    Panelmean: TPanel;
    BFlow: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LmeanT: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label3: TLabel;
    PexportTecplot: TPanel;
    Bextec: TButton;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    LT: TLabel;
    lblVOF: TLabel;
    procedure BapplyClick(Sender: TObject);
    procedure BFlowClick(Sender: TObject);
    procedure BextecClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExportTecplotForm: TExportTecplotForm;

implementation
uses
     MainUnit; // использует главный модуль

{$R *.dfm}

// передаёт картинку в программу tecplot 360
procedure TExportTecplotForm.BapplyClick(Sender: TObject);
var
   ind : Integer; // какая величина выбрана

begin
    ind:=RadioGroup1.ItemIndex;
    case ind of
       0 : // горизонтальная скорость
           begin
              Form1.exporttecplotUniversal(5);
           end;
       1 : // вертикальная скорость
           begin
              Form1.exporttecplotUniversal(6);
           end;
       2 : //  Вихрь и функция тока
           begin
              Form1.exporttecplotUniversal(2);
           end;
       3 : //  давление
           begin
              Form1.exporttecplotUniversal(4);
           end;
       4 : //  температура
           begin
              Form1.exporttecplotUniversal(3);
           end;
       5 : // Custom Field Function
           begin
              Form1.exporttecplotUniversal(1);
           end;
       6 : // функция цвета
           begin
              Form1.exporttecplotUniversal(7);
           end;
       7 : // user-defined memory
           begin
              Form1.exporttecplotUniversal(8);
           end;
       8 : // user-defined scalar
           begin
              Form1.exporttecplotUniversal(9);
           end;
    end; // case
    // шаблон для следующих переменных величин
    //Application.MessageBox('эта возможность пока не реализована','',MB_OK);

end;

procedure TExportTecplotForm.BFlowClick(Sender: TObject);
begin
   // передаёт все картинки касающиеся осреднённого поля течения в программу техплот
   Form1.exporttecplotmeanUniversalComplete; // вся информация о поле осреднённого течения
end;

procedure TExportTecplotForm.BextecClick(Sender: TObject);
begin
   // передаёт все картинки касающиеся поля течения в программу техплот
   Form1.exporttecplotUniversalComplete;
end;

end.
