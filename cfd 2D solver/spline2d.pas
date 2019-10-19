(*************************************************************************
Copyright (c) 2007, Sergey Bochkanov (ALGLIB project).

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer listed
  in this license in the documentation and/or other materials
  provided with the distribution.

- Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*************************************************************************)
unit spline2d;
interface
uses Math, Ap, Sysutils, spline3;

procedure BuildBilinearSpline(X : TReal1DArray;
     Y : TReal1DArray;
     F : TReal2DArray;
     M : Integer;
     N : Integer;
     var C : TReal1DArray);
procedure BuildBicubicSpline(X : TReal1DArray;
     Y : TReal1DArray;
     F : TReal2DArray;
     M : Integer;
     N : Integer;
     var C : TReal1DArray);
function SplineInterpolation2D(const C : TReal1DArray;
     X : Double;
     Y : Double):Double;
procedure SplineDifferentiation2D(const C : TReal1DArray;
     X : Double;
     Y : Double;
     var F : Double;
     var FX : Double;
     var FY : Double;
     var FXY : Double);
procedure SplineUnpack2D(const C : TReal1DArray;
     var M : Integer;
     var N : Integer;
     var Tbl : TReal2DArray);
procedure Spline2DLinTransXY(var C : TReal1DArray;
     AX : Double;
     BX : Double;
     AY : Double;
     BY : Double);
procedure Spline2DLinTransF(var C : TReal1DArray; A : Double; B : Double);
procedure Spline2DCopy(const C : TReal1DArray; var CC : TReal1DArray);
procedure BicubicResampleCartesian(const A : TReal2DArray;
     OldHeight : Integer;
     OldWidth : Integer;
     var B : TReal2DArray;
     NewHeight : Integer;
     NewWidth : Integer);
procedure BilinearResampleCartesian(const A : TReal2DArray;
     OldHeight : Integer;
     OldWidth : Integer;
     var B : TReal2DArray;
     NewHeight : Integer;
     NewWidth : Integer);
procedure BicubicResample(OldWidth : Integer;
     OldHeight : Integer;
     NewWidth : Integer;
     NewHeight : Integer;
     const A : TReal2DArray;
     var B : TReal2DArray);
procedure BilinearResample(OldWidth : Integer;
     OldHeight : Integer;
     NewWidth : Integer;
     NewHeight : Integer;
     const A : TReal2DArray;
     var B : TReal2DArray);

implementation

procedure BicubicCalcDerivatives(const A : TReal2DArray;
     const X : TReal1DArray;
     const Y : TReal1DArray;
     M : Integer;
     N : Integer;
     var DX : TReal2DArray;
     var DY : TReal2DArray;
     var DXY : TReal2DArray);forward;


(*************************************************************************
���������� ����������� ���������������� �������

������� ���������:
    X   -   ������ ������� ������������� ����� �� ������� �������� ������.
            ��������� ���������: [0..N-1]
    Y   -   ������ ������� ������������� ����� �� ������� �������� ������.
            ��������� ���������: [0..M-1]
    F   -   ������� �������� ������� � ����� �����.
            ��������� ���������: [0..M-1, 0..N-1]
    M   -   ������ ����� �� ��� Y, M>=2
    N   -   ������ ����� �� ��� X, N>=2
    
�������� ���������:
    C   -   �������  �������������  ���   �������������   �   ������������
            SplineInterpolation2D.

  -- ALGLIB PROJECT --
     Copyright 05.07.2007 by Bochkanov Sergey
*************************************************************************)
procedure BuildBilinearSpline(X : TReal1DArray;
     Y : TReal1DArray;
     F : TReal2DArray;
     M : Integer;
     N : Integer;
     var C : TReal1DArray);
var
    I : Integer;
    J : Integer;
    K : Integer;
    TblSize : Integer;
    Shift : Integer;
    T : Double;

begin
    X := DynamicArrayCopy(X);
    Y := DynamicArrayCopy(Y);
    F := DynamicArrayCopy(F);
    Assert((N>=2) and (M>=2), 'BuildBilinearSpline: N<2 or M<2!');
    
    //
    // Sort points
    //
    J:=0;
    while J<=N-1 do
    begin
        K := J;
        I:=J+1;
        while I<=N-1 do
        begin
            if X[I]<X[K] then
            begin
                K := I;
            end;
            Inc(I);
        end;
        if K<>J then
        begin
            I:=0;
            while I<=M-1 do
            begin
                T := F[I,J];
                F[I,J] := F[I,K];
                F[I,K] := T;
                Inc(I);
            end;
            T := X[J];
            X[J] := X[K];
            X[K] := T;
        end;
        Inc(J);
    end;
    I:=0;
    while I<=M-1 do
    begin
        K := I;
        J:=I+1;
        while J<=M-1 do
        begin
            if Y[J]<Y[K] then
            begin
                K := J;
            end;
            Inc(J);
        end;
        if K<>I then
        begin
            J:=0;
            while J<=N-1 do
            begin
                T := F[I,J];
                F[I,J] := F[K,J];
                F[K,J] := T;
                Inc(J);
            end;
            T := Y[I];
            Y[I] := Y[K];
            Y[K] := T;
        end;
        Inc(I);
    end;
    
    //
    // Fill C:
    //  C[0]            -   length(C)
    //  C[1]            -   type(C):
    //                      -1 = bilinear interpolant
    //                      -3 = general cubic spline
    //                           (see BuildBicubicSpline)
    //  C[2]:
    //      N (x count)
    //  C[3]:
    //      M (y count)
    //  C[4]...C[4+N-1]:
    //      x[i], i = 0...N-1
    //  C[4+N]...C[4+N+M-1]:
    //      y[i], i = 0...M-1
    //  C[4+N+M]...C[4+N+M+(N*M-1)]:
    //      f(i,j) table. f(0,0), f(0, 1), f(0,2) and so on...
    //
    TblSize := 4+N+M+N*M;
    SetLength(C, TblSize-1+1);
    C[0] := TblSize;
    C[1] := -1;
    C[2] := N;
    C[3] := M;
    I:=0;
    while I<=N-1 do
    begin
        C[4+I] := X[I];
        Inc(I);
    end;
    I:=0;
    while I<=M-1 do
    begin
        C[4+N+I] := Y[I];
        Inc(I);
    end;
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            Shift := I*N+J;
            C[4+N+M+Shift] := F[I,J];
            Inc(J);
        end;
        Inc(I);
    end;
end;


(*************************************************************************
���������� ������������� ���������������� �������

������� ���������:
    X   -   ������ ������� ������������� ����� �� ������� �������� ������.
            ��������� ���������: [0..N-1]
    Y   -   ������ ������� ������������� ����� �� ������� �������� ������.
            ��������� ���������: [0..M-1]
    F   -   ������� �������� ������� � ����� �����.
            ��������� ���������: [0..M-1, 0..N-1]
    M   -   ������ ����� �� ��� Y
    N   -   ������ ����� �� ��� X

�������� ���������:
    C   -   �������  �������������  ���   �������������   �   ������������
            SplineInterpolation2D.

  -- ALGLIB PROJECT --
     Copyright 05.07.2007 by Bochkanov Sergey
*************************************************************************)
procedure BuildBicubicSpline(X : TReal1DArray;
     Y : TReal1DArray;
     F : TReal2DArray;
     M : Integer;
     N : Integer;
     var C : TReal1DArray);
var
    I : Integer;
    J : Integer;
    K : Integer;
    TblSize : Integer;
    Shift : Integer;
    T : Double;
    DX : TReal2DArray;
    DY : TReal2DArray;
    DXY : TReal2DArray;
begin
    X := DynamicArrayCopy(X);
    Y := DynamicArrayCopy(Y);
    F := DynamicArrayCopy(F);
    Assert((N>=2) and (M>=2), 'BuildBicubicSpline: N<2 or M<2!');
    
    //
    // Sort points
    //
    J:=0;
    while J<=N-1 do
    begin
        K := J;
        I:=J+1;
        while I<=N-1 do
        begin
            if X[I]<X[K] then
            begin
                K := I;
            end;
            Inc(I);
        end;
        if K<>J then
        begin
            I:=0;
            while I<=M-1 do
            begin
                T := F[I,J];
                F[I,J] := F[I,K];
                F[I,K] := T;
                Inc(I);
            end;
            T := X[J];
            X[J] := X[K];
            X[K] := T;
        end;
        Inc(J);
    end;
    I:=0;
    while I<=M-1 do
    begin
        K := I;
        J:=I+1;
        while J<=M-1 do
        begin
            if Y[J]<Y[K] then
            begin
                K := J;
            end;
            Inc(J);
        end;
        if K<>I then
        begin
            J:=0;
            while J<=N-1 do
            begin
                T := F[I,J];
                F[I,J] := F[K,J];
                F[K,J] := T;
                Inc(J);
            end;
            T := Y[I];
            Y[I] := Y[K];
            Y[K] := T;
        end;
        Inc(I);
    end;
    
    //
    // Fill C:
    //  C[0]            -   length(C)
    //  C[1]            -   type(C):
    //                      -1 = bilinear interpolant
    //                           (see BuildBilinearInterpolant)
    //                      -3 = general cubic spline
    //  C[2]:
    //      N (x count)
    //  C[3]:
    //      M (y count)
    //  C[4]...C[4+N-1]:
    //      x[i], i = 0...N-1
    //  C[4+N]...C[4+N+M-1]:
    //      y[i], i = 0...M-1
    //  C[4+N+M]...C[4+N+M+(N*M-1)]:
    //      f(i,j) table. f(0,0), f(0, 1), f(0,2) and so on...
    //  C[4+N+M+N*M]...C[4+N+M+(2*N*M-1)]:
    //      df(i,j)/dx table.
    //  C[4+N+M+2*N*M]...C[4+N+M+(3*N*M-1)]:
    //      df(i,j)/dy table.
    //  C[4+N+M+3*N*M]...C[4+N+M+(4*N*M-1)]:
    //      d2f(i,j)/dxdy table.
    //
    TblSize := 4+N+M+4*N*M;
    SetLength(C, TblSize-1+1);
    C[0] := TblSize;
    C[1] := -3;
    C[2] := N;
    C[3] := M;
    I:=0;
    while I<=N-1 do
    begin
        C[4+I] := X[I];
        Inc(I);
    end;
    I:=0;
    while I<=M-1 do
    begin
        C[4+N+I] := Y[I];
        Inc(I);
    end;
    BicubicCalcDerivatives(F, X, Y, M, N, DX, DY, DXY);
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            Shift := I*N+J;
            C[4+N+M+Shift] := F[I,J];
            C[4+N+M+N*M+Shift] := DX[I,J];
            C[4+N+M+2*N*M+Shift] := DY[I,J];
            C[4+N+M+3*N*M+Shift] := DXY[I,J];
            Inc(J);
        end;
        Inc(I);
    end;
end;


(*************************************************************************
������������ ���������� (���������� ��� ������������) ��������

������� ���������:
    C   -   ������� �������������, ������������  �������������  ����������
            �������.
    X, Y-   �����, � ������� ����������� �������� �������

���������:
    �������� ���������������� ������� � ����� (X,Y)

  -- ALGLIB PROJECT --
     Copyright 05.07.2007 by Bochkanov Sergey
*************************************************************************)
function SplineInterpolation2D(const C : TReal1DArray;
     X : Double;
     Y : Double):Double;
var
    V : Double;
    VX : Double;
    VY : Double;
    VXY : Double;
begin
    SplineDifferentiation2D(C, X, Y, V, VX, VY, VXY);
    Result := V;
end;


(*************************************************************************
������������ ���������� (���������� ��� ������������) ��������.
����� ������������� ���������� ��������� � ������������ �����������.

������� ���������:
    C   -   ������� �������������, ������������  �������������  ����������
            �������.
    X, Y-   �����, � ������� ����������� �������� �������

���������:
    F   -   �������� ���������������� �������
    FX  -   dF/dX
    FY  -   dF/dY
    FXY -   d2F/dXdY

  -- ALGLIB PROJECT --
     Copyright 05.07.2007 by Bochkanov Sergey
*************************************************************************)
procedure SplineDifferentiation2D(const C : TReal1DArray;
     X : Double;
     Y : Double;
     var F : Double;
     var FX : Double;
     var FY : Double;
     var FXY : Double);
var
    N : Integer;
    M : Integer;
    T : Double;
    DT : Double;
    U : Double;
    DU : Double;
    I : Integer;
    J : Integer;
    IX : Integer;
    IY : Integer;
    L : Integer;
    R : Integer;
    H : Integer;
    Shift1 : Integer;
    S1 : Integer;
    S2 : Integer;
    S3 : Integer;
    S4 : Integer;
    SF : Integer;
    SFX : Integer;
    SFY : Integer;
    SFXY : Integer;
    Y1 : Double;
    Y2 : Double;
    Y3 : Double;
    Y4 : Double;
    V : Double;
    T0 : Double;
    T1 : Double;
    T2 : Double;
    T3 : Double;
    U0 : Double;
    U1 : Double;
    U2 : Double;
    U3 : Double;
begin
    Assert((Round(C[1])=-1) or (Round(C[1])=-3), 'TwoDimensionalInterpolation: incorrect C!');
    N := Round(C[2]);
    M := Round(C[3]);
    
    //
    // Binary search in the [ x[0], ..., x[n-2] ] (x[n-1] is not included)
    //
    L := 4;
    R := 4+N-2+1;
    while L<>R-1 do
    begin
        H := (L+R) div 2;
        if C[H]>=X then
        begin
            R := H;
        end
        else
        begin
            L := H;
        end;
    end;
    T := (X-C[L])/(C[L+1]-C[L]);
    DT := 1.0/(C[L+1]-C[L]);
    IX := L-4;
    
    //
    // Binary search in the [ y[0], ..., y[m-2] ] (y[m-1] is not included)
    //
    L := 4+N;
    R := 4+N+(M-2)+1;
    while L<>R-1 do
    begin
        H := (L+R) div 2;
        if C[H]>=Y then
        begin
            R := H;
        end
        else
        begin
            L := H;
        end;
    end;
    U := (Y-C[L])/(C[L+1]-C[L]);
    DU := 1.0/(C[L+1]-C[L]);
    IY := L-(4+N);
    
    //
    // Prepare F, dF/dX, dF/dY, d2F/dXdY
    //
    F := 0;
    FX := 0;
    FY := 0;
    FXY := 0;
    
    //
    // Bilinear interpolation
    //
    if Round(C[1])=-1 then
    begin
        Shift1 := 4+N+M;
        Y1 := C[Shift1+N*IY+IX];
        Y2 := C[Shift1+N*IY+(IX+1)];
        Y3 := C[Shift1+N*(IY+1)+(IX+1)];
        Y4 := C[Shift1+N*(IY+1)+IX];
        F := (1-T)*(1-U)*Y1+T*(1-U)*Y2+T*U*Y3+(1-T)*U*Y4;
        FX := (-(1-U)*Y1+(1-U)*Y2+U*Y3-U*Y4)*DT;
        FY := (-(1-T)*Y1-T*Y2+T*Y3+(1-T)*Y4)*DU;
        FXY := (Y1-Y2+Y3-Y4)*DU*DT;
        Exit;
    end;
    
    //
    // Bicubic interpolation
    //
    if Round(C[1])=-3 then
    begin
        
        //
        // Prepare info
        //
        T0 := 1;
        T1 := T;
        T2 := Sqr(T);
        T3 := T*T2;
        U0 := 1;
        U1 := U;
        U2 := Sqr(U);
        U3 := U*U2;
        SF := 4+N+M;
        SFX := 4+N+M+N*M;
        SFY := 4+N+M+2*N*M;
        SFXY := 4+N+M+3*N*M;
        S1 := N*IY+IX;
        S2 := N*IY+(IX+1);
        S3 := N*(IY+1)+(IX+1);
        S4 := N*(IY+1)+IX;
        
        //
        // Calculate
        //
        V := +1*C[SF+S1];
        F := F+V*T0*U0;
        V := +1*C[SFY+S1]/DU;
        F := F+V*T0*U1;
        FY := FY+1*V*T0*U0*DU;
        V := -3*C[SF+S1]+3*C[SF+S4]-2*C[SFY+S1]/DU-1*C[SFY+S4]/DU;
        F := F+V*T0*U2;
        FY := FY+2*V*T0*U1*DU;
        V := +2*C[SF+S1]-2*C[SF+S4]+1*C[SFY+S1]/DU+1*C[SFY+S4]/DU;
        F := F+V*T0*U3;
        FY := FY+3*V*T0*U2*DU;
        V := +1*C[SFX+S1]/DT;
        F := F+V*T1*U0;
        FX := FX+1*V*T0*U0*DT;
        V := +1*C[SFXY+S1]/(DT*DU);
        F := F+V*T1*U1;
        FX := FX+1*V*T0*U1*DT;
        FY := FY+1*V*T1*U0*DU;
        FXY := FXY+1*V*T0*U0*DT*DU;
        V := -3*C[SFX+S1]/DT+3*C[SFX+S4]/DT-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S4]/(DT*DU);
        F := F+V*T1*U2;
        FX := FX+1*V*T0*U2*DT;
        FY := FY+2*V*T1*U1*DU;
        FXY := FXY+2*V*T0*U1*DT*DU;
        V := +2*C[SFX+S1]/DT-2*C[SFX+S4]/DT+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S4]/(DT*DU);
        F := F+V*T1*U3;
        FX := FX+1*V*T0*U3*DT;
        FY := FY+3*V*T1*U2*DU;
        FXY := FXY+3*V*T0*U2*DT*DU;
        V := -3*C[SF+S1]+3*C[SF+S2]-2*C[SFX+S1]/DT-1*C[SFX+S2]/DT;
        F := F+V*T2*U0;
        FX := FX+2*V*T1*U0*DT;
        V := -3*C[SFY+S1]/DU+3*C[SFY+S2]/DU-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S2]/(DT*DU);
        F := F+V*T2*U1;
        FX := FX+2*V*T1*U1*DT;
        FY := FY+1*V*T2*U0*DU;
        FXY := FXY+2*V*T1*U0*DT*DU;
        V := +9*C[SF+S1]-9*C[SF+S2]+9*C[SF+S3]-9*C[SF+S4]+6*C[SFX+S1]/DT+3*C[SFX+S2]/DT-3*C[SFX+S3]/DT-6*C[SFX+S4]/DT+6*C[SFY+S1]/DU-6*C[SFY+S2]/DU-3*C[SFY+S3]/DU+3*C[SFY+S4]/DU+4*C[SFXY+S1]/(DT*DU)+2*C[SFXY+S2]/(DT*DU)+1*C[SFXY+S3]/(DT*DU)+2*C[SFXY+S4]/(DT*DU);
        F := F+V*T2*U2;
        FX := FX+2*V*T1*U2*DT;
        FY := FY+2*V*T2*U1*DU;
        FXY := FXY+4*V*T1*U1*DT*DU;
        V := -6*C[SF+S1]+6*C[SF+S2]-6*C[SF+S3]+6*C[SF+S4]-4*C[SFX+S1]/DT-2*C[SFX+S2]/DT+2*C[SFX+S3]/DT+4*C[SFX+S4]/DT-3*C[SFY+S1]/DU+3*C[SFY+S2]/DU+3*C[SFY+S3]/DU-3*C[SFY+S4]/DU-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S2]/(DT*DU)-1*C[SFXY+S3]/(DT*DU)-2*C[SFXY+S4]/(DT*DU);
        F := F+V*T2*U3;
        FX := FX+2*V*T1*U3*DT;
        FY := FY+3*V*T2*U2*DU;
        FXY := FXY+6*V*T1*U2*DT*DU;
        V := +2*C[SF+S1]-2*C[SF+S2]+1*C[SFX+S1]/DT+1*C[SFX+S2]/DT;
        F := F+V*T3*U0;
        FX := FX+3*V*T2*U0*DT;
        V := +2*C[SFY+S1]/DU-2*C[SFY+S2]/DU+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S2]/(DT*DU);
        F := F+V*T3*U1;
        FX := FX+3*V*T2*U1*DT;
        FY := FY+1*V*T3*U0*DU;
        FXY := FXY+3*V*T2*U0*DT*DU;
        V := -6*C[SF+S1]+6*C[SF+S2]-6*C[SF+S3]+6*C[SF+S4]-3*C[SFX+S1]/DT-3*C[SFX+S2]/DT+3*C[SFX+S3]/DT+3*C[SFX+S4]/DT-4*C[SFY+S1]/DU+4*C[SFY+S2]/DU+2*C[SFY+S3]/DU-2*C[SFY+S4]/DU-2*C[SFXY+S1]/(DT*DU)-2*C[SFXY+S2]/(DT*DU)-1*C[SFXY+S3]/(DT*DU)-1*C[SFXY+S4]/(DT*DU);
        F := F+V*T3*U2;
        FX := FX+3*V*T2*U2*DT;
        FY := FY+2*V*T3*U1*DU;
        FXY := FXY+6*V*T2*U1*DT*DU;
        V := +4*C[SF+S1]-4*C[SF+S2]+4*C[SF+S3]-4*C[SF+S4]+2*C[SFX+S1]/DT+2*C[SFX+S2]/DT-2*C[SFX+S3]/DT-2*C[SFX+S4]/DT+2*C[SFY+S1]/DU-2*C[SFY+S2]/DU-2*C[SFY+S3]/DU+2*C[SFY+S4]/DU+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S2]/(DT*DU)+1*C[SFXY+S3]/(DT*DU)+1*C[SFXY+S4]/(DT*DU);
        F := F+V*T3*U3;
        FX := FX+3*V*T2*U3*DT;
        FY := FY+3*V*T3*U2*DU;
        FXY := FXY+9*V*T2*U2*DT*DU;
        Exit;
    end;
end;


(*************************************************************************
���������� �������

������� ���������:
    C   -   ������ �������������, ����������� ������������� ���
            ���������� ����������� ��� ������������� �������.

�������� ���������:
    M   -   ������ ����� �� ��� Y
    N   -   ������ ����� �� ��� X
    Tbl -   ������� ������������� �������. ������ �  ����������  ���������
            [0..(N-1)*(M-1)-1, 0..19]. ������ ������ ������� �������������
            ����� ������ �����. ����� ��������� ������� ����� ������� (�.�.
            � ������� ����������� X), ����� ����� �����  (�.�.  �  �������
            ����������� Y).
            ������ �������:
            For I = 0...M-2, J=0..N-2:
                K =  I*(N-1)+J
                Tbl[K,0] = X[j]
                Tbl[K,1] = X[j+1]
                Tbl[K,2] = Y[i]
                Tbl[K,3] = Y[i+1]
                Tbl[K,4] = C00
                Tbl[K,5] = C01
                Tbl[K,6] = C02
                Tbl[K,7] = C03
                Tbl[K,8] = C10
                Tbl[K,9] = C11
                ...
                Tbl[K,19] = C33
            �� ������ �� ����� ����� ������ ����� ���:
                t = x-x[j]
                u = y-y[i]
                S(x) = SUM(c[i,j]*(x^i)*(y^j), i=0..3, j=0..3)

  -- ALGLIB PROJECT --
     Copyright 29.06.2007 by Bochkanov Sergey
*************************************************************************)
procedure SplineUnpack2D(const C : TReal1DArray;
     var M : Integer;
     var N : Integer;
     var Tbl : TReal2DArray);
var
    I : Integer;
    J : Integer;
    CI : Integer;
    CJ : Integer;
    K : Integer;
    P : Integer;
    Shift : Integer;
    S1 : Integer;
    S2 : Integer;
    S3 : Integer;
    S4 : Integer;
    SF : Integer;
    SFX : Integer;
    SFY : Integer;
    SFXY : Integer;
    Y1 : Double;
    Y2 : Double;
    Y3 : Double;
    Y4 : Double;
    DT : Double;
    DU : Double;
begin
    Assert((Round(C[1])=-3) or (Round(C[1])=-1), 'SplineUnpack2D: incorrect C!');
    N := Round(C[2]);
    M := Round(C[3]);
    SetLength(Tbl, (N-1)*(M-1)-1+1, 19+1);
    
    //
    // Fill
    //
    I:=0;
    while I<=M-2 do
    begin
        J:=0;
        while J<=N-2 do
        begin
            P := I*(N-1)+J;
            Tbl[P,0] := C[4+J];
            Tbl[P,1] := C[4+J+1];
            Tbl[P,2] := C[4+N+I];
            Tbl[P,3] := C[4+N+I+1];
            DT := 1/(Tbl[P,1]-Tbl[P,0]);
            DU := 1/(Tbl[P,3]-Tbl[P,2]);
            
            //
            // Bilinear interpolation
            //
            if Round(C[1])=-1 then
            begin
                K:=4;
                while K<=19 do
                begin
                    Tbl[P,K] := 0;
                    Inc(K);
                end;
                Shift := 4+N+M;
                Y1 := C[Shift+N*I+J];
                Y2 := C[Shift+N*I+(J+1)];
                Y3 := C[Shift+N*(I+1)+(J+1)];
                Y4 := C[Shift+N*(I+1)+J];
                Tbl[P,4] := Y1;
                Tbl[P,4+1*4+0] := Y2-Y1;
                Tbl[P,4+0*4+1] := Y4-Y1;
                Tbl[P,4+1*4+1] := Y3-Y2-Y4+Y1;
            end;
            
            //
            // Bicubic interpolation
            //
            if Round(C[1])=-3 then
            begin
                SF := 4+N+M;
                SFX := 4+N+M+N*M;
                SFY := 4+N+M+2*N*M;
                SFXY := 4+N+M+3*N*M;
                S1 := N*I+J;
                S2 := N*I+(J+1);
                S3 := N*(I+1)+(J+1);
                S4 := N*(I+1)+J;
                Tbl[P,4+0*4+0] := +1*C[SF+S1];
                Tbl[P,4+0*4+1] := +1*C[SFY+S1]/DU;
                Tbl[P,4+0*4+2] := -3*C[SF+S1]+3*C[SF+S4]-2*C[SFY+S1]/DU-1*C[SFY+S4]/DU;
                Tbl[P,4+0*4+3] := +2*C[SF+S1]-2*C[SF+S4]+1*C[SFY+S1]/DU+1*C[SFY+S4]/DU;
                Tbl[P,4+1*4+0] := +1*C[SFX+S1]/DT;
                Tbl[P,4+1*4+1] := +1*C[SFXY+S1]/(DT*DU);
                Tbl[P,4+1*4+2] := -3*C[SFX+S1]/DT+3*C[SFX+S4]/DT-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S4]/(DT*DU);
                Tbl[P,4+1*4+3] := +2*C[SFX+S1]/DT-2*C[SFX+S4]/DT+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S4]/(DT*DU);
                Tbl[P,4+2*4+0] := -3*C[SF+S1]+3*C[SF+S2]-2*C[SFX+S1]/DT-1*C[SFX+S2]/DT;
                Tbl[P,4+2*4+1] := -3*C[SFY+S1]/DU+3*C[SFY+S2]/DU-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S2]/(DT*DU);
                Tbl[P,4+2*4+2] := +9*C[SF+S1]-9*C[SF+S2]+9*C[SF+S3]-9*C[SF+S4]+6*C[SFX+S1]/DT+3*C[SFX+S2]/DT-3*C[SFX+S3]/DT-6*C[SFX+S4]/DT+6*C[SFY+S1]/DU-6*C[SFY+S2]/DU-3*C[SFY+S3]/DU+3*C[SFY+S4]/DU+4*C[SFXY+S1]/(DT*DU)+2*C[SFXY+S2]/(DT*DU)+1*C[SFXY+S3]/(DT*DU)+2*C[SFXY+S4]/(DT*DU);
                Tbl[P,4+2*4+3] := -6*C[SF+S1]+6*C[SF+S2]-6*C[SF+S3]+6*C[SF+S4]-4*C[SFX+S1]/DT-2*C[SFX+S2]/DT+2*C[SFX+S3]/DT+4*C[SFX+S4]/DT-3*C[SFY+S1]/DU+3*C[SFY+S2]/DU+3*C[SFY+S3]/DU-3*C[SFY+S4]/DU-2*C[SFXY+S1]/(DT*DU)-1*C[SFXY+S2]/(DT*DU)-1*C[SFXY+S3]/(DT*DU)-2*C[SFXY+S4]/(DT*DU);
                Tbl[P,4+3*4+0] := +2*C[SF+S1]-2*C[SF+S2]+1*C[SFX+S1]/DT+1*C[SFX+S2]/DT;
                Tbl[P,4+3*4+1] := +2*C[SFY+S1]/DU-2*C[SFY+S2]/DU+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S2]/(DT*DU);
                Tbl[P,4+3*4+2] := -6*C[SF+S1]+6*C[SF+S2]-6*C[SF+S3]+6*C[SF+S4]-3*C[SFX+S1]/DT-3*C[SFX+S2]/DT+3*C[SFX+S3]/DT+3*C[SFX+S4]/DT-4*C[SFY+S1]/DU+4*C[SFY+S2]/DU+2*C[SFY+S3]/DU-2*C[SFY+S4]/DU-2*C[SFXY+S1]/(DT*DU)-2*C[SFXY+S2]/(DT*DU)-1*C[SFXY+S3]/(DT*DU)-1*C[SFXY+S4]/(DT*DU);
                Tbl[P,4+3*4+3] := +4*C[SF+S1]-4*C[SF+S2]+4*C[SF+S3]-4*C[SF+S4]+2*C[SFX+S1]/DT+2*C[SFX+S2]/DT-2*C[SFX+S3]/DT-2*C[SFX+S4]/DT+2*C[SFY+S1]/DU-2*C[SFY+S2]/DU-2*C[SFY+S3]/DU+2*C[SFY+S4]/DU+1*C[SFXY+S1]/(DT*DU)+1*C[SFXY+S2]/(DT*DU)+1*C[SFXY+S3]/(DT*DU)+1*C[SFXY+S4]/(DT*DU);
            end;
            
            //
            // Rescale Cij
            //
            CI:=0;
            while CI<=3 do
            begin
                CJ:=0;
                while CJ<=3 do
                begin
                    Tbl[P,4+CI*4+CJ] := Tbl[P,4+CI*4+CJ]*Power(DT, CI)*Power(DU, CJ);
                    Inc(CJ);
                end;
                Inc(CI);
            end;
            Inc(J);
        end;
        Inc(I);
    end;
end;


(*************************************************************************
�������� ������ ��������� ����������� �������

������� ���������:
    C       -   ������ �������������, ����������� ������������� ���
                ���������� ������� S(x).
    AX, BX  -   ������������ �������������� x = A*t + B
    AY, BY  -   ������������ �������������� y = A*u + B

�������� ���������:
    C   -   ��������������� ������

  -- ALGLIB PROJECT --
     Copyright 30.06.2007 by Bochkanov Sergey
*************************************************************************)
procedure Spline2DLinTransXY(var C : TReal1DArray;
     AX : Double;
     BX : Double;
     AY : Double;
     BY : Double);
var
    I : Integer;
    J : Integer;
    N : Integer;
    M : Integer;
    V : Double;
    X : TReal1DArray;
    Y : TReal1DArray;
    F : TReal2DArray;
    TypeC : Integer;
begin
    TypeC := Round(C[1]);
    Assert((TypeC=-3) or (TypeC=-1), 'Spline2DLinTransXY: incorrect C!');
    N := Round(C[2]);
    M := Round(C[3]);
    SetLength(X, N-1+1);
    SetLength(Y, M-1+1);
    SetLength(F, M-1+1, N-1+1);
    J:=0;
    while J<=N-1 do
    begin
        X[J] := C[4+J];
        Inc(J);
    end;
    I:=0;
    while I<=M-1 do
    begin
        Y[I] := C[4+N+I];
        Inc(I);
    end;
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            F[I,J] := C[4+N+M+I*N+J];
            Inc(J);
        end;
        Inc(I);
    end;
    
    //
    // Special case: AX=0 or AY=0
    //
    if AX=0 then
    begin
        I:=0;
        while I<=M-1 do
        begin
            V := SplineInterpolation2D(C, BX, Y[I]);
            J:=0;
            while J<=N-1 do
            begin
                F[I,J] := V;
                Inc(J);
            end;
            Inc(I);
        end;
        if TypeC=-3 then
        begin
            BuildBicubicSpline(X, Y, F, M, N, C);
        end;
        if TypeC=-1 then
        begin
            BuildBilinearSpline(X, Y, F, M, N, C);
        end;
        AX := 1;
        BX := 0;
    end;
    if AY=0 then
    begin
        J:=0;
        while J<=N-1 do
        begin
            V := SplineInterpolation2D(C, X[J], BY);
            I:=0;
            while I<=M-1 do
            begin
                F[I,J] := V;
                Inc(I);
            end;
            Inc(J);
        end;
        if TypeC=-3 then
        begin
            BuildBicubicSpline(X, Y, F, M, N, C);
        end;
        if TypeC=-1 then
        begin
            BuildBilinearSpline(X, Y, F, M, N, C);
        end;
        AY := 1;
        BY := 0;
    end;
    
    //
    // General case: AX<>0, AY<>0
    // Unpack, scale and pack again.
    //
    J:=0;
    while J<=N-1 do
    begin
        X[J] := (X[J]-BX)/AX;
        Inc(J);
    end;
    I:=0;
    while I<=M-1 do
    begin
        Y[I] := (Y[I]-BY)/AY;
        Inc(I);
    end;
    if TypeC=-3 then
    begin
        BuildBicubicSpline(X, Y, F, M, N, C);
    end;
    if TypeC=-1 then
    begin
        BuildBilinearSpline(X, Y, F, M, N, C);
    end;
end;


(*************************************************************************
�������� �������������� ����������� �������

������� ���������:
    C       -   ������ �������������, ����������� ������������� ���
                ���������� ������� S(x).
    A, B    -   ������������ �������������� S2(x,y) = A*S(x,y) + B

�������� ���������:
    C   -   ��������������� ������

  -- ALGLIB PROJECT --
     Copyright 30.06.2007 by Bochkanov Sergey
*************************************************************************)
procedure Spline2DLinTransF(var C : TReal1DArray; A : Double; B : Double);
var
    I : Integer;
    J : Integer;
    N : Integer;
    M : Integer;
    X : TReal1DArray;
    Y : TReal1DArray;
    F : TReal2DArray;
    TypeC : Integer;
begin
    TypeC := Round(C[1]);
    Assert((TypeC=-3) or (TypeC=-1), 'Spline2DLinTransXY: incorrect C!');
    N := Round(C[2]);
    M := Round(C[3]);
    SetLength(X, N-1+1);
    SetLength(Y, M-1+1);
    SetLength(F, M-1+1, N-1+1);
    J:=0;
    while J<=N-1 do
    begin
        X[J] := C[4+J];
        Inc(J);
    end;
    I:=0;
    while I<=M-1 do
    begin
        Y[I] := C[4+N+I];
        Inc(I);
    end;
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            F[I,J] := A*C[4+N+M+I*N+J]+B;
            Inc(J);
        end;
        Inc(I);
    end;
    if TypeC=-3 then
    begin
        BuildBicubicSpline(X, Y, F, M, N, C);
    end;
    if TypeC=-1 then
    begin
        BuildBilinearSpline(X, Y, F, M, N, C);
    end;
end;


(*************************************************************************
����������� ����������� �������.

������� ���������:
    C   -   ������ �������������, ����������� ������������� ���
            ���������� �������.

�������� ���������:
    CC  -   ����� �������

  -- ALGLIB PROJECT --
     Copyright 29.06.2007 by Bochkanov Sergey
*************************************************************************)
procedure Spline2DCopy(const C : TReal1DArray; var CC : TReal1DArray);
begin
    SplineCopy(C, CC);
end;


(*************************************************************************
��������������� ������������ ��������.

    ��������� �������� ��������  �������  ��  �����  OldWidth*OldHeight  �
����� ������������ ������������  ��������  ���������  ��������  �������  �
����� ���������� ����� �������� NewWidth*NewHeight. ����� ����� ����� ����
��� �����, ��� � ����� �������, ��� ������.

������� ���������:
    A           - ������ �������� ������� �� ������ �����.
                  ��������� ��������� [0..OldHeight-1,
                  0..OldWidth-1]
    OldHeight   - ������ ������ �����, OldHeight>1
    OldWidth    - ������ ������ �����, OldWidth>1
    NewHeight   - ����� ������ �����, NewHeight>1
    NewWidth    - ����� ������ �����, NewWidth>1

�������� ���������:
    B           - ������ �������� ������� �� ����� �����.
                  ��������� ��������� [0..NewHeight-1,
                  0..NewWidth-1]

  -- ALGLIB routine --
     15 May, 2007
     Copyright by Bochkanov Sergey
*************************************************************************)
procedure BicubicResampleCartesian(const A : TReal2DArray;
     OldHeight : Integer;
     OldWidth : Integer;
     var B : TReal2DArray;
     NewHeight : Integer;
     NewWidth : Integer);
var
    Buf : TReal2DArray;
    X : TReal1DArray;
    Y : TReal1DArray;
    C : TReal1DArray;
    I : Integer;
    J : Integer;
    MW : Integer;
    MH : Integer;
begin
    Assert((OldWidth>1) and (OldHeight>1), 'BicubicResampleCartesian: width/height less than 1');
    Assert((NewWidth>1) and (NewHeight>1), 'BicubicResampleCartesian: width/height less than 1');
    
    //
    // Prepare
    //
    MW := Max(OldWidth, NewWidth);
    MH := Max(OldHeight, NewHeight);
    SetLength(B, NewHeight-1+1, NewWidth-1+1);
    SetLength(Buf, OldHeight-1+1, NewWidth-1+1);
    SetLength(X, Max(MW, MH)-1+1);
    SetLength(Y, Max(MW, MH)-1+1);
    
    //
    // Horizontal interpolation
    //
    I:=0;
    while I<=OldHeight-1 do
    begin
        
        //
        // Fill X, Y
        //
        J:=0;
        while J<=OldWidth-1 do
        begin
            X[J] := J/(OldWidth-1);
            Y[J] := A[I,J];
            Inc(J);
        end;
        
        //
        // Interpolate and place result into temporary matrix
        //
        BuildCubicSpline(X, Y, OldWidth, 0, 0.0, 0, 0.0, C);
        J:=0;
        while J<=NewWidth-1 do
        begin
            Buf[I,J] := SplineInterpolation(C, J/(NewWidth-1));
            Inc(J);
        end;
        Inc(I);
    end;
    
    //
    // Vertical interpolation
    //
    J:=0;
    while J<=NewWidth-1 do
    begin
        
        //
        // Fill X, Y
        //
        I:=0;
        while I<=OldHeight-1 do
        begin
            X[I] := I/(OldHeight-1);
            Y[I] := Buf[I,J];
            Inc(I);
        end;
        
        //
        // Interpolate and place result into B
        //
        BuildCubicSpline(X, Y, OldHeight, 0, 0.0, 0, 0.0, C);
        I:=0;
        while I<=NewHeight-1 do
        begin
            B[I,J] := SplineInterpolation(C, I/(NewHeight-1));
            Inc(I);
        end;
        Inc(J);
    end;
end;


(*************************************************************************
��������������� ���������� ��������.

    ��������� �������� ��������  �������  ��  �����  OldWidth*OldHeight  �
����� ������������ ����������  ��������  ���������  ��������   �������   �
����� ���������� ����� �������� NewWidth*NewHeight. ����� ����� ����� ����
��� �����, ��� � ����� �������, ��� ������.

������� ���������:
    A           - ������ �������� ������� �� ������ �����.
                  ��������� ��������� [0..OldHeight-1,
                  0..OldWidth-1]
    OldHeight   - ������ ������ �����, OldHeight>1
    OldWidth    - ������ ������ �����, OldWidth>1
    NewHeight   - ����� ������ �����, NewHeight>1
    NewWidth    - ����� ������ �����, NewWidth>1

�������� ���������:
    B           - ������ �������� ������� �� ����� �����.
                  ��������� ��������� [0..NewHeight-1,
                  0..NewWidth-1]

  -- ALGLIB routine --
     09.07.2007
     Copyright by Bochkanov Sergey
*************************************************************************)
procedure BilinearResampleCartesian(const A : TReal2DArray;
     OldHeight : Integer;
     OldWidth : Integer;
     var B : TReal2DArray;
     NewHeight : Integer;
     NewWidth : Integer);
var
    I : Integer;
    J : Integer;
    L : Integer;
    C : Integer;
    T : Double;
    U : Double;
begin
    SetLength(B, NewHeight-1+1, NewWidth-1+1);
    I:=0;
    while I<=NewHeight-1 do
    begin
        J:=0;
        while J<=NewWidth-1 do
        begin
            L := I*(OldHeight-1) div (NewHeight-1);
            if L=OldHeight-1 then
            begin
                L := OldHeight-2;
            end;
            U := I/(NewHeight-1)*(OldHeight-1)-L;
            C := J*(OldWidth-1) div (NewWidth-1);
            if C=OldWidth-1 then
            begin
                C := OldWidth-2;
            end;
            T := J*(OldWidth-1)/(NewWidth-1)-C;
            B[I,J] := (1-T)*(1-U)*A[L,C]+T*(1-U)*A[L,C+1]+T*U*A[L+1,C+1]+(1-T)*U*A[L+1,C];
            Inc(J);
        end;
        Inc(I);
    end;
end;


(*************************************************************************
Obsolete subroutine for backwards compatibility
*************************************************************************)
procedure BicubicResample(OldWidth : Integer;
     OldHeight : Integer;
     NewWidth : Integer;
     NewHeight : Integer;
     const A : TReal2DArray;
     var B : TReal2DArray);
begin
    BicubicResampleCartesian(A, OldHeight, OldWidth, B, NewHeight, NewWidth);
end;


(*************************************************************************
Obsolete subroutine for backwards compatibility
*************************************************************************)
procedure BilinearResample(OldWidth : Integer;
     OldHeight : Integer;
     NewWidth : Integer;
     NewHeight : Integer;
     const A : TReal2DArray;
     var B : TReal2DArray);
begin
    BilinearResampleCartesian(A, OldHeight, OldWidth, B, NewHeight, NewWidth);
end;


(*************************************************************************
Internal subroutine.
Calculation of the first derivatives and the cross-derivative.
*************************************************************************)
procedure BicubicCalcDerivatives(const A : TReal2DArray;
     const X : TReal1DArray;
     const Y : TReal1DArray;
     M : Integer;
     N : Integer;
     var DX : TReal2DArray;
     var DY : TReal2DArray;
     var DXY : TReal2DArray);
var
    I : Integer;
    J : Integer;
    XT : TReal1DArray;
    FT : TReal1DArray;
    C : TReal1DArray;
    S : Double;
    DS : Double;
    D2S : Double;
    
begin
    SetLength(DX, M-1+1, N-1+1);
    SetLength(DY, M-1+1, N-1+1);
    SetLength(DXY, M-1+1, N-1+1);
    
    //
    // dF/dX
    //
    SetLength(XT, N-1+1);
    SetLength(FT, N-1+1);
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            XT[J] := X[J];
            FT[J] := A[I,J];
            Inc(J);
        end;
        BuildCubicSpline(XT, FT, N, 0, 0.0, 0, 0.0, C);
        J:=0;
        while J<=N-1 do
        begin
            SplineDifferentiation(C, X[J], S, DS, D2S);
            DX[I,J] := DS;
            Inc(J);
        end;
        Inc(I);
    end;
    
    //
    // dF/dY
    //
    SetLength(XT, M-1+1);
    SetLength(FT, M-1+1);
    J:=0;
    while J<=N-1 do
    begin
        I:=0;
        while I<=M-1 do
        begin
            XT[I] := Y[I];
            FT[I] := A[I,J];
            Inc(I);
        end;
        BuildCubicSpline(XT, FT, M, 0, 0.0, 0, 0.0, C);
        I:=0;
        while I<=M-1 do
        begin
            SplineDifferentiation(C, Y[I], S, DS, D2S);
            DY[I,J] := DS;
            Inc(I);
        end;
        Inc(J);
    end;
    
    //
    // d2F/dXdY
    //
    SetLength(XT, N-1+1);
    SetLength(FT, N-1+1);
    I:=0;
    while I<=M-1 do
    begin
        J:=0;
        while J<=N-1 do
        begin
            XT[J] := X[J];
            FT[J] := DY[I,J];
            Inc(J);
        end;
        BuildCubicSpline(XT, FT, N, 0, 0.0, 0, 0.0, C);
        J:=0;
        while J<=N-1 do
        begin
            SplineDifferentiation(C, X[J], S, DS, D2S);
            DXY[I,J] := DS;
            Inc(J);
        end;
        Inc(I);
    end;
end;


end.

