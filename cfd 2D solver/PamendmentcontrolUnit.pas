unit PamendmentcontrolUnit;
// в данном модуле можно проконтролировать как именно
// будет решаться уравнение для поправки давления.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TPamendmendcontrolForm = class(TForm)
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    ButtonApplay: TButton;
    CheckBoxipifixpamendment: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Bresetpressure: TButton;
    procedure ButtonApplayClick(Sender: TObject);
    procedure BresetpressureClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PamendmendcontrolForm: TPamendmendcontrolForm;

implementation
uses
       MainUnit; // использует главный модуль

{$R *.dfm}

procedure TPamendmendcontrolForm.ButtonApplayClick(Sender: TObject);
begin
   case RadioGroup1.ItemIndex of
      0 : Form1.bPatankarPressure:=true; // условие Патанкара
      1 : Form1.bPatankarPressure:=false; // условие Неймана
    end;
    // фиксировать ли уровень для поправки давления ?
    if (CheckBoxipifixpamendment.Checked) then
        Form1.bipifixpamendment:=true
      else
        Form1.bipifixpamendment:=false;

end;

procedure TPamendmendcontrolForm.BresetpressureClick(Sender: TObject);
begin
   Form1.initPressure;
end;

end.
