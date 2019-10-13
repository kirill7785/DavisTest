// cg_davis.cpp: ���������� ���������������� ������� ��� ���������� DLL.
//

// �������� � ���������� ������ ���������� ���������� ��� 
// �������� � �������� �������� � ��������� Davis Test Delphi.
// �� . ����������� �.�.������.
// ���� ����� ����� �������� ������������������� � �������� ��� ��� ������.




#include "stdafx.h"
#include <math.h>
#include <stdio.h>

#define MYDEBUG 0 // ����� �������

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




// ��������� ������ ���
  // ������������ ����������� �������
  // � ������� CRS ��� ������ ���������� ����������
  struct TmyNonZeroElemMatrix
  {
     // ����� ������� �������
     // i,j ������������ ��������������
     // �������� � �������
     int i;
     int j;
     // �������� ���������� ��������
     double aij;
     // ����������� ���� ��� ��������������
     // �� �������
     int key;

  }; // TmyNonZeroElemMatrix

  // ���������� ����������� �� ���� ����� �����.
int imin(int ia, int ib) {
	if (ia<ib) {
		return ia;
	}
	else
	{
		return ib;
	}
}


// ��� ���������� ������ ���������� ����������
// � �������������� ����������
// �������� ����������� ������� CRS
// ����������� ���������� ��������� ������� ����������

// ����������������� � ��������������
// ������ �������� � ���� ����� "The C Programming Language".
// Swap : ����� ������� list[i] � list[j]
void Swap(TmyNonZeroElemMatrix* list,
                          int i,
                          int j)

{

   TmyNonZeroElemMatrix temp;

   // ���� ���� ���������� � �������� ����������� ����� ��
   // ������ begin, ������ ����� ����� ������� ���������� �����
   // ������� ������������ ����� ���������� �������.
   // ����� �������� � ������������� �����������.

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

// ��� �������� PivotList
// �� ���������� ����� ������� ��������� ������� �� ��� �����.
// ����������������� � �������������� ������ ��. ��������
// ������ ���������� ���. 106.
int PivotList(TmyNonZeroElemMatrix* list,
                              int first,
                              int last) 
{
	int PivotValue;
	int PivotPoint; // ������������ ������� ����� ����������
	int index;// ������� ����� for

   // list �������������� ������
   // first ����� ������� ��������
   // last ����� ���������� ��������

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

// ������� ���������� �����.
// ��� ����������� �������� ������� ���������� �� ��������������
// �� �������� �� ���������� �� ������.
// ������� ���������� ����������� ����� ��� �������������� ���������� �������
// �������� ������.
// ����������������� � �������������� ��. �������� ������ ���������� ���. 106.
void QuickSort(TmyNonZeroElemMatrix* list,
                              int first,
                              int last)
{
	int Pivot;

   // list ��������������� ������ ���������
   // first ����� ������� �������� � ����������� ����� ������
   // last ����� ���������� �������� � ����������� ����� ������

   if (first < last) 
   {
      Pivot = PivotList(list, first, last);
      QuickSort(list, first, Pivot-1);
      QuickSort(list, Pivot+1, last);
   }

} // QuickSort

// ������������� ����������

// ��������������� ��������
void FixHeap(TmyNonZeroElemMatrix* list,
                          int root,
                          TmyNonZeroElemMatrix m,
                          int bound)
{
	int vacant;
	int largerChild;

   // list ����������� ������ ��������
   // root ����� ����� ��������
   // m �������� �������� ����������� � ��������
   // bound ������ ������� (�����) � ��������
   vacant=root;
   while (2*vacant <= bound) 
   {
      largerChild=2*vacant;

      // ����� ����������� �� ���� ���������������� ��������
      if ((largerChild<bound) && (list[largerChild+1].key>list[largerChild].key)) 
	  {
         largerChild=largerChild + 1;
      }

      // ��������� �� ���� ���� �������� ������� ?
      if (m.key > list[largerChild].key) 
      {
         // ��, ���� �����������
         break;
	  }
      else
	  {
         // ���, �������� ����������������� �������
         // ������� �������
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

// ������������� ���������� ���������� ���
// �� ������, ��� � �� ��������������, � ���� �� � ��������
// ����� ���������.
// ����������� ������� � ���, ��� ��������� ������� ������ ���������� � 1.
void HeapSort(TmyNonZeroElemMatrix *list, int n)
{

	int i; // �������
	TmyNonZeroElemMatrix max; // ������� � ���������� ��������� �����

    // ��������������� ��������
    for ( i=(n/2); i>=1; i--)
	{
       FixHeap(list, i, list[i], n);
	}
    for (i=n; i>=2; i--)
	{
       // ����������� ������ �������� � ������
       // ��������������� ��������
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

// ��������� ������������ ���� ��������
double Scal(int isize, double *dV1,
                       double *dV2)
{

   double ds=0.0; // �������������
   for ( int i=0; i<=(isize-1); i++)
   {
      ds+=  dV1[i]*dV2[i];
   }
   return ds;
} // Scal

// ��������� ������� �� ������
// ��������� ������ �������� CRS
// ��� ����������� ��������� ����������� ������������� ������� ����.
// ����������������� � ��������������
// 1. http://www.netlib.org/linalg/html_templates  "Survey of Sparse Matrix Storage Formats"
// 2. �. �������� "����������� �������".
// ������� ���������� �� ������ ���� �������� ������������ �����.
void MatrixCRSByVector(int isize, // ����������� ������� ��� ���������� �������
                                double *val,  // ��������� �������� �������
                                int *col_ind, // ��������������� �� ������ ��������
                                int *row_ptr, // ��� ����������� ������ ��������� ������
                                double *dV, // �������� ������ �� ������� ������������ ���������
                                double *dx)  // ��������� ��������� ��������� � dx.
{

   int i,j; // �������� ����� for

   for (i=0; i<=(isize-1); i++)
   {
      dx[i]=0.0;

      for (j=row_ptr[i]; j<=(row_ptr[i+1]-1); j++) 
	  {
         dx[i]+= val[j]*dV[col_ind[j]];
	  }

   }

} // MatrixCRSByVector

// ��������� ����������������� ������� �� ������
// ��������� ������ �������� CRS
// ��� ����������� ��������� ����������� ������������� ������� ����.
// ����������������� � ��������������
// 1. http://www.netlib.org/linalg/html_templates  "Survey of Sparse Matrix Storage Formats"
// 2. �. �������� "����������� �������".
void MatrixTransposeCRSByVector(int isize, // ����������� ������� ��� ���������� �������
                                double *val,  // ��������� �������� �������
                                int  *col_ind, // ��������������� �� ������ ��������
                                int *row_ptr, // ��� ����������� ������ ��������� ������
                                double *dV, // �������� ������ �� ������� ������������ ���������
                                double *dx)  // ��������� ��������� ��������� � dx.
{

	int i,j; // �������� ����� for

   for (i=0; i<=(isize-1); i++) dx[i]=0.0; // ���������

   for (j=0; j<=(isize-1); j++)
   {

      for (i=row_ptr[j]; i<=(row_ptr[j+1]-1); i++)
	  {
         dx[col_ind[i]] += val[i]*dV[j];
	  }

   }

}  // MatrixTransposeCRSByVector

// ����� �������
// ��� ������ ���������� �� ����� ���������
double NormaV(int isize, double *dV)
{
	int i; // ������� �����
	double dnorma, dsum;

   // ������������� ����������
   dsum=0.0;
   for (i=0; i<=(isize-1); i++)
   {
      dsum+= dV[i]*dV[i];
   }
   dnorma=sqrt(dsum); // ����� �������
   return dnorma;
} // NormaV

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

// ����� �������
// ��� ������������ �������� ����� ������� ��������� �������
// ���������� �����.
double NormaSupV(int isize,
                       double *dV)
{
	int i; // ������� �����
	double  dmax; // ������� �������� ����� �������

   // ������������� ����������
   dmax=-1.0; // ������������� �����
   for (i=0; i<=(isize-1); i++)
   {
      dmax= fmax(dmax, fabs(dV[i]));
   }
    // ����� �������
   return dmax;
} // NormaSupV

// ����� �������
// ����� ������� ��������� �������
// �������������� �����.
double NormaSup2V(int isize, double *dV)
{
	int i; // ������� �����
	double dsum; // ������� �������� ����� �������
   // ������������� ����������
   dsum=0.0; // ��������� ���������
   for (i=0; i<=(isize-1); i++)
   {
      dsum+= fabs(dV[i]);
   }
    // ����� �������
   return dsum;
} // NormaSup2V

// ����� ���������� ����������
// �������� � ������� 1952 ���.
// ��. ��������, ����������� �.�. ������  ���. 88.
// ��� �.�. ������ ������ �������������� ����������
// ����� ��������� ���������� CRS �������� � ��������� ����������� �������.
// ���� �������� �������� �� ������ ��� SPD - Symmetric and Positively Defined ������.
// SPD - �������������� � ������������ ����������� �������.
// � ����������� �� �������� ������������� ��������� bGaussTransform
// � �� ������������� ��� �� ����������� ������������� ������.
// ������������� ������ ������� � ���������� ���� �� ����������������� ������� �����,
// ��� ��������� �� ����� ���� �������� ���� � ������������ ����������� �������������� ��������.
// ������ ������������� ������ ������ ������ ����� ��������������� ������� (������ �������) ������� ��� � �������.
void SoprGradCRS(int isize, // ������ ���������� �������
                          double *val, // ������� ����
                          int *col_ind, // ��������������� ��������� ��������� ������ ��������
                          int *row_ptr, // ���������� � ������� �����
                          double *dV,  // ������ ������ �����
                          double *dX0, // ������ ���������� �����������
                          double *dres, // ������ ����������
						  double *residual_history, // ������� �������� �������
                          bool bconsole_message, // �������� �� �������� ������� �� �������
                          int kend, // ����������� �� ������������ ���������� ��������
                          bool bGaussTransform, // ��������� �� ������������� ������
                          double epsilon,
						  int ibasenorma) // �������� ����������
{

	int i,k; // ��������
	double dar, dbr, dnz, dscalgg;

   // ��������� ������
   // ��� ������������ �������
   double *dx=new double[isize];  // ������� ������� �������
   double *dax=new double[isize]; // ���������� ���������
   double *dap=new double[isize]; // ������� �� ������
   double *dg=new double[isize]; // ������ ���������
   double *dp=new double[isize]; // ������ ����������� ����������� ������
   // ��� ������������� ������
   double *dbuf=new double[isize]; // ��������� ��������� ��� ���������� ������������� ������

   // ��������� �����������
   // X0 ==
   // ��� �������� dX0 ���������� ������ ���� ���������� � �������.
   for (i=0; i<=(isize-1); i++) dx[i]=dX0[i];

   // ������������� ��� ���������� ������������� ������.
   MatrixCRSByVector(isize, val, col_ind, row_ptr, dx, dax); // ��������� ������ � dax
   for (i=0; i<=(isize-1); i++) dg[i]= dV[i] - dax[i];  // ��������� �������

   if ( bGaussTransform) 
   {
      // ���� ������������� ������ ��-�� ���������.
      for (i=0; i<=(isize-1); i++) dbuf[i]= dg[i];  // ��������� ����� ��������� �������
      MatrixTransposeCRSByVector(isize, val, col_ind, row_ptr, dbuf, dg); // ��������� ������ � dg:=At*dbuf;
   }

   if (Scal(isize, dg, dg) > 1.0e-30) 
   {
      for (i=0; i<=(isize-1); i++) dp[i]=dg[i]; // p0:=g0;
      k=0; // ����� ��������
      dnz=1.0e+30; // ��������� �������� ������� (�������������)
      while ((k < kend) && (dnz > epsilon)) 
	  {
         if ( bGaussTransform) 
		 {
            // ����������� ������������� ������.
            MatrixCRSByVector(isize, val, col_ind, row_ptr, dp, dbuf); // ��������� ������ � dbuft1
            MatrixTransposeCRSByVector(isize, val, col_ind, row_ptr, dbuf, dap); // ��������� At*A*dp ������ � dap
		 }
         else
		 {
            // ������������� ������ �� �����������.
            MatrixCRSByVector(isize, val, col_ind, row_ptr, dp, dap); // ��������� A*dp ������ � dap
		 }
         dscalgg= Scal(isize, dg, dg);
         dar =  dscalgg / Scal( isize, dap, dp);
         for (i=0; i<=(isize-1); i++)
		 {
            dx[i] = dx[i] + dar*dp[i];
            dg[i] = dg[i] - dar*dap[i];
		 }
         // ����� ����������� ��� ��� �����
         // ������ ������ ��� ��� ������������
         switch (ibasenorma)
		 {
            case 1 : dnz=NormaV(isize, dg); break; // ���������
            case 2 : dnz=NormaSupV(isize, dg); break; // ���������� �����
            case 3 : dnz=NormaSup2V(isize, dg); break; // �������������� �����
	     }
         
         if (bconsole_message) 
		 {
            // ������ �������� ������� �� �������
			residual_history[k]=dnz;
	     }
         dbr = Scal(isize, dg, dg) / dscalgg;
         for (i=0; i<=(isize-1); i++)
		 {
            dp[i] = dg[i] + dbr*dp[i];
         }
         k++; // ������� � ��������� ��������
         // ���� ������� ���������� ��� ���� ����������
         if (dnz > 1.0e+17) 
		 {
            // �������������� ���������� �����������
            for (i=0; i<=(isize-1); i++) dx[i]=dX0[i];
            //MainMemo.Lines.Add('�������������� ������� ���������� ');
            //Application.MessageBox('divergence SoprGrad solver ','',MB_OK);
            break; // � ������� ��������
		 }
	  }
      // ����������� ����������
      for (i=0; i<=(isize-1); i++) dres[i]=dx[i];
   }
    else
   {
      // ���������� ��������� �����������
      for (i=0; i<=(isize-1); i++) dres[i]=dX0[i];
   }

   // ������������ ������ ���������� ��� ������������ �������
   delete dx; // ���������� �������� � ���������� ������������� ��������
   delete dax; delete dap; // ���������� ��������� ������� �� ������
   delete dg; delete dp; // ������� ��������� � ����������� ����������� ������.
   delete dbuf;

}  // SoprGradCRS

// ��� ��������� ������� ���� ��������� � ������ ����������
// �� ������������ �������� ������������������ ���������:
// ����������. ����� ����� ����������� ������� ����������.
// ������ �������� � ����� ����� "The C programming language".
// swap: ����� ������� v[i] � v[j]
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

// ��� �������� PivotList
int PivotListCSIR(int* &jptr, double* &altr, int first, int last) {
	// list==jptr and altr �������������� ������
	// first ����� ������� ��������
	// last ����� ���������� ��������

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


// ������� ���������� �����.
// ����������������� � �������������� ��. ��������� ������ ����������
// ���. 106.
void QuickSortCSIR(int* &jptr, double* &altr, int first, int last) {
	// list ��������������� ������ ���������
	// first ����� ������� �������� � ����������� ����� ������
	// last ����� ���������� �������� � ����������� ����� ������

	int pivot;

	if (first < last) {
        pivot = PivotListCSIR(jptr, altr, first, last);
        QuickSortCSIR(jptr, altr, first, pivot-1);
		QuickSortCSIR(jptr, altr, pivot+1, last);
	}
} // QuickSortCSIR

// �������� ���������� ���������
// ��� ������������ ����������� ������������
// ������� � �������� nxn.
// n - ����������� ������� ����
// ������� val ���������� � � ��� ������������
// �������� ���������� ��������� IC(0):
// val == U ������� ����������� �������
// A = transpose(U)*U=L*transpose(L);
// L=transpose(U);
// ������:
// A = 
// 9.0   0.0   0.0   3.0   1.0   0.0   1.0    
// 0.0   11.0   2.0   1.0   0.0   0.0   2.0    
// 0.0   2.0   10.0   2.0   0.0   0.0   0.0    
// 3.0   1.0   2.0   9.0   1.0   0.0   0.0    
// 1.0   0.0   0.0   1.0   12.0   0.0   1.0    
// 0.0   0.0   0.0   0.0   0.0   8.0   0.0    
// 1.0   2.0   0.0   0.0   1.0   0.0   8.0 
//������ CSIR_ITL (������� ����������� �������� ���������).
// val : 9.0 3.0 1.0 1.0 11.0 2.0 1.0 2.0 10.0 2.0 9.0 1.0 12.0 1.0 8.0 8.0 
// indx: 0 3 4 6 1 2 3 6 2 3 3 4 4 6 5 6 
// pntr: 0 4 8 10 12 14 15 16 
//--------------------------------------------
// ��������� ������������ ��� ����������:
// ��������� ������ val (indx � pntr �������� ��� ���������):
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


// ���������������� �������� ���������� ���������.
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
          if (indx[g] == indx[j]) // ������ �������� �����
             val[j] -= z * val[g];
	  else //index does not match accumulate the fill-in value
		  accumulate_fill_in += z * val[g];

	  val[pntr[h]] -= accumulate_fill_in;

    }
  }
  d = pntr[n-1];
  val[d] = sqrt(val[d]);
} // IC0FactorModify_ITL

// ��������� ������������ ������������ �����������  ������� �� ������ 
// ������������ ������ �������� CSIR. � ���� ��������� �������� ������ ��������������� �������� altr. 
// ����������� SPD ������� A (adiag, altr, jptr, iptr) ���������� �������� nxn.
// ����� ��������� ����� ����� ����������� � ����� n.
// ������:
// A = 
// 9.0   0.0   0.0   3.0   1.0   0.0   1.0    
// 0.0   11.0   2.0   1.0   0.0   0.0   2.0    
// 0.0   2.0   10.0   2.0   0.0   0.0   0.0    
// 3.0   1.0   2.0   9.0   1.0   0.0   0.0    
// 1.0   0.0   0.0   1.0   12.0   0.0   1.0    
// 0.0   0.0   0.0   0.0   0.0   8.0   0.0    
// 1.0   2.0   0.0   0.0   1.0   0.0   8.0 
// ------------------------------------------
// ������ CSIR:
// adiag: 9.0 11.0 10.0 9.0 12.0 8.0 8.0
// altr: 2.0 3.0 1.0 2.0 1.0 1.0 1.0 2.0 1.0
// jptr: 1 0 1 2 0 3 0 1 4
// iptr: 0 0 0 1 4 6 6 9
//-------------------------------------------
void  SPDMatrixCSIRByVector(double* adiag, double* altr, int* jptr, int* iptr, double* V, double* &tmp, int n)
{
	
	// ������ tmp ������������� ������� � ���� ��� �� ��� � ������ V
	if (tmp == NULL)
	{
		printf("in SPDMatrixCSIRByVector tmp==NULL\n");
		getchar();
		tmp =new double[n];
		if (tmp==NULL) {
			printf("malloc: out of memory for vector tmp in SPDMatrixCSIRByVector\n"); // �������� ������
		    getchar();
		   // exit(0); // ���������� ���������
		}
	}
	
	
    int i,j; // �������� �����
    

	//omp_set_num_threads(inumcore);

    //#pragma omp parallel for shared(tmp, V, adiag) private(i) schedule (guided)
	for (i=0; i<n; i++) tmp[i]=V[i]*adiag[i];

    // ���������������� ������
	/*
	for (i=0; i<n; i++) {
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
		    tmp[i] += V[jptr[j]]*altr[j];
		    tmp[jptr[j]] += V[i]*altr[j];
		}
	}
	*/

	// ����� ������ �� ����.
	//#pragma omp parallel for shared(tmp, V, altr, iptr, jptr,n) private(i,j) schedule (guided)
    for (i=0; i<n; i++) {
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
		    tmp[i] += V[jptr[j]]*altr[j];
		}
	}

	// ������ ����� �� �������� �����������������
    for (i=0; i<n; i++) {

		// ��� ����� �� �������� �����������������.
        //#pragma omp parallel for shared(tmp, V, altr, i, iptr, jptr) private(j)
	    for (j = iptr[i]; j<iptr[i+1]; j++)
		{
			tmp[jptr[j]] += V[i]*altr[j];
		}
	}

} // SPDMatrixCSIRByVector


// ������ ��� �� ����������� ���������������� ������� L.
// ������������ ������������ ����������� �������
// ���� A ������������ �������� ����������� ��������� 
// A~=L*transpose(L); L - ������ ����������� �������.
// L - �������� � ��������� ����:
// 1. val - ������������ � ��������������� �������� L.
// � ���������� �������. 
// 3. indx - �������������� ������ ����� ��� val, 
// 4. pntr - ���������� � ������ ���������� �������.
// f - ������ ������ ����� �������� nodes.
// ���������� ������ z=inverse(L)*f;
// ������ f ��������.
// ������ (CSIR - ������):
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
	// ����� �������� fbuf ����� ������ � ������������ ������, � �������� ������ ����� ������ ���������� NULL.
	// ���������� �������� � fbuf ����� ���������� �������.

    if (z == NULL)
	{
		double *z=new double[n];
		if (z==NULL) {
			printf("malloc: out of memory for vector z in inverse(L)*f \n"); // �������� ������
		    getchar();
		    //exit(0); // ���������� ���������
		}
	}

	//bool bserial=true;

	//if (bserial) {
		// ������������ ����������.

	    int i,j;
	    for (i=0; i<n; i++) {
            z[i]=f[i]/val[pntr[i]];
		    // ��������� i-�� �������
		    // ��� ����� �� �������� �����������������.
            // �� �� ������������ �� ������ ��� f.
		    for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			    f[indx[j]]-=z[i]*val[j];
		    }
		
	    }
		/*

	}
	else {
		// ������������ ����������.
		// ������������ ��� ������� ����������� ���������� ������������ �� ������.

		// ��� ������������ 
		// n=omp_get_num_threads(); 
		// �������������� ��������.

		int nt=0;
#pragma omp parallel shared(nt)
		{
			// ����� �����.
			nt=omp_get_num_threads();
		}

		int i,j;

		for (i=0; i<nt; i++) {
			for (j=0; j<n; j++) {
				fbuf[i][j]=0.0; // �������������.
			}
		}

#pragma omp for  shared(n, z, val, f, fbuf, pntr, indx, fbuf) 
		for (i=0; i<n; i++) {
		   // �������� � ��� ��� ����� ������������ f[i] � ��� ����� ���� ����������, ��� ����� �� ����������� !!!
            z[i]=f[i]/val[pntr[i]];
		    // ��������� i-�� �������
		    // ��� ����� �� �������� �����������������.
            // �� �� ������������ �� ������ ��� f.
		    for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			    fbuf[omp_get_thread_num()][indx[j]]-=z[i]*val[j];
		    }
		
	    }

	}
	*/
}//inverseL_ITL

// �������� ��� �� ����������� ����������������� ������� U.
// ������������ ������������ ����������� �������
// ���� A ������������ �������� ����������� ��������� 
// A~=L*transpose(L); L - ������ ����������� �������.
// U=transpose(L); - ������� ����������� �������.
// U - �������� � ��������� ����:
// 1. val - ������������ � ��������������� �������� U (� ��������� �������).
// 2. indx - �������������� ������ ��������, 
// 3. pntr - ���������� � ������ ��������� ������ ��� val.
// f - ������ ������ ����� �������� nodes.
// ���������� ������ z=inverse(U)*f;
// ������ f ��������.
// ������ (CSIR_ITL - ������):
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
			printf("malloc: out of memory for vector z in inverse(U)*f \n"); // �������� ������
		    getchar();
		    //exit(0); // ���������� ���������
		}
	}

	int i,j;

	for (i=(n-1); i>=0; i--) {
        
		// ��������� i-�� ������:
		// ��� ����� �� �������� �����������������.
		//#pragma omp parallel for shared(f, indx, z, val, i, pntr) private(j)
		for (j=pntr[i]+1; j<pntr[i+1]; j++) {
			f[i]-=z[indx[j]]*val[j];
		}
		// ����� �� ������������ �������:
        z[i]=f[i]/val[pntr[i]];
		
	}
	
}//inverseU_ITL

/* ����� ���������� ���������� �������� � ������� [1952]
*  ������� ���������:
*  M - ����������� ������� ���� � ������� SIMPLESPARSE,
*  dV - ������ ������ �����, 
*  x - ��������� ����������� � ������� ��� NULL.
*  n - ����������� ���� Anxn.
*
*  ����������� ������� M ���������� �������� nxn.
*  ����� ��������� ����� ����� ����������� � ����� n.
*  ������� M �������������� ������������ ����������� � 
*  ������������ (������������ ������������ ������������).
*  �������� ������ ��������� ��������. 
*  ���������� �������� ���������� 1000, �.�. ��������������,
*  ��� ���� ������� �� ������� �� 1000 �������� �� ��� � �� �������.
*  �������� ������ �� ������� ������� � ���������� ���������:
*  dterminatedTResudual.
*  � �������� ������������������� �������� �������� ���������� ���������:
*  K^(-1)==transpose(L)^(-1)*L^(-1); // ���������� �������������������.
* 
*  ������� �������� ��������������, ��� ��� 4 ������� ��������� �������� �� 54%
*  � ���������, ��������� �������� �� ��������� �����������������.
*
*  ��������. ��� ���� ����� �������� ������������������� ����� ���������������� 
* ���������� � �������� �.
*/
void ICCG(double *adiag, double *altr, int *jptr, int *iptr,
		  double *val, int *indx, int *pntr,
		  double *dV, double* &x, int n, bool bprintmessage, int maxiter, double eps)
{

	// ���� bdistwall==true �� �������� ���� ��� ���������� ����������� ���������� �� ������.

	double dsize=(double)(1.0*n); // ������������ ����� �������

	int k=0;
	int i; // �������
	double *ap=new double[n], *vcopy=new double[n], *f=new double[n];
	double *z=new double[n], *p=new double[n];
    double a, b, res, dbuf;
	

	double dold, dnew;

	// �������� ���������� ���������:
	// ���������� ����� ������ ����������� �����������.
	if (bprintmessage) {
		printf("Incoplete Cholesky decomposition beginig...:\n");
	}
	//IC0Factor_ITL(val, indx, pntr, n);
	//M//IC0FactorModify_ITL(val, indx, pntr, n);
	if (bprintmessage) {
		printf("Incoplete Cholesky decomposition finish...:\n");//*/
	}


	// ��� 1.1
	//X0==
	if (x==NULL) {
        x=new double[n];
		for(i=0;i<n;i++) x[i] = 0.0;
	}

	// ��������� �������� �������
	double e = eps;
	
	// ��� 1.2
    // ���������� z - ������� ���������� �����������
	SPDMatrixCSIRByVector(adiag, altr, jptr, iptr, x, ap, n);
	for (i=0; i<n; i++) z[i]=dV[i]-ap[i];
	for (i=0; i<n; i++) vcopy[i]=z[i]; 
    //M//inverseL_ITL(vcopy, val, indx, pntr, f, n);
    for (i=0; i<n; i++) vcopy[i]=f[i];  
	//M//inverseU_ITL(vcopy, val, indx, pntr, f, n);
    dnew=Scal(n,z,f);
	//dnew=sqrt(dnew)/dsize; // �������������������� ��� ������ ������ ��� �������� �� �������������� �������.

	
	// ����������� ������� ������ �� �������� ������������� ������ ��������� �������.
	//if (e*dnew<e) e*=dnew;
	//double me=sqrt(dnew)/dsize;
	//if (e*me<e) e*=me;
	//dterminatedTResudual=e;
	
	
	
	if (fabs(dnew) > e) {
	//if (fabs(me) > e) {

		// ��� 1.3
	   for (i=0; i<n; i++)	p[i]=f[i];
	   res=1000.;
	   while ((fabs(res)>e) && (k<maxiter)) {
		   // ��� 2.1
		  SPDMatrixCSIRByVector(adiag, altr, jptr, iptr, p, ap, n);

		  // ��� 2.2
		  a=dnew/Scal(n,p,ap);// ������� ���������
		  // ��� 2.3 � 2.4
          //#pragma omp parallel for shared(x,z,p,ap,a,n) private(i) schedule (guided)
		  for (i=0; i<n; i++) {
		      x[i]+=a*p[i]; // ��������� ����������� 
              z[i]-=a*ap[i];// ������� k+1-�� �����������
		  }
          //#pragma omp parallel for shared(vcopy,z,n) private(i) schedule (guided)
          for (i=0; i<n; i++) vcopy[i]=z[i];  
          //M//inverseL_ITL(vcopy, val, indx, pntr, f, n);
          //#pragma omp parallel for shared(vcopy,f,n) private(i) schedule (guided)
          for (i=0; i<n; i++) vcopy[i]=f[i]; 
	      //M//inverseU_ITL(vcopy, val, indx, pntr, f, n);
		  // ��� 2.5
          dold=dnew;
		  dnew=Scal(n,z,f);

		  // res=dnew; // �������� ���.
		  res=sqrt(dnew)/dsize;
		  if (bprintmessage) {
			  if (k%10==0) {
				  printf("iter residual\n");
			  }
		      printf(" %d %e\n", k, res);
		  }
		  // ��� 3.1
		  b=dnew/dold;
		  // ��� 3.2

          //#pragma omp parallel for shared(p,f,b,n) private(i,dbuf) schedule (guided)
		  for (i=0; i<n; i++) {
			 dbuf=p[i];
		     p[i]=f[i]+b*dbuf; // ����� ����������� �����������
		  }
          // ��� 3.3
		  k++;
	   } // while

	   // � ���� ���� ������� ���������� �� ���������� ������� ����:
       //fprintf(fp_statistic_convergence, " ICCG finish residual=%e \n",res);
       //fprintf(fp_statistic_convergence,"%e ",res); // ��� ������ �������� �������� ������� ��� ��� ��� ������ �������������

	   // ������������ ������
        delete ap; delete vcopy;
		delete z; delete p; delete f;  
	}
	else {
		// ������������ ������
		//printf("ICCG inform: residual of the initial approximation is too small...\n");
		
		//fprintf(fp_statistic_convergence, " ICCG no solve start residual < %e \n",e);
		//fprintf(fp_statistic_convergence,"%e ",e); // ��� ������ �������� �������� ������� ��� ��� ��� ������ �������������
		delete ap; delete vcopy;
		delete z; delete p; delete f;		
	}

}
	

// ����� ��� ��� ������ Bi-CGStabCRS
// �������� ��� �������� �������������� ������������ ������.
// �������������� ������� ���� ��������� � CRS �������
// A (val, col_ind, row_ptr).
// ����� �������� ����������� ������� BiCG � GMRES(1). 
void Bi_CGStabCRS(int n, double *val, int* col_ind, int* row_ptr, double *dV, double* &dX0, double* &dxret, int maxit,
				  double dterminatedTResudual, int ibasenorma, double *residual_history)
{

	// dxret - ������������ ������� !!!

	int iflag=1, icount=0;
	double delta0, deltai;
	double bet, roi;
	double roim1=1.0, al=1.0, wi=1.0;
	double *ri, *roc, *s, *t, *vi, *pi, *dx, *dax;
	double epsilon=dterminatedTResudual;  // �������� ����������
    //printf("%e\n",epsilon); // ����������� �������� ������� �� ������� �������������� ����� �� ������������� ��������.
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

    // ��������� �����������
    // X0 ==
    // ��� X0 ���������� ������ ���� ���������� � �������.
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

    MatrixCRSByVector(n,val,col_ind,row_ptr,dx,dax); // ��������� ������ �  dax
	for (i=0; i<n; i++) {
		ri[i]=dV[i]-dax[i];
		roc[i]=ri[i];
	}
	 switch (ibasenorma)
	{
            case 1 : delta0=NormaV(n, ri); break; // ���������
            case 2 : delta0=NormaSupV(n, ri); break; // ���������� �����
            case 3 : delta0=NormaSup2V(n, ri); break; // �������������� �����
	 }
	// ���� ������� ����� ������� �� �� �������:
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
		// ����� ����������� ��� ��� �����
         // ������ ������ ��� ��� ������������
         switch (ibasenorma)
		 {
            case 1 : deltai=NormaV(n, ri); break; // ���������
            case 2 : deltai=NormaSupV(n, ri); break; // ���������� �����
            case 3 : deltai=NormaSup2V(n, ri); break; // �������������� �����
	     }
		// ������ ������� �� �������
        //if ((icount % 10) == 0)  printf("iter  residual\n");
        //printf("%d %e \n",icount,deltai);
		 residual_history[icount]=deltai;
        // ���������� � ���������� ���������� � ���� log.txt ��������� � �������� ����� fp_log.
        //fprintf(fp_log,"%d %e \n",icount,deltai);
        //if ((icount % 100)== 0) getchar();

		if (deltai <epsilon) iflag=0; // ����� ����������
		else roim1=roi;
	}

    // ������������ ������
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

// ������������ �������� ���������� �� ��������.
const int CongruateGradient=0; // ����� ���������� ����������.
const int BiCGStab=1; // �������� ��� ��� ������

// ����� ���������� ���������� ��� �������� � �������� ��������.
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
							double * &residual_history, // ������� �������� �������
							int itypesorter_loc,
							int * &pointerlist_loc,
							int * &pointerlistrevers_loc,
							bool bconstr_loc,
							int ialg_loc)
{

	// �������� ! ��� ������ ������� �������� bconstr_loc ����������� ������ ���� ����� false.
	// ������ ��� ������� pointerlist_loc, pointerlistrevers_loc ������ ���� �������� � Delphi �������.
	// ����� ������� �������� � ������� ��� ���� �������� ������������ �� �����.

	int ialg=ICCGalg;//ICCGalg; //CGalg; 

	// ������������� ����.
	bool *bdirichlet=new bool[imaxnumbernode_loc+1];
	for (int k1=0; k1<=imaxnumbernode_loc; k1++) {
		bdirichlet[k1]=false; // ���� ��� �� ���� � �������� �������.
	}
	double eps0=1.0e-30;
	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// ���������� ����
			int ipi=mapPT_loc[k1].ipi;
			if ((fabs(mp_loc[ipi].dae)<eps0) && (fabs(mp_loc[ipi].daw)<eps0) && (fabs(mp_loc[ipi].dan)<eps0) && (fabs(mp_loc[ipi].das)<eps0)) {
				bdirichlet[ipi]=true;
			}
		}
	}
	// ������ db_loc � ������������� ������� ����.
	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// ���������� ����
			int ipi=mapPT_loc[k1].ipi;
			if (!bdirichlet[ipi]) {
				// �� ������� ������� � ����.
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
	// ����� ������������� ����.

	delete bdirichlet;

	// myrP - �������.
	int k=0; // ���������� ��������� � ����������� �������.
	int il=0; // ���������� ��������� ������� ��������� ������
	

	for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// ���������� ����
				il++; 
				int ipi=mapPT_loc[k1].ipi;
				if (fabs(mp_loc[ipi].dae)>eps0) k++;
				if (fabs(mp_loc[ipi].daw)>eps0) k++;
				if (fabs(mp_loc[ipi].dan)>eps0) k++;
				if (fabs(mp_loc[ipi].das)>eps0) k++;
				if (fabs(mp_loc[ipi].dap)>eps0) k++;
			}
	}

	TmyNonZeroElemMatrix *nze=new TmyNonZeroElemMatrix[k+1]; // ��������� �������� ������� ����� ������� ����������� �� �������
	
	// ��������� ������ ��� ������ ������ �����
	double *dV1=new double[il];
	 // ��������� ������ ��� ��������� ����������
	double *dx=new double[il];

   // ��������� ������� d�
   // ����� ���� �� 1 �� iNelem
   for(int  k1=0; k1<=k; k1++) 
   {
      // �������������
      // ������� ��� ��������
      // ��������� ���������
      nze[k1].i=0;
      nze[k1].j=0;
      nze[k1].aij=0.0;
      nze[k1].key=0;
   }

   

   for (int k1=0; k1<=il-1; k1++)
   {
	  dV1[k1]=0.0;  // ������������� ������� ������ �����
   }

   if (!(bconstr_loc)) {

   
#if MYDEBUG
	   int imin_=10000000, imax=-500;
#endif

   // ������ ��������������
	   // ������ ����� �������� � Delphi.
   //pointerlist=new int[il];
   for (int i1=0; i1<=(icolx*icoly-1); i1++) {
       pointerlist_loc[i1]=-1; // ������������� !!!
   }

   int j1=0;
   for (int i1=1; i1<=imaxnumbernode_loc; i1++) 
   {
      if (mapPT_loc[i1].itype==1)
	  {
         // ������ ������� ���������
         pointerlist_loc[j1]=(mapPT_loc[i1].i-1)+(mapPT_loc[i1].j-1)*icolx; // ����� ��� U
		 #if MYDEBUG
	        if (pointerlist_loc[j1]<imin_) imin_=pointerlist_loc[j1];
			if (pointerlist_loc[j1]>imax_) imax_=pointerlist_loc[j1];
         #endif
         j1++; // ������� � ��������� �������� �����
	  }
   }

   #if MYDEBUG
   imin_;
   imax_;
#endif
   

   // �������� ��������������
   //pointerlistrevers=new int[icolx*icoly]; // ��������� ������
   
   // �������������
   // ����� -1 ������������� hollow point
   for (int i1=0; i1<=(icolx*icoly-1); i1++)  pointerlistrevers_loc[i1]=-1;
   for (int i1=0; i1<=(icolx*icoly-1); i1++) 
   {
      // ����� ����� � pointerlist[j1] ���������� ����� i1
      for (int j1=0; j1<=il-1; j1++)
	  {
         // ���������� ������������
         if (pointerlist_loc[j1]==i1) 
		 {
            // �� ������ ��� U ��� ����� ��� x
            // ��� ��������� ��������������� ������������
            // � ����� ����� ���������� �������� ��������� -1
            pointerlistrevers_loc[i1]=j1;
		 }
	  }
   }


   }
   // ������������� �������
   int k1=0;
   /*
   
   for (int i1=1; i1<=icolx; i1++)
   {
      for (int j1=1; j1<=icoly; j1++)
	  {
         // ����� �� ��������� ��� ���� ����� ?
         int j2=i1+(j1-1)*icolx; // ��������� ���������� � 1
         // ����������� �� ��� ����� � ������ ����������� ?
         for (int i2=0; i2<=il-1; i2++) 
		 {
            if (j2 == (pointerlist_loc[i2]+1)) 
			{
               // � U ��������� ���������� � 1
               dx[k1]=P_loc[j2]; // ������������� ������� �������
               k1++;
			}
         }
      }
   }*/
   // ����������� ����������� ������� ������� � U
   // ������� 1:
   /*
   for (int i1=0; i1<=il-1; i1++)
   {
      dx[i1] = P_loc[pointerlist_loc[i1]+1]; // ������ � ��������� ������������;
	  //dV1[i1] = db_loc[pointerlist_loc[i1]+1]; // ���������������� ��� ������ �������.
   }
   */
   // ������� 2:
   for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
			if (mapPT_loc[k1].itype==1) {
				// ���������� ���� 
				int ipi=mapPT_loc[k1].ipi;
				dx[pointerlistrevers_loc[ipi-1]]=P_loc[ipi];
			}
   }
			

   int k2=0; // ������� ��������� ��������� // ���������� ����������� � ���� !!!
   // k - ��� ������ ������, ��������� ������� � 1 ����� ��� ������������� ����������

   // ����� ���������� ��������� � ��������� nze �� 0 �� iNelem-1

   // ���������� ������� d� � ������ � ������������� �
   // ������� ������ ����� dV
   for (k1=1; k1<=imaxnumbernode_loc; k1++)
   {
      if (mapPT_loc[k1].itype==1) {
            // ���������� ����

           int ini=mapPT_loc[k1].i+mapPT_loc[k1].j*icolx; // �����
           int isi=mapPT_loc[k1].i+(mapPT_loc[k1].j-2)*icolx; // ��
           int iwi=(mapPT_loc[k1].i-1)+(mapPT_loc[k1].j-1)*icolx; // �����
           int iei=(mapPT_loc[k1].i+1)+(mapPT_loc[k1].j-1)*icolx; // ������
           int ipi=mapPT_loc[k1].i+(mapPT_loc[k1].j-1)*icolx; // ������� �����

           int rini=pointerlistrevers_loc[ini-1];
           int risi=pointerlistrevers_loc[isi-1];
           int riwi=pointerlistrevers_loc[iwi-1];
           int riei=pointerlistrevers_loc[iei-1];
           int ripi=pointerlistrevers_loc[ipi-1];


        

    
			double dmul=1.0/mp_loc[ipi].dap; // ������������ �������������������
            nze[k2].i=ripi; nze[k2].j=ripi; nze[k2].aij=1.0; nze[k2].key=nze[k2].i;  k2++;
			if (fabs(mp_loc[ipi].dae)>eps0) { nze[k2].i=ripi; nze[k2].j=riei; nze[k2].aij= - dmul*mp_loc[ipi].dae; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].daw)>eps0) { nze[k2].i=ripi; nze[k2].j=riwi; nze[k2].aij= - dmul*mp_loc[ipi].daw; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].dan)>eps0) { nze[k2].i=ripi; nze[k2].j=rini; nze[k2].aij= - dmul*mp_loc[ipi].dan; nze[k2].key=nze[k2].i; k2++;}
			if (fabs(mp_loc[ipi].das)>eps0) { nze[k2].i=ripi; nze[k2].j=risi; nze[k2].aij= - dmul*mp_loc[ipi].das; nze[k2].key=nze[k2].i; k2++;}
            dV1[ripi]= dmul*db_loc[ipi];
		}
	}

   for (int k1=k; k1>=1; k1--) nze[k1]=nze[k1-1]; // ����� ������ �� 1.
   // ��������� ���������� � 1, � ��� ���������� nze ��������� ���������� � ����
   /*
   if (itypesorter_loc == 1)
   {
      QuickSort(nze,1,k); // ������� ���������� �����
   }
    else
	{
      // itypesorter = 2
      HeapSort(nze,k); // ������������� ����������
    }
   */

   

   // ���������� ��������� �������� � �������
   if (ialg==ICCGalg) {
	   // ICCG:
       
	  

	   // ������� ����
	   // � ������� CSIR:
	   // �������� ������� ����������� ������������ ����������� �������.
	   double *adiag=NULL, *altr=NULL;
	   int *jptr=NULL, *iptr=NULL;

	   

	    adiag = new double[il]; // ������������ ��������
		int nz=(int)((k-il)/2);
		//int nz=(int)(k/2); // ���������� ��������� ������ � �������
		altr = new double[nz]; // ��������������� ��������
		jptr = new int[nz]; // ������ ������� ��� ������� ������������
		iptr = new int[il+1]; // ��������� �� ��������� ������

		// �������������
		for (int k1=0; k1<il; k1++) adiag[k1]=0.0;
        for (int k1=0; k1<(nz); k1++) {
		   altr[k1]=0.0;
		   jptr[k1]=0;
	    }
        for (int k1=0; k1<=il; k1++) {
		    //iptr[k]=k; // ����������� ���������� ��������� ��������� ���� 1 � ������ ���� ��� ��������� ������� ���������� � 0
			iptr[k1]=nz; // debug
	    }



        int ik=0;
		int imin_=1;
		bool bvisit=false; // ������������ �� FALSE ������ ��� �������� � ����� ������.
		int ioldstr=0;


		for (int k1=0; k1<=k-1; k1++)
        {
			if (nze[k1+1].i>ioldstr) {
				ioldstr=nze[k1+1].i;
				bvisit=false;
			}

			if (nze[k1+1].j==nze[k1+1].i) {
				// ������������.
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

		// �������������������:
	   // �������� ����������� ���������� �
	   // ������� CSIR_ITL:
	   double *val=NULL;
	   int *indx=NULL, *pntr=NULL;

		// ��������������� �������� � altr �������� ���������
		nz=(int)((k-il)/2 + il); // ����� ��������� ���������
		val = new double[nz]; // ������������ �������� � ��������������� ��������
		indx = new int[nz]; // ������ ������� ��� ������� ������������
		pntr = new int[il+1]; // ��������� �� ��������� ������

		
		// �������������
        for (int k1=0; k1<(nz); k1++) {
		   val[k1]=0.0;
		   indx[k1]=0;
	    }
        for (int k1=0; k1<=il; k1++) {
		    pntr[k1]=nz; // ����������� ���������� ��������� ��������� ���� 1 � ������ ���� ��� ��������� ������� ���������� � 0
	    }

        

		ik=0; // ������� ��������� ��������������� ��������� ����
		for (int k1=0; k1<=k-1; k1++)
        {
			if (nze[k1+1].j>=nze[k1+1].i) {
				val[ik]=nze[k1+1].aij; // ��������� ��������
			    indx[ik]=nze[k1+1].j; // ����� �������

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

		// �� ������.
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

	   double *val=new double[k]; // ��������� �������� ������� ����
	   int *col_ind=new int[k]; // ��������������� ��������� ��������� ������ ��������
	   int *row_ptr=new int[il+1]; // ���������� � ��� ��� ���������� ��������� ������


	   // ��������� ������� d�
       for(int  k1=0; k1<=k-1; k1++) 
       {
           // �������������
           val[k1]=0.0;
           col_ind[k1]=0;
       }

       // �.�. ��������� ���������� � ����, �� � ������������ �������� (iNelem+1)-1,
       // ��� -1 ��� ����� �������� � ������� ����, �.�. ��������� ������� ���������� � 0.
       for (int k1=0; k1<=il; k1++) row_ptr[k1]=k; // ������������� ���������� �� ��������� ������


	   // ������������ ������� ����������� ������� ����
       //  � ������� CRS (���������� ����� ��� �������������� ��������� �� �������).
       for (int k1=0; k1<=k-1; k1++)
       {
            // ��� nze ������ k+1 �.�. ��������� ����� ������� ���������� � 1.
            // ��� ���������� ��������� ������������� ����������.
            val[k1]=nze[k1+1].aij;
            col_ind[k1]=nze[k1+1].j;
            row_ptr[nze[k1+1].i]=imin(k1, row_ptr[nze[k1+1].i]);
       }

      // ������� ����
      // ������� ���������� ����������
      // �������� � �������
      // �� ������ ���������� �������� � ��������� ����������� ������ CRS
      // � ����������� �� �������� ��������� bgt ����������� ��� �� ����������� ������������� ������.
	  double* dinit=new double[il];
	    // ����������� ����������� ������� ������� � U
	  // ������� 1 :
	  /*
      for (int i1=0; i1<=il-1; i1++)
      {
         dinit[i1] = P_loc[pointerlist_loc[i1]+1]; // ������ � ��������� ������������;
      }*/
	  // ������� 2 :
	  for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// ���������� ���� 
			int ipi=mapPT_loc[k1].ipi;
			dinit[pointerlistrevers_loc[ipi-1]]=P_loc[ipi];
		}
      }
      bool bmessage=false;
      bool bgt=false;
	  switch (ialg_loc) {
	  case CongruateGradient : // ����� ���������� ����������.
		  SoprGradCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, residual_history, bmessage, imaxiter, bgt, eps, ibasenorma_loc);  
		  break;
	  case BiCGStab : // �������� ������� ��� ��� ������
		  Bi_CGStabCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, imaxiter, eps, ibasenorma_loc, residual_history);
		  break;
	  default : // �� ��������� �������� ������� ��� ��� ������
		        Bi_CGStabCRS(il, val, col_ind, row_ptr, dV1, dinit, dx, imaxiter, eps, ibasenorma_loc, residual_history);
		        break;
	  }
	 
	  // ������������ ����������� ������.
	  delete val;
	  delete col_ind;
	  delete row_ptr;
	  delete dinit;
   }
   

   // ����������� ����������� ������� ������� � U
   // ������� 1:
   /*
   for (int i1=0; i1<=il-1; i1++)
   {
      P_loc[pointerlist_loc[i1]+1] = dx[i1]; // ������ � �������� ������;
   }*/
   // ������� 2:
   for (int k1=1; k1<=imaxnumbernode_loc; k1++) {
		if (mapPT_loc[k1].itype==1) {
			// ���������� ���� 
			int ipi=mapPT_loc[k1].ipi;
			P_loc[ipi]=dx[pointerlistrevers_loc[ipi-1]];
		}
   }
			 

	delete nze;
	
	delete dV1;
	delete dx;

	//delete pointerlist; // ������ ���������� � Delphi.
	//delete pointerlistrevers; // ������ ���������� � Delphi.
	

}