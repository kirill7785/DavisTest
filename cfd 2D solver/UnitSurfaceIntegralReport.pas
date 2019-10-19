unit UnitSurfaceIntegralReport;
// При многопараметрическом моделировании после
// каждого расчёта нужно сохранять результат в виде отчёта.
// В данном модуле пользователю позволяется сформировать отчёт,
// а именно указать какие характеристики войдут в отчёт.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormAutoReportSurfInt = class(TForm)
    grpreptype: TGroupBox;
    cbbreporttype: TComboBox;
    grpboundary: TGroupBox;
    cbbboundary: TComboBox;
    grpfieldvariable: TGroupBox;
    cbbfieldvariable: TComboBox;
    grpreportname: TGroupBox;
    edtreportname: TEdit;
    grpmultiplyer: TGroupBox;
    edtmultiplyer: TEdit;
    btnapply: TButton;
    procedure btnapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAutoReportSurfInt: TFormAutoReportSurfInt;

implementation

uses UnitDefineTrials, GridGenUnit;

{$R *.dfm}

// Ввод данных которые позволят сформировать отчёт.
procedure TFormAutoReportSurfInt.btnapplyClick(Sender: TObject);
begin
   // устанавливаем тип отчёта.
   FormDefineTrials.mylistreport[FormDefineTrials.imaxreport].itypereport:=cbbreporttype.ItemIndex;
   // имя отчёта :
   FormDefineTrials.mylistreport[FormDefineTrials.imaxreport].reportname:=edtreportname.Text;
   // домножающий множитель перевода из безразмерных единиц в размерные :
   FormDefineTrials.mylistreport[FormDefineTrials.imaxreport].multiplyer:=StrToFloat(edtmultiplyer.Text);
   // подготовка границ.
   if (GridGenForm.inumboundary>0) then
   begin
      FormDefineTrials.mylistreport[FormDefineTrials.imaxreport].ibound:=cbbboundary.ItemIndex+1; // выбранная пользователем граница.
   end;
   // идентификатор полевой величины.
   FormDefineTrials.mylistreport[FormDefineTrials.imaxreport].icff:=cbbfieldvariable.ItemIndex;
end;

end.
