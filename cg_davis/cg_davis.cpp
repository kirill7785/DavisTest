// cg_davis.cpp: определяет экспортированные функции для приложения DLL.
//

// содержит С реализацию метода сопряжённых градиентов для 
// давления и поправки давления в программе Davis Test Delphi.
// см . диссертацию Н.Г.Бураго.
// сюда также можно добавить предобуславливатели и алгоритм ван дер Ворста.




#include "stdafx.h"
#include <math.h>
#include <stdio.h>

#define MYDEBUG 0 // режим отладки

#ifdef __cplusplus 
#define EXPORT extern "C" __declspec(dllexport) 
#else 
#define EXPORT __declspec (dllexport) 
#endif 

struct MatrixCoef 
{
	/* структура даных со значением
	 * коэффициентов для одного уравнения системы
	 * на пятиточечном шаблоне.
	 * Данная структура используется
	 * в уравнениях для каждой из компонент скорости
	 * а также в уравнении для поправки давления.
	*/
	/* восток запад север юг центральная точка
	*/
	double dae, daw, dan, das, dap;
};

struct TmyNode
{
	// структура одного узла
	// 0 - пустой или не принадлежащий расчётной сетке (hollow point).
	int itype; // тип узла ( 1 - внутренний, 2 - граничный узел)
	int i,j; // целочисленные координаты узла
	// для узла также возможно имеет смысл хранить и другую информацию :
	// объём контрольного объёма, длина стенки контрольного объёма по х,
	// длина стенки контрольного объёма по y. и т.д.
	double dx, dy, dV;
	double dxe, dxw, dyn, dys;
    // для граничного условия Неймана
	int iboundary; // уникальный номер границы к которой принадлежит эта точка.
	char chnormal; // внутренняя нормаль к границе.
	// виды угловых точек
	// 0 - не угловая,
	// 1 - левый нижний угол,
	// 2 - правый нижний угол,
	// 3 - левый верхний угол,
	// 4 - правый верхний угол,
	// 5 - угол пятиточечный крест.
	int iugol; 
	// в уравнении для поправки давления
	// важно знать соседние с угловыми точками
	// это можно определить без дополнительной структуры данных.

	// для ускорения вычислений.
	int ini, isi, iwi, iei, ipi;
};




// структура данных для
  // формирования разреженной матрицы
  // в формате CRS для метода Сопряжённых Градиентов
  struct TmyNonZeroElemMatrix
  {
     // нужно хранить индексы
     // i,j определяющие местоположение
     // элемента в массиве
     int i;
     int j;
     // значение ненулевого элемента
     double aij;
     // специальный ключ для упорядочивания
     // по строкам
     int key;

  }; // TmyNonZeroElemMatrix

  // возвращает минимальное из двух целых чисел.
int imin(int ia, int ib) {
	if (ia<ib) {
		return ia;
	}
	else
	{
		return ib;
	}
}


// Для применения метода сопряжённых градиентов
// с использованием технологии
// хранения разреженной матрицы CRS
// потребуется реализация алгоритма быстрой сортировки

// Запрограммировано с использованием
// Брайан Керниган и Дени Ритчи "The C Programming Language".
// Swap : Обмен местами list[i] и list[j]
void Swap(TmyNonZeroElemMatrix* list,
                          int i,
                          int j)

{

   TmyNonZeroElemMatrix temp;

   // Если стек переполнен и отладчик остановился здесь на
   // строке begin, значит скрее всего быстрая сортировка Хоара
   // вызвала переполнение стека вложеннных вызовов.
   // Выход заменить её пирамидальной сортировкой.

   // cgange list[i] <-> list [j]

   // temp = list[i];
   temp.i=list[i].i;
   temp.j=list[i].j;
   temp.aij=list[i].aij;
   temp.key=list[i].key;
   // list[i] = list[j];
   list[i].i=list[j].i;
   list[i].j=list[j].j;
   list[i].aij=list[j].aij;
   list[i].key=list[j].key;
   // list[j] = temp;
   list[j].i=temp.i;
   list[j].j=temp.j;
   list[j].aij=temp.aij;
   list[j].key=temp.key;

} // Swap

// Вот алгоритм PivotList
// он возвращает точку деления элементов массива на две части.
// Запрограммировано с использованием книжки ДЖ. Макконел
// Анализ алгоритмов стр. 106.
int PivotList(TmyNonZeroElemMatrix* list,
                              int first,
                              int last) 
{
	int PivotValue;
	int PivotPoint; // возвращаемая позиция точки разделения
	int index;// счётчик цикла for

   // list обрабатываемый список
   // first номер первого элемента
   // last номер последнего элемента

   PivotValue = list[first].key;
   PivotPoint = first;

   for (index=(first+1); index<=last; index++)
   {
      if (list[index].key < PivotValue) 
	  {
         PivotPoint = PivotPoint + 1;
         Swap(list, PivotPoint, index);
	  }
   }

   Swap(list, first, PivotPoint);

   return PivotPoint;

} // PivotList

// Быстрая сортировка Хоара.
// Это рекурсивный алгоритм который эффективен по быстродействию
// но возможно не эффективен по памяти.
// Быстрая сортировка применяется здесь для упорядочивания достаточно больших
// массивов данных.
// Запрограммировано с использованием Дж. Макконел Анализ алгоритмов стр. 106.
void QuickSort(TmyNonZeroElemMatrix* list,
                              int first,
                              int last)
{
	int Pivot;

   // list упорядочиваемый список элементов
   // first номер первого элемента в сортируемой части списка
   // last номер последнего элемента в сортируемой части списка

   if (first < last) 
   {
      Pivot = PivotList(list, first, last);
      QuickSort(list, first, Pivot-1);
      QuickSort(list, Pivot+1, last);
   }

} // QuickSort

// Пирамидальная сортировка

// Переформировать пирамиду
void FixHeap(TmyNonZeroElemMatrix* list,
                          int root,
                          TmyNonZeroElemMatrix m,
                          int bound)
{
	int vacant;
	int largerChild;

   // list сортируемый список пирамида
   // root номер корня пирамиды
   // m ключевое значение вставляемое в пирамиду
   // bound правая граница (номер) в пирамиде
   vacant=root;
   while (2*vacant <= bound) 
   {
      largerChild=2*vacant;

      // поиск наибольшего из двух непосредственных потомков
      if ((largerChild<bound) && (list[largerChild+1].key>list[largerChild].key)) 
	  {
         largerChild=largerChild + 1;
      }

      // находится ли ключ выше текущего потомка ?
      if (m.key > list[largerChild].key) 
      {
         // да, цикл завершается
         break;
	  }
      else
	  {
         // нет, большего непосредственного потомка
         // следует поднять
         list[vacant].i=list[largerChild].i;
         list[vacant].j=list[largerChild].j;
         list[vacant].aij=list[largerChild].aij;
         list[vacant].key=list[largerChild].key;
         vacant=largerChild;
	  }
   }
   list[vacant].i=m.i;
   list[vacant].j=m.j;
   list[vacant].aij=m.aij;
   list[vacant].key=m.key;
} // FixHeap

// Пирамидальная сортировка оптимальна как
// по памяти, так и по быстродействию, к тому же её алгоритм
// очень интересен.
// Ограничение состоит в том, что нумерация массива должна начинаться с 1.
void HeapSort(TmyNonZeroElemMatrix *list, int n)
{

	int i; // счётчик
	TmyNonZeroElemMatrix max; // элемент с наибольшим значением ключа

    // конструирование пирамиды
    for ( i=(n/2); i>=1; i--)
	{
       FixHeap(list, i, list[i], n);
	}
    for (i=n; i>=2; i--)
	{
       // скопировать корень пирамиды в список
       // переформировать пирамиду
       max.i=list[1].i;
       max.j=list[1].j;
       max.aij=list[1].aij;
       max.key=list[1].key;
       FixHeap(list, 1, list[i], i-1);
       list[i].i=max.i;
       list[i].j=max.j;
       list[i].aij=max.aij;
       list[i].key=max.key;
	}
} // HeapSort

// скалярное произведение двух векторов
double Scal(int isize, double *dV1,
                       double *dV2)
{

   double ds=0.0; // инициализация
   for ( int i=0; i<=(isize-1); i++)
   {
      ds+=  dV1[i]*dV2[i];
   }
   return ds;
} // Scal

// умножение матрицы на вектор
// используя формат хранения CRS
// Это эффективная процедура учитывающая разреженность матрицы СЛАУ.
// Запрограммировано с использованием
// 1. http://www.netlib.org/linalg/html_templates  "Survey of Sparse Matrix Storage Formats"
// 2. Р. Тьюарсон "Разреженные матрицы".
// Массивы передаются по ссылке дабы избежать переполнения стека.
void MatrixCRSByVector(int isize, // размерность вектора или квадратной матрицы
                                double *val,  // ненулевые элементы матрицы
                                int *col_ind, // соответствующие им номера столбцов
                                int *row_ptr, // для определения начала следующей строки
                                double *dV, // заданный вектор на который производится умножение
                                double *dx)  // результат умножения заносится в dx.
{

   int i,j; // счётчики цикла for

   for (i=0; i<=(isize-1); i++)
   {
      dx[i]=0.0;

      for (j=row_ptr[i]; j<=(row_ptr[i+1]-1); j++) 
	  {
         dx[i]+= val[j]*dV[col_ind[j]];
	  }

   }

} // MatrixCRSByVector

// умножение транспонированной матрицы на вектор
// используя формат хранения CRS
// Это эффективная процедура учитывающая разреженность матрицы СЛАУ.
// Запрограммировано с использованием
// 1. http://www.netlib.org/linalg/html_templates  "Survey of Sparse Matrix Storage Formats"
// 2. Р. Тьюарсон "Разреженные матрицы".
void MatrixTransposeCRSByVector(int isize, // размерность вектора или квадратной матрицы
                                double *val,  // ненулевые элементы матрицы
                                int  *col_ind, // соответствующие им номера столбцов
                                int *row_ptr, // для определения начала следующей строки
                                double *dV, // заданный вектор на который производится умножение
                                double *dx)  // результат умножения заносится в dx.
{

	int i,j; // счётчики цикла for

   for (i=0; i<=(isize-1); i++) dx[i]=0.0; // обнуление

   for (j=0; j<=(isize-1); j++)
   {

      for (i=row_ptr[j]; i<=(row_ptr[j+1]-1); i++)
	  {
         dx[col_ind[i]] += val[i]*dV[j];
	  }

   }

}  // MatrixTransposeCRSByVector

// норма вектора
// как корень квадратный из суммы квадратов
double NormaV(int isize, double *dV)
{
	int i; // счётчик цикла
	double dnorma, dsum;

   // инициализация переменных
   dsum=0.0;
   for (i=0; i<=(isize-1); i++)
   {
      dsum+= dV[i]*dV[i];
   }
   dnorma=sqrt(dsum); // норма вектора
   return dnorma;
} // NormaV

// возвращает максимальное из двух вещественых чисел.
double fmax(double da, double db) {
	if (da>db) {
		return da;
	}
	else
	{
		return db;
	}
}

// норма вектора
// как максимальное значение среди модулей компонент вектора
// кубическая норма.
double NormaSupV(int isize,
                       double *dV)
{
	int i; // счётчик цикла
	double  dmax; // будущее значение нормы вектора

   // инициализация переменных
   dmax=-1.0; // отрицательное число
   for (i=0; i<=(isize-1); i++)
   {
      dmax= fmax(dmax, fabs(dV[i]));
   }
    // норма вектора
   return dmax;
} // NormaSupV

// норма вектора
// сумма модулей компонент вектора
// октаэдрическая норма.
double NormaSup2V(int isize, double *dV)
{
	int i; // счётчик цикла
	double dsum; // будущее значение нормы вектора
   // инициализация переменных
   dsum=0.0; // обнуление сумматора
   for (i=0; i<=(isize-1); i++)
   {
      dsum+= fabs(dV[i]);
   }
    // норма вектора
   return dsum;
} // NormaSup2V

// Метод Сопряжённых градиентов
// Хестенса и Штифеля 1952 год.
// см. например, диссертацию Н.Г. Бураго  стр. 88.
// или Г.И. Марчук методы вычислительной математики
// здесь применена технология CRS хранения и обработки разреженной матрицы.
// Этот алгоритм подходит не только для SPD - Symmetric and Positively Defined матриц.
// SPD - Самосопряжённые и положительно определённые матрицы.
// В зависимости от значения передаваемого параметра bGaussTransform
// в нём примененяется или не применяется трансформация Гаусса.
// Трансформация Гаусса состоит в домножении СЛАУ на транспонированную матрицу слева,
// что позволяет из любой СЛАУ получить СЛАУ с положительно определённой самосопряжённой матрицей.
// Однако трансформация Гаусса сильно портит число обусловленности матрицы (спектр матрицы) возводя его в квадрат.
void SoprGradCRS(int isize, // размер квадратной матрицы
                          double *val, // матрица СЛАУ
                          int *col_ind, // соответствующие ненулевым элементам номера столбцов
                          int *row_ptr, // информация о началах строк
                          double *dV,  // вектор правой части
                          double *dX0, // вектор начального приближения
                          double *dres, // вектор результата
						  double *residual_history, // история изменеия невязок
                          bool bconsole_message, // выводить ли значения невязки на консоль
                          int kend, // ограничение на максимальное количество итераций
                          bool bGaussTransform, // выполнять ли трансформацию Гаусса
                          double epsilon,
						  int ibasenorma) // точность вычисления
{

	int i,k; // счётчики
	double dar, dbr, dnz, dscalgg;

   // выделение памяти
   // под динамические массивы
   double *dx=new double[isize];  // искомое решение системы
   double *dax=new double[isize]; // результаты умножения
   double *dap=new double[isize]; // матрицы на вектор
   double *dg=new double[isize]; // вектор градиента
   double *dp=new double[isize]; // вектор сопряжённого направления поиска
   // для трансформации Гаусса
   double *dbuf=new double[isize]; // временное хранилище при выполнении трансформации Гаусса

   // начальное приближение
   // X0 ==
   // под вектором dX0 понимается вектор поля температур к примеру.
   for (i=0; i<=(isize-1); i++) dx[i]=dX0[i];

   // Первоначально без применения трансформации Гаусса.
   MatrixCRSByVector(isize, val, col_ind, row_ptr, dx, dax); // результат занесён в dax
   for (i=0; i<=(isize-1); i++) dg[i]= dV[i] - dax[i];  // начальная невязка

   if ( bGaussTransform) 
   {
      // Если трансформация Гаусса всё-же требуется.
      for (i=0; i<=(isize-1); i++) dbuf[i]= dg[i];  // временная копия начальной невязки
      MatrixTransposeCRSByVector(isize, val, col_ind, row_ptr, dbuf, dg); // результат занесён в dg:=At*dbuf;
   }

   if (Scal(isize, dg, dg) > 1.0e-30) 
   {
      for (i=0; i<=(isize-1); i++) dp[i]=dg[i]; // p0:=g0;
      k=0; // номер итерации
      dnz=1.0e+30; // начальное значение невязки (инициализация)
      while ((k < kend) && (dnz > epsilon)) 
	  {
         if ( bGaussTransform) 
		 {
            // выполняется трансформация Гаусса.
            MatrixCRSByVector(isize, val, col_ind, row_ptr, dp, dbuf); // результат занесён в dbuft1
            MatrixTransposeCRSByVector(isize, val, col_ind, row_ptr, dbuf, dap); // результат At*A*dp занесён в dap
		 }
         else
		 {
            // Трансформация Гаусса не выполняется.
            MatrixCRSByVector(isize, val, col_ind, row_ptr, dp, dap); // результат A*dp занесён в dap
		 }
         dscalgg= Scal(isize, dg, dg);
         dar =  dscalgg / Scal( isize, dap, dp);
         for (i=0; i<=(isize-1); i++)
		 {
            dx[i] = dx[i] + dar*dp[i];
            dg[i] = dg[i] - dar*dap[i];
		 }
         // здесь реализованы все три нормы
         // вообще говоря они все эквивалентны
         switch (ibasenorma)
		 {
            case 1 : dnz=NormaV(isize, dg); break; // евклидова
            case 2 : dnz=NormaSupV(isize, dg); break; // кубическая норма
            case 3 : dnz=NormaSup2V(isize, dg); break; // октаэдрическая норма
	     }
         
         if (bconsole_message) 
		 {
            // печать значения невязки на консоль
			residual_history[k]=dnz;
	     }
         dbr = Scal(isize, dg, dg) / dscalgg;
         for (i=0; i<=(isize-1); i++)
		 {
            dp[i] = dg[i] + dbr*dp[i];
         }
         k++; // переход к следующей итерации
         // если процесс расходится его надо остановить
         if (dnz > 1.0e+17) 
		 {
            // восстановление начального приближения
            for (i=0; i<=(isize-1); i++) dx[i]=dX0[i];
            //MainMemo.Lines.Add('вычислительный процесс расходится ');
            //Application.MessageBox('divergence SoprGrad solver ','',MB_OK);
            break; // и останов процесса
		 }
	  }
      // возвращение результата
      for (i=0; i<=(isize-1); i++) dres[i]=dx[i];
   }
    else
   {
      // возвращает начальное приближение
      for (i=0; i<=(isize-1); i++) dres[i]=dX0[i];
   }

   // освобождение памяти выделенной под динамические массивы
   delete dx; // уточняемая величина в результате итерационного процесса
   delete dax; delete dap; // результаты умножения матрицы на вектор
   delete dg; delete dp; // векторы градиента и сопряжённого направления поиска.
   delete dbuf;

}  // SoprGradCRS

// Для генерации матрицы СЛАУ требуется в случае реализации
// на динамических массивах переупорядочивание элементов:
// сортировка. Здесь будет реализована быстрая сортировка.
// Брайан Керниган и Денис Ритчи "The C programming language".
// swap: Обмен местами v[i] и v[j]
void swapCSIR(int* &v, double* &dr, int i, int j)
{
        int tempi;
		double tempr;

		// change v[i] <-> v[j]
		tempi = v[i];
		v[i] = v[j];
		v[j] = tempi;
		// change dr[i] <-> dr[j]
		tempr = dr[i];
		dr[i] = dr[j];
		dr[j] = tempr;

} // swap

// Вот алгоритм PivotList
int PivotListCSIR(int* &jptr, double* &altr, int first, int last) {
	// list==jptr and altr обрабатываемый список
	// first номер первого элемента
	// last номер последнего элемента

	int PivotValue = jptr[first];
	int PivotPoint = first;

	for (int index=(first+1); index<=last; index++) {
		if (jptr[index]<PivotValue) {
			PivotPoint++;
			swapCSIR(jptr, altr, PivotPoint, index);
		}
	}

	swapCSIR(jptr, altr, first, PivotPoint);

	return PivotPoint;
} // PivotList


// Быстрая сортировка Хоара.
// Запрограммировано с использованием ДЖ. Макконелл Анализ алгоритмов
// стр. 106.
void QuickSortCSIR(int* &jptr, double* &altr, int first, int last) {
	// list упорядочиваемый список элементов
	// first номер первого элемента в сортируемой части списка
	// last номер последнего элемента в сортируемой части списка

	int pivot;

	if (first < last) {
        pivot = PivotListCSIR(jptr, altr, first, last);
        QuickSortCSIR(jptr, altr, first, pivot-1);
		QuickSortCSIR(jptr, altr, pivot+1, last);
	}
} // QuickSortCSIR

// Неполное разложение Холецкого
// для положительно определённой симметричной
// матрицы А размером nxn.
// n - размерность матрицы СЛАУ
// Матрица val изменяется и в ней возвращается
// неполное разложение Холецкого IC(0):
// val == U верхняя треугольная матрица
// A = transpose(U)*U=L*transpose(L);
// L=transpose(U);
// пример:
// A = 
// 9.0   0.0   0.0   3.0   1.0   0.0   1.0    
// 0.0   11.0   2.0   1.0   0.0   0.0   2.0    
// 0.0   2.0   10.0   2.0   0.0   0.0   0.0    
// 3.0   1.0   2.0   9.0   1.0   0.0   0.0    
// 1.0   0.0   0.0   1.0   12.0   0.0   1.0    
// 0.0   0.0   0.0   0.0   0.0   8.0   0.0    
// 1.0   2.0   0.0   0.0   1.0   0.0   8.0 
//формат CSIR_ITL (верхний треугольник хранится построчно).
// val : 9.0 3.0 1.0 1.0 11.0 2.0 1.0 2.0 10.0 2.0 9.0 1.0 12.0 1.0 8.0 8.0 
// indx: 0 3 4 6 1 2 3 6 2 3 3 4 4 6 5 6 
// pntr: 0 4 8 10 12 14 15 16 
//--------------------------------------------
// Результат факторизации без заполнения:
// изменённый массив val (indx и pntr остались без изменений):
// val (factorization)= 
// 3.0
// 1.0
// 0.3333333333333333
// 0.3333333333333333
// 3.3166247903554
// 0.6030226891555273
// 0.30151134457776363
// 0.6030226891555273
// 3.1622776601683795
// 0.6324555320336759
// 2.932575659723036
// 0.34099716973523675
// 3.4472773213410837
// 0.2578524458667825
// 2.8284271247461903
// 2.7310738989293286
//-------------------------------------------
void IC0Factor_ITL(double* val, int* indx, int* pntr, int n)
{
  int d, g, h, i, j, k;
  double z;

  for (k = 0; k < n - 1; k++) {
    d = pntr[k];
    z = val[d] = sqrt(val[d]);

    for (i = d + 1; i < pntr[k+1]; i++)
      val[i] /= z;

    for (i = d + 1; i < pntr[k+1]; i++) {
      z = val[i];
      h = indx[i];
      g = i;

      for (j = pntr[h] ; j < pntr[h+1]; j++)
        for ( ; g < pntr[k+1] && indx[g+1] <= indx[j]; g++)
          if (indx[g] == indx[j])
             val[j] -= z * val[g];
    }
  }
  d = pntr[n-1];
  val[d] = sqrt(val[d]);
} // IC0Factor_ITL


// Модифицированное неполное разложение Холецкого.
void IC0FactorModify_ITL(double* val, int* indx, int* pntr, int n)
{
  int d, g, h, i, j, k;
  double z, accumulate_fill_in;

  for (k = 0; k < n - 1; k++) {
    d = pntr[k];
    z = val[d] = sqrt(val[d]);

    for (i = d + 1; i < pntr[k+1]; i++)
      val[i] /= z;

    for (i = d + 1; i < pntr[k+1]; i++) {
      z = val[i];
      h = indx[i];
      g = i;

      accumulate_fill_in = 0.0;

      for (j = pntr[h] ; j < pntr[h+1]; j++)
        for ( ; g < pntr[k+1] && indx[g+1] <= indx[j]; g++)
          if (indx[g] == indx[j]) // номера столбцов равны
             val[j] -= z * val[g];
	  else //index does not match accumulate the fill-in value
		  accumulate_fill_in += z * val[g];

	  val[pntr[h]] -= accumulate_fill_in;

    }
  }
  d = pntr[n-1];
  val[d] = sqrt(val[d]);
} // IC0FactorModify_ITL

// умножение симметричной положительно определённой  матрицы на вектор 
// используется формат хранения CSIR. В силу симметрии хранятся только поддиагональные элементы altr. 
// Разреженная SPD матрица A (adiag, altr, jptr, iptr) квадратная размером nxn.
// Число уравнений равно числу неизвестных и равно n.
// пример:
// A = 
// 9.0   0.0   0.0   3.0   1.0   0.0   1.0    
// 0.0   11.0   2.0   1.0   0.0   0.0   2.0    
// 0.0   2.0   10.0   2.0   0.0   0.0   0.0    
// 3.0   1.0   2.0   9.0   1.0   0.0   0.0    
// 1.0   0.0   0.0   1.0   12.0   0.0   1.0    
// 0.0   0.0   0.0   0.0   0.0   8.0   0.0    
// 1.0   2.0   0.0   0.0   1.0   0.0   8.0 
// ------------------------------------------
// формат CSIR:
// adiag: 9.0 11.0 10.0 9.0 12.0 8.0 8.0
// altr: 2.0 3.0 1.0 2.0 1.0 1.0 1.0 2.0 1.0
// jptr: 1 0 1 2 0 3 0 1 4
// iptr: 0 0 0 1 4 6 6 9
//-------------------------------------------
void  SPDMatrixCSIRByVector(double* adiag, double* altr, int* jptr, int* iptr, double* V, double* &tmp, int n)
{
	
	// вектор tmp индексируется начиная с нуля так же как и вектор V
	if (tmp == NULL)
	{
		printf("in SPDMatrixCSIRByVector tmp==NULL\n");
		getchar();
		tmp =new double[n];
		if (tmp==NULL) {
			printf("malloc: out of memory for vector tmp in SPDMatrixCSIRByVector\n"); // нехватка памяти
		    getchar();
		   // exit(0); // завершение программы
		}
	}
	
	
    int i,j; // Счётчики цикла
    

	//omp_set_num_threads(inumcore);

    //#pragma omp parallel for shared(tmp, V, adiag) private(i) schedule (guided)
	for (i=0; i<n; i++) tmp[i]=V[i]*adiag[i];

    // Последовательная секция
	/*
	for (i=0; i<n; i++) {
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
		    tmp[i] += V[jptr[j]]*altr[j];
		    tmp[jptr[j]] += V[i]*altr[j];
		}
	}
	*/

	// Часть первая из двух.
	//#pragma omp parallel for shared(tmp, V, altr, iptr, jptr,n) private(i,j) schedule (guided)
    for (i=0; i<n; i++) {
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
		    tmp[i] += V[jptr[j]]*altr[j];
		}
	}

	// Вторая часть не поддаётся распараллеливанию
    for (i=0; i<n; i++) {

		// эта часть не поддаётся распараллеливанию.
        //#pragma omp parallel for shared(tmp, V, altr, i, iptr, jptr) private(j)
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
			tmp[jptr[j]] += V[i]*altr[j];
		}
	}

} // SPDMatrixCSIRByVector


// Прямой ход по разреженной нижнетреугольной матрице L.
// симметричная положительно определённая матрица
// СЛАУ A представлена неполным разложением Холецкого 
// A~=L*transpose(L); L - нижняя треугольная матрица.
// L - хранится в следующем виде:
// 1. val - диагональные и поддиагональные элементы L.
// в столбцовом порядке. 
// 3. indx - соотвествующие номера строк для val, 
// 4. pntr - информация о начале следующего столбца.
// f - вектор правой части размером nodes.
// возвращает вектор z=inverse(L)*f;
// Вектор f портится.
// пример (CSIR - формат):
//  L = 
//  9.0   0.0   0.0   0.0   0.0   0.0   0.0   
//  0.0   11.0   0.0   0.0   0.0   0.0   0.0   
//  0.0   2.0   10.0   0.0   0.0   0.0   0.0   
//  3.0   1.0   2.0   9.0   0.0   0.0   0.0   
//  1.0   0.0   0.0   1.0   12.0   0.0   0.0   
//  0.0   0.0   0.0   0.0   0.0   8.0   0.0   
//  1.0   2.0   0.0   0.0   1.0   0.0   8.0   
// ------------------------------------------
// val: 9.0 3.0 1.0 1.0 11.0 2.0 1.0 2.0 10.0 2.0 9.0 1.0 12.0 1.0 8.0 8.0
// indx: 0 3 4 6 1 2 3 6 2 3 3 4 4 6 5 6
// pntr: 0 4 8 10 12 14 15 16
//-------------------------------------------
void inverseL_ITL(double* f, double* val, int* indx, int* pntr, double* &z, int n) {
	
	// Real **fbuf;
	// набор векторов fbuf нужен только в параллельной версии, в серийной версии можно просто передавать NULL.
	// количество векторов в fbuf равно количеству потоков.

    if (z == NULL)
	{
		double *z=new double[n];
		if (z==NULL) {
			printf("malloc: out of memory for vector z in inverse(L)*f \n"); // нехватка памяти
		    getchar();
		    //exit(0); // завершение программы
		}
	}

	//bool bserial=true;

	//if (bserial) {
		// однопоточное исполнение.

	    int i,j;
	    for (i=0; i<n; i++) {
            z[i]=f[i]/val[pntr[i]];
		    // обработка i-го столбца
		    // эта часть не поддаётся распараллеливанию.
            // из за зависимостей по данным для f.
		    for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			    f[indx[j]]-=z[i]*val[j];
		    }
		
	    }
		/*

	}
	else {
		// параллельное исполнение.
		// параллельный код требует правильного разрешения зависимостей по данным.

		// Нам понадобиться 
		// n=omp_get_num_threads(); 
		// дополнительных векторов.

		int nt=0;
#pragma omp parallel shared(nt)
		{
			// число нитей.
			nt=omp_get_num_threads();
		}

		int i,j;

		for (i=0; i<nt; i++) {
			for (j=0; j<n; j++) {
				fbuf[i][j]=0.0; // инициализация.
			}
		}

#pragma omp for  shared(n, z, val, f, fbuf, pntr, indx, fbuf) 
		for (i=0; i<n; i++) {
		   // Проблема в том что здесь используется f[i] а оно может быть обновлённым, что здесь не учитывается !!!
            z[i]=f[i]/val[pntr[i]];
		    // обработка i-го столбца
		    // эта часть не поддаётся распараллеливанию.
            // из за зависимостей по данным для f.
		    for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			    fbuf[omp_get_thread_num()][indx[j]]-=z[i]*val[j];
		    }
		
	    }

	}
	*/
}//inverseL_ITL

// Обратный ход по разреженной верхнетреугольной матрице U.
// симметричная положительно определённая матрица
// СЛАУ A представлена неполным разложением Холецкого 
// A~=L*transpose(L); L - нижняя треугольная матрица.
// U=transpose(L); - верхняя треугольная матрица.
// U - хранится в следующем виде:
// 1. val - диагональные и наддиагональные элементы U (в строковом формате).
// 2. indx - соотвествующие номера столбцов, 
// 3. pntr - информация о начале следующей строки для val.
// f - вектор правой части размером nodes.
// возвращает вектор z=inverse(U)*f;
// Вектор f портится.
// пример (CSIR_ITL - формат):
//  U=transpose(L) = 
//  9.0   0.0   0.0   3.0   1.0   0.0   1.0   
//  0.0   11.0   2.0   1.0   0.0   0.0   2.0   
//  0.0   0.0   10.0   2.0   0.0   0.0   0.0   
//  0.0   0.0   0.0   9.0   1.0   0.0   0.0   
//  0.0   0.0   0.0   0.0   12.0   0.0   1.0   
//  0.0   0.0   0.0   0.0   0.0   8.0   0.0   
//  0.0   0.0   0.0   0.0   0.0   0.0   8.0 
// ------------------------------------------
// val: 9.0 3.0 1.0 1.0 11.0 2.0 1.0 2.0 10.0 2.0 9.0 1.0 12.0 1.0 8.0 8.0
// indx: 0 3 4 6 1 2 3 6 2 3 3 4 4 6 5 6
// pntr: 0 4 8 10 12 14 15 16
//-------------------------------------------
void inverseU_ITL(double* f, double* val, int* indx, int* pntr, double* &z, int n) {

    if (z == NULL)
	{
		z = new double[n];
		if (z==NULL) {
			printf("malloc: out of memory for vector z in inverse(U)*f \n"); // нехватка памяти
		    getchar();
		    //exit(0); // завершение программы
		}
	}

	int i,j;

	for (i=(n-1); i>=0; i--) {
        
		// Обработка i-ой строки:
		// эта часть не поддаётся распараллеливанию.
		//#pragma omp parallel for shared(f, indx, z, val, i, pntr) private(j)
		for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			f[i]-=z[indx[j]]*val[j];
		}
		// делим на диагональный элемент:
        z[i]=f[i]/val[pntr[i]];
		
	}
	
}//inverseU_ITL

/* Метод сопряжённых градиентов Хестенса и Штифеля [1952]
*  Входные параметры:
*  M - разреженная матрица СЛАУ в формате SIMPLESPARSE,
*  dV - вектор правой части, 
*  x - начальное приближение к решению или NULL.
*  n - размерность СЛАУ Anxn.
*
*  Разреженная матрица M квадратная размером nxn.
*  Число уравнений равно числу неизвестных и равно n.
*  Матрица M предполагается положительно определённой и 
*  симметричной (диагональное преобладание присутствует).
*  Хранятся только ненулевые элементы. 
*  Количество итераций ограничено 1000, т.к. предполагается,
*  что если решение не сошлось за 1000 итераций то оно и не сойдётся.
*  Точность выхода по невязке задаётся в глобальной константе:
*  dterminatedTResudual.
*  В качестве предобуславливателя работает неполное разложение Холецкого:
*  K^(-1)==transpose(L)^(-1)*L^(-1); // обращённый предобуславливатель.
* 
*  Удалось частично распараллелить, так что 4 ядерный процессор загружен на 54%
*  К сожалению, некоторые операции не поддаются распараллеливанию.
*
*  Внимание. для того чтобы включить предобуславливатель нужно раскоментировать 
* коментарии с маркером М.
*/
void ICCG(double *adiag, double *altr, int *jptr, int *iptr,
		  double *val, int *indx, int *pntr,
		  double *dV, double* &x, int n, bool bprintmessage, int maxiter, double eps)
{

	// если bdistwall==true то решается СЛАУ для нахождения кратчайшего расстояния до стенки.

	double dsize=(double)(1.0*n); // вещественная длина вектора

	int k=0;
	int i; // счётчик
	double *ap=new double[n], *vcopy=new double[n], *f=new double[n];
	double *z=new double[n], *p=new double[n];
    double a, b, res, dbuf;
	

	double dold, dnew;

	// неполное разложение Холецкого:
	// Возвращает левый нижний треугольный сомножитель.
	if (bprintmessage) {
		printf("Incoplete Cholesky decomposition beginig...:\n");
	}
	//IC0Factor_ITL(val, indx, pntr, n);
	//M//IC0FactorModify_ITL(val, indx, pntr, n);
	if (bprintmessage) {
		printf("Incoplete Cholesky decomposition finish...:\n");//*/
	}


	// шаг 1.1
	//X0==
	if (x==NULL) {
        x=new double[n];
		for(i=0;i<n;i++) x[i] = 0.0;
	}

	// пороговое значение невязки
	double e = eps;
	
	// шаг 1.2
    // вычисление z - невязки начального приближения
	SPDMatrixCSIRByVector(adiag, altr, jptr, iptr, x, ap, n);
	for (i=0; i<n; i++) z[i]=dV[i]-ap[i];
	for (i=0; i<n; i++) vcopy[i]=z[i]; 
    //M//inverseL_ITL(vcopy, val, indx, pntr, f, n);
    for (i=0; i<n; i++) vcopy[i]=f[i];  
	//M//inverseU_ITL(vcopy, val, indx, pntr, f, n);
    dnew=Scal(n,z,f);
	//dnew=sqrt(dnew)/dsize; // среднеквадратическая эту трогат нельзя она завязана на вычислительный процесс.

	
	// терминаьная невязка всегда на точность аппроксимации меньше стартовой невязки.
	//if (e*dnew<e) e*=dnew;
	//double me=sqrt(dnew)/dsize;
	//if (e*me<e) e*=me;
	//dterminatedTResudual=e;
	
	
	
	if (fabs(dnew) > e) {
	//if (fabs(me) > e) {

		// шаг 1.3
	   for (i=0; i<n; i++)	p[i]=f[i];
	   res=1000.;
	   while ((fabs(res)>e) && (k<maxiter)) {
		   // шаг 2.1
		  SPDMatrixCSIRByVector(adiag, altr, jptr, iptr, p, ap, n);

		  // шаг 2.2
		  a=dnew/Scal(n,p,ap);// шаговый множитель
		  // шаг 2.3 и 2.4
          //#pragma omp parallel for shared(x,z,p,ap,a,n) private(i) schedule (guided)
		  for (i=0; i<n; i++) {
		      x[i]+=a*p[i]; // очередное приближение 
              z[i]-=a*ap[i];// невязка k+1-го приближения
		  }
          //#pragma omp parallel for shared(vcopy,z,n) private(i) schedule (guided)
          for (i=0; i<n; i++) vcopy[i]=z[i];  
          //M//inverseL_ITL(vcopy, val, indx, pntr, f, n);
          //#pragma omp parallel for shared(vcopy,f,n) private(i) schedule (guided)
          for (i=0; i<n; i++) vcopy[i]=f[i]; 
	      //M//inverseU_ITL(vcopy, val, indx, pntr, f, n);
		  // шаг 2.5
          dold=dnew;
		  dnew=Scal(n,z,f);

		  // res=dnew; // исходный код.
		  res=sqrt(dnew)/dsize;
		  if (bprintmessage) {
			  if (k%10==0) {
				  printf("iter residual\n");
			  }
		      printf(" %d %e\n", k, res);
		  }
		  // шаг 3.1
		  b=dnew/dold;
		  // шаг 3.2

          //#pragma omp parallel for shared(p,f,b,n) private(i,dbuf) schedule (guided)
		  for (i=0; i<n; i++) {
			 dbuf=p[i];
		     p[i]=f[i]+b*dbuf; // новое направление минимизации
		  }
          // шаг 3.3
		  k++;
	   } // while

	   // В этот файл пишется статистика об успешности решения СЛАУ:
       //fprintf(fp_statistic_convergence, " ICCG finish residual=%e \n",res);
       //fprintf(fp_statistic_convergence,"%e ",res); // нет смысла печатать конечную невязку так как она задана пользователем

	   // Освобождение памяти
        delete ap; delete vcopy;
		delete z; delete p; delete f;  
	}
	else {
		// Освобождение памяти
		//printf("ICCG inform: residual of the initial approximation is too small...\n");
		
		//fprintf(fp_statistic_convergence, " ICCG no solve start residual < %e \n",e);
		//fprintf(fp_statistic_convergence,"%e ",e); // нет смысла печатать конечную невязку так как она задана пользователем
		delete ap; delete vcopy;
		delete z; delete p; delete f;		
	}

}
	

// Метод Ван Дер Ворста Bi-CGStabCRS
// работает для возможно несимметричных вещественных матриц.
// Несимметричная матрица СЛАУ передаётся в CRS формате
// A (val, col_ind, row_ptr).
// Метод является комбинацией методов BiCG и GMRES(1). 
void Bi_CGStabCRS(int n, double *val, int* col_ind, int* row_ptr, double *dV, double* &dX0, double* &dxret, int maxit,
				  double dterminatedTResudual, int ibasenorma, double *residual_history)
{

	// dxret - возвращаемое решение !!!

	int iflag=1, icount=0;
	double delta0, deltai;
	double bet, roi;
	double roim1=1.0, al=1.0, wi=1.0;
	double *ri, *roc, *s, *t, *vi, *pi, *dx, *dax;
	double epsilon=dterminatedTResudual;  // точность вычисления
    //printf("%e\n",epsilon); // контрольное значение невязки по которой осуществляется выход из итерационного процесса.
    //getchar();
	int i;

	ri=new double[n]; roc=new double[n]; s=new double[n]; t=new double[n];
	vi=new double[n]; pi=new double[n]; dx=new double[n]; dax=new double[n];

	for (i=0; i<n; i++) {
		s[i]=0.0;
		t[i]=0.0;
		vi[i]=0.0;
		pi[i]=0.0;
	}

    // начальное приближение
    // X0 ==
    // под X0 понимается вектор поля температур к примеру.
    if (dX0==NULL) {
	   dX0=new double[n];
	   for (i=0; i<n; i++) {
		   dx[i]=0.0;
		   dX0[i]=0.0;
	   }
    }
    else {
	   for (i=0; i<n; i++) dx[i]=dX0[i];
    }

    MatrixCRSByVector(n,val,col_ind,row_ptr,dx,dax); // результат занесён в  dax
	for (i=0; i<n; i++) {
		ri[i]=dV[i]-dax[i];
		roc[i]=ri[i];
	}
	 switch (ibasenorma)
	{
            case 1 : delta0=NormaV(n, ri); break; // евклидова
            case 2 : delta0=NormaSupV(n, ri); break; // кубическая норма
            case 3 : delta0=NormaSup2V(n, ri); break; // октаэдрическая норма
	 }
	// Если решение сразу хорошее то не считать:
	if (fabs(delta0)<epsilon) iflag=0; 

	while ( iflag != 0 && icount < maxit) {

		icount++;

		roi=Scal(n,roc,ri);
		bet=(roi/roim1)*(al/wi);
		#pragma omp parallel for shared(n,pi,ri,vi,wi,bet) private(i) schedule (guided)
		for (i=0; i<n; i++) {
			pi[i]=ri[i]+(pi[i]-vi[i]*wi)*bet;
		}
	
		MatrixCRSByVector(n,val,col_ind,row_ptr,pi,vi);
		al=roi/Scal(n,roc,vi);
		#pragma omp parallel for shared(n,s,ri,vi,al) private(i) schedule (guided)
        for (i=0; i<n; i++) {
			s[i]=ri[i]-al*vi[i];
		}
		
        MatrixCRSByVector(n,val,col_ind,row_ptr,s,t);
		wi=Scal(n,t,s)/Scal(n,t,t);
		#pragma omp parallel for shared(n,dx,al,pi,wi,s,ri,t) private(i) schedule (guided)
		for (i=0; i<n; i++) {
			dx[i]+=al*pi[i]+wi*s[i];
			ri[i]=s[i]-wi*t[i];
		}
		// здесь реализованы все три нормы
         // вообще говоря они все эквивалентны
         switch (ibasenorma)
		 {
            case 1 : deltai=NormaV(n, ri); break; // евклидова
            case 2 : deltai=NormaSupV(n, ri); break; // кубическая норма
            case 3 : deltai=NormaSup2V(n, ri); break; // октаэдрическая норма
	     }
		// печать невязки на консоль
        //if ((icount % 10) == 0)  printf("iter  residual\n");
        //printf("%d %e \n",icount,deltai);
		 residual_history[icount]=deltai;
        // информация о сходимости печатается в файл log.txt связанный с маркером файла fp_log.
        //fprintf(fp_log,"%d %e \n",icount,deltai);
        //if ((icount % 100)== 0) getchar();

		if (deltai <epsilon) iflag=0; // конец вычисления
		else roim1=roi;
	}

    // освобождение памяти
	delete ri; delete roc; delete s; delete t;
	delete vi; delete pi; delete dax;

	for (i=0; i<n; i++) {
		dX0[i]=dx[i];
		dxret[i]=dx[i];
	}

	delete dx; 


} // Bi_CGStabCRS


const int CGalg=0;
const int ICCGalg=1;

// передаваемый параметр отвечающий за алгоритм.
const int CongruateGradient=0; // метод сопряжённых градиентов.
const int BiCGStab=1; // алгоритм Ван дер Ворста

// метод сопряжённых градиентов для давления и поправки давления.
EXPORT void cg_pressure(double eps, 
							int imaxiter,
							int imaxnumbernode_loc,
							int icolx, int icoly,
							bool bipifix_loc, 
							int ipifix_loc,
							int ibasenorma_loc,
							MatrixCoef * &mp_loc,
							TmyNode * &mapPT_loc,
							double * &P_loc,
							double * &db_loc,
							double *  &myrP_loc,
							double * &residual_history, // история изменеия невязок
							int itypesorter_loc,
							int * &pointerlist_loc,
							int * &pointerlistrevers_loc,
							bool bconstr_loc,
							int ialg_loc)
{

	// Внимание ! при первом запуске параметр bconstr_loc обязательно должен быть равен false.
	// память под массивы pointerlist_loc, pointerlistrevers_loc должна быть выделена в Delphi заранее.
	// Здесь никаких операций с памятью для этих массивов производится не будет.

	int ialg=ICCGalg;//ICCGalg; //CGalg; 

	// Симметризация СЛАУ.
	bool *bdirichlet=new bool[imaxnumbernode_loc+1];
	for (int k1=0; k1<=imaxnumbernode_loc; k1++) {
		bdirichlet[k1]=false; // пока это не узел с условием Дирихле.
	}
	double eps0=1.0e-30;
	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// внутренний узел
			int ipi=mapPT_loc[k1].ipi;
			if ((fabs(mp_loc[ipi].dae)<eps0) && (fabs(mp_loc[ipi].daw)<eps0) && (fabs(mp_loc[ipi].dan)<eps0) && (fabs(mp_loc[ipi].das)<eps0)) {
				bdirichlet[ipi]=true;
			}
		}
	}
	// правка db_loc и коэффициентов матрицы СЛАУ.
	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// внутренний узел
			int ipi=mapPT_loc[k1].ipi;
			if (!bdirichlet[ipi]) {
				// Не условие Дирихле в узле.
				int iei=mapPT_loc[k1].iei;
				if (bdirichlet[iei]) {
					db_loc[ipi]+=mp_loc[ipi].dae*db_loc[iei]/mp_loc[iei].dap;
					mp_loc[ipi].dae=0.0;
				}
				int iwi=mapPT_loc[k1].iwi;
				if (bdirichlet[iwi]) {
					db_loc[ipi]+=mp_loc[ipi].daw*db_loc[iwi]/mp_loc[iwi].dap;
					mp_loc[ipi].daw=0.0;
				}
				int ini=mapPT_loc[k1].ini;
				if (bdirichlet[ini]) {
					db_loc[ipi]+=mp_loc[ipi].dan*db_loc[ini]/mp_loc[ini].dap;
					mp_loc[ipi].dan=0.0;
				}
				int isi=mapPT_loc[k1].isi;
				if (bdirichlet[isi]) {
					db_loc[ipi]+=mp_loc[ipi].das*db_loc[isi]/mp_loc[isi].dap;
					mp_loc[ipi].das=0.0;
				}
			}
		}
	}
	// Конец симметризации СЛАУ.

	delete bdirichlet;

	// myrP - невязка.
	int k=0; // количество элементов в разреженной матрице.
	int il=0; // количество уравнений которое требуется решить
	

	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// внутренний узел
				il++; 
				int ipi=mapPT_loc[k1].ipi;
				if (fabs(mp_loc[ipi].dae)>eps0) k++;
				if (fabs(mp_loc[ipi].daw)>eps0) k++;
				if (fabs(mp_loc[ipi].dan)>eps0) k++;
				if (fabs(mp_loc[ipi].das)>eps0) k++;
				if (fabs(mp_loc[ipi].dap)>eps0) k++;
			}
	}

	TmyNonZeroElemMatrix *nze=new TmyNonZeroElemMatrix[k+1]; // ненулевые элементы которые потом придётся сортировать по строкам
	
	// выделение памяти под вектор правой части
	double *dV1=new double[il];
	 // выделение памяти под результат вычисления
	double *dx=new double[il];

   // обнуление матрицы dА
   // здесь было от 1 до iNelem
   for(int  k1=0; k1<=k; k1++) 
   {
      // инициализация
      // массива для хранения
      // ненулевых элементов
      nze[k1].i=0;
      nze[k1].j=0;
      nze[k1].aij=0.0;
      nze[k1].key=0;
   }

   

   for (int k1=0; k1<=il-1; k1++)
   {
	  dV1[k1]=0.0;  // инициализация вектора правой части
   }

   if (!(bconstr_loc)) {

   
#if MYDEBUG
	   int imin_=10000000, imax=-500;
#endif

   // прямое преобразование
	   // Память лучше выделять в Delphi.
   //pointerlist=new int[il];
   for (int i1=0; i1<=(icolx*icoly-1); i1++) {
       pointerlist_loc[i1]=-1; // инициализация !!!
   }

   int j1=0;
   for (int i1=1; i1<=imaxnumbernode_loc; i1++) 
   {
      if (mapPT_loc[i1].itype==1)
	  {
         // список номеров уравнений
         pointerlist_loc[j1]=(mapPT_loc[i1].i-1)+(mapPT_loc[i1].j-1)*icolx; // номер для U
		 #if MYDEBUG
	        if (pointerlist_loc[j1]<imin_) imin_=pointerlist_loc[j1];
			if (pointerlist_loc[j1]>imax_) imax_=pointerlist_loc[j1];
         #endif
         j1++; // переход к следующей непустой точке
	  }
   }

   #if MYDEBUG
   imin_;
   imax_;
#endif
   

   // обратное преобразование
   //pointerlistrevers=new int[icolx*icoly]; // выделение памяти
   
   // инициализация
   // номер -1 соответствует hollow point
   for (int i1=0; i1<=(icolx*icoly-1); i1++)  pointerlistrevers_loc[i1]=-1;
   for (int i1=0; i1<=(icolx*icoly-1); i1++) 
   {
      // нужно найти в pointerlist[j1] уникальный номер i1
      for (int j1=0; j1<=il-1; j1++)
	  {
         // нахождение соответствия
         if (pointerlist_loc[j1]==i1) 
		 {
            // по номеру для U даёт номер для x
            // для некоторых соответствующих несуществует
            // и тогда номер заменяется условным значением -1
            pointerlistrevers_loc[i1]=j1;
		 }
	  }
   }


   }
   // инициализация вектора
   int k1=0;
   /*
   
   for (int i1=1; i1<=icolx; i1++)
   {
      for (int j1=1; j1<=icoly; j1++)
	  {
         // нужно ли уравнение для этой точки ?
         int j2=i1+(j1-1)*icolx; // нумерация начинается с 1
         // принадлежит ли эта точка к списку зачисленных ?
         for (int i2=0; i2<=il-1; i2++) 
		 {
            if (j2 == (pointerlist_loc[i2]+1)) 
			{
               // в U нумерация начинается с 1
               dx[k1]=P_loc[j2]; // инициализация вектора решения
               k1++;
			}
         }
      }
   }*/
   // копирование полученного решения обратно в U
   // Вариант 1:
   /*
   for (int i1=0; i1<=il-1; i1++)
   {
      dx[i1] = P_loc[pointerlist_loc[i1]+1]; // вектор с начальным приближением;
	  //dV1[i1] = db_loc[pointerlist_loc[i1]+1]; // инициализируется при сборке матрицы.
   }
   */
   // Вариант 2:
   for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// внутренний узел 
				int ipi=mapPT_loc[k1].ipi;
				dx[pointerlistrevers_loc[ipi-1]]=P_loc[ipi];
			}
   }
			

   int k2=0; // счётчик ненулевых элементов // Начинается обязательно с нуля !!!
   // k - это просто индекс, нумерация начиная с 1 нужна для пирамидальной сортировки

   // здесь происходит обращение к элементам nze от 0 до iNelem-1

   // Заполнение матрицы dА с учётом её разреженности и
   // вектора правой части dV
   for (k1=1; k1<=imaxnumbernode_loc; k1++)
   {
      if (mapPT_loc[k1].itype==1) {
            // внутренний узел

           int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // север
           int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // юг
           int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // запад
           int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // восток
           int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // текущая точка

           int rini=pointerlistrevers_loc[ini-1];
           int risi=pointerlistrevers_loc[isi-1];
           int riwi=pointerlistrevers_loc[iwi-1];
           int riei=pointerlistrevers_loc[iei-1];
           int ripi=pointerlistrevers_loc[ipi-1];


        

    
			double dmul=1.0/mp_loc[ipi].dap; // диагональное предъобуславливание
            nze[k2].i=ripi; nze[k2].j=ripi; nze[k2].aij=1.0; nze[k2].key=nze[k2].i;  k2++;
			if (fabs(mp_loc[ipi].dae)>eps0) { nze[k2].i=ripi; nze[k2].j=riei; nze[k2].aij= - dmul*mp_loc[ipi].dae; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].daw)>eps0) { nze[k2].i=ripi; nze[k2].j=riwi; nze[k2].aij= - dmul*mp_loc[ipi].daw; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].dan)>eps0) { nze[k2].i=ripi; nze[k2].j=rini; nze[k2].aij= - dmul*mp_loc[ipi].dan; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].das)>eps0) { nze[k2].i=ripi; nze[k2].j=risi; nze[k2].aij= - dmul*mp_loc[ipi].das; nze[k2].key=nze[k2].i; k2++;}
            dV1[ripi]= dmul*db_loc[ipi];
		}
	}

   for (int k1=k; k1>=1; k1--) nze[k1]=nze[k1-1]; // сдвиг вправо на 1.
   // нумерация начинается с 1, а при заполнении nze нумерация начиналась с нуля
   /*
   if (itypesorter_loc == 1)
   {
      QuickSort(nze,1,k); // быстрая сортировка Хоара
   }
    else
	{
      // itypesorter = 2
      HeapSort(nze,k); // пирамидальная сортировка
    }
   */

   

   // Сопряжённые градиенты Хестенса и Штифеля
   if (ialg==ICCGalg) {
	   // ICCG:
       
	  

	   // матрица СЛАУ
	   // в формате CSIR:
	   // Хранится верхний треугольник симметричной разреженной матрицы.
	   double *adiag=NULL, *altr=NULL;
	   int *jptr=NULL, *iptr=NULL;

	   

	    adiag = new double[il]; // диагональные элементы
		int nz=(int)((k-il)/2);
		//int nz=(int)(k/2); // количество элементов данное с запасом
		altr = new double[nz]; // поддиагональные элементы
		jptr = new int[nz]; // номера столцов для нижнего треугольника
		iptr = new int[il+1]; // указатели на следующую строку

		// инициализация
		for (int k1=0; k1<il; k1++) adiag[k1]=0.0;
        for (int k1=0; k1<(nz); k1++) {
		   altr[k1]=0.0;
		   jptr[k1]=0;
	    }
        for (int k1=0; k1<=il; k1++) {
		    //iptr[k]=k; // присваиваем количество ненулевых элементов плюс 1 с учётом того что нумерация массива начинается с 0
			iptr[k1]=nz; // debug
	    }



        int ik=0;
		int imin_=1;
		bool bvisit=false; // сбрасывается на FALSE только при переходе к новой строке.
		int ioldstr=0;


		for (int k1=0; k1<=k-1; k1++)
        {
			if (nze[k1+1].i>ioldstr) {
				ioldstr=nze[k1+1].i;
				bvisit=false;
			}

			if (nze[k1+1].j==nze[k1+1].i) {
				// диагональный.
				adiag[nze[k1+1].j]=nze[k1+1].aij;
			}
			else if (nze[k1+1].j<nze[k1+1].i) 
			{
				if (ik<nz) {
                   altr[ik]=nze[k1+1].aij;
				   jptr[ik]=nze[k1+1].j;
				}
				bvisit=true;
			}
			imin_=imin(iptr[nze[k1+1].i],ik);
			iptr[nze[k1+1].i]=imin_;
			if (imin_==0) for (int k3=0; k3<nze[k1+1].i; k3++) iptr[k3]=0;	
			if (bvisit) { 
				ik++;
				bvisit=false;
			}


		}

		for (int k3=0; k3<il; k3++) QuickSortCSIR(jptr, altr, iptr[k3], iptr[k3+1]-1);

		// предобуславливатель:
	   // неполным разложением Холесского в
	   // формате CSIR_ITL:
	   double *val=NULL;
	   int *indx=NULL, *pntr=NULL;

		// поддиагональные элементы в altr хранятся построчно
		nz=(int)((k-il)/2 + il); // число ненулевых элементов
		val = new double[nz]; // диагональные элементы и наддиагональные элементы
		indx = new int[nz]; // номера столцов для нижнего треугольника
		pntr = new int[il+1]; // указатели на следующую строку

		
		// инициализация
        for (int k1=0; k1<(nz); k1++) {
		   val[k1]=0.0;
		   indx[k1]=0;
	    }
        for (int k1=0; k1<=il; k1++) {
		    pntr[k1]=nz; // присваиваем количество ненулевых элементов плюс 1 с учётом того что нумерация массива начинается с 0
	    }

        

		ik=0; // счётчик ненулевых поддиагональных элементов СЛАУ
		for (int k1=0; k1<=k-1; k1++)
        {
			if (nze[k1+1].j>=nze[k1+1].i) {
				val[ik]=nze[k1+1].aij; // ненулевое значение
			    indx[ik]=nze[k1+1].j; // номер столбца

				pntr[nze[k1+1].i]=imin(pntr[nze[k1+1].i],ik);
			    ik++;
			}

		}
		/*
		for (int k1=0; k1<(nz); k1++) {
			val[k1];
			indx[k1];
		}
		for (int k1=0; k1<=il; k1++) {
		    pntr[k1];
	    }
		*/

		for (int k1=0; k1<il; k1++) QuickSortCSIR(indx, val, pntr[k1], pntr[k1+1]-1);

		/*
		for (int k1=0; k1<(nz); k1++) {
			val[k1];
			indx[k1];
		}
		for (int k1=0; k1<=il; k1++) {
		    pntr[k1];
	    }
		*/

		// Всё готово.
		bool bmessage=false;
		ICCG(adiag, altr, jptr, iptr, val, indx, pntr, dV1, dx, il, bmessage, imaxiter, eps);

		delete adiag;
		delete altr;
		delete jptr;
		delete iptr;

		delete val;
		delete indx;
		delete pntr;

   }
   else {

	   double *val=new double[k]; // ненулевые элементы матрицы СЛАУ
	   int *col_ind=new int[k]; // соответствующие ненулевым элементам номера столбцов
	   int *row_ptr=new int[il+1]; // информация о том где начинается следующая строка


	   // обнуление матрицы dА
       for(int  k1=0; k1<=k-1; k1++) 
       {
           // инициализация
           val[k1]=0.0;
           col_ind[k1]=0;
       }

       // т.к. нумерация начинается с нуля, то и максимальное значение (iNelem+1)-1,
       // где -1 для учёта элемента с номером ноль, т.к. нумерация массива начинается с 0.
       for (int k1=0; k1<=il; k1++) row_ptr[k1]=k; // инициализация указателей на следующую строку


	   // формирование матрицы разреженной матрицы СЛАУ
       //  в формате CRS (сортировка нужна для упорядочивания элементов по строкам).
       for (int k1=0; k1<=k-1; k1++)
       {
            // для nze индекс k+1 т.к. нумерация этого массива начиналась с 1.
            // это требование алгоритма пирамидальной сортировки.
            val[k1]=nze[k1+1].aij;
            col_ind[k1]=nze[k1+1].j;
            row_ptr[nze[k1+1].i]=imin(k1, row_ptr[nze[k1+1].i]);
       }

      // Решение СЛАУ
      // методом Сопряжённых Градиентов
      // Хестенса и Штифеля
      // на основе технологии хранения и обработки разреженных матриц CRS
      // В зависимости от значения параметра bgt применяется или не применяется трансформация Гаусса.
	  double* dinit=new double[il];
	    // копирование полученного решения обратно в U
	  // Вариант 1 :
	  /*
      for (int i1=0; i1<=il-1; i1++)
      {
         dinit[i1] = P_loc[pointerlist_loc[i1]+1]; // вектор с начальным приближением;
      }*/
	  // Вариант 2 :
	  for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// внутренний узел 
			int ipi=mapPT_loc[k1].ipi;
			dinit[pointerlistrevers_loc[ipi-1]]=P_loc[ipi];
		}
      }
      bool bmessage=false;
      bool bgt=false;
	  switch (ialg_loc) {
	  case CongruateGradient : // Метод Сопряжённых Градиентов.
		  SoprGradCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, residual_history, bmessage, imaxiter, bgt, eps, ibasenorma_loc);  
		  break;
	  case BiCGStab : // Алгоритм Хенрика Ван Дер Ворста
		  Bi_CGStabCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, imaxiter, eps, ibasenorma_loc, residual_history);
		  break;
	  default : // по умолчанию алгоритм Хенрика Ван Дер Ворста
		        Bi_CGStabCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, imaxiter, eps, ibasenorma_loc, residual_history);
		        break;
	  }
	 
	  // Освобождение оперативной памяти.
	  delete val;
	  delete col_ind;
	  delete row_ptr;
	  delete dinit;
   }
   

   // копирование полученного решения обратно в U
   // Вариант 1:
   /*
   for (int i1=0; i1<=il-1; i1++)
   {
      P_loc[pointerlist_loc[i1]+1] = dx[i1]; // вектор с решением задачи;
   }*/
   // Вариант 2:
   for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// внутренний узел 
			int ipi=mapPT_loc[k1].ipi;
			P_loc[ipi]=dx[pointerlistrevers_loc[ipi-1]];
		}
   }
			 

	delete nze;
	
	delete dV1;
	delete dx;

	//delete pointerlist; // память выделяется в Delphi.
	//delete pointerlistrevers; // память выделяется в Delphi.
	

}