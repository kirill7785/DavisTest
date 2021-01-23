# DavisTest
2D cfd solver

System requarements:
* OS Windows x64
* compiller delphi 2018 : Embarcadero® Delphi 10.3 Version 26.0.32429.4364 
* dll compiller: visual studio 2019 community
* microsoft redistributable package: VC_redist.x64
* evalution tecplot 360 or paraview for visualization.

Algorithms:
* 2D temperature solver;
* 2D cfd simulation on SIMPLE; SIMPLEC or SIMPLER algorithms for pressure velosity coupling;
* Chess Mesh; 
* Hollow block is support;
* Bussinesk approach for natural convection is support;
* Unsteady simulations is support;
* <= 4 user defined scalar is support;
* original dynamic mesh!!!
* original Volume of Fluid (VOF) method; Surfase Tension Force (CSF)is support; !!!
* original Algebraic Multigrid for solve Ax=b;
* amg AMGCL ddemidov for continity equation. (Future 23.01.2021)
* High Resolution Scheme for approximation convection: QUICK; SMART; SUPERBEE; etc...
* OpenGL graphics; Animations.
* Only cartesian rectangular coordinate system
* Does not have a turbulence model

![alt text](https://raw.githubusercontent.com/kirill7785/DavisTest/master/picture/cavity%20Re%3D100/cavity%20Re100.bmp)
![alt text](https://raw.githubusercontent.com/kirill7785/DavisTest/master/picture/davis%20Ra1E3%20Pr0i7/Ra1E3Pr0i7.bmp)
![alt text](https://raw.githubusercontent.com/kirill7785/DavisTest/master/picture/Raley%20Benar%20Ra1E4%20Pr0i7/Raley%20Benar%20Ra%3D1E4.bmp)
![alt text]( https://github.com/kirill7785/DavisTest/blob/master/picture/cylinder%20Re%3D200/Speed%20обтекание%20квадрата.png)
![alt text]( https://github.com/kirill7785/DavisTest/blob/master/picture/cylinder%20Re%3D200/Pressure%20обтекание%20квадрата.png)
