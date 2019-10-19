unit Unitanimation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormAnimationSetting = class(TForm)
    lbl1: TLabel;
    cbbanimate: TComboBox;
    lbl2: TLabel;
    btnapply: TButton;
    chkanimation: TCheckBox;
    procedure btnapplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAnimationSetting: TFormAnimationSetting;

implementation

uses MainUnit;

{$R *.dfm}

// настройка периодичности записи анимационных кадров.
procedure TFormAnimationSetting.btnapplyClick(Sender: TObject);
begin
   case cbbanimate.ItemIndex of
     0 : begin
            Form1.ianimateeverytimestep:=1;
         end;
     1 : begin
            Form1.ianimateeverytimestep:=2;
         end;
     2 : begin
            Form1.ianimateeverytimestep:=3;
         end;
     3 : begin
            Form1.ianimateeverytimestep:=4;
         end;
     4 : begin
            Form1.ianimateeverytimestep:=5;
         end;
     5 : begin
            Form1.ianimateeverytimestep:=10;
         end;
     6 : begin
            Form1.ianimateeverytimestep:=15;
         end;
     7 : begin
            Form1.ianimateeverytimestep:=20;
         end;
     8 : begin
            Form1.ianimateeverytimestep:=25;
         end;
     9 : begin
            Form1.ianimateeverytimestep:=30;
         end;
     10 : begin
             Form1.ianimateeverytimestep:=40;
         end;
     11 : begin
             Form1.ianimateeverytimestep:=50;
         end;
     12 : begin
             Form1.ianimateeverytimestep:=100;
         end;
     13 : begin
             Form1.ianimateeverytimestep:=200;
         end;
   end;
   Form1.banimationnow:=chkanimation.Checked;
end;

end.
