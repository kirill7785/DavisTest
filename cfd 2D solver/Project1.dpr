﻿program Project1;
(*
 *  Davis Test: Простой код для моделирования сложных процессов переноса.
 *  Область применения : двумерный тепломассообмен или перенос заряда в полупроводнике
 *  в области с прямоугольной геометрией.
 *
 *  Данный проект Project1 посвящён
 *  решению системы уравнений гидродинамики
 *  и теплообмена.
 *  Его главной целью является написание
 *  максимально понятного кода  солвера
 *  (именно поэтому код пишется на языке Object Pascal в среде Delphi) ,
 *  так чтобы любой человек которому понадобится
 *  решить какую-либо свою конкретную гидродинамическую задачу
 *  смог беспрепятственно и без осложнений получить доступ
 *  к этому коду, прочитать и понять его, а также изменить
 *  и переделать под себя.
 *  Данный код предоставляется как есть без каких-либо гарантий.
 *  На данный момент данный проект состоит из ряда модулей перечисленных ниже:
 *  MainUnit - главный модуль в нём содержится основной код солвера,
 *  DisplayUnit - модуль простейшей визуализации,
 *  MeshGen - модуль генерации простейшей сетки,
 *  GridGenUnit - улучшеннный генератор сетки,
 *  (Далее перечислено несколько модулей "пустышек" в них почти нет кода
 *    они просто реализуют взаимодействие с пользователем)
 *  myGeneralSolver - доступ к некоторым настройкам решателя,
 *  myRunmodule - здесь прописан ход решения на высоком уровне, при этом
 *  используются необходимые процедуры описанные в главном модуле MainUnit.
 *  InitializeUnit - здесь можно задать или изменить параметры инициализации,
 *  MaterialUnit - здесь можно задать или изменить параметры материалов,
 *  ExportTecplotUnit - здесь можно передать данные в программу tecplot360,
 *  BoundaryConditionUnit - модуль задания граничных условий,
 *  SourceInEquationUnit - задание источникового члена,
 *  Unit2DPlot - меню реализованной визуализации,
 *  myProgressBarUnit - содержит индикатор хода выполнения расчёта,
 *  что очень удобно для пользователя.
 *  AlgoSolverUnit - выбор алгоритма решателя: Гаусс-Зейдель или переменные направления.
 *  controlSIMPLEUnit - модуль где можно задать структуру одной итерации алгоритма SIMPLE.
 *  RelaxFactorsUnit - выбор параметров релаксации.
 *  ApproxConvectionUnit - выбор схемы аппроксимации конвективного члена.
 *  ModelEquationUnit - выбор системы решаемых уравнений.
 *  TerminateProcessUnit - меню где можно прервать процесс вычислений.
 *  MyResControlUnit - модуль где можно задать пороговые значения невязок,
 *  что позволит контролировать вычислительный процесс.
 *  GravityUnit - меню где можно задать ускорение свободного падения
 *
 *  AddBrickUnit - модуль где добавляется пустой hollow блок
 *  Cabinet2DUnit - модуль где редактируются параметры кабинета
 *  BonConRedoUnit - модуль где редактируются границы расчётной области
 *  HBlockRedoUnit - модуль где редактируются hollow блоки
 *
 *  UnitDefineTrials - модуль где настраивается многовариантный расчёт или т.е. целая серия расчётов
 *  с целью выявить внутренние связи присущие математической модели.
*)

uses
  Forms,
  MainUnit in 'MainUnit.pas' {Form1},
  DisplayUnit in 'DisplayUnit.pas' {DisplayForm},
  MeshGen in 'MeshGen.pas' {FMesh},
  myGeneralSolver in 'myGeneralSolver.pas' {General},
  myRunmodule in 'myRunmodule.pas' {myRun},
  InitializeUnit in 'InitializeUnit.pas' {myInitialize},
  MaterialUnit in 'MaterialUnit.pas' {MaterialForm},
  ExportTecplotUnit in 'ExportTecplotUnit.pas' {ExportTecplotForm},
  BoundaryConditionUnit in 'BoundaryConditionUnit.pas' {BoundaryConditionForm},
  SourceInEquationUnit in 'SourceInEquationUnit.pas' {SourceInEquationForm},
  Unit2DPlot in 'Unit2DPlot.pas' {Form2DPlot},
  InterpolateCaseUnit in 'InterpolateCaseUnit.pas' {InterpolateCaseForm},
  myProgressBarUnit in 'myProgressBarUnit.pas' {myProgressBarForm},
  myProgressBarUnsteadyUnit in 'myProgressBarUnsteadyUnit.pas' {myProgressBarUnsteadyForm},
  AlgoSolverUnit in 'AlgoSolverUnit.pas' {AlgoSolver},
  controlSIMPLEUnit in 'controlSIMPLEUnit.pas' {controlSIMPLEForm},
  RelaxFactorsUnit in 'RelaxFactorsUnit.pas' {RelaxFactorsForm},
  ApproxConvectionUnit in 'ApproxConvectionUnit.pas' {ApproxConvectionForm},
  ModelEquationUnit in 'ModelEquationUnit.pas' {ModelEquationForm},
  TerminateProcessUnit in 'TerminateProcessUnit.pas' {TerminateProcessForm},
  MyResControlUnit in 'MyResControlUnit.pas' {MyResControlForm},
  SoprGradUnit in 'SoprGradUnit.pas' {SoprGradForm},
  GravityUnit in 'GravityUnit.pas' {GravityForm},
  GridGenUnit in 'GridGenUnit.pas' {GridGenForm},
  AddBrickUnit in 'AddBrickUnit.pas' {AddbrickForm},
  CabinetGlobalMeshUnit in 'CabinetGlobalMeshUnit.pas' {CabinetGlobalMeshForm},
  Cabinet2DUnit in 'Cabinet2DUnit.pas' {Cabinet2DForm},
  BonConRedoUnit in 'BonConRedoUnit.pas' {BonConRedoForm},
  HBlockRedoUnit in 'HBlockRedoUnit.pas' {HBlockRedoForm},
  DynMeshUnit in 'DynMeshUnit.pas' {DynMeshForm},
  PamendmentcontrolUnit in 'PamendmentcontrolUnit.pas' {PamendmendcontrolForm},
  PatchUnit in 'PatchUnit.pas' {PatchForm},
  RectangleDomenUnit in 'RectangleDomenUnit.pas' {RectangleDomenForm},
  CircleDomenUnit in 'CircleDomenUnit.pas' {CircleDomenForm},
  Unitlanguage in 'Unitlanguage.pas' {Formlanguage},
  UnitEasyCabinet in 'UnitEasyCabinet.pas' {FormCabinetEasy},
  UnitVOFScheme in 'UnitVOFScheme.pas' {FormVolumeFractPar},
  Unithelpcg in 'Unithelpcg.pas' {FormCGhelp},
  UnitUserDefinedMemory in 'UnitUserDefinedMemory.pas' {FormUDM},
  UnitUserDefinedScalar in 'UnitUserDefinedScalar.pas' {FormUserDefinedScalar},
  UnitUserDefinedScalarDiffusion in 'UnitUserDefinedScalarDiffusion.pas' {FormUDSDiffusivity},
  Unitanimation in 'Unitanimation.pas' {FormAnimationSetting},
  UnitAddVariable in 'UnitAddVariable.pas' {AddVariableForm},
  UnitCustomFieldFunction in 'UnitCustomFieldFunction.pas' {FormCustomFieldFunction},
  UnitInterpritatortest in 'UnitInterpritatortest.pas' {FormInterpritator},
  Unitnotepad in 'Unitnotepad.pas' {Formnotepad},
  Unithelp1 in 'Unithelp1.pas' {FormHelp},
  UnitSurfaceIntegrals in 'UnitSurfaceIntegrals.pas' {FormSurfaceIntegrals},
  Unitdeclar in 'Unitdeclar.pas',
  Unitaddmeshline in 'Unitaddmeshline.pas' {Formaddmeshline},
  UnitPatternCFF in 'UnitPatternCFF.pas' {FormPatCFF},
  Unitmessagesilicon in 'Unitmessagesilicon.pas' {Formmessagesilicon},
  UnitSolutionLimits in 'UnitSolutionLimits.pas' {FormSolutionLimits},
  UnitDefineTrials in 'UnitDefineTrials.pas' {FormDefineTrials},
  Unitlengthscaleplot in 'Unitlengthscaleplot.pas' {Formlengthscaleplot},
  UnitSurfaceIntegralReport in 'UnitSurfaceIntegralReport.pas' {FormAutoReportSurfInt},
  UnitParametricTrialsOnlineReport in 'UnitParametricTrialsOnlineReport.pas' {FormParametricTrialsOnlineReport},
  UnitLaunchMeshGen in 'UnitLaunchMeshGen.pas' {frmLaunchGenerator},
  UnitOpenGL in 'UnitOpenGL.pas' {OpenGLUnit};

{$R *.res}



begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDisplayForm, DisplayForm);
  Application.CreateForm(TFMesh, FMesh);
  Application.CreateForm(TGeneral, General);
  Application.CreateForm(TmyRun, myRun);
  Application.CreateForm(TmyInitialize, myInitialize);
  Application.CreateForm(TMaterialForm, MaterialForm);
  Application.CreateForm(TExportTecplotForm, ExportTecplotForm);
  Application.CreateForm(TBoundaryConditionForm, BoundaryConditionForm);
  Application.CreateForm(TSourceInEquationForm, SourceInEquationForm);
  Application.CreateForm(TForm2DPlot, Form2DPlot);
  Application.CreateForm(TInterpolateCaseForm, InterpolateCaseForm);
  Application.CreateForm(TmyProgressBarForm, myProgressBarForm);
  Application.CreateForm(TmyProgressBarUnsteadyForm, myProgressBarUnsteadyForm);
  Application.CreateForm(TAlgoSolver, AlgoSolver);
  Application.CreateForm(TcontrolSIMPLEForm, controlSIMPLEForm);
  Application.CreateForm(TRelaxFactorsForm, RelaxFactorsForm);
  Application.CreateForm(TApproxConvectionForm, ApproxConvectionForm);
  Application.CreateForm(TModelEquationForm, ModelEquationForm);
  Application.CreateForm(TTerminateProcessForm, TerminateProcessForm);
  Application.CreateForm(TMyResControlForm, MyResControlForm);
  Application.CreateForm(TSoprGradForm, SoprGradForm);
  Application.CreateForm(TGravityForm, GravityForm);
  Application.CreateForm(TGridGenForm, GridGenForm);
  Application.CreateForm(TAddbrickForm, AddbrickForm);
  Application.CreateForm(TCabinetGlobalMeshForm, CabinetGlobalMeshForm);
  Application.CreateForm(TCabinet2DForm, Cabinet2DForm);
  Application.CreateForm(TBonConRedoForm, BonConRedoForm);
  Application.CreateForm(THBlockRedoForm, HBlockRedoForm);
  Application.CreateForm(TDynMeshForm, DynMeshForm);
  Application.CreateForm(TPamendmendcontrolForm, PamendmendcontrolForm);
  Application.CreateForm(TPatchForm, PatchForm);
  Application.CreateForm(TRectangleDomenForm, RectangleDomenForm);
  Application.CreateForm(TCircleDomenForm, CircleDomenForm);
  Application.CreateForm(TFormlanguage, Formlanguage);
  Application.CreateForm(TFormCabinetEasy, FormCabinetEasy);
  Application.CreateForm(TFormVolumeFractPar, FormVolumeFractPar);
  Application.CreateForm(TFormCGhelp, FormCGhelp);
  Application.CreateForm(TFormUDM, FormUDM);
  Application.CreateForm(TFormUserDefinedScalar, FormUserDefinedScalar);
  Application.CreateForm(TFormUDSDiffusivity, FormUDSDiffusivity);
  Application.CreateForm(TFormAnimationSetting, FormAnimationSetting);
  Application.CreateForm(TAddVariableForm, AddVariableForm);
  Application.CreateForm(TFormCustomFieldFunction, FormCustomFieldFunction);
  Application.CreateForm(TFormInterpritator, FormInterpritator);
  Application.CreateForm(TFormnotepad, Formnotepad);
  Application.CreateForm(TFormHelp, FormHelp);
  Application.CreateForm(TFormSurfaceIntegrals, FormSurfaceIntegrals);
  Application.CreateForm(TFormaddmeshline, Formaddmeshline);
  Application.CreateForm(TFormPatCFF, FormPatCFF);
  Application.CreateForm(TFormmessagesilicon, Formmessagesilicon);
  Application.CreateForm(TFormSolutionLimits, FormSolutionLimits);
  Application.CreateForm(TFormDefineTrials, FormDefineTrials);
  Application.CreateForm(TFormlengthscaleplot, Formlengthscaleplot);
  Application.CreateForm(TFormAutoReportSurfInt, FormAutoReportSurfInt);
  Application.CreateForm(TFormParametricTrialsOnlineReport, FormParametricTrialsOnlineReport);
  Application.CreateForm(TfrmLaunchGenerator, frmLaunchGenerator);
  Application.CreateForm(TOpenGLUnit, OpenGLUnit);
  Application.Run;
end.
