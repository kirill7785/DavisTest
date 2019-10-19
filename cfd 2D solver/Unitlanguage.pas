unit Unitlanguage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormlanguage = class(TForm)
    pnllanguage1: TPanel;
    rglanguage1: TRadioGroup;
    grpparallelcpu: TGroupBox;
    lblcore: TLabel;
    cbbcore: TComboBox;
    procedure rglanguage1Click(Sender: TObject);
    procedure cbbcoreChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Formlanguage: TFormlanguage;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormlanguage.rglanguage1Click(Sender: TObject);
begin
   // смена языка реализации
   if (rglanguage1.ItemIndex>2) then
   begin
      rglanguage1.ItemIndex:=1; // пока реализован лишь язык паскаль и Си (частично)
   end;

   Form1.ilanguage:=rglanguage1.ItemIndex; // считывание языка реализации.
   if (rglanguage1.ItemIndex=2) then
   begin
      grpparallelcpu.Visible:=True;
      Form1.ig_nNumberOfThreads:=1+cbbcore.ItemIndex;
   end
    else
   begin
      grpparallelcpu.Visible:=False;
   end;

end;

procedure TFormlanguage.cbbcoreChange(Sender: TObject);
begin
   Form1.ig_nNumberOfThreads:=1+cbbcore.ItemIndex;
end;

end.
