unit UnitOpenGL;
(* Изображение полевых величин на основе библиотеки OpenGL.
*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dglOpenGL, DGLUT, StdCtrls, jpeg, ExtCtrls;

type
  TOpenGLUnit = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    
  private
    { Private declarations }
    procedure SetupGL; // процедура инициализации.
    procedure Render; // процедура прорисовки.
  public
    { Public declarations }
    drawing : Boolean;
    ix0, iy0 : Integer;

    procedure ColorToGL(c7 : TColor;var dcol7 : TColor; var R7, G7, B7 : GLFloat);
    procedure IdleHandler(Sender: TObject; var Done: Boolean);
  end;

  const
NearClipping = 0.1; //ближняя плоскость отсечения
farClipping = 200; //дальняя плоскость отсечения

var
  OpenGLUnit: TOpenGLUnit;
  dc : HDC;  // контекст устройства.
  hrc : HGLRC;  // конекст рендеринга.
  Oxc, Oyc, Ozc, R1, Alf, Bet, perspectiveangle : Real;

implementation

uses MainUnit, GridGenUnit;

{$R *.dfm}

procedure TOpenGLUnit.ColorToGL(c7 : TColor;var dcol7 : TColor; var R7, G7, B7 : GLFloat);
begin
   dcol7:=c7;
   R7:=( c7 mod $100) / 255;
   G7:=(( c7 div $100) mod $100) / 255;
   B7:=( c7 div $10000) / 255;
end;

procedure TOpenGLUnit.SetupGL;
begin
   //glClearColor(0.0,0.0,0.0,0.0); //цвет фона
   //glClearColor (0.5, 0.5, 0.75, 1.0); //Цвет фона
   glClearColor (1.0, 1.0, 1.0, 1.0); //Цвет фона белый
   glEnable(GL_DEPTH_TEST); //включить тест глубины : включаем проверку разрешения фигур (впереди стоящая закрывает фигуру за ней)
   glDepthFunc(GL_LEQUAL); //тип проверки

   glEnable(GL_LIGHTING);
   glEnable(GL_LIGHT0);
   glEnable(GL_COLOR_MATERIAL);

   glMatrixMode(GL_PROJECTION);
   glLoadIdentity;
   gluPerspective(perspectiveangle,Width/Height,NearClipping,FarClipping);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity;
   gluLookAt(0.5*Form1.dLx,0.5*Form1.dLy,5,0.5*Form1.dLx,0.5*Form1.dLy,0, 0,0.01,1);
end;

procedure TOpenGLUnit.IdleHandler(Sender: TObject; var Done: Boolean);
begin
   Render;
   Sleep(5);
   Done:=False;
end;

procedure TOpenGLUnit.FormCreate(Sender: TObject);
begin
   Oxc:=0.0;//0.5*Form1.dLx;
   Oyc:=0.0;//0.5*Form1.dLy;

   perspectiveangle:=45.0;
   dc:=GetDC(OpenGLUnit.Handle);
   if not InitOpenGL then //если OpenGL не доступна, то приложение закрываем
      Application.Terminate;
   hrc := CreateRenderingContext(dc,[opDoubleBuffered],32,24,8,0,0,0); //здесь создаем контекст рендеринга, //необходимыми параметрами, в предыдущем уроке мы их изучали
   ActivateRenderingContext(dc,hrc); //теперь активируем и связываем контекст рендеринга и контекст //устройства
   SetupGL; // включение необходимого состояния OpenGL.
   Application.OnIdle:=IdleHandler;



   //glEnable(GL_CULL_FACE );  //показывать только передние грани
   //glCullFace(GL_BACK );
   //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
end;

procedure TOpenGLUnit.Render;
var
   minD, maxD : Real; // минимальные и максимальные значения отображаемой величины
   icol1, icol2, icol3, icol4 : Real; // цвета 4 вершин.
   i,j, k : Integer;
   msc : Real;
begin

   msc:=1.0/Sqrt(Sqr(Form1.dLx)+sqr(Form1.dLy));

   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //очищаем буфер цвета

   //эти команды мы изучим позже
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity;
   gluPerspective(perspectiveangle,Width/Height,NearClipping,FarClipping);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity;

   //Oxc:=0.0;//0.5*Form1.dLx;
   //Oyc:=0.0;//0.5*Form1.dLy;
   Ozc:=0.0;
   R1:=1.0; //Sqrt(Sqr(Form1.dLx)+Sqr(Form1.dLy));
   Bet:=1.3;
   Alf:=0.1;
  // perspectiveangle:=45.0;

   //gluLookAt(Oxc+R1*cos(Bet)*cos(Alf),Oyc+R1*cos(Bet)*sin(Alf), Ozc-5.0+R1*sin(Bet),Oxc,Oyc, Ozc-5.0,0.0,0.0,1.0);
    //gluLookAt(Oxc,Oyc, Ozc+5*R1,Oxc,Oyc, Ozc-15.0,0.0,0.0,1.0);
   //gluLookAt(-2,3,-4,0,0,0, 0,1,0);
   gluLookAt(Oxc+0.5*Form1.dLx*msc,Oyc+0.5*Form1.dLy*msc,5.0,Oxc+0.5*Form1.dLx*msc,Oyc+0.5*Form1.dLy*msc,0.0, 0.0,0.01,1.0);


   (*
   glpushMatrix;

   glTranslatef(0,0,-5.0);
  glColor3f(0.0,1.0,0.0);
  glBegin(GL_TRIANGLES); //рисуем треугольник
	glColor3f(1,0,0);  glVertex3f(0,5,0); //первая вершина
	glColor3f(0,1,0);  glVertex3f(1,4,0); //вторая вершина
	glColor3f(0,1,0);  glVertex3f(-1,4,0); //третья вершина
	glEnd;
  glPopmatrix;

  glpushMatrix;
	//glTranslatef(0,0,-5.0);
  glColor3f(0.0,1.0,0.0);
	glutSolidCube(2);      //Куб
   glPopmatrix;
   *)

  if ((Form1.D<>nil) and (Form1.D2=nil) and (Form1.D3=nil)) then
  begin

      // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;
         (*
         for i:=1 to inx*iny do
         begin
            if (D[i]>maxD) then maxD:=D[i];
            if (D[i]<minD) then minD:=D[i];
         end;
         *)
         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;

               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1);
                  end
                    else if ((255.0 <icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 <icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 <icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol1-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,ypos[j]*msc,0.0); //первая вершина

                  if ((0 <=icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0+icol4)/255.0,1.0);
                  end
                    else if ((255.0 <icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 <icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 <icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,ypos[j+1]*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 <icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,ypos[j+1]*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,ypos[j]*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc,0.0);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;
  end
  else if ((Form1.D<>nil)and(Form1.D2<>nil)and(Form1.D3=nil)) then
   begin
      // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;

         (*
         for i:=1 to inx*iny do
         begin
            if (D[i]>maxD) then maxD:=D[i];
            if (D[i]<minD) then minD:=D[i];
         end;
         *)

         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;


               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1.0);
                  end
                    else if ((255.0 <icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 < icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol1-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,(ypos[j]-0.6*Form1.dLy)*msc,0.0); //первая вершина

                  if ((0.0 <=icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol4)/255.0,1.0);
                  end
                    else if ((255.0 < icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 < icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0, 0.0);
                  end;

	                glVertex3f(xpos[i]*msc,(ypos[j+1]-0.6*Form1.dLy)*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 < icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,(ypos[j+1]-0.6*Form1.dLy)*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,(ypos[j]-0.6*Form1.dLy)*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc-0.6*Form1.dLy*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;

      // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;

         (*
         for i:=1 to inx*iny do
         begin
            if (D2[i]>maxD) then maxD:=D2[i];
            if (D2[i]<minD) then minD:=D2[i];
         end;
         *)

         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;


               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D2[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D2[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D2[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D2[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1.0);
                  end
                    else if ((255.0 < icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 < icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol1-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,(ypos[j]+0.6*Form1.dLy)*msc,0.0); //первая вершина

                  if ((0.0 <=icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol4)/255.0,1.0);
                  end
                    else if ((255.0 < icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 < icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,(ypos[j+1]+0.6*Form1.dLy)*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 < icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,(ypos[j+1]+0.6*Form1.dLy)*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,(ypos[j]+0.6*Form1.dLy)*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc+0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc+0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc+0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc+0.6*Form1.dLy*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;
   end
    else if ((Form1.D<>nil)and(Form1.D2<>nil)and(Form1.D3<>nil)) then
   begin
      // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;


         (*
         for i:=1 to inx*iny do
         begin
            if (D[i]>maxD) then maxD:=D[i];
            if (D[i]<minD) then minD:=D[i];
         end;
         *)
         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;


               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1.0);
                  end
                    else if ((255.0 < icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 < icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol1-765.0))/255.0, 0.0);
                  end;

	                glVertex3f(xpos[i]*msc-0.6*Form1.dLx*msc,ypos[j]*msc-0.6*Form1.dLy*msc,0.0); //первая вершина

                  if ((0.0 <=icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol4)/255.0,1.0);
                  end
                    else if ((255.0 < icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 < icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc-0.6*Form1.dLx*msc,ypos[j+1]*msc-0.6*Form1.dLy*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 < icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc-0.6*Form1.dLx*msc,ypos[j+1]*msc-0.6*Form1.dLy*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc-0.6*Form1.dLx*msc,ypos[j]*msc-0.6*Form1.dLy*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f(bricklist[i].xS*msc-0.6*Form1.dLx*msc,bricklist[i].yS*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc-0.6*Form1.dLx*msc,bricklist[i].yS*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc+ bricklist[i].xL*msc-0.6*Form1.dLx*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc-0.6*Form1.dLy*msc,0.0);
                glVertex3f(bricklist[i].xS*msc-0.6*Form1.dLx*msc,bricklist[i].yS*msc+ bricklist[i].yL*msc-0.6*Form1.dLy*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;

    // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;

         (*
         for i:=1 to inx*iny do
         begin
            if (D2[i]>maxD) then maxD:=D2[i];
            if (D2[i]<minD) then minD:=D2[i];
         end;
         *)

         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;


               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D2[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D2[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D2[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D2[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1.0);
                  end
                    else if ((255.0 < icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 < icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1,(255.0-(icol1-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,ypos[j]*msc+0.6*Form1.dLy*msc,0.0); //первая вершина

                  if ((0.0 <=icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol4)/255.0,1.0);
                  end
                    else if ((255.0 < icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 < icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i]*msc,ypos[j+1]*msc+0.6*Form1.dLy*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 < icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,ypos[j+1]*msc+0.6*Form1.dLy*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f(xpos[i+1]*msc,ypos[j]*msc+0.6*Form1.dLy*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f(bricklist[i].xS*msc,(bricklist[i].yS+0.6*Form1.dLy)*msc,0.0);
                glVertex3f((bricklist[i].xS+ bricklist[i].xL)*msc,(bricklist[i].yS+0.6*Form1.dLy)*msc,0.0);
                glVertex3f((bricklist[i].xS+ bricklist[i].xL)*msc,(bricklist[i].yS+ bricklist[i].yL+0.6*Form1.dLy)*msc,0.0);
                glVertex3f(bricklist[i].xS*msc,(bricklist[i].yS+ bricklist[i].yL+0.6*Form1.dLy)*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;

    // нужно вычислить максимальные и минимальные значения температуры
      maxD:=-1e+300;
      minD:=1e+300;

      with Form1 do
      begin
         glpushMatrix;

         (*
         for i:=1 to inx*iny do
         begin
            if (D3[i]>maxD) then maxD:=D3[i];
            if (D3[i]<minD) then minD:=D3[i];
         end;
         *)

         for k:=1 to imaxnumbernode do
         begin
            if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
            begin
               if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    if (D[k]>maxD) then maxD:=D[k];
                    if (D[k]<minD) then minD:=D[k];
                 end;
            end;
          end;


         // нужно нарисовать закрашенные контрольные объёмы
         // обход снизу вверх, слева направо
         for k:=1 to imaxnumbernode do
         begin
          if ((mapPT[k].i < inx) and (mapPT[k].j < iny)) then
          begin
             if ((GridGenForm.tnm[mapPT[k].i+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j-1)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+1+(mapPT[k].j)*inx].itypenode > 0) and
                 (GridGenForm.tnm[mapPT[k].i+(mapPT[k].j)*inx].itypenode > 0)) then
                 begin
                    i:=mapPT[k].i;
                    j:=mapPT[k].j;

               // выбор цвета
               icol1:=0.0; // синий по умолчанию
               icol2:=0.0;
               icol3:=0.0;
               icol4:=0.0;
               if (abs(maxD-minD)>1.0e-300) then
               begin
                  // maxD <> minD
                  icol1:=(1020.0*((D3[i+(j-1)*inx]-minD)/(maxD-minD)));
                  icol2:=(1020.0*((D3[i+1+(j-1)*inx]-minD)/(maxD-minD)));
                  icol3:=(1020.0*((D3[i+1+(j-1+1)*inx]-minD)/(maxD-minD)));
                  icol4:=(1020.0*((D3[i+(j-1+1)*inx]-minD)/(maxD-minD)));
               end;


               glBegin(GL_QUADS); //рисуем квадрат

                  if ((0.0 <=icol1) and (icol1 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol1)/255.0,1.0);
                  end
                    else if ((255.0 < icol1) and (icol1 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol1-255.0))/255.0);
                  end
                   else if ((510.0 < icol1) and (icol1 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol1-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol1) and (icol1 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol1-765.0))/255.0,0.0);
                  end;

	                glVertex3f((xpos[i]+0.6*Form1.dLx)*msc,ypos[j]*msc,0.0); //первая вершина

                  if ((0.0 <= icol4) and (icol4 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol4)/255.0, 1.0);
                  end
                    else if ((255.0 < icol4) and (icol4 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol4-255.0))/255.0);
                  end
                   else if ((510.0 < icol4) and (icol4 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol4-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol4) and (icol4 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol4-765.0))/255.0, 0.0);
                  end;

	                glVertex3f((xpos[i]+0.6*Form1.dLx)*msc,ypos[j+1]*msc,0.0); //четвёртая вершина

                    if ((0.0 <=icol3) and (icol3 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol3)/255.0,1.0);
                  end
                    else if ((255.0 < icol3) and (icol3 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol3-255.0))/255.0);
                  end
                   else if ((510.0 < icol3) and (icol3 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol3-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol3) and (icol3 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol3-765.0))/255.0,0.0);
                  end;

	                glVertex3f((xpos[i+1]+0.6*Form1.dLx)*msc,ypos[j+1]*msc,0.0); //третия вершина

                  if ((0.0 <=icol2) and (icol2 <= 255.0)) then
                  begin   // синий голубой
                     glColor3f(0.0,(0.0+icol2)/255.0,1.0);
                  end
                    else if ((255.0 < icol2) and (icol2 <= 510.0)) then
                  begin   // голубой зелёный
                     glColor3f(0.0,1.0,(255.0-(icol2-255.0))/255.0);
                  end
                   else if ((510.0 < icol2) and (icol2 <= 765.0)) then
                  begin   // зелёный жёлтый
                     glColor3f((0.0+(icol2-510.0))/255.0,1.0,0.0);
                  end
                   else if ((765.0 < icol2) and (icol2 <= 1020.0)) then
                  begin   // жёлтый красный
                     glColor3f(1.0,(255.0-(icol2-765.0))/255.0,0.0);
                  end;

	                glVertex3f((xpos[i+1]+0.6*Form1.dLx)*msc,ypos[j]*msc,0.0); //вторая вершина

	             glEnd;

               end;
         end;
         end;

         glColor3f(1.0,1.0,1.0); // белый фон.


      // учёт расположения hollow block
      for i:=1 to (GridGenForm.maxbrickelem-1) do
      begin
         with GridGenForm do
         begin
            glBegin(GL_QUADS);
                glVertex3f((bricklist[i].xS+0.6*Form1.dLx)*msc,bricklist[i].yS*msc,0.0);
                glVertex3f((bricklist[i].xS+ bricklist[i].xL+0.6*Form1.dLx)*msc,bricklist[i].yS*msc,0.0);
                glVertex3f((bricklist[i].xS+ bricklist[i].xL+0.6*Form1.dLx)*msc,(bricklist[i].yS+ bricklist[i].yL)*msc,0.0);
                glVertex3f((bricklist[i].xS+0.6*Form1.dLx)*msc,(bricklist[i].yS+ bricklist[i].yL)*msc,0.0);
            glEnd;
         end; // with
      end;
        glPopMatrix;
    end;
   end;

  SwapBuffers(DC); // эта команда выводит содержимого буфера на экран, если вы забудете написать эту //команду, то у вас ничего выводится, не будет.
end;



procedure TOpenGLUnit.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
   perspectiveangle:=perspectiveangle+1.0;
   if (perspectiveangle>175.0) then
   begin
      perspectiveangle:=175.0;
   end;
end;

procedure TOpenGLUnit.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   perspectiveangle:=perspectiveangle-1.0;
   if (perspectiveangle<5.0) then
   begin
      perspectiveangle:=5.0;
   end;
end;

procedure TOpenGLUnit.FormResize(Sender: TObject);
   var
   tmpBool : Boolean;
begin
  if (Width>300) then
  begin
      GroupBox1.Left:=Width-200;
   end;
   // OpenGL
   glViewport(0,0,ClientWidth,ClientHeight);
   glMatrixMode(GL_PROJECTION); //переходим в матрицу проекции
   glLoadIdentity;  //Сбрасываем текущую матрицу
   gluPerspective(perspectiveangle,ClientWidth/ClientHeight,NearClipping,FarClipping);
  // glMatrixMode(GL_MODELVIEW); // переходим в модельную матрицу
   glLoadIdentity; //Сбрасываем текущую матрицу
   //Oxc:=0.0;//0.5*Form1.dLx;
   //Oyc:=0.0;//0.5*Form1.dLy;
   //Ozc:=0.0;
   //R1:=1.0;//Sqrt(Sqr(Form1.dLx)+Sqr(Form1.dLy));
   //Bet:=0.3;
   //Alf:=0.1;
   //perspectiveangle:=45.0;

   //gluLookAt(Oxc+R1*cos(Bet)*cos(Alf),Oyc+R1*cos(Bet)*sin(Alf), Ozc-5.0+R1*sin(Bet),Oxc,Oyc, Ozc-5.0,0.0,0.0,1.0);
   //gluLookAt(Oxc,Oyc, Ozc+5*R1,Oxc,Oyc, Ozc-15.0,0.0,0.0,1.0);
   IdleHandler(Sender,tmpBool);
end;



procedure TOpenGLUnit.FormDestroy(Sender: TObject);
begin
   DeactivateRenderingContext;
   DestroyRenderingContext(hrc);
   ReleaseDC(Handle,dc);
end;

procedure TOpenGLUnit.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if (Button = mbLeft) then
   begin
      drawing:=false;
      // запоминаем начальную позицию мыши
      ix0:=X;
      iy0:=Y;
   end
end;



procedure TOpenGLUnit.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Button = mbLeft) then
   begin
      Oxc:=Oxc-0.01*(X-ix0);
      Oyc:=Oyc+0.01*(Y-iy0);
      drawing:=true;
   end;
end;



procedure TOpenGLUnit.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    if (X>Width-GroupBox1.Width) then
    begin
        GroupBox1.Visible:=true;
    end
    else
    begin
        GroupBox1.Visible:=false;
    end;
end;

procedure TOpenGLUnit.Timer1Timer(Sender: TObject);
begin
   Render;
end;

end.
