unit GravityUnit;
// позволяет задать силу тяжести
// через удобное меню

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TGravityForm = class(TForm)
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    Egx: TEdit;
    Lgx: TLabel;
    Label1: TLabel;
    Egy: TEdit;
    Bapply: TButton;
    CheckBoxGravityVibrations: TCheckBox;
    Panel2: TPanel;
    GroupBoxParam: TGroupBox;
    LabelAmplityde: TLabel;
    LabelFrequency: TLabel;
    EAmplityde: TEdit;
    EFrequency: TEdit;
    RadioGroupDirect: TRadioGroup;
    procedure BapplyClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBoxGravityVibrationsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GravityForm: TGravityForm;

implementation
uses
      MainUnit; // использует главный модуль
{$R *.dfm}

// установка новых значений для
// ускорения свободного падения
procedure TGravityForm.BapplyClick(Sender: TObject);
var
    bOk : Boolean;
    r : Double;
begin
   bOk:=True;
   if (CheckBox1.Checked) then
   begin
      if (not TryStrToFloat(Egx.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(Egx.Text+' is incorrec value.');
      end;
      if (not TryStrToFloat(Egy.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(Egy.Text+' is incorrec value.');
      end;
   end;
   if (CheckBoxGravityVibrations.Checked) then
   begin
      if (not TryStrToFloat(EAmplityde.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(EAmplityde.Text+' amplitude is incorrec value.');
      end;
      if (not TryStrToFloat(EFrequency.Text,r)) then
      begin
         bOk:=False;
         ShowMessage(EFrequency.Text+' frequency is incorrec value.');
      end;
   end;
   if (bOk) then
   begin
     if (CheckBox1.Checked) then
     begin
        // задание ускорения свободного падения
        Form1.dgx:=StrToFloat(Egx.Text);
        Form1.dgy:=StrToFloat(Egy.Text);
     end;
     if (CheckBoxGravityVibrations.Checked) then
     begin
        // задание параметров для вибрации
        case RadioGroupDirect.ItemIndex of
          0 : // горизонтальные
              begin
                 Form1.rgravVib.chDirect:='x';
              end;
          1 : // вертикальные
              begin
                Form1.rgravVib.chDirect:='y';
              end;
        end; // case
        Form1.rgravVib.Amplitude:=StrToFloat(EAmplityde.Text); // амплитуда вибраций
        Form1.rgravVib.Frequency:=StrToFloat(EFrequency.Text); // частота вибраций
     end;
   end;
end;

// вызывается при установке или
// снятии флажка
procedure TGravityForm.CheckBox1Click(Sender: TObject);
begin
   // снятие или установка флажка
   if (CheckBox1.Checked) then
   begin
      // учитывать силу тяжести
      Egx.Text:='0'; // необходимая инициализация
      Egy.Text:='0'; // инициализация
      GroupBox1.Visible:=true;
   end
   else
   begin
      // не учитывать силу тяжести
      Form1.dgx:=0.0; // Обнуление значений, т.к. сила тяжести выключена
      Form1.dgy:=0.0; // сила тяжести выключена.
      GroupBox1.Visible:=false;
   end;
end; // снятие или установка флажка

// Вызывается при установке или снятии флажка
// и относится к вибрациям вызванным силой тяжести меняющейся
// по гармоническому закону времени.
procedure TGravityForm.CheckBoxGravityVibrationsClick(Sender: TObject);
begin
   if (CheckBoxGravityVibrations.Checked) then
   begin
      if (not(Form1.btimedepend)) then
      begin
         // предложить включить нестационарный солвер
         // и предупредить что в противном случая измения не вступят в силу.
         Application.MessageBox('Обязательно включите нестационарный солвер иначе никакого эффекта не будет.','',MB_OK);
      end;
      Form1.rgravVib.bOn:=true; // вибрации включены
      EAmplityde.Text:=FloatToStr(Form1.rgravVib.Amplitude);  // значение амплитуды
      EFrequency.Text:=FloatToStr(Form1.rgravVib.Frequency);  // значение частоты
      case Form1.rgravVib.chDirect of
        'x' : // горизонтальные вибрации
             begin
                RadioGroupDirect.ItemIndex:=0;
             end;
        'y' : // вертикальные вибрации
             begin
                RadioGroupDirect.ItemIndex:=1;
             end;
      end;
      Panel2.Visible:=true;
   end
    else
   begin
      Form1.rgravVib.bOn:=false; // вибрации выключены
      Panel2.Visible:=false;
   end;
end;

end.
