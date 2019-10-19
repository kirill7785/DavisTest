unit MyResControlUnit;
// в этом модуле можно задать пороговые значения невязок
// по достижению которых вычисление будет прервано

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMyResControlForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    LabelTemperature: TLabel;
    LabelXVel: TLabel;
    LabelYVel: TLabel;
    LabelPamendment: TLabel;
    LabelEquation: TLabel;
    LabelValue2: TLabel;
    EditTemperature: TEdit;
    EditXVel: TEdit;
    EditYVel: TEdit;
    EditPamendment: TEdit;
    Labelcontinity1: TLabel;
    Labelcontinity2: TLabel;
    Editcontinity: TEdit;
    LabelValue1: TLabel;
    ButtonApply: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Estreamfunc: TEdit;
    Label10: TLabel;
    LabelPressure: TLabel;
    EditPressure: TEdit;
    Label3: TLabel;
    Label11: TLabel;
    lbludsindex: TLabel;
    cbbuds: TComboBox;
    edtuds: TEdit;
    procedure ButtonApplyClick(Sender: TObject);
    procedure cbbudsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MyResControlForm: TMyResControlForm;

implementation

uses
     MainUnit; // использует главный модуль

{$R *.dfm}


// по нажатию на кнопку пороговые значения невязок
// считываются в специальную структуру данных.
procedure TMyResControlForm.ButtonApplyClick(Sender: TObject);
var
    bOk : Boolean;
    r : Double;
begin
  bOk:=True;
  if (not TryStrToFloat(EditTemperature.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EditTemperature.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EditXVel.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EditXVel.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EditYVel.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EditYVel.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EditPamendment.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EditPamendment.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(Editcontinity.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Editcontinity.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(Estreamfunc.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(Estreamfunc.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(EditPressure.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EditPressure.Text+' is incorrect value.');
  end;
  if (not TryStrToFloat(edtuds.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(edtuds.Text+' is incorrect value.');
  end;

  if (bOk) then
  begin
     // Здесь нужно считать введённые
     // пороговые значения невязок в специальную
     // структуру данных.
     Form1.rcs.temp:=StrToFloat(EditTemperature.Text); // температура
     Form1.rcs.Vx:=StrToFloat(EditXVel.Text); // горизонтальная компонента скорости
     Form1.rcs.Vy:=StrToFloat(EditYVel.Text); // вертикальная компонента скорости
     Form1.rcs.Pamendment:=StrToFloat(EditPamendment.Text); // поправка давления
     Form1.rcs.continity:=StrToFloat(Editcontinity.Text); // нескомпенсированные источники массы
     Form1.rcs.streamfunction:=StrToFloat(Estreamfunc.Text); // функция тока
     Form1.rcs.Pressure:=StrToFloat(EditPressure.Text); // Давление
     case cbbuds.ItemIndex of
      0 : begin
             Form1.rcs.uds1:=StrToFloat(edtuds.Text);
          end;
      1 : begin
             Form1.rcs.uds2:=StrToFloat(edtuds.Text);
          end;
      2 : begin
             Form1.rcs.uds3:=StrToFloat(edtuds.Text);
          end;
      3 : begin
             Form1.rcs.uds4:=StrToFloat(edtuds.Text);
          end;
     end;
  end;
end;

procedure TMyResControlForm.cbbudsChange(Sender: TObject);
begin
   case cbbuds.ItemIndex of
      0 : begin
             edtuds.Text:=FloatToStr(Form1.rcs.uds1);
          end;
      1 : begin
             edtuds.Text:=FloatToStr(Form1.rcs.uds2);
          end;
      2 : begin
             edtuds.Text:=FloatToStr(Form1.rcs.uds3);
          end;
      3 : begin
             edtuds.Text:=FloatToStr(Form1.rcs.uds4);
          end;
   end;
end;

end.

