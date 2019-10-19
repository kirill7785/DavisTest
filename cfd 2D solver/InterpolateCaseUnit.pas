unit InterpolateCaseUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TInterpolateCaseForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InterpolateCaseForm: TInterpolateCaseForm;

implementation

{$R *.dfm}

// в этом методе нет кода
// здесь есть компонент RadioGroup
// и у него есть свойство ItemIndex.
// Значение поля этого свойства используется
// в главном модуле MainUnit
// а здесь его можно менять.

end.
