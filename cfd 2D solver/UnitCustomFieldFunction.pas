unit UnitCustomFieldFunction;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormCustomFieldFunction = class(TForm)
    lblcount: TLabel;
    cbbcount: TComboBox;
    pnlcff: TPanel;
    lbl1: TLabel;
    cbbindex: TComboBox;
    lbl2: TLabel;
    edtdefinition: TEdit;
    lblname: TLabel;
    edtname: TEdit;
    btnapply: TButton;
    procedure cbbindexChange(Sender: TObject);
    procedure btnapplyClick(Sender: TObject);
    procedure cbbcountChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCustomFieldFunction: TFormCustomFieldFunction;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormCustomFieldFunction.cbbindexChange(Sender: TObject);
begin
   // смена Custom Field Function
   case cbbindex.ItemIndex of
    0 : begin
           edtname.Text:=Form1.cff1name;
           edtdefinition.Text:=Form1.cff1str;
        end;
    1 : begin
           edtname.Text:=Form1.cff2name;
           edtdefinition.Text:=Form1.cff2str;
        end;
    2 : begin
           edtname.Text:=Form1.cff3name;
           edtdefinition.Text:=Form1.cff3str;
        end;
    3 : begin
           edtname.Text:=Form1.cff4name;
           edtdefinition.Text:=Form1.cff4str;
        end;
    4 : begin
           edtname.Text:=Form1.cff5name;
           edtdefinition.Text:=Form1.cff5str;
        end;
    5 : begin
           edtname.Text:=Form1.cff6name;
           edtdefinition.Text:=Form1.cff6str;
        end;
    6 : begin
           edtname.Text:=Form1.cff7name;
           edtdefinition.Text:=Form1.cff7str;
        end;
    7 : begin
           edtname.Text:=Form1.cff8name;
           edtdefinition.Text:=Form1.cff8str;
        end;
    8 : begin
           edtname.Text:=Form1.cff9name;
           edtdefinition.Text:=Form1.cff9str;
        end;
    9 : begin
           edtname.Text:=Form1.cff10name;
           edtdefinition.Text:=Form1.cff10str;
        end;
   end;
end;

procedure TFormCustomFieldFunction.btnapplyClick(Sender: TObject);
begin
   // Ввод Custom Field Function
   case cbbindex.ItemIndex of
    0 : begin
           Form1.cff1name:=edtname.Text;
           Form1.cff1str:=edtdefinition.Text;
        end;
    1 : begin
           Form1.cff2name:=edtname.Text;
           Form1.cff2str:=edtdefinition.Text;
        end;
    2 : begin
           Form1.cff3name:=edtname.Text;
           Form1.cff3str:=edtdefinition.Text;
        end;
    3 : begin
           Form1.cff4name:=edtname.Text;
           Form1.cff4str:=edtdefinition.Text;
        end;
    4 : begin
           Form1.cff5name:=edtname.Text;
           Form1.cff5str:=edtdefinition.Text;
        end;
    5 : begin
           Form1.cff6name:=edtname.Text;
           Form1.cff6str:=edtdefinition.Text;
        end;
    6 : begin
           Form1.cff7name:=edtname.Text;
           Form1.cff7str:=edtdefinition.Text;
        end;
    7 : begin
           Form1.cff8name:=edtname.Text;
           Form1.cff8str:=edtdefinition.Text;
        end;
    8 : begin
           Form1.cff9name:=edtname.Text;
           Form1.cff9str:=edtdefinition.Text;
        end;
    9 : begin
           Form1.cff10name:=edtname.Text;
           Form1.cff10str:=edtdefinition.Text;
        end;
   end;
end;

// Изменение количества Custom Field Functions.
procedure TFormCustomFieldFunction.cbbcountChange(Sender: TObject);
begin
   //
   Form1.inumCFF:=cbbcount.ItemIndex;
   case cbbcount.ItemIndex of
   0 : begin
          pnlcff.Visible:=False;
       end;
   1 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.ItemIndex:=0;
       end;
   2 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.ItemIndex:=0;
       end;
   3 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.ItemIndex:=0;
       end;
   4 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.ItemIndex:=0;
       end;
   5 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.ItemIndex:=0;
       end;
   6 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.AddItem('6',Sender);
          cbbindex.ItemIndex:=0;
       end;
   7 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.AddItem('6',Sender);
          cbbindex.AddItem('7',Sender);
          cbbindex.ItemIndex:=0;
       end;
    8 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.AddItem('6',Sender);
          cbbindex.AddItem('7',Sender);
          cbbindex.AddItem('8',Sender);
          cbbindex.ItemIndex:=0;
       end;
    9 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.AddItem('6',Sender);
          cbbindex.AddItem('7',Sender);
          cbbindex.AddItem('8',Sender);
          cbbindex.AddItem('9',Sender);
          cbbindex.ItemIndex:=0;
       end;
     10 : begin
          pnlcff.Visible:=True;
          cbbindex.Clear;
          cbbindex.AddItem('1',Sender);
          cbbindex.AddItem('2',Sender);
          cbbindex.AddItem('3',Sender);
          cbbindex.AddItem('4',Sender);
          cbbindex.AddItem('5',Sender);
          cbbindex.AddItem('6',Sender);
          cbbindex.AddItem('7',Sender);
          cbbindex.AddItem('8',Sender);
          cbbindex.AddItem('9',Sender);
          cbbindex.AddItem('10',Sender);
          cbbindex.ItemIndex:=0;
       end;
   end;
end;


end.
