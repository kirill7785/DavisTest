unit UnitSurfaceIntegrals;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  Unitdeclar;

 type

  TFormSurfaceIntegrals = class(TForm)
    grpreporttype: TGroupBox;
    cbbreptype: TComboBox;
    grpboundary: TGroupBox;
    cbbboundary: TComboBox;
    grpfieldvar: TGroupBox;
    cbbfieldvar: TComboBox;
    grpresult: TGroupBox;
    lblresult: TLabel;
    btncompute: TButton;
    procedure btncomputeClick(Sender: TObject);
  private
    { Private declarations }
    fex : T2myDynArray;
  public
    { Public declarations }

    // Вычисляет анализируемые величины.
    procedure getready();
  end;

var
  FormSurfaceIntegrals: TFormSurfaceIntegrals;

implementation

uses MainUnit, GridGenUnit;

{$R *.dfm}

// Вычисляет анализируемые величины.
procedure TFormSurfaceIntegrals.getready();
var
    inx, iny : Integer;
    i : Integer;
begin
   inx:=Form1.inx;
   iny:=Form1.iny;
   // Custom Field Functions
   SetLength(fex,10);
   for i:=0 to 9 do
   begin
      SetLength(fex[i],inx*iny+1);
   end;
   // Вычисляет всё необходимое.
   Form1.getreadycalc(fex);
end;

procedure TFormSurfaceIntegrals.btncomputeClick(Sender: TObject);
var
   k : Integer;
   sum : Float;
   rmin, rmax : Float;
   icount : Integer;
begin
   // Вычисление.
   // 1. определить тип отчёта, границу и field variable  для вычисления.
   // 2. произвести вычисление и напечатать результат.
   sum:=0.0;
   rmin:=1.0e+30;
   rmax:=-1.0e+30;
   icount:=0; // счётчик количества узлов.
   for k:=1 to Form1.imaxnumbernode do
   begin
      if (Form1.mapPT[k].itype=2) then
      begin
         if (Form1.mapPT[k].iboundary=GridGenForm.edgelist[cbbboundary.ItemIndex+1].idescriptor) then
         begin
            // данная граница выбрана в селекторе.
            case Form1.mapPT[k].chnormal of
               'E', 'W' : begin
                             if (cbbreptype.ItemIndex=0) then
                             begin
                                // Area.
                                sum:=sum+Form1.mapPT[k].dy;
                             end;
                             if (cbbreptype.ItemIndex=1) then
                             begin
                                sum:=sum+fex[cbbfieldvar.ItemIndex][k]*Form1.mapPT[k].dy;
                             end;
                             if (cbbreptype.ItemIndex=2) then
                             begin
                                Inc(icount);
                                sum:=sum+fex[cbbfieldvar.ItemIndex][k];
                             end;
                             if (cbbreptype.ItemIndex=3) then
                             begin
                                if (fex[cbbfieldvar.ItemIndex][k]<rmin) then
                                begin
                                   rmin:=fex[cbbfieldvar.ItemIndex][k];
                                end;
                             end;
                             if (cbbreptype.ItemIndex=4) then
                             begin
                                if (fex[cbbfieldvar.ItemIndex][k]>rmax) then
                                begin
                                   rmax:=fex[cbbfieldvar.ItemIndex][k];
                                end;
                             end;
                          end;
               'N', 'S' : begin
                              if (cbbreptype.ItemIndex=0) then
                             begin
                                // Area.
                                sum:=sum+Form1.mapPT[k].dx;
                             end;
                             if (cbbreptype.ItemIndex=1) then
                             begin
                                 sum:=sum+fex[cbbfieldvar.ItemIndex][k]*Form1.mapPT[k].dx;
                             end;
                              if (cbbreptype.ItemIndex=2) then
                             begin
                                 sum:=sum+fex[cbbfieldvar.ItemIndex][k];
                                 Inc(icount);
                             end;
                             if (cbbreptype.ItemIndex=3) then
                             begin
                                if (fex[cbbfieldvar.ItemIndex][k]<rmin) then
                                begin
                                   rmin:=fex[cbbfieldvar.ItemIndex][k];
                                end;
                             end;
                             if (cbbreptype.ItemIndex=4) then
                             begin
                                if (fex[cbbfieldvar.ItemIndex][k]>rmax) then
                                begin
                                   rmax:=fex[cbbfieldvar.ItemIndex][k];
                                end;
                             end;
                          end;
            end;
         end;
      end;
   end;
   if ((cbbreptype.ItemIndex=0) or (cbbreptype.ItemIndex=1)) then
   begin
      lblresult.Caption:=FloatToStr(sum);
   end;
   if (cbbreptype.ItemIndex=2) then
   begin
      // Vertex Average
      sum:=sum/icount;
      lblresult.Caption:=FloatToStr(sum);
   end;
   if (cbbreptype.ItemIndex=3) then
   begin
      // Минимальное значение.
      lblresult.Caption:=FloatToStr(rmin);
   end;
   if (cbbreptype.ItemIndex=4) then
   begin
      // Максимальное значение.
      lblresult.Caption:=FloatToStr(rmax);
   end;
end;

end.
