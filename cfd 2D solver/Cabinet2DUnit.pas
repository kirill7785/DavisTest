unit Cabinet2DUnit;
// изменение размеров кабинета

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCabinet2DForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    EdLx: TEdit;
    EdLy: TEdit;
    BApply: TButton;
    procedure BApplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Cabinet2DForm: TCabinet2DForm;

implementation
uses
     MainUnit, GridGenUnit;

{$R *.dfm}

// изменение размеров кабинета
procedure TCabinet2DForm.BApplyClick(Sender: TObject);
var
   bOk : Boolean;
   r : Double;
begin
  bOk:=True;

  if (not TryStrToFloat(EdLx.Text,r)) then
  begin
     bOk:=False;
     ShowMessage(EdLx.Text+' is incorrect value.');
  end;

   if (not TryStrToFloat(EdLy.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(EdLy.Text+' is incorrect value.');
   end;

   if (bOk) then
   begin
      if (StrToFloat(EdLx.Text)<=0.0) then
      begin
          bOk:=False;
          ShowMessage(EdLx.Text+' error ! is negative Width value');
      end;
      if (StrToFloat(EdLy.Text)<=0.0) then
      begin
          bOk:=False;
          ShowMessage(EdLy.Text+' error ! is negative Height value');
      end;
   end;

  if (bOk) then
  begin
    Form1.dLx:=StrToFloat(EdLx.Text); // ширина и высота
    Form1.dLy:=StrToFloat(EdLy.Text);
    GridGenForm.bricklist[0].xL:=Form1.dLx; // ширина и
    GridGenForm.bricklist[0].yL:=Form1.dLy; // высота
    Close;
  end;
end;

end.
