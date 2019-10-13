// mgf.cpp: ���������� ���������������� ������� ��� ���������� DLL.
// mgf - multi grid fedorenko.
// ������������ ������������ ���������� �� ������ OpenMP.


/* ������ dll ������������� ��� ��������� ���������� � ��������� DavisTestDelphi.
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
	/* ��������� ����� �� ���������
	 * ������������� ��� ������ ��������� �������
	 * �� ������������ �������.
	 * ������ ��������� ������������
	 * � ���������� ��� ������ �� ��������� ��������
	 * � ����� � ��������� ��� �������� ��������.
	*/
	/* ������ ����� ����� �� ����������� �����
	*/
	double dae, daw, dan, das, dap;
};

struct TmyNode
{
	// ��������� ������ ����
	// 0 - ������ ��� �� ������������� ��������� ����� (hollow point).
	int itype; // ��� ���� ( 1 - ����������, 2 - ��������� ����)
	int i,j; // ������������� ���������� ����
	// ��� ���� ����� �������� ����� ����� ������� � ������ ���������� :
	// ����� ������������ ������, ����� ������ ������������ ������ �� �,
	// ����� ������ ������������ ������ �� y. � �.�.
	double dx, dy, dV;
	double dxe, dxw, dyn, dys;
    // ��� ���������� ������� �������
	int iboundary; // ���������� ����� ������� � ������� ����������� ��� �����.
	char chnormal; // ���������� ������� � �������.
	// ���� ������� �����
	// 0 - �� �������,
	// 1 - ����� ������ ����,
	// 2 - ������ ������ ����,
	// 3 - ����� ������� ����,
	// 4 - ������ ������� ����,
	// 5 - ���� ������������ �����.
	int iugol; 
	// � ��������� ��� �������� ��������
	// ����� ����� �������� � �������� �������
	// ��� ����� ���������� ��� �������������� ��������� ������.

	// ��� ��������� ����������.
	int ini, isi, iwi, iei, ipi;
};

// ���������� ������ ������������� �����.
/* ��� ���������� � ���������� math.h
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

// ���������� ������������ �� ���� ����� �����.
int imax(int ia, int ib) {
	if (ia>ib) {
		return ia;
	}
	else
	{
		return ib;
	}
}

// ���������� ������������ �� ���� ����������� �����.
double fmax(double da, double db) {
	if (da>db) {
		return da;
	}
	else
	{
		return db;
	}
}

// ��������� ����� ������������ ������������� ������� �������� U
// ���������� ������ ���������� �� ����� ��������� ����������� ������� �������.
// ��� ���������� ����� ��������� �������.
// ��������� �����.
double myEvklidNorma(double *U, int imaxnumbernode, 
				   TmyNode *mapPT)
{
   // �������������
   double dsum=0.0;
  
#pragma omp parallel 
   {

#pragma omp for reduction (+:dsum)
   for (int k=1; k<=imaxnumbernode; k++) 
   {
     
         if (mapPT[k].itype != 0) 
		 {
            // ���������� ����
			double rbuf;
            //rbuf = U[mapPT[k].i+(mapPT[k].j-1)*icolx]; // �������� �� ��������� ���������
			rbuf = U[mapPT[k].ipi]; // �������� �� ��������� ���������
            // ����� �������� ������������
            dsum +=  rbuf*rbuf/imaxnumbernode;
		 }
    
   }

   }

   return sqrt(dsum);  // ���������� ����� ������������ ������������� �������� U
} // ����� ������������ ������������� ������� ��������

// ����� ������������ ������������� ������� �������� U �� �������� �
// ������������� �
// ���������� ������������ �������� �������.
// ���������� �����.
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
   

	return r; // ���������� ����� ������������ ������������� �������� U
} // ����� ������������ ������������� ������� ��������

// �������������� ����� ������������ ������������� ������� �������� U
// ���������� ����� ������� ��������� ������� �������.
// �������������� �����.
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
	return r; // ���������� ����� ������������ ������������� �������� U
} // ����� ������������ ������������� ������� ��������

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

	// URF - �������� ������� ����������.
	// myrP_loc - �������,
	// db_loc - ������ �����,
	// P_loc - ������� �������������.

	omp_set_num_threads(g_nNumberOfThreads); // ������������� ���������� �������.


	// ������, ����� ������������ ���������,
	// ����� ���������� � �������.
	double deviation=1.0e30; // ����� ������� �����
	int k=1; // ����� ��������

	while ((deviation > eps) && (k<=imaxiter)) 
	{
#pragma omp for   
		for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// ���������� ����

				// ���������� ����� ��� �������� ��������
				// ������������ ������������ �����
				//int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // �����
				//int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // ��
				//int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // �����
				//int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // ������
				//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // ������� �����.
				int ini=mapPT_loc[k1].ini;
				int isi=mapPT_loc[k1].isi;
				int iei=mapPT_loc[k1].iei;
				int iwi=mapPT_loc[k1].iwi;
				int ipi=mapPT_loc[k1].ipi;

				// ����� ����� ���� ������� �� ����, ��� ���� ���������
				if (fabs(mp_loc[ipi].dap) > 1.0e-30) {
					// ����� �������������� ��� ������� �� ����
                    if ((bipifix_loc) && (ipi==ipifix_loc)) {
						P_loc[ipifix_loc]=0.0; // ��������� �������
					}
					else
					{
						P_loc[ipi]=P_loc[ipi]+URF*((mp_loc[ipi].dae*P_loc[iei]+mp_loc[ipi].daw*P_loc[iwi]+mp_loc[ipi].dan*P_loc[ini]+mp_loc[ipi].das*P_loc[isi]+db_loc[ipi])/mp_loc[ipi].dap-P_loc[ipi]);
					}
				}
				
			}
		} // ������ �� ���������� ������.

		// ��� ������������� ���������
		// ������� ����� ������� ����� ����������� 
		// ������ 0.5*(inx+iny) �������� ������� �����-�������.
		// ����� ���������� ������� ����� ������� ����� �������� �-�.
		if (((2*k) % (icolx + icoly)) == 0) {
			// ����������� �������
			#pragma omp for   
			for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
				if (mapPT_loc[k1].itype==1) {
					// ���������� ����

					// ������������ ���������� �����.
					//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // ������� �����.
					int ipi=mapPT_loc[k1].ipi;
					if ((bipifix_loc) && (ipi == ipifix_loc)) {
						myrP_loc[ipifix_loc]=0.0; // ���� ��������� ����������� �����
					}
					else 
					{
                        //int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // �����
				        //int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // ��
				        //int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // �����
				        //int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // ������
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

            // �������� ��������� ����� ����������� ���������� ������
		    switch (ibasenorma_loc) {
		    case 1 : // ��������� �����
			     deviation=myEvklidNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 2 : // ����������
			     deviation=mySupNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 3 : // ��������������
			     deviation=mySup2Norma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    }

		}

		k++; // ������� � ��������� ��������

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

	// myrUDS - �������.
	// icurentuds - ����� UDS  1..4.
	// bQneiC_loc - ���������� ��� ������ ����� �� ������ ������� � 
	// ��������� ������� ����������� ��������� ������ �� ����� �������.
	// ������ �������� ����� 20 ��������� ������ � ����� 4 uds.
	// �������� ���������� ������������� ������� 1..20, 1..20, 1..20, 1..20.
	// bzerocurrentorzerodiff_loc - ���������� � ��� ���������� �� � ������ �����
	// ������ ������� ������� ���������� ���������� ������� ���� ����� ���� � 
	// ���������� ���������� ������������� ���� ����� ����.

	int k=0; // ����� ��������� ��������.
	double residualuds=1.0; // ��������� �������� �������.
	double URF=1.0;

	omp_set_num_threads(g_nNumberOfThreads); // ������������� ���������� �������.

	while ((residualuds > eps) && (k < imaxiter))
	{

		#pragma omp for  
		for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// ���������� ����

				// ���������� ����� ��� �������� ��������
				// ������������ ������������ �����
				//int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // �����
				//int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // ��
				//int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // �����
				//int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // ������
				//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // ������� �����.
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
				// ��������� ����.
				int ipi, ini, isi, iei, iwi;

				if (mapPT_loc[k1].iugol==0) {
					if (bQneiC_loc[mapPT_loc[k1].iboundary+(icurentuds-1)*20-1]) {
						// ���������� ���������� �������.
						switch (mapPT_loc[k1].chnormal) {
			               case 'N' : // ����� (������ ������)
							          ipi=k1;
									  ini=k1+icolx;
									  iwi=k1-1;
									  iei=k1+1;

                                      UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].dan*UDS_loc[ini]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
				                      break;
						   case 'S' : // �� (������� ������)
                                      ipi=k1;
									  isi=k1-icolx;
									  iwi=k1-1;
									  iei=k1+1;

									  UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dae*UDS_loc[iei]+
					                            mp_loc[ipi].daw*UDS_loc[iwi]+
												mp_loc[ipi].das*UDS_loc[isi]+
												db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							          break;
						   case 'W' : // ����� (������ ������)
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
						   case 'E' : // ������ (����� ������)
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
					} // ����������� ��������� ������ �� �������.

					
					// ���������� ���������� ������� ���� ����� ���� ���
					// ���������� ���������� ������������ ������������ ���� ����� ����.
					if (bzerocurrentorzerodiff_loc[mapPT_loc[k1].iboundary+(icurentuds-1)*20-1]) {
                        // ���������� ���������� �������.
						switch (mapPT_loc[k1].chnormal) {
						case 'N' : // ����� (������ ������)
							ini=k1+icolx;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].dan*UDS_loc[ini]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);
							break;
						case 'S' : // �� (������� ������)
							isi=k1-icolx;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].das*UDS_loc[isi]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							break;
						case 'W' : // ����� (������ ������)
							iwi=k1-1;
							ipi=k1;

							UDS_loc[ipi]=UDS_loc[ipi]+URF*((mp_loc[ipi].daw*UDS_loc[iwi]+db_loc[ipi])/mp_loc[ipi].dap-UDS_loc[ipi]);

							break;
						case 'E' : // ������ (����� ������)
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
						case 1 : // ����� ������ ����.
						    ini=k1+icolx;
							iei=k1+1;

							UDS_loc[ipi]=0.5*(UDS_loc[iei]+UDS_loc[ini]);

						break;

						case 2 : // ������ ������ ����
							ini=k1+icolx;
							iwi=k1-1;

                            UDS_loc[ipi]=0.5*(UDS_loc[iwi]+UDS_loc[ini]);

						break;

						case 3 : // ������� ����� ����
							isi=k1-icolx;
							iei=k1+1;

                            UDS_loc[ipi]=0.5*(UDS_loc[iei]+UDS_loc[isi]);

						break;

						case 4 : // ������� ������ ����
							isi=k1-icolx;
							iwi=k1-1;

							UDS_loc[ipi]=0.5*(UDS_loc[iwi]+UDS_loc[isi]);

						break;

						case 5 : // ������������  ������.
							ini=k1+icolx;
							isi=k1-icolx;
							iei=k1+1;
							iwi=k1-1;

							UDS_loc[ipi]=0.25*(UDS_loc[iwi]+UDS_loc[isi]+UDS_loc[iei]+UDS_loc[ini]);

							break;
					}
				}
			}
		} // ������ �� ���������� ������.


		if (((2*k) % (icolx+icoly))==0) {

			// ����������� �������
			#pragma omp for  
			for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
				if (mapPT_loc[k1].itype==1) {
					// ���������� ����

					// ������������ ���������� �����.
					//int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // ������� �����.
					//int ipi=mapPT_loc[k1].ipi;
					int ipi=k1;
					
                    //int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // �����
				    //int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // ��
				    //int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // �����
				    //int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // ������
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

			// �������� ��������� ����� ����������� ���������� ������
		    switch (ibasenorma_loc) {
		    case 1 : // ��������� �����
			     residualuds=myEvklidNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 2 : // ����������
			     residualuds=mySupNorma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    case 3 : // ��������������
			     residualuds=mySup2Norma(myrP_loc, imaxnumbernode_loc,  mapPT_loc);
			     break;
		    }
		}

		k++;

	}

}