// mgf.cpp: определяет экспортированные функции для приложения DLL.
// mgf - multi grid fedorenko.
// используются параллельные вычисления на основе OpenMP.


/* Данная dll предназначена для ускорения вычислений в программе DavisTestDelphi.
*/


#include "stdafx.h"
#include <math.h>
#include <omp.h>


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

// возвращает модуль вещественного числа.
/* уже определена в библиотеке math.h
double fabs(double r) {
	if (r<0.0) {
		return (-r);
	}
	else
	{
		return r;
	}
}
*/

// возвращает максимальное из двух целых чисел.
int imax(int ia, int ib) {
	if (ia>ib) {
		return ia;
	}
	else
	{
		return ib;
	}
}

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

// евклидова норма внутренности универсальной полевой величины U
// возвращает корень квадратный из суммы квадратов компонентов вектора невязки.
// для внутренней части расчётной области.
// евклидова норма.
double myEvklidNorma(double *U, int imaxnumbernode, 
				   TmyNode *mapPT)
{
   // инициализация
   double dsum=0.0;
  
#pragma omp parallel 
   {

#pragma omp for reduction (+:dsum)
   for (int k=1; k<=imaxnumbernode; k++) 
   {
     
         if (mapPT[k].itype != 0) 
		 {
            // внутренний узел
			double rbuf;
            //rbuf = U[mapPT[k].i+(mapPT[k].j-1)*icolx]; // помещаем во временное хранилище
			rbuf = U[mapPT[k].ipi]; // помещаем во временное хранилище
            // здесь возможно переполнение
            dsum +=  rbuf*rbuf/imaxnumbernode;
		 }
    
   }

   }

   return sqrt(dsum);  // возвращает норму внутренности универсальной величины U
} // норма внутренности универсальной полевой величины

// норма внутренности универсальной полевой величины U по аналогии с
// пространством С
// возвращает максимальное значение невязки.
// кубическая норма.
double mySupNorma(double *U, int imaxnumbernode,
				   TmyNode *mapPT) 
{
	double r=0.0;

#pragma omp parallel 
	{
	
#pragma omp master
		r=0.0;


#pragma omp barrier
#pragma omp for
	for (int k=1; k<=imaxnumbernode; k++) {
		if (mapPT[k].itype!=0) {
			//r=fmax(r,fabs(U[mapPT[k].i+(mapPT[k].j-1)*icolx]));
#pragma omp critical
            r=fmax(r,fabs(U[mapPT[k].ipi]));
		}
	}

	}
   

	return r; // возвращает норму внутренности универсальной величины U
} // норма внутренности универсальной полевой величины

// октаэдрическая норма внутренности универсальной полевой величины U
// возвращает сумму модулей компонент вектора невязки.
// октаэдрическая норма.
double mySup2Norma(double *U, int imaxnumbernode,
				   TmyNode *mapPT) 
{
	double r=0.0;

	#pragma omp parallel 
   {

#pragma omp for reduction (+:r)
	for (int k=1; k<=imaxnumbernode; k++) {

		if (mapPT[k].itype!=0) {

			//r+=fabs(U[mapPT[k].i+(mapPT[k].j-1)*icolx]);
            r+=fabs(U[mapPT[k].ipi]);
		}
	}

   }
	return r; // возвращает норму внутренности универсальной величины U
} // норма внутренности универсальной полевой величины

EXPORT void seidel_pressure_omp(double eps, 
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
							int g_nNumberOfThreads,
							double URF)
{

	// URF - параметр верхней релаксации.
	// myrP_loc - невязка,
	// db_loc - правая часть,
	// P_loc - искомое распределение.

	omp_set_num_threads(g_nNumberOfThreads); // устанавливаем количество потоков.


	// теперь, когда коэффициенты вычислены,
	// можно приступить к решению.
	double deviation=1.0e30; // очень большое число
	int k=1; // номер итерации

	while ((deviation > eps) && (k<=imaxiter)) 
	{
#pragma omp for   
		for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// внутренний узел

				// координаты узлов для поправки давления
				// используется обыкновенная сетка
				//int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // север
				//int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // юг
				//int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // запад
				//int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // восток
				//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // текущая точка.
				int ini=mapPT_loc[k1].ini;
				int isi=mapPT_loc[k1].isi;
				int iei=mapPT_loc[k1].iei;
				int iwi=mapPT_loc[k1].iwi;
				int ipi=mapPT_loc[k1].ipi;

				// здесь может быть деление на ноль, его надо исключить
				if (fabs(mp_loc[ipi].dap) > 1.0e-30) {
					// здесь гарантированно нет деления на ноль
                    if ((bipifix_loc) && (ipi==ipifix_loc)) {
						P_loc[ipifix_loc]=0.0; // фиксируем уровень
					}
					else
					{
						P_loc[ipi]=P_loc[ipi]+URF*((mp_loc[ipi].dae*P_loc[iei]+mp_loc[ipi].daw*P_loc[iwi]+mp_loc[ipi].dan*P_loc[ini]+mp_loc[ipi].das*P_loc[isi]+db_loc[ipi])/mp_loc[ipi].dap-P_loc[ipi]);
					}
				}
				
			}
		} // проход по внутренним точкам.

		// для существенного ускорения
		// времени счёта невязка будет вычисляться 
		// каждую 0.5*(inx+iny) итерацию солвера Гауса-Зейделя.
		// Время вычисления невязки равно времени одной итерации Г-З.
		if (((2*k) % (icolx + icoly)) == 0) {
			// отслеживаем невязку
			#pragma omp for   
			for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
				if (mapPT_loc[k1].itype==1) {
					// внутренний узел

					// используется обновлённая сетка.
					//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // текущая точка.
					int ipi=mapPT_loc[k1].ipi;
					if ((bipifix_loc) && (ipi == ipifix_loc)) {
						myrP_loc[ipifix_loc]=0.0; // одно уравнение выполняется точно
					}
					else 
					{
                        //int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // север
				        //int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // юг
				        //int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // запад
				        //int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // восток
						int ini=mapPT_loc[k1].ini;
						int isi=mapPT_loc[k1].isi;
						int iwi=mapPT_loc[k1].iwi;
						int iei=mapPT_loc[k1].iei; 
						myrP_loc[ipi]=mp_loc[ipi].dae*P_loc[iei];
						myrP_loc[ipi]+=mp_loc[ipi].daw*P_loc[iwi];
						myrP_loc[ipi]+=mp_loc[ipi].dan*P_loc[ini];
						myrP_loc[ipi]+=mp_loc[ipi].das*P_loc[isi];
						myrP_loc[ipi]+=db_loc[ipi] - mp_loc[ipi].dap*P_loc[ipi];

					}
				}
			}

            // проверка насколько точно выполняется дискретный аналог
		    switch (ibasenorma_loc) {
		    case 1 : // евклидова норма
			     deviation=myEvklidNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 2 : // кубическая
			     deviation=mySupNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 3 : // октаэдрическая
			     deviation=mySup2Norma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    }

		}

		k++; // переход к следующей итерации

	}
}

EXPORT void seidel_uds_omp(double eps, 
							int imaxiter,
							int imaxnumbernode_loc,
							int icolx, int icoly,
							int ibasenorma_loc,
							MatrixCoef * &mp_loc,
							TmyNode * &mapPT_loc,
							double * &UDS_loc,
							double * &db_loc,
							double *  &myrP_loc,
							bool * &bQneiC_loc,
							bool * &bzerocurrentorzerodiff_loc,
							int g_nNumberOfThreads,
							int icurentuds)
{

	// myrUDS - невязка.
	// icurentuds - номер UDS  1..4.
	// bQneiC_loc - информация для данной точки на данной границе о 
	// граничном условии продолжения уравнения вплоть до самой границе.
	// формат хранения всего 20 возможных границ и всего 4 uds.
	// Хранение информации осущестляется линейно 1..20, 1..20, 1..20, 1..20.
	// bzerocurrentorzerodiff_loc - информация о том поставлено ли в данной точке
	// данной границы условия нормальная компонента полного тока равна нулю и 
	// нормальная компонента диффузионного тока равна нулю.

	int k=0; // номер начальной итерации.
	double residualuds=1.0; // начальное значение невязки.
	double URF=1.0;

	omp_set_num_threads(g_nNumberOfThreads); // устанавливаем количество потоков.

	while ((residualuds > eps) && (k < imaxiter))
	{

		#pragma omp for  
		for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// внутренний узел

				// координаты узлов для поправки давления
				// используется обыкновенная сетка
				//int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // север
				//int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // юг
				//int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // запад
				//int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // восток
				//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // текущая точка.
				//int ini=mapPT_loc[k1].ini;
				//int isi=mapPT_loc[k1].isi;
				//int iei=mapPT_loc[k1].iei;
				//int iwi=mapPT_loc[k1].iwi;
				//int ipi=mapPT_loc[k1].ipi;

				int ipi=k1;
				int ini=k1+icolx;
				int isi=k1-icolx;
				int iwi=k1-1;
				int iei=k1+1;

				UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].dan*UDS_loc[ini]+
												mp_loc[ipi].das*UDS_loc[isi]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
				
			}
			else if (mapPT_loc[k1].itype==2) {
				// граничный узел.
				int ipi, ini, isi, iei, iwi;

				if (mapPT_loc[k1].iugol==0) {
					if (bQneiC_loc[mapPT_loc[k1].iboundary+(icurentuds-1)*20-1]) {
						// определяем внутреннюю нормаль.
						switch (mapPT_loc[k1].chnormal) {
			               case 'N' : // север (нижняя стенка)
							          ipi=k1;
									  ini=k1+icolx;
									  iwi=k1-1;
									  iei=k1+1;

                                      UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].dan*UDS_loc[ini]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
				                      break;
						   case 'S' : // юг (верхняя стенка)
                                      ipi=k1;
									  isi=k1-icolx;
									  iwi=k1-1;
									  iei=k1+1;

									  UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].das*UDS_loc[isi]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							          break;
						   case 'W' : // запад (правая стенка)
							          ipi=k1;
									  ini=k1+icolx;
									  iwi=k1-1;
									  isi=k1-icolx;

									  UDS_loc[ipi]=UDS_loc[ipi]+URF*((
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].dan*UDS_loc[ini]+
												mp_loc[ipi].das*UDS_loc[isi]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
							          break;
						   case 'E' : // восток (левая стенка)
							          int ipi=k1;
				                      int ini=k1+icolx;
				                      int isi=k1-icolx;
				                      int iei=k1+1; 

                                      UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
												mp_loc[ipi].dan*UDS_loc[ini]+
												mp_loc[ipi].das*UDS_loc[isi]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							          break;
					    }
					} // продолжение уравнения вплоть до границы.

					
					// нормальная компонента полного тока равна нулю или
					// нормальная компонента диффузионной составляющей тока равна нулю.
					if (bzerocurrentorzerodiff_loc[mapPT_loc[k1].iboundary+(icurentuds-1)*20-1]) {
                        // определяем внутреннюю нормаль.
						switch (mapPT_loc[k1].chnormal) {
						case 'N' : // север (нижняя стенка)
							ini=k1+icolx;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dan*UDS_loc[ini]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
							break;
						case 'S' : // юг (верхняя стенка)
							isi=k1-icolx;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].das*UDS_loc[isi]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							break;
						case 'W' : // запад (правая стенка)
							iwi=k1-1;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].daw*UDS_loc[iwi]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							break;
						case 'E' : // восток (левая стенка)
							iei=k1+1;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							break;

						}
					}


				}
				else {
					int ipi, ini, iei, iwi, isi;
					ipi=k1;
					switch (mapPT_loc[k1].iugol) {
						case 1 : // левый нижний угол.
						    ini=k1+icolx;
							iei=k1+1;

							UDS_loc[ipi]=0.5*(UDS_loc[iei]+UDS_loc[ini]);

						break;

						case 2 : // правый нижний угол
							ini=k1+icolx;
							iwi=k1-1;

                            UDS_loc[ipi]=0.5*(UDS_loc[iwi]+UDS_loc[ini]);

						break;

						case 3 : // верхний левый угол
							isi=k1-icolx;
							iei=k1+1;

                            UDS_loc[ipi]=0.5*(UDS_loc[iei]+UDS_loc[isi]);

						break;

						case 4 : // верхний правый угол
							isi=k1-icolx;
							iwi=k1-1;

							UDS_loc[ipi]=0.5*(UDS_loc[iwi]+UDS_loc[isi]);

						break;

						case 5 : // пятиточечная  звезда.
							ini=k1+icolx;
							isi=k1-icolx;
							iei=k1+1;
							iwi=k1-1;

							UDS_loc[ipi]=0.25*(UDS_loc[iwi]+UDS_loc[isi]+UDS_loc[iei]+UDS_loc[ini]);

							break;
					}
				}
			}
		} // проход по внутренним точкам.


		if (((2*k) % (icolx+icoly))==0) {

			// отслеживаем невязку
			#pragma omp for  
			for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
				if (mapPT_loc[k1].itype==1) {
					// внутренний узел

					// используется обновлённая сетка.
					//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // текущая точка.
					//int ipi=mapPT_loc[k1].ipi;
					int ipi=k1;
					
                    //int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // север
				    //int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // юг
				    //int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // запад
				    //int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // восток
					//int ini=mapPT_loc[k1].ini;
					//int isi=mapPT_loc[k1].isi;
					//int iwi=mapPT_loc[k1].iwi;
					//int iei=mapPT_loc[k1].iei;
					int ini=k1+icolx;
					int isi=k1-icolx;
					int iwi=k1-1;
					int iei=k1+1;


					myrP_loc[ipi]=mp_loc[ipi].dae*UDS_loc[iei];
					myrP_loc[ipi]+=mp_loc[ipi].daw*UDS_loc[iwi];
					myrP_loc[ipi]+=mp_loc[ipi].dan*UDS_loc[ini];
					myrP_loc[ipi]+=mp_loc[ipi].das*UDS_loc[isi];
					myrP_loc[ipi]+=db_loc[ipi] - mp_loc[ipi].dap*UDS_loc[ipi];

					
				}
			}

			// проверка насколько точно выполняется дискретный аналог
		    switch (ibasenorma_loc) {
		    case 1 : // евклидова норма
			     residualuds=myEvklidNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 2 : // кубическая
			     residualuds=mySupNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 3 : // октаэдрическая
			     residualuds=mySup2Norma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    }
		}

		k++;

	}

}