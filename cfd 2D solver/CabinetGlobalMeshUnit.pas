unit CabinetGlobalMeshUnit;
// задание глобльного количества узлов для разбиения кабинета сеткой.

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TCabinetGlobalMeshForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Einx: TEdit;
    Einy: TEdit;
    ButtonApply: TButton;
    procedure ButtonApplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CabinetGlobalMeshForm: TCabinetGlobalMeshForm;

implementation
uses
      MainUnit, GridGenUnit; // использует главный модуль.

{$R *.dfm}

// по событию нажатия на кнопку считывает количество точек
// (узлов сетки ) по горизонтали и вертикали
procedure TCabinetGlobalMeshForm.ButtonApplyClick(Sender: TObject);
var
   bOk : Boolean;
   r : Integer;
begin
   bOk:=True;
   if (not TryStrToInt(Einx.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Einx.Text+' is incorrect value.');
   end;
   if (not TryStrToInt(Einy.Text,r)) then
   begin
      bOk:=False;
      ShowMessage(Einy.Text+' is incorrect value.');
   end;
   if (bOk) then
   begin
      Form1.inx:=StrToInt(Einx.Text);
      Form1.iny:=StrToInt(Einy.Text);
      Close; // закрытие формы по завершении диалога.
   end;
end;

end.
