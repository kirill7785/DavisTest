unit controlSIMPLEUnit;
// задаёт оценку сверху для количества итераций
// внутри алгоритма SIMPLE
// Ещё на одной вкладке можно настроить
// точность решения каждого уравнения отдельно.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TcontrolSIMPLEForm = class(TForm)
    btnBapply: TButton;
    grpmainpanel: TGroupBox;
    grpvelocitycomponent: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    edtEVxlin: TEdit;
    edtEVylin: TEdit;
    grpcorrection_to_the_pressure: TGroupBox;
    edtEPamendment: TEdit;
    grpStreamFunction: TGroupBox;
    edtStreamFunction: TEdit;
    grptemperature: TGroupBox;
    edtTemperature: TEdit;
    grppressure: TGroupBox;
    edtPressure: TEdit;
    grpUDS: TGroupBox;
    lbluds: TLabel;
    cbbuds: TComboBox;
    edtuds: TEdit;
    GBVOF: TGroupBox;
    EVOF: TEdit; // по нажатию на эту кнопку новые данные заносятся из формы в сердце главного модуля
    procedure btnBapplyClick(Sender: TObject);
    procedure cbbudsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  controlSIMPLEForm: TcontrolSIMPLEForm;

implementation
uses
     MainUnit; // использует главный модуль

{$R *.dfm}

// задаёт структуру одной итерации в алгоритме SIMPLE
procedure TcontrolSIMPLEForm.btnBapplyClick(Sender: TObject);
var
    bOk : Boolean;
    ir : Integer;
begin
   bOk:=True;
   if (Form1.imaxUDS > 0) then
   begin
      if (not TryStrToInt(edtuds.Text,ir)) then
      begin
         bOk:=False;
         ShowMessage(edtuds.Text+' in UDS Caption is incorrect');
      end;
   end;
   if (not TryStrToInt(EVOF.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(EVOF.Text+' in VOF Caption is incorrect');
   end;
   if (not TryStrToInt(edtPressure.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtPressure.Text+' in Pressure Caption is incorrect');
   end;
   if (not TryStrToInt(edtStreamFunction.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtStreamFunction.Text+' in Stream Function Caption is incorrect');
   end;
   if (not TryStrToInt(edtTemperature.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtTemperature.Text+' in Temperature Caption is incorrect');
   end;
   if (not TryStrToInt(edtEPamendment.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtEPamendment.Text+' in Pressure Amendment Caption is incorrect');
   end;
   if (not TryStrToInt(edtEVylin.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtEVylin.Text+' in y-velocity Caption is incorrect');
   end;
   if (not TryStrToInt(edtEVxlin.Text,ir)) then
   begin
      bOk:=False;
      ShowMessage(edtEVxlin.Text+' in x-velocity Caption is incorrect');
   end;
   if (bOk) then
   begin
      // параметры решения номинально линейной СЛАУ
      Form1.iterSimple.iterVxLin:=StrToInt(edtEVxlin.Text); // для Vx
      Form1.iterSimple.iterVyLin:=StrToInt(edtEVylin.Text); // для Vy
      // для поправки давления
      Form1.iterSimple.iterPamendment:=StrToInt(edtEPamendment.Text); // поправка давления
      // для нахождения поля температур в случае задач с
      // учётом естественной конвекции
      Form1.iterSimple.iterTemperature:=StrToInt(edtTemperature.Text); // поле температур
      // для нахождения функции тока
      Form1.iterSimple.iterStreamFunction:=StrToInt(edtStreamFunction.Text);
      // для давления в алгоритме SIMPLE Revised 1979
      Form1.iterSimple.iterPressure:=StrToInt(edtPressure.Text);
      if (Form1.btimedepend and (Form1.bVOFExplicit=false)) then
      begin
         Form1.iterSimple.iterVof:=StrToInt(EVOF.Text);
      end;
      if (Form1.imaxUDS>0) then
      begin
        case cbbuds.ItemIndex of
        0 : begin
              Form1.iterSimple.iteruds1:=StrToInt(edtuds.Text);
             end;
        1 : begin
               Form1.iterSimple.iteruds2:=StrToInt(edtuds.Text);
             end;
        2 : begin
                Form1.iterSimple.iteruds3:=StrToInt(edtuds.Text);
             end;
        3 : begin
                Form1.iterSimple.iteruds4:=StrToInt(edtuds.Text);
             end;
        end;
      end;
   end;
end; // структура одной итерации алгоритма SIMPLE

procedure TcontrolSIMPLEForm.cbbudsChange(Sender: TObject);
begin
   case cbbuds.ItemIndex of
      0 : begin
            edtuds.Text:=IntToStr(Form1.iterSimple.iteruds1);
          end;
      1 : begin
            edtuds.Text:=IntToStr(Form1.iterSimple.iteruds2);
          end;
      2 : begin
            edtuds.Text:=IntToStr(Form1.iterSimple.iteruds3);
          end;
      3 : begin
            edtuds.Text:=IntToStr(Form1.iterSimple.iteruds4);
          end;
   end;
end;

end.

