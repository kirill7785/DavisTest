unit UnitPatternCFF;
// Задаёт некоторые функции-заготовки, которые потом будут визуализироваться в программе tecplot360.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormPatCFF = class(TForm)
    lbl1: TLabel;
    cbbpattern: TComboBox;
    pnlsilicon: TPanel;
    lbl2: TLabel;
    lblvsat: TLabel;
    edtvsat: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    lblelectronmobility: TLabel;
    edtelectronmobility: TEdit;
    btninfo: TButton;
    btncontinue: TButton;
    procedure btncontinueClick(Sender: TObject);
    procedure cbbpatternChange(Sender: TObject);
    procedure btninfoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPatCFF: TFormPatCFF;

implementation

uses MainUnit, Unitmessagesilicon;

{$R *.dfm}

procedure TFormPatCFF.btncontinueClick(Sender: TObject);
var
    rbuf : Real;
begin
   case cbbpattern.ItemIndex of
     // 0 просто закрываем форму.
     1 : begin
            // Полная информация о кремниевом приборе:
            // распределение пространственного заряда, дрейфовых скоростей и токов в полупроводнике.
            Form1.inumCFF:=7; // 7   отображаемых величин.
            // различные характеристики кремния.
            rbuf:=StrToFloat(edtelectronmobility.Text)/strToFloat(edtvsat.Text);
            Form1.cff1name:='x-vel';
            Form1.cff1str:='$gradxuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff2name:='y-vel';
            Form1.cff2str:='$gradyuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff3name:='vel-mag';
            Form1.cff3str:='sqrt(sqr($gradxuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))+sqr($gradyuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))))';
            Form1.cff4name:='curent-x';
            Form1.cff4str:=Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff5name:='curent-y';
            Form1.cff5str:=Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff6name:='curent-magnitude';
            Form1.cff6str:='sqrt(sqr('+Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))+sqr('+Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1/(1.0+'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1)))))';
            // пространственный заряд
            Form1.cff7name:='charge';
            Form1.cff7str:=Form1.dsc1str;
         end;
     2 : begin
            // Полная информация об алмазном приборе (для моделирования обращённого прибора):
            // распределение пространственного заряда, дрейфовых скоростей и токов в полупроводнике.
            Form1.inumCFF:=7; // 7   отображаемых величин.
            // различные характеристики алмаза.
            rbuf:=StrToFloat(edtelectronmobility.Text)/strToFloat(edtvsat.Text);
            Form1.cff1name:='x-vel';
            Form1.cff1str:='$gradxuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))';
            Form1.cff2name:='y-vel';
            Form1.cff2str:='$gradyuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))';
            Form1.cff3name:='vel-mag';
            Form1.cff3str:='sqrt(sqr($gradxuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1)))+sqr($gradyuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))))';
            Form1.cff4name:='curent-x';
            Form1.cff4str:=Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))';
            Form1.cff5name:='curent-y';
            Form1.cff5str:=Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))';
            Form1.cff6name:='curent-magnitude';
            Form1.cff6str:='sqrt(sqr('+Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1)))+sqr('+Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1*'+edtvsat.Text+'*(1.0-exp(-'+FloatToStr(rbuf)+'*sqrt(sqr($gradxuds1)+sqr($gradyuds1))))/sqrt(sqr($gradxuds1)+sqr($gradyuds1))))';
            // пространственный заряд
            Form1.cff7name:='charge';
            Form1.cff7str:=Form1.dsc1str;
         end;
     3 : begin
            // Полная информация о GaAs приборе:
            // распределение пространственного заряда, дрейфовых скоростей и токов в полупроводнике.
            Form1.inumCFF:=7; // 7   отображаемых величин.
            // различные характеристики GaAs.
            Form1.cff1name:='x-vel';
            Form1.cff1str:='$gradxuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff2name:='y-vel';
            Form1.cff2str:='$gradyuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff3name:='vel-mag';
            Form1.cff3str:='(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff4name:='curent-x';
            Form1.cff4str:=Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff5name:='curent-y';
            Form1.cff5str:=Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))';
            Form1.cff6name:='curent-magnitude';
            Form1.cff6str:='sqrt(sqr('+Form1.gamma2str+'*$gradxuds2-$uds2*$gradxuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1))))+sqr('+Form1.gamma2str+'*$gradyuds2-$uds2*$gradyuds1*(sqrt(sqr($gradxuds1)+sqr($gradyuds1))+'+FloatToStr(Form1.ruds_GaAs_top)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(1.0+'+FloatToStr(Form1.ruds_GaAs_bottom)+'*sqr(sqr($gradxuds1)+sqr($gradyuds1)))/(sqrt(sqr($gradxuds1)+sqr($gradyuds1)))))';
            // пространственный заряд
            Form1.cff7name:='charge';
            Form1.cff7str:=Form1.dsc1str;
         end;
   end;
   Close;
end;

// делает видимым или невидимым соответствующие панели где
// задаются свойства шаблоны Custom Field Function
procedure TFormPatCFF.cbbpatternChange(Sender: TObject);
begin
   case cbbpattern.ItemIndex of
   0 : begin
          pnlsilicon.Visible:=False;
       end;
   1 : begin
          pnlsilicon.Visible:=True;
       end;
   2 : begin
          pnlsilicon.Visible:=True;
       end;
   end;
end;

procedure TFormPatCFF.btninfoClick(Sender: TObject);
begin
   Formmessagesilicon.ShowModal;
end;

end.
