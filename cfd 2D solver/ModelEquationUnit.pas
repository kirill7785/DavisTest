unit ModelEquationUnit;
// здесь можно выбрать систему уравнений для решения.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TModelEquationForm = class(TForm)
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    Bapply: TButton;
    btnvof: TButton;
    procedure BapplyClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure btnvofClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    oldeq : Integer; // предыдущий набор уравнений до выбора
  end;

var
  ModelEquationForm: TModelEquationForm;

implementation
uses
      MainUnit, UnitVOFScheme; // использует главный модуль

{$R *.dfm}

// выбор  решаемого уравнения или системы таких уравнений
procedure TModelEquationForm.BapplyClick(Sender: TObject);
begin
   Form1.imodelEquation:=RadioGroup1.ItemIndex+1;
   if ((oldeq=0) or (oldeq=1)) and ((RadioGroup1.ItemIndex=2) or (RadioGroup1.ItemIndex=3)) then
   begin
      // от теплопроводности перешли к Навье-Стоксу
      Form1.imarker:=0; // сброс показа невязки
   end;
   if ((oldeq=2) or (oldeq=3)) and ((RadioGroup1.ItemIndex=0) or (RadioGroup1.ItemIndex=1)) then
   begin
      // от Навье-Стокса к теплопроводности
      Form1.imarker:=0; // сброс показа невязки
   end;
   if ((RadioGroup1.ItemIndex=4) or (oldeq=4)) then Form1.imarker:=0; // VOF model
   Close;
end; // выбор системы решаемых уравнений

procedure TModelEquationForm.RadioGroup1Click(Sender: TObject);
begin
   // щелчёк с выбором набора уравнений.
   if (RadioGroup1.ItemIndex=4) then // VOF
   begin
      if (Form1.btimedepend=False) then
      begin
          Form1.btimedepend:=True;
          MessageBox(0,'VOF method решатель автоматически переведён на нестационарный.','Warning',MB_OK);
      end;
      btnvof.Visible:=True;
   end
   else
   begin
      btnvof.Visible:=False;
   end;
end;

procedure TModelEquationForm.btnvofClick(Sender: TObject);
begin
   // Volume Fractiomn Parameters
   FormVolumeFractPar.CBCSF.Checked:=Form1.bCSF;
   if (FormVolumeFractPar.CBCSF.Checked) then
   begin
       FormVolumeFractPar.Esigma.Text:=FloatToStr(Form1.rsigma);
       if (Form1.bWallAdhesion) then
       begin
          FormVolumeFractPar.CBWallAdhesion.Checked:=true;
       end
       else
       begin
          FormVolumeFractPar.CBWallAdhesion.Checked:=false;
       end;
       FormVolumeFractPar.Panel1.Visible:=true;
   end
   else
   begin
      FormVolumeFractPar.Panel1.Visible:=false;
   end;
   if (Form1.iantidiffusionBuragoevery=High(Integer)) then
   begin
      FormVolumeFractPar.cbbeveryts.ItemIndex:=12;
   end
   else
   begin
      case Form1.iantidiffusionBuragoevery of
       1 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=0;
           end;
       2 : begin
              FormVolumeFractPar.cbbeveryts.ItemIndex:=1;
           end;
       3 : begin
              FormVolumeFractPar.cbbeveryts.ItemIndex:=2;
           end;
       4 : begin
              FormVolumeFractPar.cbbeveryts.ItemIndex:=3;
           end;
       5 : begin
              FormVolumeFractPar.cbbeveryts.ItemIndex:=4;
           end;
       10 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=5;
            end;
       15 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=6;
            end;
       20 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=7;
            end;
       25 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=8;
            end;
       50 : begin
               FormVolumeFractPar.cbbeveryts.ItemIndex:=9;
            end;
       100 : begin
                FormVolumeFractPar.cbbeveryts.ItemIndex:=10;
             end;
       200 : begin
                FormVolumeFractPar.cbbeveryts.ItemIndex:=11;
             end;
      end;
   end;
   // Показываем число Куранта.
   FormVolumeFractPar.EditCourant.Text:=FloatToStr(Form1.CourantNumber);
   FormVolumeFractPar.ShowModal;
end;

end.
