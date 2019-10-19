unit Unitdeclar;
// Здесь объявляется используемая модель вещественного числа,
// а также динамический массив.

interface


type

  //Float = Single;
  Float = Real;
  //Float = Extended;
  // Real48 e-39..e+38   11-12
  // Real -324..308 15-16
  // Extended -4951..4932 19-20
  // Comp -63 63 19-20

  // тип динамический массив вещественных чисел
  TmyDynArray = array of Float;
  // двумерный динамический массив
  T2myDynArray = array of TmyDynArray;

  TPmyDynArray = ^TmyDynArray; // ссылочный тип

  TmyDynArrayi = array of Integer;
  TPmyDynArrayi = ^TmyDynArrayi; // ссылочный тип

  TmyDynArrayb = array of Boolean;
  TPmyDynArrayb = ^TmyDynArrayb;

  PmyBoolean =^Boolean;


implementation

end.
 