unit UnitEasyCabinet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  Float = Real;
  //Float = Extended;

  // опорные точки формирующие границу.
  TmyEasyPoint = record
     x , y , size : Float;
     marker : Integer;
  end;

  TFormCabinetEasy = class(TForm)
    lbl1: TLabel;
    cbb1: TComboBox;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    number_of_points : Integer;
    my_easy_points : array of TmyEasyPoint;
  end;

var
  FormCabinetEasy: TFormCabinetEasy;

implementation

{$R *.dfm}

procedure TFormCabinetEasy.FormCreate(Sender: TObject);
begin
   number_of_points:=3;
   SetLength(my_easy_points,number_of_points);
   my_easy_points[0].x:=0.0;
   my_easy_points[0].y:=0.0;
   my_easy_points[0].size:=0.1;
   my_easy_points[0].marker:=1;
   my_easy_points[1].x:=1.0;
   my_easy_points[1].y:=0.0;
   my_easy_points[1].size:=0.1;
   my_easy_points[1].marker:=1;
   my_easy_points[2].x:=0.0;
   my_easy_points[2].y:=1.0;
   my_easy_points[2].size:=0.1;
   my_easy_points[2].marker:=1;
end;

end.
