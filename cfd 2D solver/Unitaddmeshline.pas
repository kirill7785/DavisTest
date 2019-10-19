unit Unitaddmeshline;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormaddmeshline = class(TForm)
    grpx: TGroupBox;
    grpy: TGroupBox;
    chkx1: TCheckBox;
    chkx2: TCheckBox;
    chkx3: TCheckBox;
    chkx4: TCheckBox;
    chkx5: TCheckBox;
    chkx6: TCheckBox;
    chkx7: TCheckBox;
    chkx8: TCheckBox;
    chkx9: TCheckBox;
    chkx10: TCheckBox;
    chkx11: TCheckBox;
    chkx12: TCheckBox;
    chkx13: TCheckBox;
    chky1: TCheckBox;
    chky2: TCheckBox;
    chky3: TCheckBox;
    chky4: TCheckBox;
    chky5: TCheckBox;
    chky6: TCheckBox;
    chky7: TCheckBox;
    chky8: TCheckBox;
    chky9: TCheckBox;
    chky10: TCheckBox;
    chky11: TCheckBox;
    chky12: TCheckBox;
    chky13: TCheckBox;
    edtx1: TEdit;
    edtx2: TEdit;
    edtx3: TEdit;
    edtx4: TEdit;
    edtx5: TEdit;
    edtx6: TEdit;
    edtx7: TEdit;
    edtx8: TEdit;
    edtx9: TEdit;
    edtx10: TEdit;
    edtx11: TEdit;
    edtx12: TEdit;
    edtx13: TEdit;
    edty1: TEdit;
    edty2: TEdit;
    edty3: TEdit;
    edty4: TEdit;
    edty5: TEdit;
    edty6: TEdit;
    edty7: TEdit;
    edty8: TEdit;
    edty9: TEdit;
    edty10: TEdit;
    edty11: TEdit;
    edty12: TEdit;
    edty13: TEdit;
    lstx: TListBox;
    lblx1: TLabel;
    lsty: TListBox;
    lbly1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Formaddmeshline: TFormaddmeshline;

implementation

{$R *.dfm}


// Данный метод сделан специально для проверки корректности ввода.
procedure TFormaddmeshline.FormClose(Sender: TObject;
  var Action: TCloseAction);
  var
     bOk : Boolean;
     r : Double;
begin
   bOk:=True;

   if (chkx1.Checked) then
   begin
      if (not TryStrToFloat(edtx1.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx1.Text+ ' x1 is incorrect value.');
      end;
   end;

   if (chkx2.Checked) then
   begin
      if (not TryStrToFloat(edtx2.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx2.Text+ ' x2 is incorrect value.');
      end;
   end;

   if (chkx3.Checked) then
   begin
      if (not TryStrToFloat(edtx3.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx3.Text+ ' x3 is incorrect value.');
      end;
   end;

   if (chkx4.Checked) then
   begin
      if (not TryStrToFloat(edtx4.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx4.Text+ ' x4 is incorrect value.');
      end;
   end;

    if (chkx5.Checked) then
   begin
      if (not TryStrToFloat(edtx5.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx5.Text+ ' x5 is incorrect value.');
      end;
   end;

   if (chkx6.Checked) then
   begin
      if (not TryStrToFloat(edtx6.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx6.Text+ ' x6 is incorrect value.');
      end;
   end;

   if (chkx7.Checked) then
   begin
      if (not TryStrToFloat(edtx7.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx7.Text+ ' x7 is incorrect value.');
      end;
   end;

   if (chkx8.Checked) then
   begin
      if (not TryStrToFloat(edtx8.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx8.Text+ ' x8 is incorrect value.');
      end;
   end;

    if (chkx9.Checked) then
   begin
      if (not TryStrToFloat(edtx9.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx9.Text+ ' x9 is incorrect value.');
      end;
   end;

   if (chkx10.Checked) then
   begin
      if (not TryStrToFloat(edtx10.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx10.Text+ ' x10 is incorrect value.');
      end;
   end;

   if (chkx11.Checked) then
   begin
      if (not TryStrToFloat(edtx11.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx11.Text+ ' x11 is incorrect value.');
      end;
   end;

    if (chkx12.Checked) then
   begin
      if (not TryStrToFloat(edtx12.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx12.Text+ ' x12 is incorrect value.');
      end;
   end;

    if (chkx13.Checked) then
   begin
      if (not TryStrToFloat(edtx13.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edtx13.Text+ ' x13 is incorrect value.');
      end;
   end;

   if (chky1.Checked) then
   begin
      if (not TryStrToFloat(edty1.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty1.Text+ ' y1 is incorrect value.');
      end;
   end;

   if (chky2.Checked) then
   begin
      if (not TryStrToFloat(edty2.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty2.Text+ ' y2 is incorrect value.');
      end;
   end;

   if (chky3.Checked) then
   begin
      if (not TryStrToFloat(edty3.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty3.Text+ ' y3 is incorrect value.');
      end;
   end;

   if (chky4.Checked) then
   begin
      if (not TryStrToFloat(edty4.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty4.Text+ ' y4 is incorrect value.');
      end;
   end;

    if (chky5.Checked) then
   begin
      if (not TryStrToFloat(edty5.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty5.Text+ ' y5 is incorrect value.');
      end;
   end;

   if (chky6.Checked) then
   begin
      if (not TryStrToFloat(edty6.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty6.Text+ ' y6 is incorrect value.');
      end;
   end;

   if (chky7.Checked) then
   begin
      if (not TryStrToFloat(edty7.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty7.Text+ ' y7 is incorrect value.');
      end;
   end;

   if (chky8.Checked) then
   begin
      if (not TryStrToFloat(edty8.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty8.Text+ ' y8 is incorrect value.');
      end;
   end;

    if (chky9.Checked) then
   begin
      if (not TryStrToFloat(edty9.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty9.Text+ ' y9 is incorrect value.');
      end;
   end;

   if (chky10.Checked) then
   begin
      if (not TryStrToFloat(edty10.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty10.Text+ ' y10 is incorrect value.');
      end;
   end;

   if (chky11.Checked) then
   begin
      if (not TryStrToFloat(edty11.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty11.Text+ ' y11 is incorrect value.');
      end;
   end;

    if (chky12.Checked) then
   begin
      if (not TryStrToFloat(edty12.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty12.Text+ ' y12 is incorrect value.');
      end;
   end;

    if (chky13.Checked) then
   begin
      if (not TryStrToFloat(edty13.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(edty13.Text+ ' y13 is incorrect value.');
      end;
   end;


   if (bOk) then
   begin
      Close;
   end;
end;

end.
