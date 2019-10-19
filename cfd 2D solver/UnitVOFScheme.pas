unit UnitVOFScheme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormVolumeFractPar = class(TForm)
    rgscheme: TRadioGroup;
    grpantD: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    cbbeveryts: TComboBox;
    lbl3: TLabel;
    lbl4: TLabel;
    GroupBoxCourant: TGroupBox;
    EditCourant: TEdit;
    ButtonApply: TButton;
    ButtonClose: TButton;
    CBCSF: TCheckBox;
    Panel1: TPanel;
    CBWallAdhesion: TCheckBox;
    Label1: TLabel;
    Esigma: TEdit;
    procedure rgschemeClick(Sender: TObject);
    procedure cbbeverytsChange(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure CBCSFClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormVolumeFractPar: TFormVolumeFractPar;

implementation

uses MainUnit;

{$R *.dfm}
 

procedure TFormVolumeFractPar.rgschemeClick(Sender: TObject);
begin
   if (rgscheme.ItemIndex=0) then
   begin
      Form1.bVOFExplicit:=True;
      Form1.iterSimple.iterVof:=1; // для функции цвета. Явный метод !!!
      GroupBoxCourant.Visible:=True;
      ButtonApply.Visible:=True;
   end
   else
   begin
      Form1.bVOFExplicit:=False;
      Form1.iterSimple.iterVof:=10; // Неявный метод
      GroupBoxCourant.Visible:=False;
      ButtonApply.Visible:=True;
   end;
end;

procedure TFormVolumeFractPar.cbbeverytsChange(Sender: TObject);
begin
   if (cbbeveryts.ItemIndex<12) then
   begin
      Form1.iantidiffusionBuragoevery:= StrToInt(cbbeveryts.Items[cbbeveryts.ItemIndex]);
   end
   else
   begin
      // OFF
      Form1.iantidiffusionBuragoevery:=High(Integer); // Никогда не делаем антидиффузионную корекцию.
   end;
end;

// закрытие данной формы.
procedure TFormVolumeFractPar.ButtonCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TFormVolumeFractPar.ButtonApplyClick(Sender: TObject);
begin
    if (Form1.bVOFExplicit) then
    begin
       // считываем число Куранта !!!
       Form1.CourantNumber:=StrToFloat(EditCourant.Text);
    end;
    Form1.bCSF:=CBCSF.Checked;
    if (CBCSF.Checked) then
    begin
       // только в случае если активна сила поверхностного натяжения !!1
       Form1.bWallAdhesion:=CBWallAdhesion.Checked;
       Form1.rsigma:=StrToFloat(Esigma.Text);
    end;
end;

// настройка силы поверхностного натяжения с учётом углов смачивания.
procedure TFormVolumeFractPar.CBCSFClick(Sender: TObject);
begin
   if (CBCSF.Checked) then
   begin
       Esigma.Text:=FloatToStr(Form1.rsigma);
       if (Form1.bWallAdhesion) then
       begin
          CBWallAdhesion.Checked:=true;
       end
       else
       begin
          CBWallAdhesion.Checked:=false;
       end;
       Panel1.Visible:=true;
   end
   else
   begin
      Panel1.Visible:=false;
   end;
end;

end.
