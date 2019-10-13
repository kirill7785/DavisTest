// my_cl_amg.cpp: ���������� ���������������� ������� ��� ���������� DLL.
//

#include "stdafx.h"

#ifdef __cplusplus 
#define EXPORT extern "C" __declspec(dllexport) 
#else 
#define EXPORT __declspec (dllexport) 
#endif 


// cuda_class_aglom_amg.cu: ���������� ����� ����� ��� ����������� ����������.
// classical aglomeration algebraic multigrid method.
// ������������ �������������� �������������� ������������� �����.
// 15 ������ 2015. ������ 0.08 � ������� ���������� ������ ������ 0.07. ������ ���� � ����������� ����������� ���������
// ������.
// 8 ������ 2015. ������ 0.07 � ������� ��������� ������ �� ����������� ��������� ��������������
// ���������. ������ �������� �� ����� 800�800 ������ �������� �� 49�. ��� �� ������, � ��������
// �������� � amg1r5 �������������� ����������� � 8� ��� ������ ������. ��� ���������� �������� � ��������������� �
// ������ 0.07 ����� ��� � ������ 0.06 �� ����� ����� �� ��������� � ������������ ���������.
// � ������ 0.07 ������ ������ � ����������� ��������� ���������,�������� ����� ���������� ����������� �������.
// ����������� ��������� �� �������� ������� ����������� �� ���� ����������� �� ������� ���������� ���������� 
// ��������-���� � �������� ����������� ���������� (AliceFlow) � ������ ����� my_amg_v0.07  ����� ������������ 
// � ������ ����� �������.
// 31 - ������� 2015. ������ 0.06 � ������� ��������� ������ �� ����������� ���������
// �������������� ���������. ��������� ��� ������. ������ �������� �� ����� 800�800 �������� �� 9��� 32�.
// ������ ������ ��������� �������� ����� ������� ���������� �������������� ������ � 
// ������� ��� ����� ����� ������ ������������. ���� �������� �������� ������������ � ��������� ������ ����.
// 22-23 ������� 2015. ������ 0.05 � ������� ����������������� ���� ���������� ���
// ������������ ���������� ���������. ���������� ���� ���������� �������� ��� �� 15%
// �� ��������� � ������� 0.04. ����� � ������ 0.05 ���������� �������� ���������� ���
// ������������ ���������� ��������� gustavson sparse matrix multiplayer IBM 1978.
// �������� ���������� ������� ��� �� ��������� � ������� 0.04 ����� ��� �����.
// 18 ������� 2015. ��������� ��������������� ����������.
// ������������� �� �������� ������� �� ������ �������� �� ����� 
// ������� �������. 18 ������� ���������� ������ 0.04. ������ 0.04 �� �����
// ������� ������ 0_03. ���� �������� ��� �������� ���������� C-F ���������, 
// ��� � ���������� ��������� ��������. ��� ���������� �-F ��������� 
// ����������� ��� ������������ ��� ����� � ������� ����� ������������ ��
// �� ������� ������ ����������� ��������� ������ �� ����������� �����.
// ��� ���������� ����������� �������� �������� ����� ����������� �� ������������� ������,
// ���������� �� ��������� ������� ��������������� �������.
// version 0.03 15 october 2015. (�������� ���������� �������� �����, ���������� restriction , interpolation.)
// �� ��������� � ������� 0.01 ���������� : �������� �����, ���������� ��������� ���������. ������� ������ ������ �����������.
// �� ��������� � ������� 0.02 ��� ���� �������, �����������. ������� ������ � MergeSort ������� �� �� ��������� ���������� � ������ HeapSort.
// ��� �������� �� ����� ������������ �� 10��� ��������� ��������� �� ����� �������� �� ������� ������������.
// ��� ������� ������ 0.02 �� 50%.
/*    ###     ##    ###   ####
*    #  #    #  #  # ##  #
*   #####   #    #   ##  #   ##  for AliceFlowv0_22 AliceMeshv_0_34 and anather products...
*  #    #  #         ##   ####
*/

//#include "cuda_runtime.h"
//#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <math.h>
#include <stdlib.h>
#include <windows.h>
//#include <omp.h>


// cuda primer start
/*

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ void addKernel(int *c, const int *a, const int *b)
{
    int i = threadIdx.x;
    c[i] = a[i] + b[i];
}

int main_test_example()
{
    const int arraySize = 5;
    const int a[arraySize] = { 1, 2, 3, 4, 5 };
    const int b[arraySize] = { 10, 20, 30, 40, 50 };
    int c[arraySize] = { 0 };

    // Add vectors in parallel.
    cudaError_t cudaStatus = addWithCuda(c, a, b, arraySize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addWithCuda failed!");
        return 1;
    }

    printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",
        c[0], c[1], c[2], c[3], c[4]);

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

    return 0;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size)
{
    int *dev_a = 0;
    int *dev_b = 0;
    int *dev_c = 0;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input vectors from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Launch a kernel on the GPU with one thread for each element.
    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    
    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    
    return cudaStatus;
}

*/
// cuda primer end

#define Real double
#define integer int

typedef struct TAk {
	integer i, j;
	Real aij;
	//� ��������� ������ ��������� ind �� ������������.
	integer ind; // ������� � �������������� ����������.
} Ak;

typedef struct TList {
	integer ii, i, countsosed;
	TList* next;
	TList* prev;
} List;

// ��� ��������� ������� ���� ��������� � ������ ����������
// �� ������������ �������� ������������������ ���������:
// ����������. ����� ����� ����������� ������� ����������.
// ������ �������� � ����� ����� "The C programming language".
// swap: ����� ������� A[i] � A[j]
void swap(Ak * &A, integer i, integer j)
{
	Ak A_temp;

	// change A[i] <-> A[j]
	A_temp = A[i];
	A[i] = A[j];
	A[j] = A_temp;

} // swap

/*
// ��� �������� PivotList
integer PivotList(Ak * &A, integer n, integer first, integer last) {
// list==jptr and altr �������������� ������
// first ����� ������� ��������
// last ����� ���������� ��������

integer PivotValue = A[first].i*n+A[first].j;
integer PivotPoint = first;

for (integer index = (first + 1); index <= last; index++) {
if (A[index].i*n+A[index].j<PivotValue) {
PivotPoint++;
swap(A, PivotPoint, index);
}
}

swap(A, first, PivotPoint);

return PivotPoint;
} // PivotListamg
*/
// ��� �������� PivotList
integer PivotList(Ak * &A, integer first, integer last) {
	// list==jptr and altr �������������� ������
	// first ����� ������� ��������
	// last ����� ���������� ��������

	integer PivotValue_j = A[first].j;
	integer PivotValue_i = A[first].i;
	integer PivotPoint = first;

	for (integer index = (first + 1); index <= last; index++) {
		if (A[index].i<PivotValue_i) {
			PivotPoint++;
			swap(A, PivotPoint, index);
		}
		else if ((A[index].i == PivotValue_i) && (A[index].j < PivotValue_j)) {
			PivotPoint++;
			swap(A, PivotPoint, index);
		}
	}

	swap(A, first, PivotPoint);

	return PivotPoint;
} // PivotList

// ��� �������� PivotList
integer PivotList_j(Ak * &A, integer first, integer last) {
	// list==jptr and altr �������������� ������
	// first ����� ������� ��������
	// last ����� ���������� ��������

	integer PivotValue_j = A[first].j;
	integer PivotValue_i = A[first].i;
	integer PivotPoint = first;

	for (integer index = (first + 1); index <= last; index++) {
		if (A[index].j<PivotValue_j) {
			PivotPoint++;
			swap(A, PivotPoint, index);
		}
		else if ((A[index].j == PivotValue_j) && (A[index].i < PivotValue_i)) {
			PivotPoint++;
			swap(A, PivotPoint, index);
		}
	}

	swap(A, first, PivotPoint);

	return PivotPoint;
} // PivotListamg_j


// ������������� ����������

// ��������������� ��������
void FixHeap_j(Ak* &A,
	integer root,
	Ak m,
	integer bound,
	/*integer n,*/ integer iadd)
{
	integer vacant;
	integer largerChild;

	// list ����������� ������ ��������
	// root ����� ����� ��������
	// m �������� �������� ����������� � ��������
	// bound ������ ������� (�����) � ��������
	vacant = root;
	while (2 * vacant <= bound)
	{
		largerChild = 2 * vacant;
		integer lCadd = largerChild + iadd;
		integer lCadd1 = lCadd + 1;

		// ����� ����������� �� ���� ���������������� ��������
		bool compare_result = false;
		if (A[lCadd1].j > A[lCadd].j) {
			compare_result = true;
		}
		else if (A[lCadd1].j == A[lCadd].j) {
			if (A[lCadd1].i > A[lCadd].i) {
				compare_result = true;
			}
		}
		if ((largerChild<bound) && (compare_result /*A[largerChild + 1+iadd].j*n+ A[largerChild + 1 + iadd].i> A[largerChild + iadd].j*n+ A[largerChild + iadd].i*/))
		{
			largerChild = largerChild + 1;
		}

		lCadd = largerChild + iadd;
		// ��������� �� ���� ���� �������� ������� ?
		compare_result = false;
		if (m.j > A[lCadd].j) {
			compare_result = true;
		}
		else if (m.j == A[lCadd].j) {
			if (m.i > A[lCadd].i) {
				compare_result = true;
			}
		}
		if (compare_result /*m.j*n+m.i >  A[largerChild + iadd].j*n+ A[largerChild + iadd].i*/)
		{
			// ��, ���� �����������
			break;
		}
		else
		{
			// ���, �������� ����������������� �������
			// ������� �������
			A[vacant + iadd] = A[lCadd];
			vacant = largerChild;
		}
	}
	A[vacant + iadd] = m;
} // FixHeap_j



// ��������������� ��������
void FixHeap(Ak* &A,
	integer root,
	Ak m,
	integer bound,
	integer n, integer iadd)
{
	integer vacant;
	integer largerChild;

	// list ����������� ������ ��������
	// root ����� ����� ��������
	// m �������� �������� ����������� � ��������
	// bound ������ ������� (�����) � ��������
	vacant = root;
	while (2 * vacant <= bound)
	{
		largerChild = 2 * vacant;
		integer lCadd = largerChild + iadd;
		integer lCadd1 = lCadd + 1;

		// ����� ����������� �� ���� ���������������� ��������
		//integer key1 = A[largerChild + 1 + iadd].i*n + A[largerChild + 1 + iadd].j;
		//integer key2 = A[largerChild + iadd].i*n + A[largerChild + iadd].j;
		bool compare_result = false;
		if (A[lCadd1].i > A[lCadd].i) {
			compare_result = true;
		}
		else if (A[lCadd1].i == A[lCadd].i) {
			if (A[lCadd1].j > A[lCadd].j) {
				compare_result = true;
			}
		}
		if ((largerChild<bound) && compare_result/*(key1>key2)*/)
		{
			largerChild = largerChild + 1;
		}

		lCadd = largerChild + iadd;
		// ��������� �� ���� ���� �������� ������� ?
		//integer key5 = m.i*n + m.j;
		//integer key6 = A[largerChild + iadd].i*n + A[largerChild + iadd].j;
		compare_result = false;
		if (m.i > A[lCadd].i) {
			compare_result = true;
		}
		else if (m.i == A[lCadd].i) {
			if (m.j > A[lCadd].j) {
				compare_result = true;
			}
		}
		if (compare_result/*key5 > key6*/)
		{
			// ��, ���� �����������
			break;
		}
		else
		{
			// ���, �������� ����������������� �������
			// ������� �������
			A[vacant + iadd] = A[lCadd];
			vacant = largerChild;
		}
	}
	A[vacant + iadd] = m;
} // FixHeap

// HeapSort ����� ������� ������ �� ������������ �� 10^5 � ����� ������ �� 10^8 ��� ����� ����������� ���� � ���. 

// ������������� ���������� ���������� ���
// �� ������, ��� � �� ��������������, � ���� �� � ��������
// ����� ���������.
// ����������� ������� � ���, ��� ��������� ������� ������ ���������� � 1.
void HeapSort(Ak * &A, integer n, integer first, integer last)
{

	Ak maxelm; // ������� � ���������� ��������� �����

	// ��������������� ��������
	for (integer i = ((last - first + 1) / 2); i >= 1; i--)
	{
		FixHeap(A, i, A[i + first - 1], last - first + 1, n, first - 1);
	}
	for (integer i = last - first + 1; i >= 2; i--)
	{
		// ����������� ������ �������� � ������
		// ��������������� ��������
		maxelm = A[first];
		FixHeap(A, 1, A[i + first - 1], i - 1, n, first - 1);
		A[i + first - 1] = maxelm;
	}
} // HeapSort



// ������������� ���������� ���������� ���
// �� ������, ��� � �� ��������������, � ���� �� � ��������
// ����� ���������.
// ����������� ������� � ���, ��� ��������� ������� ������ ���������� � 1.
void HeapSort_j(Ak * &A, integer first, integer last)
{

	Ak maxelm; // ������� � ���������� ��������� �����

	integer iadd = first - 1;
	// ��������������� ��������
	for (integer i = ((last - first + 1) / 2); i >= 1; i--)
	{
		FixHeap_j(A, i, A[i + iadd], last - first + 1, iadd);
	}
	for (integer i = last - first + 1; i >= 2; i--)
	{
		// ����������� ������ �������� � ������
		// ��������������� ��������
		maxelm = A[1 + iadd];
		FixHeap_j(A, 1, A[i + iadd], i - 1, iadd);
		A[i + iadd] = maxelm;
	}
} // HeapSort_j

// ���������� ��������. 
// ������� �������������� ������.
void MergeSort(Ak * &Aorig, integer size) {
	// �������������� ���������� �� ���� �� size-1.
	// ������ � �������������� �� ����� �������� �������.
	// ������� ������ ��� ���������� ������� ���������.
	Ak* A = Aorig;
	Ak* B = A + size;
	Ak* C;

	// A - ����������� ������, B - ��������������� ������ (������ �� �������� ������ � � ������-�� ������� ��� � �������� ������ � �).
	// C - ��������� ��� ������.
	for (int i = 1; i < size; i = i * 2) // ������ ������������ ����������
	{
		for (int j = 0; j < size; j = j + 2 * i) // ������ ������� �� ������������ 
			// ����������
		{
			int r = j + i; // ������ ������� �� ������������ ����������
			int n1 = 0, n2 = 0;
			if (i < size - j) { n1 = i; }
			else { n1 = size - j; };
			if (i < size - r) { n2 = i; }
			else { n2 = size - r; };

			if (n1 < 0) n1 = 0;
			if (n2 < 0) n2 = 0;

			// ������� ������������� ����������
			for (int ia = 0, ib = 0, k = 0; k < n1 + n2; k++)
			{
				if (ia >= n1) B[j + k] = A[r + ib++];
				else
					if (ib >= n2) B[j + k] = A[j + ia++];
					else {
						bool compare_result = false;
						int lCadd = j + ia;
						int lCadd1 = r + ib;
						if (A[lCadd1].i > A[lCadd].i) {
							compare_result = true;
						}
						else if (A[lCadd1].i == A[lCadd].i) {
							if (A[lCadd1].j > A[lCadd].j) {
								compare_result = true;
							}
						}
						if (compare_result) {
							B[j + k] = A[j + ia++];
						}
						else {
							B[j + k] = A[r + ib++];
						}
					}
			}



		}
		C = A; A = B; B = C;

	}

	C = A; A = B; B = C;

	// �����������, ���� ��������� �������� �� � �������� � � ��������������� �������
	if (B != Aorig)
		memcpy(Aorig, B, size*sizeof(Ak));

	A = NULL; B = NULL; C = NULL;
} // MergeSort


// ���������� ��������. 
// ������� �������������� ������.
void MergeSort_j(Ak * &Aorig, integer size) {
	// �������������� ���������� �� ���� �� size-1.
	// ������ � �������������� �� ����� �������� �������.
	// ������� ������ ��� ���������� ������� ���������.
	Ak* A = Aorig;
	Ak* B = A + size;
	Ak* C;

	// A - ����������� ������, B - ��������������� ������ (������ �� �������� ������ � � ������-�� ������� ��� � �������� ������ � �).
	// C - ��������� ��� ������.
	for (int i = 1; i < size; i = i * 2) // ������ ������������ ����������
	{
		for (int j = 0; j < size; j = j + 2 * i) // ������ ������� �� ������������ 
			// ����������
		{
			int r = j + i; // ������ ������� �� ������������ ����������
			int n1 = 0, n2 = 0;
			if (i < size - j) { n1 = i; }
			else { n1 = size - j; };
			if (i < size - r) { n2 = i; }
			else { n2 = size - r; };

			if (n1 < 0) n1 = 0;
			if (n2 < 0) n2 = 0;

			// ������� ������������� ����������
			for (int ia = 0, ib = 0, k = 0; k < n1 + n2; k++)
			{
				if (ia >= n1) B[j + k] = A[r + ib++];
				else
					if (ib >= n2) B[j + k] = A[j + ia++];
					else {
						bool compare_result = false;
						int lCadd = j + ia;
						int lCadd1 = r + ib;
						if (A[lCadd1].j > A[lCadd].j) {
							compare_result = true;
						}
						else if (A[lCadd1].j == A[lCadd].j) {
							if (A[lCadd1].i > A[lCadd].i) {
								compare_result = true;
							}
						}
						if (compare_result) {
							B[j + k] = A[j + ia++];
						}
						else {
							B[j + k] = A[r + ib++];
						}
					}
			}



		}
		C = A; A = B; B = C;

	}

	C = A; A = B; B = C;

	// �����������, ���� ��������� �������� �� � �������� � � ��������������� �������
	if (B != Aorig)
		memcpy(Aorig, B, size*sizeof(Ak));

	A = NULL; B = NULL; C = NULL;
} // MergeSort_j



// ������� ���������� �����.
// ����������������� � �������������� ��. ��������� ������ ����������
// ���. 106.
void QuickSort(Ak * &A, integer first, integer last) {
	// list ��������������� ������ ���������
	// first ����� ������� �������� � ����������� ����� ������
	// last ����� ���������� �������� � ����������� ����� ������

	if (0) {
		/*
		// BubbleSort
		integer numberOfPairs = last - first + 1;
		bool swappedElements = true;
		while (swappedElements) {
		numberOfPairs--;
		swappedElements = false;
		for (integer i = first; i <= first + numberOfPairs - 1; i++) {
		if (A[i].i*n+A[i].j>A[i + 1].i*n+A[i+1].j) {
		swap(A, i, i + 1);
		swappedElements = true;
		}
		}
		}
		*/
	}
	else
	{
		integer pivot;

		if (first < last) {
			pivot = PivotList(A, first, last);
			QuickSort(A, first, pivot - 1);
			QuickSort(A, pivot + 1, last);
		}
	}
} // QuickSort

// ������� ���������� �����.
// ����������������� � �������������� ��. ��������� ������ ����������
// ���. 106.
void QuickSort_j(Ak * &A, integer first, integer last) {
	// list ��������������� ������ ���������
	// first ����� ������� �������� � ����������� ����� ������
	// last ����� ���������� �������� � ����������� ����� ������

	if (0) {
		// BubbleSort
		integer numberOfPairs = last - first + 1;
		bool swappedElements = true;
		while (swappedElements) {
			numberOfPairs--;
			swappedElements = false;
			for (integer i = first; i <= first + numberOfPairs - 1; i++) {
				if (A[i].j > A[i + 1].j) {
					swap(A, i, i + 1);
					swappedElements = true;
				}
			}
		}
	}
	else
	{
		integer pivot;

		if (first < last) {
			pivot = PivotList_j(A, first, last);
			QuickSort_j(A, first, pivot - 1);
			QuickSort_j(A, pivot + 1, last);
		}
	}
} // QuickSort_j

/*
// ��� ����������� �������������� ��� ���������� ���� ���������� ������������������
// ��������� ������ � �� ���������� ���������� ���������� restriction � prolongation.
// �������� ����� ���� ��������� 1 �������� 2015 ����.

integer aggregative_amg(Ak* &A, integer nnz, integer n, Real* &x, Real* &b) {


// ��������� ���������� � �������.

const integer maxlevel = 30;
integer ilevel = 1;
integer nnz_a[maxlevel];
integer n_a[maxlevel];
nnz_a[0] = nnz;
n_a[0] = n;
bool* flag = new bool[n + 1];
integer iadd = 0;

while ((ilevel<maxlevel-1)&&(n_a[ilevel - 1] > 50)) {
//heapsort(A, key=i*n_a[ilevel - 1] + j, 1, nnz_a[ilevel - 1]);
QuickSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);

for (integer ii = 1+iadd; ii <= nnz_a[ilevel - 1]+iadd; ii++) {
//	printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n",ii,A[ii].aij,ii,A[ii].i,ii,A[ii].j);
//if (ii % 20 == 0) getchar();
}

for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
flag[ii] = false;
}
for (integer ii = 1+iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
A[ii].ind = ii-iadd;
}



// Copy(A) �� nnz ����� ������.
for (integer ii = nnz_a[ilevel - 1] + 1 + iadd; ii <= 2 * nnz_a[ilevel - 1] + iadd; ii++) {
A[ii] = A[ii - nnz_a[ilevel - 1]];
}

integer n_coarce = 1; // ����� ��������.
const integer max_sosed = 20;
const integer NULL_SOSED = -1;
integer vacant = NULL_SOSED;
for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
if (flag[A[ii].i] == false) {
// ��������� �� ������������������� ������� � (���������� �����).

integer set[max_sosed]; // �� ����� 20 ����� � ����� ��������.
for (integer js = 0; js < max_sosed; js++) {
set[js] = NULL_SOSED;
}
integer ic = 0;
set[ic] = A[ii].i;
ic++;

// ���� ���� j ��� �� ��� �������� � �������.
if (flag[A[ii].j] == false) {
vacant = A[ii].j;
for (integer js = 0; js < ic; js++) {
if (vacant == set[js]) {
vacant = NULL_SOSED;
}
}
if (vacant != NULL_SOSED) {
set[ic] = vacant;
ic++;
}
}
integer iscan = ii + 1;
while ((iscan <= nnz_a[ilevel - 1] + iadd) && (A[iscan].i == set[0])) {
// ���� ���� j ��� �� ��� �������� � �������.
if (flag[A[iscan].j] == false) {
vacant = A[iscan].j;
for (integer js = 0; js < ic; js++) {
if (vacant == set[js]) {
vacant = NULL_SOSED;
}
}
if (vacant != NULL_SOSED) {
set[ic] = vacant;
ic++;

}
}

iscan++;

} // while


// (i,j) -> (I,J)
// ������������ ����� A ����������� ������.
for (integer k = nnz_a[ilevel - 1] + 1 + iadd; k <= 2 * nnz_a[ilevel - 1] + iadd; k++) {
bool found = false;
for (integer k1 = 0; k1 < ic; k1++) {
if (A[k - nnz_a[ilevel - 1]].i == set[k1]) found = true;
}
if (found) A[k].i = n_coarce;
found = false;
for (integer k1 = 0; k1 < ic; k1++) {
if (A[k - nnz_a[ilevel - 1]].j == set[k1]) found = true;
}
if (found) A[k].j = n_coarce;
}

// �������� ���� ��� ���������� � �������.
for (integer js = 0; js < ic; js++) {
flag[set[js]] = true;
}

n_coarce++;

// ���� ������� ������.



} // ���� �� ��� ��� ������� � �������.
} // �������� �������.

//printf("%d %d\n",n,n_coarce-1);
//getchar();
n_a[ilevel] = n_coarce - 1;

// ���������� �� ������ ����� key=i*(iglcoarce_number-1)+j;
// � ������� ind ������� ������ ���������� �������.
//heapsort(A, key = i*(n_coarce - 1) + j, nnz + 1, 2 * nnz);
QuickSort(A, n_coarce - 1, nnz_a[ilevel-1] + 1 + iadd, 2 * nnz_a[ilevel-1] + iadd);


for (integer ii = 1+nnz_a[ilevel-1]+iadd; ii <= 2*nnz_a[ilevel - 1]+iadd; ii++) {
//	printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n",ii,A[ii].aij,ii,A[ii].i,ii,A[ii].j);
//if (ii % 20 == 0) getchar();
}



// ����������� � ������ ����� ������� ���� �� coarce �����.
// �������������.
// ����� ������ 1 nnz �� fine ������.
for (integer ii = 2 * nnz_a[ilevel - 1]+1 + iadd; ii <= 3 * nnz_a[ilevel - 1] + iadd; ii++) {
A[ii].aij = 0.0;
A[ii].ind = NULL_SOSED;
A[ii].i = NULL_SOSED;
A[ii].j = NULL_SOSED;
}

for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) flag[ii] = false;


integer ic1 = 2 * nnz_a[ilevel - 1] + 1 + iadd;
integer im = 1;
integer im0 = 0;
for (integer ii = nnz_a[ilevel - 1] + 1 + iadd; ii <= 2 * nnz_a[ilevel - 1] + iadd; ii++) {
if (flag[A[ii].i] == false) {
integer istr = A[ii].i;
while ((ii + im0 <= 2 * nnz_a[ilevel - 1] + iadd)&&(istr==A[ii+im0].i)) {

if (ic1 <= 3 * nnz_a[ilevel - 1] + iadd) {
A[ic1].i = A[ii + im0].i;
A[ic1].j = A[ii + im0].j;
A[ic1].aij += A[ii + im0].aij;
while ((ii + im <= 2 * nnz_a[ilevel - 1] + iadd) && (A[ii + im0].i == A[ii + im].i) && (A[ii + im0].j == A[ii + im].j))
{
A[ic1].aij += A[ii + im].aij;
im++;
}
ic1++;
im0 = im;
im++;
}
else {
printf("error 1\n");
getchar();
}
}
flag[A[ii].i] = true;
im = 1;
im0 = 0;
}
}

nnz_a[ilevel] = ic1 - 1 - 2 * nnz_a[ilevel - 1] - iadd;
iadd += 2 * nnz_a[ilevel - 1];

printf("nnz : fine=%d, coarse=%d, operator complexity=%e. n : fine=%d, coarse=%d grid complexity=%e.\n", nnz_a[ilevel - 1], nnz_a[ilevel], (double)(nnz_a[ilevel])/(double)( nnz_a[ilevel - 1]), n_a[ilevel - 1], n_a[ilevel], (double)(n_a[ilevel])/ (double)(n_a[ilevel - 1]));
getchar();

ilevel++;// ������������� ������� ���������.

} // �������� ����� ���������.

return 0;

} // aggregative_amg


*/

// seidel � residual ��� ����������  �������� � �������� i, j ������� ������ � �������������� ����� � ����� ���������,
// �� ��� ������� ������ ������� ����� ����� ��� ���� ����������� �� ������� i.


// smoother.
// 1 september 2015.
void seidel(Ak* &A, integer istart, integer iend, Real* &x, Real* &b, bool* &flag, integer n)
{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	for (integer i = 1; i <= n; i++) {
		flag[i] = false;
	}
	for (integer ii = istart; ii <= iend; ii++) {
		if (flag[A[ii].i] == false) {
			integer istr = A[ii].i;
			integer ic = ii;
			Real ap = 0.0;
			x[istr] = b[istr];
			while ((ic <= iend) && (A[ic].i == istr)) {
				if (A[ic].j != istr) {
					x[istr] += -A[ic].aij*x[A[ic].j];
				}
				else ap = A[ic].aij;
				ic++;
			}
			/*
			if (fabs(ap) < 1.0e-30) {
			printf("zero diagonal elements in string %d",istr);
			getchar();
			exit(1);
			}
			else */{
				x[istr] /= ap;
			}
			flag[A[ii].i] = true;
		}
	}


} // seidel
/*
integer *row_ptr_start = new integer[4 * n_a[0] + 1];
integer *row_ptr_end = new integer[4 * n_a[0] + 1];
// istart - ��������� ������� ��������� ��������� � ������� �.
// iend - �������� ������� ��������� ��������� � ������� �.
for (integer i = 1; i <= n; i++) {
flag[i] = false;
}
for (integer ii = 1; ii <= nnz_a[0]; ii++) {
if (flag[A[ii].i] == false) {
integer istr = A[ii].i;
integer ic = ii;
integer icdiag = ii;
row_ptr_start[istr] = ii;
Real ap = 0.0;
//x[istr] = b[istr];
while ((ic <= nnz_a[0]) && (A[ic].i == istr)) {
if (A[ic].j != istr) {
//x[istr] += -A[ic].aij*x[A[ic].j];
}
else {
ap = A[ic].aij;
icdiag = ic;
}
ic++;
}
row_ptr_end[istr] = ic - 1;
if (fabs(ap) < 1.0e-30) {
printf("zero diagonal elements in string %d", istr);
getchar();
exit(1);
}
else {
//x[istr] /= ap;
}

flag[A[ii].i] = true;
Ak temp = A[ii];
A[ii] = A[icdiag];
A[icdiag] = temp;
A[ii].aij = 1.0 / ap; // ��������� ������� �������.
}
}
*/

// smoother.
// 9 september 2015.
// q - quick.
void seidelq(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd)
{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	integer startpos = istartq + iadd;
	integer endpos = iendq + iadd;
	for (integer ii = startpos; ii <= endpos; ii++) {
		integer istr = ii - iadd;
		x[istr] = b[istr];

		for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++)
		{
			x[istr] += -A[ii1].aij*x[A[ii1].j];
		}
		x[istr] *= A[row_ptr_start[ii]].aij;
	}


} // seidelq

/*
// smoother.
// 9 september 2015.
// q - quick.
// ����� ����������.
void seidelq(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd)
{
// istart - ��������� ������� ��������� ��������� � ������� �.
// iend - �������� ������� ��������� ��������� � ������� �.
integer startpos = istartq + iadd;
integer endpos = iendq + iadd;

//Real *sum=new Real[endpos-startpos+1];

#pragma omp parallel for
for (integer ii = startpos; ii <= endpos; ii++) {
integer istr = ii - iadd;
x[istr] = b[istr];
//	Real sum = 0.0;
//#pragma omp parallel for reduction(+:sum)
for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++)
{
x[istr] += -A[ii1].aij*x[A[ii1].j];
//sum = sum - A[ii1].aij*x[A[ii1].j];
}
//x[istr] += sum;
x[istr] *= A[row_ptr_start[ii]].aij;
}


//for (integer ii = startpos; ii <= endpos; ii++) {
//	integer istr = ii - iadd;
//	x[istr] = sum[istr]*A[row_ptr_start[ii]].aij;
//}


//delete[] sum;
} // seidelq
*/


// residual.
// 2 september 2014
void residual(Ak* &A, integer istart, integer iend, Real* &x, Real* &b, bool* &flag, integer n, Real* &residual)
{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	for (integer i = 1; i <= n; i++) {
		flag[i] = false;
		residual[i] = 0.0;
	}
	for (integer ii = istart; ii <= iend; ii++) {
		if (flag[A[ii].i] == false) {
			integer istr = A[ii].i;
			integer ic = ii;
			residual[istr] = b[istr];
			while ((ic <= iend) && (A[ic].i == istr)) {
				if (A[ic].j != istr)  residual[istr] += -A[ic].aij*x[A[ic].j];
				else residual[istr] += -A[ic].aij*x[istr];
				ic++;
			}
			flag[A[ii].i] = true;
		}
	}


} // residual

// smoother.
// 9 september 2015.
// q - quick.
void residualq(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd, Real* &residual)
{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	integer startpos = istartq + iadd;
	integer endpos = iendq + iadd;
	for (integer ii = startpos; ii <= endpos; ii++) {
		integer istr = ii - iadd;
		residual[istr] = b[istr];
		for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++) { residual[istr] += -A[ii1].aij*x[A[ii1].j]; }
		residual[istr] += (-1.0 / A[row_ptr_start[ii]].aij)*x[istr];
	}


} // residualq

// smoother.
// 9 september 2015.
// q - quick.
void residualqspeshial(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd, Real* &residual)
{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	integer startpos = istartq + iadd;
	integer endpos = iendq + iadd;
	for (integer ii = startpos; ii <= endpos; ii++) {
		integer istr = ii - iadd;
		residual[istr] = b[istr];
		for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++) { residual[istr] += -A[ii1].aij*x[A[ii1].j]; }
		//residual[istr] -=  A[row_ptr_start[ii]].aij*x[istr];
		// 2.0 2.441 2.543 2.546
		//residual[istr] -= 2.0*A[row_ptr_start[ii]].aij*x[istr];
		//Real omega = 1.855; // SOR
		//residual[istr] += ((-1.0 / A[row_ptr_start[ii]].aij)*x[istr]); // ������ �������.
		residual[istr] += ((-1.0 / A[row_ptr_start[ii]].aij)*x[istr]) / 16.0;
		//residual[istr] *= omega;
		// 2.423
		// 1.855 4.448
		// 1.0  5.074
		// 8.713 5.706
	}


} // residualqspeshial

// restriction
// 3 september 2015.
// 6 september 2015.
// ������ ���� ������������� �� i, ������� �� j �������.
void restriction(Ak* &R, integer istart, integer iend, bool* &flag, Real * &x_fine, Real * &x_coarse, integer n_fine, integer n_coarse) {
	// x_coarse[1..n_coarse]=R n_coarse x n_fine*x_fine[1..n_fine];
	for (integer i = 1; i <= n_coarse; i++) {
		flag[i] = false;
	}
	for (integer ii = istart; ii <= iend; ii++) {
		if (flag[R[ii].i] == false) {
			integer istr = R[ii].i;
			integer ic = ii;
			x_coarse[istr] = 0.0;
			while ((ic <= iend) && (R[ic].i == istr)) {
				x_coarse[istr] += R[ic].aij*x_fine[R[ic].j];
				ic++;
			}
			flag[R[ii].i] = true;
		}
	}

} // restriction

// prolongation
// 3 september 2015.
// 6 september 2015.
// ������ ���� ������������� �� j, ������� �� i �������.
// P=transpose(R).
void prolongation(Ak* &P, integer istart, integer iend, bool* &flag, Real * &x_fine, Real * &x_coarse, integer n_fine, integer n_coarse) {
	// x_fine[1..n_fine]=P n_fine x n_coarse*x_coarse[1..n_coarse];
	// P=c*transpose(R); Pij=c*Rji;
	for (integer j = 1; j <= n_fine; j++) {
		flag[j] = false;
	}
	for (integer ii = istart; ii <= iend; ii++) {
		if (flag[P[ii].j] == false) {
			integer jstr = P[ii].j;
			integer ic = ii;
			x_fine[jstr] = 0.0;
			while ((ic <= iend) && (P[ic].j == jstr)) {
				x_fine[jstr] += P[ic].aij*x_coarse[P[ic].i];
				ic++;
			}

			flag[P[ii].j] = true;
		}
	}

} // prolongation

// Evklid norma of vector r in size n.
Real norma(Real * &r, integer n) {
	Real ret = 0.0;
	for (integer ii = 1; ii <= n; ii++) {
		ret += r[ii] * r[ii] / n;
	}
	ret = sqrt(ret);
	return ret;
}

// ������� ������� �������� u � ��������� tecplot 360.
void exporttecplot(Real* u, integer n_size) {
	FILE *fp;
	errno_t err;
	err = fopen_s(&fp, "fedorenko1.PLT", "w");
	// �������� ����� ��� ������.
	if ((err) != 0) {
		printf("Create File Error\n");
	}
	else {
		if (fp != NULL) {
			// ������ ��� ����������
			fprintf_s(fp, "VARIABLES = x y u\n");
			fprintf_s(fp, "zone\n");
			integer m = (int)(sqrt((double)(1.0*n_size)));
			integer n = m;
			Real h = 1.0 / (m - 1);
			fprintf_s(fp, "I=%d, J=%d, K=1, F=POINT\n", m, n);
			for (integer j = 0; j < n; j++) for (integer i = 0; i < m; i++)   fprintf_s(fp, "%e %e %e\n", i*h, j*h, u[i*m + j + 1]);
			fclose(fp);
			WinExec("C:\\Program Files\\Tecplot\\Tecplot 360 EX 2014 R1\\bin\\tec360.exe fedorenko1.PLT", SW_NORMAL);
			//WinExec("C:\\Program\ Files\ (x86)\\Tecplot\\Tec360\ 2008\\bin\\tec360.exe fedorenko1.PLT", SW_NORMAL);
		}
		else {
			printf("Create File Error\n");
		}
	}

	system("PAUSE");

} // exporttecplot

// ������� ���������� �. �����. ����� n*log2(n).
void quickSort_set(integer* &ifrQ, integer left, integer right)
{
	integer i = left, j = right;
	integer tmp;
	integer pivot = ifrQ[(left + right) / 2];

	/* partition */
	while (i <= j) {
		while (ifrQ[i]<pivot)
			i++;
		while (ifrQ[j]>pivot)
			j--;
		if (i <= j) {
			tmp = ifrQ[i];
			ifrQ[i] = ifrQ[j];
			ifrQ[j] = tmp;
			i++;
			j--;
		}
	};

	/* recursion */
	if (left<j)
		quickSort_set(ifrQ, left, j);
	if (i<right)
		quickSort_set(ifrQ, i, right);


}

// �������� �����.
integer BinarySearch(integer* &A, integer key, integer n)
{
	integer left = 0, right = n, mid;
	while (left <= right)
	{
		mid = left + (right - left) / 2;
		if (key<A[mid]) right = mid - 1;
		else if (key>A[mid]) left = mid + 1;
		else {
			// ���� ����������� ��������� ��� mid ����� ����� �������������.
			while ((mid > 0) && (A[mid - 1] == A[mid])) {
				mid--;
			}
			return mid;
		}
	}
	return -1;
}
// �������� �����.
integer BinarySearchAi(Ak* &A, integer key, integer istart, integer iend)
{
	integer left = istart, right = iend, mid;
	while (left <= right)
	{
		mid = left + (right - left) / 2;
		if (key<A[mid].i) right = mid - 1;
		else if (key>A[mid].i) left = mid + 1;
		else {
			// ���� ����������� ��������� ��� mid ����� ����� �������������.
			while ((mid > istart) && (A[mid - 1].i == A[mid].i)) {
				mid--;
			}
			return mid;
		}
	}
	return -1;
}
// �������� �����.
integer BinarySearchAj(Ak* &A, integer key, integer istart, integer iend)
{
	integer left = istart, right = iend, mid;
	while (left <= right)
	{
		mid = left + (right - left) / 2;
		if (key<A[mid].j) right = mid - 1;
		else if (key>A[mid].j) left = mid + 1;
		else {
			// ���� ����������� ��������� ��� mid ����� ����� �������������.
			while ((mid > istart) && (A[mid - 1].j == A[mid].j)) {
				mid--;
			}
			return mid;
		};
	}
	return -1;
}



// 16 �������� 2015 ���� ���������� ��� �������� 
// ���������� � ������������ ������� ���������� �������,
// � ���� ���������� ��� � �����-�� ���� ���������� �� ������������ ������ �������.
// �������� ���������� � ������������� ����� ������� ������ �� ������ ������ �.�. ������� � ����� ������ �������.
// 3 september 2015 Villa Borgese.
integer aggregative_amg(Ak* &A, integer nnz,
	integer n,
	Ak* &R, // restriction
	Ak* &P, // prolongation
	Real* &x, Real* &b) {

	// ���������� ����������� ������� ����������, ������� QuickSort �� ��������.
	bool bquicktypesort = false;


	// x_coarse[1..n_coarse]=R n_coarse x n_fine*x_fine[1..n_fine];
	// x_fine[1..n_fine]=P n_fine x n_coarse*x_coarse[1..n_coarse];

	// ��������� ���������� � �������.

	const integer maxlevel = 30;
	integer ilevel = 1;
	integer nnz_a[maxlevel];
	integer n_a[maxlevel];
	nnz_a[0] = nnz;
	n_a[0] = n;
	bool* flag = new bool[n + 1];
	bool* flag_ = new bool[n + 1];
	integer iadd = 0;
	integer nnzR = 1;
	integer iaddR = 0;
	integer nnz_aRP[maxlevel];
	bool bcontinue = true;

	while ((ilevel<maxlevel - 1) && (n_a[ilevel - 1] > 50) && (bcontinue)) {


		//heapsort(A, key=i*n_a[ilevel - 1] + j, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort(A, 1 + iadd, nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < 100000) {
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[1 + iadd];
				MergeSort(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}

		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			//	printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n",ii,A[ii].aij,ii,A[ii].i,ii,A[ii].j);
			//if (ii % 20 == 0) getchar();
		}

		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			flag[ii] = false;
		}
		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			A[ii].ind = ii - iadd;
		}



		// Copy(A) �� nnz ����� ������.
		for (integer ii = nnz_a[ilevel - 1] + 1 + iadd; ii <= 2 * nnz_a[ilevel - 1] + iadd; ii++) {
			A[ii] = A[ii - nnz_a[ilevel - 1]];
		}

		// ������� ����� � ���������� � �� j 
		for (integer k = 1 + iadd; k <= nnz_a[ilevel - 1] + iadd; k++) {
			A[k + 2 * nnz_a[ilevel - 1]] = A[k]; // copy
			A[k + 2 * nnz_a[ilevel - 1]].ind = k; // ��������� ����� �� ����������.
		}
		// ���������� �� j.
		if (nnz_a[ilevel - 1] < 100000) {
			HeapSort_j(A,/* n_a[ilevel - 1]*/ 1 + iadd + 2 * nnz_a[ilevel - 1], nnz_a[ilevel - 1] + iadd + 2 * nnz_a[ilevel - 1]);
		}
		else {
			Ak* Aorig = &A[1 + iadd + 2 * nnz_a[ilevel - 1]];
			MergeSort_j(Aorig, nnz_a[ilevel - 1]);
			Aorig = NULL;
		}


		integer n_coarce = 1; // ����� ��������.
		nnzR = 1;
		const integer max_sosed = 27850;
		const integer NULL_SOSED = -1;
		integer vacant = NULL_SOSED;
		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			if (flag[A[ii].i] == false) {
				// ��������� �� ������������������� ������� � (���������� �����).

				Real sum = 0.0;
				integer nnzRl = nnzR + iaddR;

				integer set[max_sosed]; // �� ����� 20 ����� � ����� ��������.
				// ������������� ������ ��������� ��� �� ����� � ��� ������ �������� ��������������.
				//for (integer js = 0; js < max_sosed; js++) {
				//set[js] = NULL_SOSED;
				//}
				integer ic = 0;
				set[ic] = A[ii].i;
				Real theta = 0.25; // �������� ����� ������� ������ ����� �����������.
				Real max_vnediagonal = -1.0; // ������������ �������� ������ ��� ������������� ��������. 
				// ��������� ������������ �������.
				for (integer is0 = ii; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == set[0]); is0++) {
					if (A[is0].j == set[0]) {
						sum += fabs(A[is0].aij);
						R[nnzRl].aij = fabs(A[is0].aij);
						R[nnzRl].i = n_coarce; // ������ ������ �����
						R[nnzRl].j = set[0]; //������ �� ��������� �����.
						nnzRl++;
						break;
					}
					else {
						if (fabs(A[is0].aij) > max_vnediagonal) {
							max_vnediagonal = fabs(A[is0].aij);
						}
					}
				}

				ic++;



				// ���� ���� j ��� �� ��� �������� � �������.
				if (flag[A[ii].j] == false) {
					if ((A[ii].j != set[0]) && (fabs(A[ii].aij) >= theta*max_vnediagonal)) {
						vacant = A[ii].j;
						for (integer js = 0; js < ic; js++) {
							if (vacant == set[js]) {
								vacant = NULL_SOSED;
							}
						}
						if (vacant != NULL_SOSED) {
							set[ic] = vacant;
							sum += fabs(A[ii].aij);
							R[nnzRl].aij = fabs(A[ii].aij);
							R[nnzRl].i = n_coarce;
							R[nnzRl].j = vacant;
							nnzRl++;
							ic++;
						}
					}
				}
				integer iscan = ii + 1;
				while ((iscan <= nnz_a[ilevel - 1] + iadd) && (A[iscan].i == set[0])) {
					// ���� ���� j ��� �� ��� �������� � �������.
					if (flag[A[iscan].j] == false) {
						if ((A[iscan].j != set[0]) && (fabs(A[iscan].aij) >= theta*max_vnediagonal)) {
							vacant = A[iscan].j;
							for (integer js = 0; js < ic; js++) {
								if (vacant == set[js]) {
									vacant = NULL_SOSED;
								}
							}
							if (vacant != NULL_SOSED) {
								set[ic] = vacant;
								sum += fabs(A[iscan].aij);
								R[nnzRl].aij = fabs(A[iscan].aij);
								R[nnzRl].i = n_coarce;
								R[nnzRl].j = vacant;
								nnzRl++;
								ic++;

							}
						}
					}

					iscan++;

				} // while

				// R restriction.
				for (integer k1 = 0; k1 < ic; k1++) {
					R[nnzR + iaddR].aij /= sum;
					nnzR++;
				}


				//{
				//integer* Aset = new integer[ic];
				//for (integer ii3 = 0; ii3 < ic; ii3++) Aset[ii3] = set[ii3]; // copy
				// HeapSort(Aset,0,ic-1);
				//quickSort_set(Aset, 0, ic - 1);

				// bynarySearh 88.56%
				// aggregativeamg 8.89%
				// seidel 0.87%
				// (i,j) -> (I,J)
				// ������������ ����� A ����������� ������.
				//for (integer k = nnz_a[ilevel - 1] + 1 + iadd; k <= 2 * nnz_a[ilevel - 1] + iadd; k++) {
				//bool found = false;

				//if (BinarySearch(Aset, A[k - nnz_a[ilevel - 1]].i, ic - 1) > -1) found = true;
				//for (integer k1 = 0; k1 < ic; k1++) {
				//	if (A[k - nnz_a[ilevel - 1]].i == set[k1]) found = true;
				//	}
				//if (found) A[k].i = n_coarce;
				//found = false;
				//if (BinarySearch(Aset, A[k - nnz_a[ilevel - 1]].j, ic - 1) > -1) found = true;

				//for (integer k1 = 0; k1 < ic; k1++) {
				//if (A[k - nnz_a[ilevel - 1]].j == set[k1]) found = true;
				//}

				//if (found) A[k].j = n_coarce;

				//}

				//delete[] Aset;
				//}


				{
					// 7 �������� 2015.
					// �� ��������������� ��� ��� � ����������� �� i.
					for (integer k1 = 0; k1 < ic; k1++) {
						integer key = set[k1];
						integer ifound = BinarySearchAi(A, key, 1 + iadd, nnz_a[ilevel - 1] + iadd);
						if (ifound > -1) {
							integer if1 = ifound;
							while ((if1 <= nnz_a[ilevel - 1] + iadd) && (A[if1].i == key)){
								A[if1 + nnz_a[ilevel - 1]].i = n_coarce;
								if1++;
							}
							if1 = ifound - 1;
							while ((if1 >= 1 + iadd) && (A[if1].i == key)){
								A[if1 + nnz_a[ilevel - 1]].i = n_coarce;
								if1--;
							}

						}
					}
					// ����������� � �� ������ ������� � ���������� �� j. �������� �������� � ����� ������.
					// � ������� ���� ����� ��� j.
					// �� ��������������� ��� ��� � ����������� �� j.
					for (integer k1 = 0; k1 < ic; k1++) {
						integer key = set[k1];
						integer ifound = BinarySearchAj(A, key, 1 + iadd + 2 * nnz_a[ilevel - 1], nnz_a[ilevel - 1] + iadd + 2 * nnz_a[ilevel - 1]);
						if (ifound > -1) {
							integer if1 = ifound;
							while ((if1 <= nnz_a[ilevel - 1] + iadd + 2 * nnz_a[ilevel - 1]) && (A[if1].j == key)) {
								A[A[if1].ind + nnz_a[ilevel - 1]].j = n_coarce;
								if1++;
							}
							if1 = ifound - 1;
							while ((if1 >= 1 + iadd + 2 * nnz_a[ilevel - 1]) && (A[if1].j == key)) {
								A[A[if1].ind + nnz_a[ilevel - 1]].j = n_coarce;
								if1--;
							}

						}
					}
					// ��������� ������ � ������� 1 + iadd + 2 * nnz_a[ilevel - 1]..nnz_a[ilevel - 1] + iadd + 2 * nnz_a[ilevel - 1]
					// ������ �������.

				}


				// �������� ���� ��� ���������� � �������.
				for (integer js = 0; js < ic; js++) {
					flag[set[js]] = true;
				}

				n_coarce++;

				// ���� ������� ������.



			} // ���� �� ��� ��� ������� � �������.
		} // �������� �������.


		// ���������� ������ � ������� ������ ��������� ���������������.
		//for (integer ii = 1; ii <= n; ii++) {
		//flag_[ii] = false;
		//}
		//for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
		//if (flag_[R[ii].i] == false) {
		//integer istr = R[ii].i;
		//integer ic7 = ii;
		//while ((ic7 <= iaddR + nnzR - 1) && (R[ic7].i == istr)) {
		//printf("%e ", R[ic7].aij);
		//ic7++;
		//}
		//printf("\n");
		//system("pause");
		//flag_[R[ii].i] = true;
		//}
		//}


		// �������� restriction �������� � �� ���������� �� i.
		// ����� ��������� ��������� nnzR-1.
		// P=Copy(R);
		for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
			P[ii] = R[ii];
			//printf("ii=%d aij=%e, i=%d j=%d\n",ii,P[ii].aij,P[ii].i,P[ii].j);
			//getchar();
		}

		// heapsort(P,key==j,iaddR+1,iaddR+nnzR - 1);
		if (bquicktypesort) {
			QuickSort_j(P, 1 + iaddR, iaddR + nnzR - 1);
		}
		else {
			HeapSort_j(P, /*n_a[ilevel-1]*/ 1 + iaddR, iaddR + nnzR - 1);
		}

		// �������� ������������ ��� �� ������ ����������������� �������� �������� �
		// � ����������������� �������� �������� ���������� �� ���������. ��������� 
		// ������������ �� ���������� ����������� : ���� ����� ��������� ��������� ���������� � ����� �������,
		// �� �������������� � ������� � ��������� ������������ ������������ ������� ����� �������.
		// ���� ��� ����������� ������ ���� ������� ����� ���� ����������-������������ ���� �����.

		for (integer ii = 1; ii <= n; ii++) {
			flag_[ii] = false;
		}
		Real mul = -1.e30;
		for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
			if (flag_[P[ii].j] == false) {
				integer jstr = P[ii].j;
				integer ic7 = ii;
				mul = -1.e30;
				while ((ic7 <= iaddR + nnzR - 1) && (P[ic7].j == jstr)) {
					if (fabs(P[ic7].aij) > mul) {
						mul = fabs(P[ic7].aij);
					}
					ic7++;
				}
				ic7 = ii;
				while ((ic7 <= iaddR + nnzR - 1) && (P[ic7].j == jstr)) {
					P[ic7].aij /= mul; // ������������ ������� �������.
					ic7++;
				}
				flag_[P[ii].j] = true;
			}
		}

		//for (integer ii = 1; ii <= n; ii++) {
		//flag_[ii] = false;
		//}
		//for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
		//if (flag_[P[ii].j] == false) {
		//integer jstr = P[ii].j;
		//integer ic7 = ii;
		//while ((ic7 <= iaddR + nnzR - 1) && (P[ic7].j == jstr)) {
		//printf("%e ",P[ic7].aij);
		//ic7++;
		//}
		//printf("\n");
		//system("pause");
		//flag_[P[ii].j] = true;
		//}
		//}




		nnz_aRP[ilevel - 1] = nnzR - 1;
		iaddR += nnzR - 1;

		//printf("%d %d\n",n,n_coarce-1);
		//getchar();
		n_a[ilevel] = n_coarce - 1;

		// ���������� �� ������ ����� key=i*(iglcoarce_number-1)+j;
		// � ������� ind ������� ������ ���������� �������.
		//heapsort(A, key = i*(n_coarce - 1) + j, nnz + 1, 2 * nnz);
		if (bquicktypesort) {
			QuickSort(A, /*n_coarce - 1,*/ nnz_a[ilevel - 1] + 1 + iadd, 2 * nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < 100000) {
				HeapSort(A, n_coarce - 1, nnz_a[ilevel - 1] + 1 + iadd, 2 * nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[nnz_a[ilevel - 1] + 1 + iadd];
				MergeSort(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}

		for (integer ii = 1 + nnz_a[ilevel - 1] + iadd; ii <= 2 * nnz_a[ilevel - 1] + iadd; ii++) {
			//	printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n",ii,A[ii].aij,ii,A[ii].i,ii,A[ii].j);
			//if (ii % 20 == 0) getchar();
		}



		// ����������� � ������ ����� ������� ���� �� coarce �����.
		// �������������.
		// ����� ������ 1 nnz �� fine ������.
		for (integer ii = 2 * nnz_a[ilevel - 1] + 1 + iadd; ii <= 3 * nnz_a[ilevel - 1] + iadd; ii++) {
			A[ii].aij = 0.0;
			A[ii].ind = NULL_SOSED;
			A[ii].i = NULL_SOSED;
			A[ii].j = NULL_SOSED;
		}

		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) flag[ii] = false;


		integer ic1 = 2 * nnz_a[ilevel - 1] + 1 + iadd;
		integer im = 1;
		integer im0 = 0;
		for (integer ii = nnz_a[ilevel - 1] + 1 + iadd; ii <= 2 * nnz_a[ilevel - 1] + iadd; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				while ((ii + im0 <= 2 * nnz_a[ilevel - 1] + iadd) && (istr == A[ii + im0].i)) {

					if (ic1 <= 3 * nnz_a[ilevel - 1] + iadd) {
						A[ic1].i = A[ii + im0].i;
						A[ic1].j = A[ii + im0].j;
						A[ic1].aij += A[ii + im0].aij;
						while ((ii + im <= 2 * nnz_a[ilevel - 1] + iadd) && (A[ii + im0].i == A[ii + im].i) && (A[ii + im0].j == A[ii + im].j))
						{
							A[ic1].aij += A[ii + im].aij;
							im++;
						}
						ic1++;
						im0 = im;
						im++;
					}
					else {
						printf("error 1\n");
						system("PAUSE");
					}
				}
				flag[A[ii].i] = true;
				im = 1;
				im0 = 0;
			}
		}

		nnz_a[ilevel] = ic1 - 1 - 2 * nnz_a[ilevel - 1] - iadd;
		iadd += 2 * nnz_a[ilevel - 1];

		printf("nnz : fine=%d, coarse=%d, operator complexity=%e. \n", nnz_a[ilevel - 1], nnz_a[ilevel], (double)(nnz_a[ilevel]) / (double)(nnz_a[ilevel - 1]));
		printf("n : fine=%d, coarse=%d grid complexity=%e.\n", n_a[ilevel - 1], n_a[ilevel], (double)(n_a[ilevel]) / (double)(n_a[ilevel - 1]));
		printf("nnz_aRP = %d\n", nnz_aRP[ilevel - 1]);
		//getchar();

		ilevel++;// ������������� ������� ���������.
		if (ilevel >= 2) {
			if (n_a[ilevel - 2] <= n_a[ilevel - 1]) bcontinue = false;
		}

	} // �������� ����� ���������.

	//for (integer ii = 1; ii <= nnz_aRP[0] + nnz_aRP[1]; ii++) {
	//printf("ii=%d aij=%e, i=%d j=%d\n", ii, R[ii].aij, R[ii].i, R[ii].j);
	//getchar();
	//}


	//exporttecplot(b,n);

	//Real *test_coarse = new Real[n_a[1] + 1];

	// restriction
	//restriction(R, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);
	//for (integer ii = 1; ii <= n_a[0]; ii++) {
	//b[ii] = 0.0;
	//}

	//{
	//Real *test_coarse1 = new Real[n_a[2] + 1];

	// restriction
	//restriction(R, 1+nnz_aRP[0], nnz_aRP[0]+nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
	//for (integer ii = 1; ii <= n_a[1]; ii++) {
	//test_coarse[ii] = 0.0;
	//}

	//{
	//	Real *test_coarse2 = new Real[n_a[3] + 1];

	// restriction
	//restriction(R, 1 + nnz_aRP[0]+nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1]+nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
	//for (integer ii = 1; ii <= n_a[2]; ii++) {
	//test_coarse1[ii] = 0.0;
	//}

	//prolongation(P, 1 + nnz_aRP[0]+ nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
	//}

	//prolongation(P, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
	//}

	//prolongation(P, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);

	//exporttecplot(b, n);


	// ���������� ������� � cycling:

	// smoother.
	// 1 september 2015.
	//void seidel(Ak* &A, integer istart, integer iend, Real* &x, Real* &b, bool* &flag, integer n)
	//{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	//for (integer i = 1; i <= n; i++) {
	//flag[i] = false;
	//}
	//for (integer ii = istart; ii <= iend; ii++) {
	//if (flag[A[ii].i] == false) {
	//integer istr = A[ii].i;
	//integer ic = ii;
	//Real ap = 0.0;
	//x[istr] = b[istr];
	//while ((ic<=iend)&&(A[ic].i == istr)) {
	//if (A[ic].j != istr) {
	//x[istr] += -A[ic].aij*x[A[ic].j];
	//}
	//else ap = A[ic].aij;
	//ic++;
	//}
	//if (fabs(ap) < 1.0e-30) {
	//printf("zero diagonal elements in string %d",istr);
	//getchar();
	//exit(1);
	//}
	//else {
	//x[istr] /= ap;
	//}
	//flag[A[ii].i] = true;
	//}
	//}


	//} // seidel


	integer *row_ptr_start = new integer[4 * n_a[0] + 1];
	integer *row_ptr_end = new integer[4 * n_a[0] + 1];
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	for (integer i = 1; i <= n; i++) {
		flag[i] = false;
	}
	for (integer ii = 1; ii <= nnz_a[0]; ii++) {
		if (flag[A[ii].i] == false) {
			integer istr = A[ii].i;
			integer ic = ii;
			integer icdiag = ii;
			row_ptr_start[istr] = ii;
			Real ap = 0.0;
			//x[istr] = b[istr];
			while ((ic <= nnz_a[0]) && (A[ic].i == istr)) {
				if (A[ic].j != istr) {
					//x[istr] += -A[ic].aij*x[A[ic].j];
				}
				else {
					ap = A[ic].aij;
					icdiag = ic;
				}
				ic++;
			}
			row_ptr_end[istr] = ic - 1;
			if (fabs(ap) < 1.0e-30) {
				printf("zero diagonal elements in string %d", istr);
				system("PAUSE");
				exit(1);
			}
			else {
				//x[istr] /= ap;
			}

			flag[A[ii].i] = true;
			Ak temp = A[ii];
			A[ii] = A[icdiag];
			A[icdiag] = temp;
			A[ii].aij = 1.0 / ap; // ��������� ������� �������.
		}
	}
	// ������ ������� �����������.
	if (ilevel > 1) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		for (integer ii = 2 * nnz_a[0] + 1; ii <= 2 * nnz_a[0] + nnz_a[1]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= 2 * nnz_a[0] + nnz_a[1]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}

	// ������ ������� �����������.

	if (ilevel > 2) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		for (integer ii = 2 * nnz_a[0] + 2 * nnz_a[1] + 1; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// ������ ������� �����������.

	if (ilevel > 3) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		for (integer ii = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 1; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// 14 �������� 2015 �����������
	// �������� ������� �����������.

	if (ilevel > 4) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 1;
		integer iend = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// ����� ������� �����������.

	if (ilevel > 5) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 1;
		integer iend = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}

	// ������ ������� �����������.

	if (ilevel > 6) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 1;
		integer iend = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]] = ic - 1;
				if (fabs(ap) < 1.0e-30) {
					printf("zero diagonal elements in string %d", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}




	// smoother.
	// 9 september 2015.
	// q - quick.
	// seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);
	//void seidelq(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd)
	//{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	//integer startpos = istartq + iadd;
	//integer endpos = iendq+iadd;
	//for (integer ii = startpos; ii <= endpos; ii++) {
	//integer istr = ii - iadd;
	//x[istr] = b[istr];
	//for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++)
	//{
	//x[istr] += -A[ii1].aij*x[A[ii1].j]; 
	//}
	//x[istr] *= A[row_ptr_start[ii]].aij;
	//}


	//} // seidelq



	printf("cycling: V cycle.\n");
	printf("level=%d\n", ilevel);
	printf("multigrid R.P.Fedorenko 1961.\n");
	printf("aggregative algebraic multigrid method.\n");
	//system("pause");

	// 10 11 21 multigrid tutorial ����� �����.

	integer nu1 = 4;
	integer nu2 = 3;

	//ilevel = 1; //debug
	Real rho = 1.0;
	Real dres = 1.0;
	int iiter = 1;
	const Real tolerance = 1.0e-12;


	Real *residual_fine = new Real[n_a[0] + 1];
	Real *residual_coarse = NULL;
	Real* error_approx_coarse = NULL;
	Real *residual_fine1 = NULL;
	Real *residual_coarse1 = NULL;
	Real* error_approx_coarse1 = NULL;
	Real *error_approx_fine1 = NULL;
	Real *residual_fine2 = NULL;
	Real *residual_coarse2 = NULL;
	Real* error_approx_coarse2 = NULL;
	Real *error_approx_fine2 = NULL;
	Real *residual_fine3 = NULL;
	Real *residual_coarse3 = NULL;
	Real* error_approx_coarse3 = NULL;
	Real *error_approx_fine3 = NULL;
	Real *residual_fine4 = NULL;
	Real *residual_coarse4 = NULL;
	Real *error_approx_coarse4 = NULL;
	Real *error_approx_fine4 = NULL;
	Real *residual_fine5 = NULL;
	Real *residual_coarse5 = NULL;
	Real* error_approx_coarse5 = NULL;
	Real *error_approx_fine5 = NULL;
	Real *residual_fine6 = NULL;
	Real *residual_coarse6 = NULL;
	Real* error_approx_coarse6 = NULL;
	Real *error_approx_fine6 = NULL;

	if (ilevel > 1) {
		residual_coarse = new Real[n_a[1] + 1];
		error_approx_coarse = new Real[n_a[1] + 1];
		if (ilevel > 2) {
			// residual
			residual_fine1 = new Real[n_a[1] + 1];
			residual_coarse1 = new Real[n_a[2] + 1];
			error_approx_coarse1 = new Real[n_a[2] + 1];
			error_approx_fine1 = new Real[n_a[1] + 1];
			if (ilevel > 3) {
				// residual
				residual_fine2 = new Real[n_a[2] + 1];
				residual_coarse2 = new Real[n_a[3] + 1];
				error_approx_coarse2 = new Real[n_a[3] + 1];
				error_approx_fine2 = new Real[n_a[2] + 1];
				if (ilevel > 4) {
					// residual
					residual_fine3 = new Real[n_a[3] + 1];
					residual_coarse3 = new Real[n_a[4] + 1];
					error_approx_coarse3 = new Real[n_a[4] + 1];
					error_approx_fine3 = new Real[n_a[3] + 1];
					if (ilevel > 5) {
						// residual
						residual_fine4 = new Real[n_a[4] + 1];
						residual_coarse4 = new Real[n_a[5] + 1];
						error_approx_coarse4 = new Real[n_a[5] + 1];
						error_approx_fine4 = new Real[n_a[4] + 1];
						if (ilevel > 6) {
							// residual
							residual_fine5 = new Real[n_a[5] + 1];
							residual_coarse5 = new Real[n_a[6] + 1];
							error_approx_coarse5 = new Real[n_a[6] + 1];
							error_approx_fine5 = new Real[n_a[5] + 1];
							if (ilevel > 7) {
								// residual
								residual_fine6 = new Real[n_a[6] + 1];
								residual_coarse6 = new Real[n_a[7] + 1];
								error_approx_coarse6 = new Real[n_a[7] + 1];
								error_approx_fine6 = new Real[n_a[6] + 1];
							}
						}
					}
				}
			}
		}
	}
	Real *error_approx_fine = new Real[n_a[0] + 1];


	//for (integer iprohod = 0; iprohod < 20; iprohod++) {
	while (dres>tolerance) {

		// smother
		for (integer iter = 0; iter < nu1; iter++) {
			//seidel(A, 1, nnz_a[0], x, b, flag, n_a[0]);
			//quick seidel
			seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);

		}

		//exporttecplot(x, n);

		// residual_r
		//Real *residual_fine = new Real[n_a[0] + 1];
		//residual(A, 1, nnz_a[0], x, b, flag, n_a[0], residual_fine);
		residualq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0, residual_fine);
		dres = norma(residual_fine, n_a[0]);
		printf("%d %e rho=%e\n", iiter, dres, dres / rho);
		iiter++;
		//rho=norma(residual_fine, n_a[0]);
		rho = dres;
		//if (iprohod%5==0) getchar();
		if (ilevel > 1) {

			//Real *residual_coarse = new Real[n_a[1] + 1];

			// restriction
			restriction(R, 1, nnz_aRP[0], flag, residual_fine, residual_coarse, n_a[0], n_a[1]);

			// A*e=r;
			//Real* error_approx_coarse = new Real[n_a[1] + 1];
			for (integer ii = 1; ii <= n_a[1]; ii++) {
				error_approx_coarse[ii] = 0.0;
			}
			// pre smothing
			for (integer iter = 0; iter < nu1; iter++) {
				//seidel(A, 1 + 2 * nnz_a[0], 2 * nnz_a[0] + nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1]);
				seidelq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0]);
			}

			if (ilevel > 2) {
				// residual
				//Real *residual_fine1 = new Real[n_a[1] + 1];
				//residual(A, 1+2*nnz_a[0], 2*nnz_a[0]+nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1], residual_fine1);
				//residualq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0], residual_fine1);
				residualqspeshial(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0], residual_fine1);


				//Real *residual_coarse1 = new Real[n_a[2] + 1];

				// restriction
				restriction(R, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, residual_fine1, residual_coarse1, n_a[1], n_a[2]);

				// A*e=r;
				//Real* error_approx_coarse1 = new Real[n_a[2] + 1];
				for (integer ii = 1; ii <= n_a[2]; ii++) {
					error_approx_coarse1[ii] = 0.0;
				}
				// pre smothing
				for (integer iter = 0; iter < nu1; iter++) {
					//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2]);
					seidelq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1]);
				}
				if (ilevel > 3) {
					// residual
					//Real *residual_fine2 = new Real[n_a[2] + 1];
					//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2], residual_fine2);
					//residualq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0]+n_a[1], residual_fine2);
					residualqspeshial(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1], residual_fine2);

					//Real *residual_coarse2 = new Real[n_a[3] + 1];

					// restriction
					restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, residual_fine2, residual_coarse2, n_a[2], n_a[3]);

					// A*e=r;
					//Real* error_approx_coarse2 = new Real[n_a[3] + 1];
					for (integer ii = 1; ii <= n_a[3]; ii++) {
						error_approx_coarse2[ii] = 0.0;
					}
					// pre smothing
					for (integer iter = 0; iter < nu1; iter++) {
						//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3]);
						seidelq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2]);

					}
					if (ilevel > 4) {
						// residual
						//Real *residual_fine3 = new Real[n_a[3] + 1];
						//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3], residual_fine3);
						//residualq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2], residual_fine3);
						//speshial
						residualqspeshial(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2], residual_fine3);



						//Real *residual_coarse3 = new Real[n_a[4] + 1];

						// restriction
						restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], flag, residual_fine3, residual_coarse3, n_a[3], n_a[4]);

						// A*e=r;
						//Real* error_approx_coarse3 = new Real[n_a[4] + 1];
						for (integer ii = 1; ii <= n_a[4]; ii++) {
							error_approx_coarse3[ii] = 0.0;
						}
						// pre smothing
						for (integer iter = 0; iter < nu1; iter++) {
							//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4]);
							seidelq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3]);
						}
						if (ilevel > 5) {
							// residual
							//Real *residual_fine4 = new Real[n_a[4] + 1];
							//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4], residual_fine4);
							//residualq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3], residual_fine4);
							//speshial 14 september 2015.
							residualqspeshial(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3], residual_fine4);


							//Real *residual_coarse4 = new Real[n_a[5] + 1];

							// restriction
							restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], flag, residual_fine4, residual_coarse4, n_a[4], n_a[5]);

							// A*e=r;
							//Real* error_approx_coarse4 = new Real[n_a[5] + 1];
							for (integer ii = 1; ii <= n_a[5]; ii++) {
								error_approx_coarse4[ii] = 0.0;
							}
							// pre smothing
							for (integer iter = 0; iter < nu1; iter++) {
								//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5]);
								seidelq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]);
							}
							if (ilevel > 6) {
								// residual
								//Real *residual_fine5 = new Real[n_a[5] + 1];
								//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5], residual_fine5);
								//if (ilevel <= 15) {
								residualq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4], residual_fine5);
								//}
								//else {
								// �������� � ������������.
								//speshial 14 september 2015.
								// ��� ��� �������� � ���������� ����� �������� �� ������� ����� � 1��� �����. �����������.
								//residualqspeshial(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4], residual_fine5);
								//}

								//Real *residual_coarse5 = new Real[n_a[6] + 1];

								// restriction
								restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], flag, residual_fine5, residual_coarse5, n_a[5], n_a[6]);

								// A*e=r;
								//Real* error_approx_coarse5 = new Real[n_a[6] + 1];
								for (integer ii = 1; ii <= n_a[6]; ii++) {
									error_approx_coarse5[ii] = 0.0;
								}
								// pre smothing
								for (integer iter = 0; iter < nu1; iter++) {
									//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6]);
									seidelq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]);
								}

								if (ilevel > 7) {
									// residual
									//Real *residual_fine6 = new Real[n_a[6] + 1];
									//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] +2*nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6], residual_fine6);
									residualq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5], residual_fine6);

									//Real *residual_coarse6 = new Real[n_a[7] + 1];

									// restriction
									restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], flag, residual_fine6, residual_coarse6, n_a[6], n_a[7]);

									// A*e=r;
									//Real* error_approx_coarse6 = new Real[n_a[7] + 1];
									for (integer ii = 1; ii <= n_a[7]; ii++) {
										error_approx_coarse6[ii] = 0.0;
									}
									// pre smothing
									for (integer iter = 0; iter < nu1; iter++) {
										seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7]);
									}

									if (ilevel > 8) {
										// residual
										Real *residual_fine7 = new Real[n_a[7] + 1];
										residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7], residual_fine7);


										Real *residual_coarse7 = new Real[n_a[8] + 1];

										// restriction
										restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7], flag, residual_fine7, residual_coarse7, n_a[7], n_a[8]);

										// A*e=r;
										Real* error_approx_coarse7 = new Real[n_a[8] + 1];
										for (integer ii = 1; ii <= n_a[8]; ii++) {
											error_approx_coarse7[ii] = 0.0;
										}
										// pre smothing
										for (integer iter = 0; iter < nu1; iter++) {
											seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + nnz_a[8], error_approx_coarse7, residual_coarse7, flag, n_a[8]);
										}


										if (ilevel > 9) {
											// residual
											Real *residual_fine8 = new Real[n_a[8] + 1];
											integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7];
											integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + nnz_a[8];
											residual(A, n1, n2, error_approx_coarse7, residual_coarse7, flag, n_a[8], residual_fine8);


											Real *residual_coarse8 = new Real[n_a[9] + 1];

											// restriction
											integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7];
											integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
											restriction(R, n3, n4, flag, residual_fine8, residual_coarse8, n_a[8], n_a[9]);

											// A*e=r;
											Real* error_approx_coarse8 = new Real[n_a[9] + 1];
											for (integer ii = 1; ii <= n_a[9]; ii++) {
												error_approx_coarse8[ii] = 0.0;
											}
											// pre smothing
											for (integer iter = 0; iter < nu1; iter++) {
												integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8];
												integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + nnz_a[9];
												seidel(A, n5, n6, error_approx_coarse8, residual_coarse8, flag, n_a[9]);
											}

											if (ilevel > 10) {
												// 8 �������� 2015 ������ ���� 

												// residual
												Real *residual_fine9 = new Real[n_a[9] + 1];
												integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8];
												integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + nnz_a[9];
												residual(A, n1, n2, error_approx_coarse8, residual_coarse8, flag, n_a[9], residual_fine9);


												Real *residual_coarse9 = new Real[n_a[10] + 1];

												// restriction
												integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
												integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
												restriction(R, n3, n4, flag, residual_fine9, residual_coarse9, n_a[9], n_a[10]);

												// A*e=r;
												Real* error_approx_coarse9 = new Real[n_a[10] + 1];
												for (integer ii = 1; ii <= n_a[10]; ii++) {
													error_approx_coarse9[ii] = 0.0;
												}
												// pre smothing
												for (integer iter = 0; iter < nu1; iter++) {
													integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9];
													integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + nnz_a[10];
													seidel(A, n5, n6, error_approx_coarse9, residual_coarse9, flag, n_a[10]);
												}

												if (ilevel > 11) {
													// 8 �������� 2015 ������ ���� 

													// residual
													Real *residual_fine10 = new Real[n_a[10] + 1];
													integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9];
													integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + nnz_a[10];
													residual(A, n1, n2, error_approx_coarse9, residual_coarse9, flag, n_a[10], residual_fine10);


													Real *residual_coarse10 = new Real[n_a[11] + 1];

													// restriction
													integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
													integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
													restriction(R, n3, n4, flag, residual_fine10, residual_coarse10, n_a[10], n_a[11]);

													// A*e=r;
													Real* error_approx_coarse10 = new Real[n_a[11] + 1];
													for (integer ii = 1; ii <= n_a[11]; ii++) {
														error_approx_coarse10[ii] = 0.0;
													}
													// pre smothing
													for (integer iter = 0; iter < nu1; iter++) {
														integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10];
														integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + nnz_a[11];
														seidel(A, n5, n6, error_approx_coarse10, residual_coarse10, flag, n_a[11]);
													}

													if (ilevel > 12) {
														// 11 �������� 2015 ������ ���� 

														// residual
														Real *residual_fine11 = new Real[n_a[11] + 1];
														integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10];
														integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + nnz_a[11];
														residual(A, n1, n2, error_approx_coarse10, residual_coarse10, flag, n_a[11], residual_fine11);


														Real *residual_coarse11 = new Real[n_a[12] + 1];

														// restriction
														integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
														integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
														restriction(R, n3, n4, flag, residual_fine11, residual_coarse11, n_a[11], n_a[12]);

														// A*e=r;
														Real* error_approx_coarse11 = new Real[n_a[12] + 1];
														for (integer ii = 1; ii <= n_a[12]; ii++) {
															error_approx_coarse11[ii] = 0.0;
														}
														// pre smothing
														for (integer iter = 0; iter < nu1; iter++) {
															integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11];
															integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + nnz_a[12];
															seidel(A, n5, n6, error_approx_coarse11, residual_coarse11, flag, n_a[12]);
														}

														if (ilevel > 13) {
															// 11 �������� 2015 ������ ���� 

															// residual
															Real *residual_fine12 = new Real[n_a[12] + 1];
															integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11];
															integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + nnz_a[12];
															residual(A, n1, n2, error_approx_coarse11, residual_coarse11, flag, n_a[12], residual_fine12);


															Real *residual_coarse12 = new Real[n_a[13] + 1];

															// restriction
															integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
															integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
															restriction(R, n3, n4, flag, residual_fine12, residual_coarse12, n_a[12], n_a[13]);

															// A*e=r;
															Real* error_approx_coarse12 = new Real[n_a[13] + 1];
															for (integer ii = 1; ii <= n_a[13]; ii++) {
																error_approx_coarse12[ii] = 0.0;
															}
															// pre smothing
															for (integer iter = 0; iter < nu1; iter++) {
																integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12];
																integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + nnz_a[13];
																seidel(A, n5, n6, error_approx_coarse12, residual_coarse12, flag, n_a[13]);
															}


															if (ilevel > 14) {
																// 11 �������� 2015 ������ ���� 

																// residual
																Real *residual_fine13 = new Real[n_a[13] + 1];
																integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12];
																integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + nnz_a[13];
																residual(A, n1, n2, error_approx_coarse12, residual_coarse12, flag, n_a[13], residual_fine13);


																Real *residual_coarse13 = new Real[n_a[14] + 1];

																// restriction
																integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
																integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																restriction(R, n3, n4, flag, residual_fine13, residual_coarse13, n_a[13], n_a[14]);

																// A*e=r;
																Real* error_approx_coarse13 = new Real[n_a[14] + 1];
																for (integer ii = 1; ii <= n_a[14]; ii++) {
																	error_approx_coarse13[ii] = 0.0;
																}
																// pre smothing
																for (integer iter = 0; iter < nu1; iter++) {
																	integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13];
																	integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + nnz_a[14];
																	seidel(A, n5, n6, error_approx_coarse13, residual_coarse13, flag, n_a[14]);
																}

																if (ilevel > 15) {
																	// 14 �������� 2015 ������ �� ������ � ��. 

																	// residual
																	Real *residual_fine14 = new Real[n_a[14] + 1];
																	integer n1 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13];
																	integer n2 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + nnz_a[14];
																	residual(A, n1, n2, error_approx_coarse13, residual_coarse13, flag, n_a[14], residual_fine14);


																	Real *residual_coarse14 = new Real[n_a[15] + 1];

																	// restriction
																	integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																	integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																	restriction(R, n3, n4, flag, residual_fine14, residual_coarse14, n_a[14], n_a[15]);

																	// A*e=r;
																	Real* error_approx_coarse14 = new Real[n_a[15] + 1];
																	for (integer ii = 1; ii <= n_a[15]; ii++) {
																		error_approx_coarse14[ii] = 0.0;
																	}
																	// pre smothing
																	for (integer iter = 0; iter < nu1; iter++) {
																		integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + 2 * nnz_a[14];
																		integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + 2 * nnz_a[14] + nnz_a[15];
																		seidel(A, n5, n6, error_approx_coarse14, residual_coarse14, flag, n_a[15]);
																	}

																	// post smothing
																	for (integer iter = 0; iter < nu2; iter++) {
																		integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + 2 * nnz_a[14];
																		integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + 2 * nnz_a[14] + nnz_a[15];
																		seidel(A, n5, n6, error_approx_coarse14, residual_coarse14, flag, n_a[15]);
																	}


																	// prolongation
																	// residual_r
																	Real *error_approx_fine14 = new Real[n_a[14] + 1];
																	for (integer ii = 1; ii <= n_a[14]; ii++) {
																		error_approx_fine14[ii] = 0.0;
																	}

																	//for (integer ii = 1; ii <= n_a[15]; ii++) {// debug
																	//printf("error_approx_coarse14[%d]=%e\n",ii, error_approx_coarse14[ii]);

																	//printf("residual_coarse14[%d]=%e\n", ii, residual_coarse14[ii]);
																	//getchar();
																	//}
																	//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]+2*nnz_a[13]+2*nnz_a[14]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12] +2*nnz_a[13]+2*nnz_a[14]+ nnz_a[15]; ii++) {// debug
																	//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
																	//if (ii % 20 == 0) getchar();
																	//}

																	integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																	integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																	prolongation(P, n7, n8, flag, error_approx_fine14, error_approx_coarse14, n_a[14], n_a[15]);

																	// correction
																	for (integer ii = 1; ii <= n_a[14]; ii++) {
																		error_approx_coarse13[ii] += error_approx_fine14[ii];
																	}

																	// free
																	delete[] error_approx_fine14;
																	delete[] error_approx_coarse14;
																	delete[] residual_coarse14;
																	delete[] residual_fine14;

																}


																// post smothing
																for (integer iter = 0; iter < nu2; iter++) {
																	integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13];
																	integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + 2 * nnz_a[13] + nnz_a[14];
																	seidel(A, n5, n6, error_approx_coarse13, residual_coarse13, flag, n_a[14]);
																}


																// prolongation
																// residual_r
																Real *error_approx_fine13 = new Real[n_a[13] + 1];
																for (integer ii = 1; ii <= n_a[13]; ii++) {
																	error_approx_fine13[ii] = 0.0;
																}

																//for (integer ii = 1; ii <= n_a[14]; ii++) {// debug
																//printf("error_approx_coarse13[%d]=%e\n",ii, error_approx_coarse13[ii]);

																//printf("residual_coarse13[%d]=%e\n", ii, residual_coarse13[ii]);
																//getchar();
																//}
																//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]+2*nnz_a[13]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12] +2*nnz_a[13]+ nnz_a[14]; ii++) {// debug
																//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
																//if (ii % 20 == 0) getchar();
																//}

																integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
																integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																prolongation(P, n7, n8, flag, error_approx_fine13, error_approx_coarse13, n_a[13], n_a[14]);

																// correction
																for (integer ii = 1; ii <= n_a[13]; ii++) {
																	error_approx_coarse12[ii] += error_approx_fine13[ii];
																}

																// free
																delete[] error_approx_fine13;
																delete[] error_approx_coarse13;
																delete[] residual_coarse13;
																delete[] residual_fine13;

															}


															// post smothing
															for (integer iter = 0; iter < nu2; iter++) {
																integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12];
																integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + 2 * nnz_a[12] + nnz_a[13];
																seidel(A, n5, n6, error_approx_coarse12, residual_coarse12, flag, n_a[13]);
															}


															// prolongation
															// residual_r
															Real *error_approx_fine12 = new Real[n_a[12] + 1];
															for (integer ii = 1; ii <= n_a[12]; ii++) {
																error_approx_fine12[ii] = 0.0;
															}

															//for (integer ii = 1; ii <= n_a[13]; ii++) {// debug
															//printf("error_approx_coarse12[%d]=%e\n",ii, error_approx_coarse12[ii]);

															//printf("residual_coarse12[%d]=%e\n", ii, residual_coarse12[ii]);
															//getchar();
															//}
															//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]+ nnz_a[13]; ii++) {// debug
															//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
															//if (ii % 20 == 0) getchar();
															//}

															integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
															integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
															prolongation(P, n7, n8, flag, error_approx_fine12, error_approx_coarse12, n_a[12], n_a[13]);

															// correction
															for (integer ii = 1; ii <= n_a[12]; ii++) {
																error_approx_coarse11[ii] += error_approx_fine12[ii];
															}

															// free
															delete[] error_approx_fine12;
															delete[] error_approx_coarse12;
															delete[] residual_coarse12;
															delete[] residual_fine12;

														}



														// post smothing
														for (integer iter = 0; iter < nu2; iter++) {
															integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11];
															integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + 2 * nnz_a[11] + nnz_a[12];
															seidel(A, n5, n6, error_approx_coarse11, residual_coarse11, flag, n_a[12]);
														}


														// prolongation
														// residual_r
														Real *error_approx_fine11 = new Real[n_a[11] + 1];
														for (integer ii = 1; ii <= n_a[11]; ii++) {
															error_approx_fine11[ii] = 0.0;
														}

														//for (integer ii = 1; ii <= n_a[12]; ii++) {// debug
														//printf("error_approx_coarse11[%d]=%e\n",ii, error_approx_coarse11[ii]);

														//printf("residual_coarse11[%d]=%e\n", ii, residual_coarse11[ii]);
														//getchar();
														//}
														//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+ nnz_a[12]; ii++) {// debug
														//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
														//if (ii % 20 == 0) getchar();
														//}

														integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
														integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
														prolongation(P, n7, n8, flag, error_approx_fine11, error_approx_coarse11, n_a[11], n_a[12]);

														// correction
														for (integer ii = 1; ii <= n_a[11]; ii++) {
															error_approx_coarse10[ii] += error_approx_fine11[ii];
														}

														// free
														delete[] error_approx_fine11;
														delete[] error_approx_coarse11;
														delete[] residual_coarse11;
														delete[] residual_fine11;

													}


													// post smothing
													for (integer iter = 0; iter < nu2; iter++) {
														integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10];
														integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + 2 * nnz_a[10] + nnz_a[11];
														seidel(A, n5, n6, error_approx_coarse10, residual_coarse10, flag, n_a[11]);
													}


													// prolongation
													// residual_r
													Real *error_approx_fine10 = new Real[n_a[10] + 1];
													for (integer ii = 1; ii <= n_a[10]; ii++) {
														error_approx_fine10[ii] = 0.0;
													}

													//for (integer ii = 1; ii <= n_a[11]; ii++) {// debug
													//printf("error_approx_coarse10[%d]=%e\n",ii, error_approx_coarse10[ii]);

													//printf("residual_coarse10[%d]=%e\n", ii, residual_coarse10[ii]);
													//getchar();
													//}
													//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+ nnz_a[11]; ii++) {// debug
													//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
													//if (ii % 20 == 0) getchar();
													//}

													integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
													integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
													prolongation(P, n7, n8, flag, error_approx_fine10, error_approx_coarse10, n_a[10], n_a[11]);

													// correction
													for (integer ii = 1; ii <= n_a[10]; ii++) {
														error_approx_coarse9[ii] += error_approx_fine10[ii];
													}

													// free
													delete[] error_approx_fine10;
													delete[] error_approx_coarse10;
													delete[] residual_coarse10;
													delete[] residual_fine10;

												}



												// post smothing
												for (integer iter = 0; iter < nu2; iter++) {
													integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9];
													integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + 2 * nnz_a[9] + nnz_a[10];
													seidel(A, n5, n6, error_approx_coarse9, residual_coarse9, flag, n_a[10]);
												}


												// prolongation
												// residual_r
												Real *error_approx_fine9 = new Real[n_a[9] + 1];
												for (integer ii = 1; ii <= n_a[9]; ii++) {
													error_approx_fine9[ii] = 0.0;
												}

												//for (integer ii = 1; ii <= n_a[10]; ii++) {// debug
												//printf("error_approx_coarse9[%d]=%e\n",ii, error_approx_coarse9[ii]);

												//printf("residual_coarse9[%d]=%e\n", ii, residual_coarse9[ii]);
												//getchar();
												//}
												//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+ nnz_a[10]; ii++) {// debug
												//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
												//if (ii % 20 == 0) getchar();
												//}

												integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
												integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
												prolongation(P, n7, n8, flag, error_approx_fine9, error_approx_coarse9, n_a[9], n_a[10]);

												// correction
												for (integer ii = 1; ii <= n_a[9]; ii++) {
													error_approx_coarse8[ii] += error_approx_fine9[ii];
												}

												// free
												delete[] error_approx_fine9;
												delete[] error_approx_coarse9;
												delete[] residual_coarse9;
												delete[] residual_fine9;

											}

											// post smothing
											for (integer iter = 0; iter < nu2; iter++) {
												integer n5 = 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8];
												integer n6 = 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + 2 * nnz_a[8] + nnz_a[9];
												seidel(A, n5, n6, error_approx_coarse8, residual_coarse8, flag, n_a[9]);
											}


											// prolongation
											// residual_r
											Real *error_approx_fine8 = new Real[n_a[8] + 1];
											for (integer ii = 1; ii <= n_a[8]; ii++) {
												error_approx_fine8[ii] = 0.0;
											}

											//for (integer ii = 1; ii <= n_a[9]; ii++) {// debug
											//printf("error_approx_coarse8[%d]=%e\n",ii, error_approx_coarse8[ii]);

											//printf("residual_coarse8[%d]=%e\n", ii, residual_coarse8[ii]);
											//getchar();
											//}
											//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+ nnz_a[9]; ii++) {// debug
											//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
											//if (ii % 20 == 0) getchar();
											//}

											integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7];
											integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
											prolongation(P, n7, n8, flag, error_approx_fine8, error_approx_coarse8, n_a[8], n_a[9]);

											// correction
											for (integer ii = 1; ii <= n_a[8]; ii++) {
												error_approx_coarse7[ii] += error_approx_fine8[ii];
											}

											// free
											delete[] error_approx_fine8;
											delete[] error_approx_coarse8;
											delete[] residual_coarse8;
											delete[] residual_fine8;

										}

										// post smothing
										for (integer iter = 0; iter < nu2; iter++) {
											seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + 2 * nnz_a[7] + nnz_a[8], error_approx_coarse7, residual_coarse7, flag, n_a[8]);
										}


										// prolongation
										// residual_r
										Real *error_approx_fine7 = new Real[n_a[7] + 1];
										for (integer ii = 1; ii <= n_a[7]; ii++) {
											error_approx_fine7[ii] = 0.0;
										}

										//for (integer ii = 1; ii <= n_a[8]; ii++) {// debug
										//printf("error_approx_coarse7[%d]=%e\n",ii, error_approx_coarse7[ii]);

										//printf("residual_coarse7[%d]=%e\n", ii, residual_coarse7[ii]);
										//getchar();
										//}
										//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+ nnz_a[8]; ii++) {// debug
										//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
										//if (ii % 20 == 0) getchar();
										//}

										prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7], flag, error_approx_fine7, error_approx_coarse7, n_a[7], n_a[8]);

										// correction
										for (integer ii = 1; ii <= n_a[7]; ii++) {
											error_approx_coarse6[ii] += error_approx_fine7[ii];
										}

										// free
										delete[] error_approx_fine7;
										delete[] error_approx_coarse7;
										delete[] residual_coarse7;
										delete[] residual_fine7;

									}


									// post smothing
									for (integer iter = 0; iter < nu2; iter++) {
										seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + 2 * nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7]);
									}


									// prolongation
									// residual_r
									//Real *error_approx_fine6 = new Real[n_a[6] + 1];
									for (integer ii = 1; ii <= n_a[6]; ii++) {
										error_approx_fine6[ii] = 0.0;
									}

									//for (integer ii = 1; ii <= n_a[7]; ii++) {// debug
									//printf("error_approx_coarse6[%d]=%e\n",ii, error_approx_coarse6[ii]);

									//printf("residual_coarse6[%d]=%e\n", ii, residual_coarse6[ii]);
									//getchar();
									//}
									//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+ nnz_a[7]; ii++) {// debug
									//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
									//if (ii % 20 == 0) getchar();
									//}

									prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], flag, error_approx_fine6, error_approx_coarse6, n_a[6], n_a[7]);

									// correction
									for (integer ii = 1; ii <= n_a[6]; ii++) {
										error_approx_coarse5[ii] += error_approx_fine6[ii];
									}

									// free
									//delete[] error_approx_fine6;
									//delete[] error_approx_coarse6;
									//delete[] residual_coarse6;
									//delete[] residual_fine6;

								}

								// post smothing
								for (integer iter = 0; iter < nu2; iter++) {
									//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6]);
									seidelq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]);
								}

								// prolongation
								// residual_r
								//Real *error_approx_fine5 = new Real[n_a[5] + 1];
								for (integer ii = 1; ii <= n_a[5]; ii++) {
									error_approx_fine5[ii] = 0.0;
								}

								//for (integer ii = 1; ii <= n_a[6]; ii++) {// debug
								//printf("error_approx_coarse5[%d]=%e\n",ii, error_approx_coarse5[ii]);

								//printf("residual_coarse5[%d]=%e\n", ii, residual_coarse5[ii]);
								//getchar();
								//}
								//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+ nnz_a[6]; ii++) {// debug
								//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
								//if (ii % 20 == 0) getchar();
								//}

								prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], flag, error_approx_fine5, error_approx_coarse5, n_a[5], n_a[6]);

								// correction
								for (integer ii = 1; ii <= n_a[5]; ii++) {
									error_approx_coarse4[ii] += error_approx_fine5[ii];
								}

								// free
								//delete[] error_approx_fine5;
								//delete[] error_approx_coarse5;
								//delete[] residual_coarse5;
								//delete[] residual_fine5;

							}
							// post smothing
							for (integer iter = 0; iter < nu2; iter++) {
								//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5]);
								seidelq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]);
							}

							// prolongation
							// residual_r
							//Real *error_approx_fine4 = new Real[n_a[4] + 1];
							for (integer ii = 1; ii <= n_a[4]; ii++) {
								error_approx_fine4[ii] = 0.0;
							}

							//for (integer ii = 1; ii <= n_a[5]; ii++) {// debug
							//printf("error_approx_coarse4[%d]=%e\n",ii, error_approx_coarse4[ii]);

							//printf("residual_coarse4[%d]=%e\n", ii, residual_coarse4[ii]);
							//getchar();
							//}
							//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ nnz_a[5]; ii++) {// debug
							//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
							//if (ii % 20 == 0) getchar();
							//}

							prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], flag, error_approx_fine4, error_approx_coarse4, n_a[4], n_a[5]);

							// correction
							for (integer ii = 1; ii <= n_a[4]; ii++) {
								error_approx_coarse3[ii] += error_approx_fine4[ii];
							}

							// free
							//delete[] error_approx_fine4;
							//delete[] error_approx_coarse4;
							//delete[] residual_coarse4;
							//delete[] residual_fine4;

						}
						// post smothing
						for (integer iter = 0; iter < nu2; iter++) {
							//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4]);
							seidelq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3]);
						}

						// prolongation
						// residual_r
						//Real *error_approx_fine3 = new Real[n_a[3] + 1];
						for (integer ii = 1; ii <= n_a[3]; ii++) {
							error_approx_fine3[ii] = 0.0;
						}

						//for (integer ii = 1; ii <= n_a[4]; ii++) {// debug
						//printf("error_approx_coarse3[%d]=%e\n",ii, error_approx_coarse3[ii]);

						//printf("residual_coarse3[%d]=%e\n", ii, residual_coarse3[ii]);
						//getchar();
						//}
						//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ nnz_a[4]; ii++) {// deug
						//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
						//if (ii % 20 == 0) getchar();
						//}

						prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], flag, error_approx_fine3, error_approx_coarse3, n_a[3], n_a[4]);

						// correction
						for (integer ii = 1; ii <= n_a[3]; ii++) {
							error_approx_coarse2[ii] += error_approx_fine3[ii];
						}

						// free
						//delete[] error_approx_fine3;
						//delete[] error_approx_coarse3;
						//delete[] residual_coarse3;
						//delete[] residual_fine3;

					}
					// post smothing
					for (integer iter = 0; iter < nu2; iter++) {
						//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3]);
						seidelq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2]);

					}

					// prolongation
					// residual_r
					//Real *error_approx_fine2 = new Real[n_a[2] + 1];
					for (integer ii = 1; ii <= n_a[2]; ii++) {
						error_approx_fine2[ii] = 0.0;
					}

					//for (integer ii = 1; ii <= n_a[3]; ii++) {// deug
					//printf("error_approx_coarse2[%d]=%e\n",ii, error_approx_coarse2[ii]);

					//printf("residual_coarse2[%d]=%e\n", ii, residual_coarse2[ii]);
					//getchar();
					//}
					//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ nnz_a[3]; ii++) {// deug
					//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
					//if (ii % 20 == 0) getchar();
					//}

					prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, error_approx_fine2, error_approx_coarse2, n_a[2], n_a[3]);

					// correction
					for (integer ii = 1; ii <= n_a[2]; ii++) {
						error_approx_coarse1[ii] += error_approx_fine2[ii];
					}

					// free
					//delete[] error_approx_fine2;
					//delete[] error_approx_coarse2;
					//delete[] residual_coarse2;
					//delete[] residual_fine2;

				}
				// post smothing
				for (integer iter = 0; iter < nu2; iter++) {
					//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2]);
					seidelq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1]);
				}

				// prolongation
				// residual_r
				//Real *error_approx_fine1 = new Real[n_a[1] + 1];
				for (integer ii = 1; ii <= n_a[1]; ii++) {
					error_approx_fine1[ii] = 0.0;
				}

				//for (integer ii = 1; ii <= n_a[2]; ii++) {// deug
				//printf("error_approx_coarse1[%d]=%e\n",ii, error_approx_coarse1[ii]);

				//printf("residual_coarse1[%d]=%e\n", ii, residual_coarse1[ii]);
				//getchar();
				//}
				//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2]; ii++) {// deug
				//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
				//if (ii % 20 == 0) getchar();
				//}

				prolongation(P, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, error_approx_fine1, error_approx_coarse1, n_a[1], n_a[2]);

				// correction
				for (integer ii = 1; ii <= n_a[1]; ii++) {
					error_approx_coarse[ii] += error_approx_fine1[ii];
				}

				// free
				//delete[] error_approx_fine1;
				//delete[] error_approx_coarse1;
				//delete[] residual_coarse1;
				//delete[] residual_fine1;

			}

			// post smothing
			for (integer iter = 0; iter < nu2; iter++) {
				//seidel(A, 1 + 2 * nnz_a[0], 2 * nnz_a[0] + nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1]);
				seidelq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0]);
			}

			// prolongation
			// residual_r
			//Real *error_approx_fine = new Real[n_a[0] + 1];
			for (integer ii = 1; ii <= n_a[0]; ii++) {
				error_approx_fine[ii] = 0.0;
			}

			prolongation(P, 1, nnz_aRP[0], flag, error_approx_fine, error_approx_coarse, n_a[0], n_a[1]);

			// correction
			for (integer ii = 1; ii <= n_a[0]; ii++) {
				x[ii] += error_approx_fine[ii];
			}

			// free
			//delete[] error_approx_fine;
			//delete[] error_approx_coarse;
			//delete[] residual_coarse;
			//delete[] residual_fine;
		}
		// post smother
		for (integer iter = 0; iter < nu2; iter++) {
			//seidel(A, 1, nnz_a[0], x, b, flag, n_a[0]);
			//quick seidel
			seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);
		}
	}

	system("pause");

	// free
	delete[] error_approx_fine;
	if (ilevel > 1) {
		delete[] error_approx_coarse;
		delete[] residual_coarse;
		if (ilevel > 2) {
			// free
			delete[] error_approx_fine1;
			delete[] error_approx_coarse1;
			delete[] residual_coarse1;
			delete[] residual_fine1;
			if (ilevel > 3) {
				// free
				delete[] error_approx_fine2;
				delete[] error_approx_coarse2;
				delete[] residual_coarse2;
				delete[] residual_fine2;
				if (ilevel > 4) {
					// free
					delete[] error_approx_fine3;
					delete[] error_approx_coarse3;
					delete[] residual_coarse3;
					delete[] residual_fine3;
					if (ilevel > 5) {
						// free
						delete[] error_approx_fine4;
						delete[] error_approx_coarse4;
						delete[] residual_coarse4;
						delete[] residual_fine4;
						if (ilevel > 6) {
							// free
							delete[] error_approx_fine5;
							delete[] error_approx_coarse5;
							delete[] residual_coarse5;
							delete[] residual_fine5;
							if (ilevel > 7) {
								// free
								delete[] error_approx_fine6;
								delete[] error_approx_coarse6;
								delete[] residual_coarse6;
								delete[] residual_fine6;
							}
						}
					}
				}
			}
		}
	}
	delete[] residual_fine;

	delete[] row_ptr_start;
	delete[] row_ptr_end;
	return 0;

} // aggregative_amg

// ���������� �������� �� ���� ����� �����.
integer i_my_max(integer ia, integer ib) {
	if (ia > ib) {
		return ia;
	}
	else {
		return ib;
	}
}

// ���������� ������� �� ���� ����� �����.
integer i_my_min(integer ia, integer ib) {
	if (ia > ib) {
		return ib;
	}
	else {
		return ia;
	}
}

// 18 ������� 2015. ��������� ��������������� ����������.
// ������������� �� �������� ������� �� ������ �������� �� ����� 
// ������� �������. 18 ������� ���������� ������ 0.04. ������ 0.04 �� �����
// ������� ������ 0_03. ���� �������� ��� �������� ���������� C-F ���������, 
// ��� � ���������� ��������� ��������. ��� ���������� �-F ��������� 
// ����������� ��� ������������ ��� ����� � ������� ����� ������������ ��
// �� ������� ������ ����������� ��������� ������ �� ����������� �����.
// ��� ���������� ����������� �������� �������� ����� ����������� �� ������������� ������,
// ���������� �� ��������� ������� ��������������� �������.
// 4 ������� ���������� ���������� ������������������ ��������� ������.
// 30 �������� ���������� ����������� ������. ������ ������������ 
// �������������� ������������� ����� �� ������  C-F ���������.
// 16 �������� 2015 ���� ���������� ��� �������� 
// ���������� � ������������ ������� ���������� �������,
// � ���� ���������� ��� � �����-�� ���� ���������� �� ������������ ������ �������.
// �������� ���������� � ������������� ����� ������� ������ �� ������ ������ �.�. ������� � ����� ������ �������.
// 3 september 2015 Villa Borgese.
integer classic_aglomerative_amg1(Ak* &A, integer nnz,
	integer n, // dimension of vectors x and b.
	Ak* &R, // restriction
	Ak* &P, // prolongation
	Ak* &Atemp,
	Ak* &Atemp2,
	Real* &x, Real* &b,
	Real theta,
	bool &bamgdivergencedetected
	) {


    bamgdivergencedetected=false;
	
	// �������� ����� ������� ������ ����� �����������.
	// Real theta = 0.25;  // 0.25 for 2D and 0.5 for 3D 

	bool blite_and_quick_version = false;
	// false ��� ����� ������������ ���������� �������� ������, 
	// � ��� ���������� �������� �����������.
	const integer heapsortsizelimit = 10000000; // 10M

	const Real RealZERO = 1.0e-300;// 1.0e-10;
	const Real divisionZERO = 1.0e-300;
	const Real RealMAXIMUM = 1.0e300;
	// ���������/���������� ����������� ������.
	bool debug_reshime = false;

	const integer max_sosed = 27850;
	// �� ����� ������������ ���������� � ������������ ���������� �������.
	integer Maximumsosedcount = -1;
	// �� ������� ���������� ����� �������� � ������������ ����� ������� � ������� �,
	// ����� � ���������� ���������� C-F ���������.
	integer icandidate_shadow = -1;
	bool bmaxsosedinfoactive = false;

	// ���������� ����������� ������� ����������, ������� QuickSort �� ��������.
	bool bquicktypesort = false;


	// x_coarse[1..n_coarse]=R n_coarse x n_fine*x_fine[1..n_fine];
	// x_fine[1..n_fine]=P n_fine x n_coarse*x_coarse[1..n_coarse];

	// ��������� ���������� � �������.

	const integer maxlevel = 30;
	integer ilevel = 1;
	integer nnz_a[maxlevel];
	integer n_a[maxlevel];
	nnz_a[0] = nnz;
	n_a[0] = n;
	bool* flag = new bool[n + 1];
	//bool* flag_ = new bool[n + 1];
	bool* flag_shadow = new bool[n + 1];
	integer iadd = 0;
	integer nnzR = 1;
	integer iaddR = 0;
	integer nnz_aRP[maxlevel];
	bool bcontinue = true;
	bool* this_is_C_node = new bool[n + 1];
	bool* this_is_F_node = new bool[n + 1];

	// ������ ������� ����� F �����
	const integer imaxpoolsize = 2000;
	integer pool_sosed[imaxpoolsize];
	integer imax_pool_ind;

	while ((ilevel < maxlevel - 1) && (n_a[ilevel - 1] > 50) && (bcontinue)) {

		Maximumsosedcount = -1;
		bmaxsosedinfoactive = false;

		if (ilevel > 1) {
			if (n_a[ilevel - 2] == n_a[ilevel - 1]) break;
		}

		if (((ilevel > 1) && (nnz_a[ilevel - 1] > nnz_a[ilevel - 2]))) {
			//break;
		}

		// level info.
		if (ilevel == 2) {
			printf("ilevel=%d", ilevel);
			printf("n_a[0]=%d n_a[1]=%d nnz_a[0]=%d nnz_a[1]=%d iadd=%d\n", n_a[0], n_a[1], nnz_a[0], nnz_a[1], iadd);
			if (debug_reshime) system("pause");
		}
		if (ilevel == 3) {
			printf("ilevel=%d", ilevel);
			printf("n_a[0]=%d n_a[1]=%d n_a[2]=%d nnz_a[0]=%d nnz_a[1]=%d nnz_a[2]=%d iadd=%d\n", n_a[0], n_a[1], n_a[2], nnz_a[0], nnz_a[1], nnz_a[2], iadd);
			if (debug_reshime) system("pause");
		}
		if (ilevel == 4) {
			printf("ilevel=%d", ilevel);
			printf("n_a[0]=%d n_a[1]=%d n_a[2]=%d n_a[3]=%d \n", n_a[0], n_a[1], n_a[2], n_a[3]);
			printf("nnz_a[0]=%d nnz_a[1]=%d nnz_a[2]=%d nnz_a[3]=%d iadd=%d\n", nnz_a[0], nnz_a[1], nnz_a[2], nnz_a[3], iadd);
			if (debug_reshime) system("pause");
		}

		if ((ilevel == 5) || (ilevel == 6) || (ilevel == 7) || (ilevel == 8) || (ilevel == 9) || (ilevel == 10)) {
			printf("ilevel=%d\n", ilevel);
			for (integer i_1 = 0; i_1 < ilevel; i_1++) {
				printf("n_a[%d]=%d nnz_a[%d]=%d\n", i_1, n_a[i_1], i_1, nnz_a[i_1]);
			}
			if (debug_reshime) system("pause");
		}

		if ((ilevel == 11) || (ilevel == 12) || (ilevel == 13) || (ilevel == 14) || (ilevel == 15)) {
			printf("ilevel=%d\n", ilevel);
			for (integer i_1 = 0; i_1 < ilevel; i_1++) {
				printf("n_a[%d]=%d nnz_a[%d]=%d\n", i_1, n_a[i_1], i_1, nnz_a[i_1]);
			}
			if (debug_reshime) system("pause");
		}

		if ((ilevel == 16) || (ilevel == 17) || (ilevel == 18) || (ilevel == 19) || (ilevel == 20)) {
			printf("ilevel=%d\n", ilevel);
			for (integer i_1 = 0; i_1 < ilevel; i_1++) {
				printf("n_a[%d]=%d nnz_a[%d]=%d\n", i_1, n_a[i_1], i_1, nnz_a[i_1]);
			}
			if (debug_reshime) system("pause");
		}

		if (ilevel > 17) {
			printf("very big matrix (mesh). no programming.\n");
			system("pause");
			exit(1);
		}

		//nnzR = 1;

		for (int ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			this_is_C_node[ii] = false;
			this_is_F_node[ii] = false;
		}

		for (int ii = n_a[ilevel - 1]; ii <= n; ii++) {
			this_is_C_node[ii] = false;
			this_is_F_node[ii] = false;
		}

		// ���������� ��������  �  �� i.
		//heapsort(A, key=i*n_a[ilevel - 1] + j, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort(A, /*n_a[ilevel - 1],*/ 1 + iadd, nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < heapsortsizelimit) {
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[1 + iadd];
				MergeSort(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}

		// ���������� ��������� ���������� ����� �������.
		integer band_size = -1;
		integer band_size_i = -1;
		for (integer i_1 = 1; i_1 <= n; i_1++) {
			flag[i_1] = false;
		}
		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			if (!flag[A[ii].i]) {
				flag[A[ii].i] = true;
				integer istart = ii;
				while ((istart <= nnz_a[ilevel - 1] + iadd) && (A[istart].i == A[ii].i) && (A[istart].j != A[ii].i)) istart++;
				if ((istart <= nnz_a[ilevel - 1] + iadd) && (A[istart].i == A[ii].i)) {
					integer ifound = istart;
					istart = ii;
					while ((istart <= nnz_a[ilevel - 1] + iadd) && (A[istart].i == A[ii].i)) {

						if (A[istart].j != A[ii].i) {
							integer ij = BinarySearchAi(A, A[istart].j, 1 + iadd, nnz_a[ilevel - 1] + iadd);
							while ((ij <= nnz_a[ilevel - 1] + iadd) && (A[ij].i == A[istart].j) && (A[ij].j != A[istart].j)) ij++;
							if ((ij <= nnz_a[ilevel - 1] + iadd) && (A[ij].i == A[istart].j) && (A[ij].j == A[istart].j)) {
								if (abs(ij - ifound) > band_size) band_size = abs(ij - ifound);
								if (abs(A[ij].j - A[ifound].i) > band_size_i) band_size_i = abs(A[ij].j - A[ifound].i);
							}
						}
						istart++;
					}
				}
			}
		}
		printf("bandsize=%d\n", band_size);
		//band_size = -1; // OFF band_size acselerator.

		// ������ ����� � Atemp, ����� ����� ������������� �� j.
		for (int i_1 = 1 + iadd; i_1 <= nnz_a[ilevel - 1] + iadd; i_1++) {
			Atemp[i_1 - iadd] = A[i_1];
			Atemp[i_1 - iadd].ind = i_1; // ���������� �������������� ������� � �.
		}
		// ��������� ����� �� j.
		// �� ��������� �� j, ����� ����� ������ ������ �� j.
		HeapSort_j(Atemp, 1, nnz_a[ilevel - 1]);

		// ���������� ��������� ���������� ����� �������.
		integer band_sizej = -1;
		for (integer i_1 = 1; i_1 <= n; i_1++) {
			flag[i_1] = false;
		}
		for (integer ii = 1; ii <= nnz_a[ilevel - 1]; ii++) {
			if (!flag[Atemp[ii].j]) {
				flag[Atemp[ii].j] = true;
				integer istart = ii;
				while ((istart <= nnz_a[ilevel - 1]) && (Atemp[istart].j == Atemp[ii].j) && (Atemp[istart].i != Atemp[ii].j)) istart++;
				if ((istart <= nnz_a[ilevel - 1]) && (Atemp[istart].j == Atemp[ii].j)) {
					integer ifound = istart;
					istart = ii;
					while ((istart <= nnz_a[ilevel - 1]) && (Atemp[istart].j == Atemp[ii].j)) {

						if (Atemp[istart].i != Atemp[ii].j) {
							integer ij = BinarySearchAj(Atemp, Atemp[istart].i, 1, nnz_a[ilevel - 1]);
							while ((ij <= nnz_a[ilevel - 1]) && (Atemp[ij].j == Atemp[istart].i) && (Atemp[ij].i != Atemp[istart].i)) ij++;
							if ((ij <= nnz_a[ilevel - 1]) && (Atemp[ij].j == Atemp[istart].i) && (Atemp[ij].i == Atemp[istart].i)) {
								if (abs(ij - ifound) > band_sizej) band_sizej = abs(ij - ifound);
							}
						}
						istart++;
					}
				}
			}
		}
		printf("bandsizej=%d\n", band_sizej);
		if ((band_size == -1) && (band_sizej == -1)) {
			bcontinue = false;
			// ���� �� ����� �������� ������ ��� ���������.
			// ��������� ����� �� ���� ��������������� �� �������
			// ���������� ������ � �������... ?
			// �������� ��� ��������������� ���� �������� ���� �� �������� ������������.
			break;
		}
		//getchar();
		//band_size = -1; // OFF band_size acselerator.


		//if (ilevel == 2) {
		// ������� ������� ������ ���������� ���������� �������.
		// �������� ������� ���� ���������� ������������ �������� RAP.
		//for (integer ii7 = 1 + iadd; ii7 <= iadd + nnz_a[ilevel - 1]; ii7++) {
		//if (A[ii7].i > n_a[ilevel - 1]) {
		//		printf("matrix incorrect i\n");
		//}
		//if (A[ii7].j > n_a[ilevel - 1]) {
		//	printf("%d ",A[ii7].j);
		//}
		//	printf("A[%d].i=%d A[%d].j=%d A[%d].aij=%e\n", ii7, A[ii7].i, ii7, A[ii7].j, ii7, A[ii7].aij);
		//system("pause");
		//}
		//}

		//for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
		//	printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n",ii,A[ii].aij,ii,A[ii].i,ii,A[ii].j);
		//if (ii % 20 == 0) getchar();
		//}

		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			flag[ii] = false;
		}

		// ������� ������ ������ ������ � �������.
		integer* row_startA = new integer[n_a[ilevel - 1] + 1];
		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			if (flag[A[ii].i] == false) {
				flag[A[ii].i] = true;
				row_startA[A[ii].i] = ii;
			}
		}

		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			flag[ii] = false;
		}


		// ��������� ��� ������ ���� ����� ��� �������.
		integer* count_sosed = new integer[n_a[ilevel - 1] + 1];
		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			count_sosed[ii] = 0; // ��� �������.
		}

		if (blite_and_quick_version)
		{
			// � ��� ����� ����������� ���� ������� ����� ���� �������.
			// ������� ��������� �� ����� ������ ������� � (����� �����).
			for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
				if (flag[A[ii].i] == false) {
					integer ic = -1;
					for (integer is0 = ii; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii].i); is0++) {
						ic++; //i,j
					}
					count_sosed[A[ii].i] = ic;
					if (ic > Maximumsosedcount) {
						Maximumsosedcount = ic;
						icandidate_shadow = ii;
						bmaxsosedinfoactive = true;
					}
					flag[A[ii].i] = true;
				}
			}
		}
		else {


			// ��� ����� ���� ���� ������� ���� ����� ������, ����� ��� 
			// ���������� ���� ������� ������ � ���� ����� �������.
			// ������� ��������� �� ����� ������ ������� � (����� �����).
			for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
				if (flag[A[ii].i] == false) {
					integer ic = -1;
					integer cand[max_sosed];
					for (integer is0 = ii; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii].i); is0++) {
						ic++; //i,j
						cand[ic] = A[is0].j;
					}
					integer len_sosed = ic;
					// ����� ������� j ������� ����� ������� A[ii].i
					//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1] + iadd; ii1++) {
					//if (A[ii1].i != A[ii].i) {
					//	if (A[ii1].j == A[ii].i) {
					// j,i
					//		bool foundsosed = false;
					//		for (integer i_1 = 0; i_1 <= len_sosed; i_1++) {
					//			if (A[ii1].j == cand[i_1]) foundsosed = true;
					//		}
					//		if (!foundsosed) {
					//			ic++;
					//			cand[ic] = A[ii1].j;
					//			len_sosed++;
					//		}
					//	}
					//}
					//}
					// ���������� ������ � �������� ������� �� j.
					integer ii2 = BinarySearchAj(Atemp, A[ii].i, 1, nnz_a[ilevel - 1]);
					for (integer ii1 = ii2; (ii1 <= nnz_a[ilevel - 1]) && (Atemp[ii1].j == A[ii].i); ii1++) {
						if (Atemp[ii1].i != A[ii].i) {
							// j,i
							bool foundsosed = false;
							for (integer i_1 = 0; i_1 <= len_sosed; i_1++) {
								if (Atemp[ii1].j == cand[i_1]) foundsosed = true;
							}
							if (!foundsosed) {
								ic++;
								cand[ic] = Atemp[ii1].j;
								len_sosed++;
							}
						}
					}


					count_sosed[A[ii].i] = ic;
					if (ic > Maximumsosedcount) {
						Maximumsosedcount = ic;
						icandidate_shadow = ii;
						bmaxsosedinfoactive = true;
					}
					flag[A[ii].i] = true;
				}
			}
		}


		integer maxsosed = 0;
		integer icandidate = 0;
		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			flag[ii] = false; // init flag
		}
		// ������� ���� � ���������� ������ ������� � ���������� ���.
		// ��� ������ ������������� ���� � ���������� ������ �������.
		for (integer ii = 1 + iadd; ii <= nnz_a[ilevel - 1] + iadd; ii++) {
			if (flag[A[ii].i] == false) {
				if (count_sosed[A[ii].i] > maxsosed) {
					maxsosed = count_sosed[A[ii].i];
					icandidate = ii;
					if (bmaxsosedinfoactive) {
						// ���������� ��������� ����� �� ����� for.
						// ��� ������ ������ ��������� ���������� ������������.
						if (maxsosed == Maximumsosedcount) break;
					}
				}
				flag[A[ii].i] = true;
			}
		}

		for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
			flag[ii] = false; // init flag
		}


		// ����� �������� ��� ����� � coarse, � ��� � ���� ��� ����� � Fine �������� ���� ��� �����������
		// � ������ Fine ��������� �� ������� �������.

		integer n_coarce = 1; // ��������� ����� C ����.
		nnzR = 1;

		const integer NULL_SOSED = -1;
		integer vacant = NULL_SOSED;
		bool bcontinue = true;

		// ���������� C-F ���������.
		//while (icandidate != 0)
		integer icountprohod = 0;
		// �� ����� ��������� � ����� ������� ���������� ��� �� ���������� ����,
		// ��� �������� ���������� ������������ ��������� � ������ ���� � ������������ 
		// ����������� �������.
		integer ibegining_start_index_found_maximum = 1 + iadd;
		// ������ �� ���� ������� ��� ���� �������� ��� ���������������.
		bool *bmarkervisit = new bool[n + 1];
		// �������� ��� ���� �������� ��� ������������.
		for (integer i_1 = 1; i_1 <= n; i_1++) bmarkervisit[i_1] = false;

		for (integer i_1 = 1; i_1 <= nnz_a[ilevel - 1]; i_1++) {
			Atemp2[i_1] = A[i_1 + iadd]; // copy
			Atemp2[i_1].ind = i_1 + iadd;
			A[i_1 + iadd].ind = i_1; // ���������� �������� �����.
			//if (ilevel == 2) {
			//printf("%e %d %d %d\n", Atemp2[i_1].aij, Atemp2[i_1].i, Atemp2[i_1].j, Atemp2[i_1].ind);
			//getchar();
			//}
		}

		// ���������� �������������� ����������� 
		// ����������� �������� ������������
		// ����� �������� ������ ������ ������������ flag.
		integer istartflag_scan = 1;

		//if (bmaxsosedinfoactive == true) {
		//printf("bmaxsosedinfoactive==true\n");
		//getchar();
		//}
		List* plist = NULL;
		List* plist_current = NULL;


		integer istat_old = 0;
		integer istat_new = 0;
		integer istat_new2 = 0;

		while (bcontinue)
		{



			imax_pool_ind = 1;

			//printf("prohod count number %d\n", icountprohod);


			integer set[max_sosed]; // �� ����� 20 ����� � ����� ��������.
			// ������������� ������ ������ ��� ��� �� ����� � ��� ������ �������� ��������������.
			//for (integer js = 0; js < max_sosed; js++) {
			//set[js] = NULL_SOSED;
			//}
			integer ic = 0;

			integer ii = icandidate;
			if (flag[A[ii].i] == false) {
				// ��������� �� ������������������ ������� � (���������� �����).
				integer nnzRl = nnzR + iaddR;


				ic = 0; // ������������ �������������.
				set[ic] = A[ii].i;


				Real max_vnediagonal = -1.0; // ������������ �������� ������ ��� ������������� ��������. 
				// ��������� ������������ �������.
				// ���� set[0]==A[is0].i.
				// ���������� �������� ������������� �������������� ��������, � 
				// ������ ���� ��� ���� ���� ������� ������ � ����� ���������� ����� ��������� �������.
				this_is_C_node[set[0]] = true;
				bmarkervisit[set[0]] = true;
				pool_sosed[0] = ii;
				for (integer is0 = ii; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == set[0]); is0++) {
					if (A[is0].j == set[0]) {

						nnzRl++;
						break;
					}
					else {
						if (fabs(A[is0].aij) > max_vnediagonal) {
							max_vnediagonal = fabs(A[is0].aij); //i,j
						}
					}
					if (!blite_and_quick_version) {
						// ���� ���� �������� ����������.
						// ����� ����� j,i ��� �������� i ��� �� ��� ������� � ���������� �-F ���������.
						// ��������� �������� �����.
						//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1] + iadd; ii1++) {
						//if (A[ii1].i != set[0]) {
						//if (!flag[A[ii1].i]) {
						//	if (A[ii1].j == set[0]) {
						//		if (fabs(A[ii1].aij) > max_vnediagonal) {
						//			max_vnediagonal = fabs(A[ii1].aij); //j,i
						//		}
						//	}
						//}
						//}
						//}

						// ���� ���� �������� ����������.
						// ����� ����� j,i ��� �������� i ��� �� ��� ������� � ���������� �-F ���������.
						// ���������� ������ �� ������ ��������� ������.
						integer ii2 = BinarySearchAj(Atemp, set[0], 1, nnz_a[ilevel - 1]);
						for (integer ii1 = ii2; (ii1 <= nnz_a[ilevel - 1]) && (Atemp[ii1].j == set[0]); ii1++)
						{
							if (Atemp[ii1].i != set[0]) {
								if (!flag[Atemp[ii1].i]) {
									if (fabs(Atemp[ii1].aij) > max_vnediagonal) {
										max_vnediagonal = fabs(Atemp[ii1].aij); //j,i
									}
								}
							}
						}

					}
				}

				ic++;



				// ���� ���� j ��� �� ��� �������� � �������.
				if (flag[A[ii].j] == false) {
					if ((A[ii].j != set[0]) && (fabs(A[ii].aij) >= theta*max_vnediagonal)) {
						vacant = A[ii].j;
						pool_sosed[imax_pool_ind] = ii;
						for (integer js = 0; js < ic; js++) {
							if (vacant == set[js]) {
								vacant = NULL_SOSED;
							}
						}
						if (vacant != NULL_SOSED) {
							set[ic] = vacant;
							imax_pool_ind++;
							if (imax_pool_ind > imaxpoolsize) {
								printf("pool index incorrupt: pool ind > pool_size\n");
								getchar();
							}
							nnzRl++;
							ic++;
						}
					}
				}
				integer iscan = ii + 1;
				while ((iscan <= nnz_a[ilevel - 1] + iadd) && (A[iscan].i == set[0])) {
					// ���� ���� j ��� �� ��� �������� � �������.
					if (flag[A[iscan].j] == false) {
						if ((A[iscan].j != set[0]) && (fabs(A[iscan].aij) >= theta*max_vnediagonal)) {
							vacant = A[iscan].j;
							pool_sosed[imax_pool_ind] = iscan;
							for (integer js = 0; js < ic; js++) {
								if (vacant == set[js]) {
									vacant = NULL_SOSED;
								}
							}
							if (vacant != NULL_SOSED) {
								set[ic] = vacant;
								imax_pool_ind++;
								if (imax_pool_ind > imaxpoolsize) {
									printf("pool index incorrupt: pool ind > pool_size\n");
									getchar();
								}
								nnzRl++;
								ic++;

							}
						}
					}

					iscan++;

				} // while

				// ��� ���� ������ ������ ����� i,j

				if (!blite_and_quick_version) {

					// ���� ���� j,i
					//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1]; ii1++) {
					//if ((A[ii1].i != set[0]) && (A[ii1].j == set[0])) {
					//if (!flag[A[ii1].i]) {
					//if (fabs(A[ii1].aij) >= theta*max_vnediagonal) {
					//	vacant = A[ii1].i;
					//	for (integer js = 0; js < ic; js++) {
					//		if (vacant == set[js]) {
					//			vacant = NULL_SOSED;
					//		}
					//	}
					//	if (vacant != NULL_SOSED) {
					//		set[ic] = vacant; // j,i �����.

					//		nnzRl++;
					//		ic++;
					//	}
					//	}
					//}
					//}
					//}

					// ���� ����� j,i
					// ��������� ������ �� ������ ��������� ������.
					//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1]; ii1++) {
					//if ((A[ii1].i != set[0]) && (A[ii1].j == set[0])) {
					//if (!flag[A[ii1].i]) {
					//if (fabs(A[ii1].aij) >= theta*max_vnediagonal) {
					//	vacant = A[ii1].i;
					//	for (integer js = 0; js < ic; js++) {
					//		if (vacant == set[js]) {
					//			vacant = NULL_SOSED;
					//		}
					//	}
					//	if (vacant != NULL_SOSED) {
					//		set[ic] = vacant; // j,i �����.

					//		nnzRl++;
					//		ic++;
					//	}
					//}
					//}
					//}
					//}

					// ���� ���� j,i
					// ����� ������� ������ �� ������ ��������� ������.
					integer ii1 = BinarySearchAj(Atemp, set[0], 1, nnz_a[ilevel - 1]);
					for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1]) && (Atemp[ii2].j == set[0]); ii2++) {
						if ((Atemp[ii2].i != set[0]) && (!flag[Atemp[ii2].i])) {
							if (fabs(Atemp[ii2].aij) >= theta*max_vnediagonal) {
								vacant = Atemp[ii2].i;
								pool_sosed[imax_pool_ind] = Atemp[ii2].ind; // ������� � �.
								for (integer js = 0; js < ic; js++) {
									if (vacant == set[js]) {
										vacant = NULL_SOSED;
									}
								}
								if (vacant != NULL_SOSED) {
									set[ic] = vacant; // j,i �����.
									imax_pool_ind++;
									if (imax_pool_ind > imaxpoolsize) {
										printf("pool index incorrupt: pool ind > pool_size\n");
										getchar();
									}
									nnzRl++;
									ic++;
								}
							}
						}
					}


				}


				for (integer isc = 1; isc < ic; isc++) {
					this_is_F_node[set[isc]] = true; // ��� ������ ����� F ����.
					bmarkervisit[set[isc]] = true;
				}




				// �������� ���� ��� ���������� � �������.
				for (integer js = 0; js < ic; js++) {
					flag[set[js]] = true;
				}
				/*
				for (integer isc = 1; isc < n_a[ilevel - 1]; isc++) {
				if (flag[isc] == false) {
				// ����� ������� ���� isc
				integer ii1 = BinarySearchAi(A, isc, 1 + iadd, nnz_a[ilevel - 1] + iadd);
				//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1] + iadd; ii1++) {
				//	if (A[ii1].i == isc) {
				integer ic2 = 0;
				for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
				for (int js = 1; js < ic; js++) {
				if (A[is0].j == set[js]) {
				ic2++;
				}
				}
				}
				count_sosed[isc] += ic2;
				//	}
				//}
				// ���� ����� ��� �������� �� set[1..ic-1]
				// ������ ����������� ������� count_sosed[isc] �� �������.
				}
				}
				*/

				//if (1) {
				if (band_size == -1) {

					// ��� ������� ���������� � ������ �����.

					for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
						flag_shadow[i_1] = flag[i_1];
					}
					// ����������� ��������� ��� ������� ����� F �����.
					// j ���� ����� F ����� i ������� ��������. // ij �����.
					//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1] + iadd; ii1++) {
					// ����� ������� ������� ����.
					for (integer ii_2 = ibegining_start_index_found_maximum; ii_2 <= nnz_a[ilevel - 1] + iadd; ii_2++) {
						integer ii1 = Atemp2[ii_2 - iadd].ind;
						integer isc = A[ii1].i;
						if ((flag_shadow[isc] == false) && ((!bmarkervisit[isc]))) {
							flag_shadow[isc] = true;
							integer ic2 = 0;
							for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
								for (int js = 1; js < ic; js++) {
									if (A[is0].j == set[js]) {
										ic2++;
									}
								}
							}
							count_sosed[isc] += ic2;
							if (bmaxsosedinfoactive) {
								// ��������� ���������� � ������������ ���������� �������.
								if (count_sosed[isc] >= Maximumsosedcount) {
									Maximumsosedcount = count_sosed[isc];
									icandidate_shadow = ii1;

									if (plist == NULL) {
										plist = new List;
										plist->next = NULL;
										plist->prev = NULL;
										plist->ii = ii1;
										plist->countsosed = count_sosed[isc];
										plist->i = isc;
										plist_current = plist;
									}
									else {
										List *ptemp = new List;
										ptemp->ii = ii1;
										ptemp->i = isc;
										ptemp->countsosed = count_sosed[isc];
										ptemp->next = NULL;
										ptemp->prev = plist_current;
										plist_current->next = ptemp;
										plist_current = ptemp;
										ptemp = NULL;
									}
								}
							}
						}
					}

				}
				else {

					// ����� � ������ ���� ������������ �������� �����������.
					// ��� ������� � ��������� : ���� � ���������� ������� � ������� ii 
					// ����� ������� ���� � ����������� +- band_size.


					// ������ ����� ����� band_size
					//for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
					//flag_shadow[i_1] = flag[i_1];
					//}
					if (ic <= 0) {
						// ��������� ic �� ����� ���� ����, � ������ ic==1 
						// ����� �� ���������� �� ������ ������ ��� ��������� �������� �������� �����������.
						// �������� ������ ����� ���� �������� � � ����� ������, �.�. ������ 
						// ����� ����� ��������� �.�. � ��� �� ������������ �������� �����������.
						// 7 ������ 2015.


						if (ic == 0) {
							printf("ic==0 iformation\n");
							getchar();
						}
						// �� ����������� ������ ������� ��� ������� ������ ��������
						// ��� �������� ������ ���������� � ������ �����.


						// ��� ������� ���������� � ������ �����.

						for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
							flag_shadow[i_1] = flag[i_1];
						}
						// ����������� ��������� ��� ������� ����� F �����.
						// j ���� ����� F ����� i ������� ��������. // ij �����.
						//for (integer ii1 = 1 + iadd; ii1 <= nnz_a[ilevel - 1] + iadd; ii1++) {
						// ����� ������� ������� ����.
						for (integer ii_2 = ibegining_start_index_found_maximum; ii_2 <= nnz_a[ilevel - 1] + iadd; ii_2++) {
							integer ii1 = Atemp2[ii_2 - iadd].ind;
							integer isc = A[ii1].i;
							if ((flag_shadow[isc] == false) && ((!bmarkervisit[isc]))) {
								flag_shadow[isc] = true;
								integer ic2 = 0;
								for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
									for (int js = 1; js < ic; js++) {
										if (A[is0].j == set[js]) {
											ic2++;
										}
									}
								}
								count_sosed[isc] += ic2;
								if (bmaxsosedinfoactive) {
									// ��������� ���������� � ������������ ���������� �������.
									if (count_sosed[isc] >= Maximumsosedcount) {
										Maximumsosedcount = count_sosed[isc];
										icandidate_shadow = ii1;

										if (plist == NULL) {
											plist = new List;
											plist->next = NULL;
											plist->prev = NULL;
											plist->ii = ii1;
											plist->countsosed = count_sosed[isc];
											plist->i = isc;
											plist_current = plist;
										}
										else {
											List *ptemp = new List;
											ptemp->ii = ii1;
											ptemp->i = isc;
											ptemp->countsosed = count_sosed[isc];
											ptemp->next = NULL;
											ptemp->prev = plist_current;
											plist_current->next = ptemp;
											plist_current = ptemp;
											ptemp = NULL;
										}
									}
								}
							}
						}

					}
					else {

						if (0) {
							// ��������� ������� ����.


							for (int js = 1; js < ic; js++) {
								for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
									flag_shadow[i_1] = flag[i_1];
								}

								integer istart = i_my_max(1 + iadd, pool_sosed[js] - band_size - 1);
								integer iend = i_my_min(nnz_a[ilevel - 1] + iadd, pool_sosed[js] + band_size + 1);
								// ���� ������ ����� ���������� ��������� ����� ������������ F ����.
								for (integer ii_2 = istart; ii_2 <= iend; ii_2++) {
									integer isc = A[ii_2].i;
									if ((flag_shadow[isc] == false)/* && ((!bmarkervisit[isc]))*/) {
										flag_shadow[isc] = true;
										integer ic2 = 0;
										integer iend2 = i_my_min(nnz_a[ilevel - 1] + iadd, ii_2 + band_size + 1);
										integer istart2 = ii_2;
										while ((istart2 >= 1 + iadd) && (A[istart2].i == A[ii_2].i)) istart2--;
										istart2++;
										for (integer is0 = istart2; (is0 <= iend2) && (A[is0].i == A[ii_2].i); is0++) {
											if (A[is0].j == set[js]) {
												ic2++;
											}
										}

										count_sosed[isc] += ic2;
										if (bmaxsosedinfoactive) {
											// ��������� ���������� � ������������ ���������� �������.
											if (count_sosed[isc] >= Maximumsosedcount) {
												Maximumsosedcount = count_sosed[isc];
												icandidate_shadow = ii_2;

												if (plist == NULL) {
													plist = new List;
													plist->next = NULL;
													plist->prev = NULL;
													plist->ii = ii_2;
													plist->countsosed = count_sosed[isc];
													plist->i = isc;
													plist_current = plist;
												}
												else {
													List *ptemp = new List;
													ptemp->ii = ii_2;
													ptemp->i = isc;
													ptemp->countsosed = count_sosed[isc];
													ptemp->next = NULL;
													ptemp->prev = plist_current;
													plist_current->next = ptemp;
													plist_current = ptemp;
													ptemp = NULL;
												}
											}
										}
									}
								}
							}
						}
						else {

							for (int js = 1; js < ic; js++) {
								//for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
								//flag_shadow[i_1] = flag[i_1];
								//}

								//integer istart = i_my_max(1 + iadd, pool_sosed[js] - band_size - 1);
								//integer iend = i_my_min(nnz_a[ilevel - 1] + iadd, pool_sosed[js] + band_size + 1);

								//integer i3 = 1;
								//while ((i3 <= n_a[ilevel - 1]) && (row_startA[i3] < istart)) i3++;
								//integer i4 = n_a[ilevel - 1];
								//while ((i4 >= 1) && (row_startA[i4]>iend)) i4--;

								integer i3 = i_my_max(1, set[js] - band_size_i - 1);
								integer i4 = i_my_min(n_a[ilevel - 1], set[js] + band_size_i + 1);

								// ���� ������ ����� ���������� ��������� ����� ������������ F ����.
								//for (integer ii_2 = istart; ii_2 <= iend; ii_2++) {

								// ���� ������ ���� set[js].
								for (integer i5 = i3; i5 <= i4; i5++) {
									//integer isc = A[ii_2].i;
									integer ii_2 = row_startA[i5];
									//integer ii_2 = BinarySearchAi(A, i5, 1 + iadd, nnz_a[ilevel - 1] + iadd);
									integer isc = i5;
									//if ((flag_shadow[isc] == false)/* && ((!bmarkervisit[isc]))*/) {
									if (flag[isc] == false) {
										//flag_shadow[isc] = true;
										integer ic2 = 0;
										integer iend2 = i_my_min(nnz_a[ilevel - 1] + iadd, ii_2 + band_size + 1);
										integer istart2 = ii_2;
										while ((istart2 >= 1 + iadd) && (A[istart2].i == A[ii_2].i)) istart2--;
										istart2++;
										for (integer is0 = istart2; (is0 <= iend2) && (A[is0].i == A[ii_2].i); is0++) {
											if (A[is0].j == set[js]) {
												ic2++;
											}
										}

										count_sosed[isc] += ic2;
										if (bmaxsosedinfoactive) {
											// ��������� ���������� � ������������ ���������� �������.
											if (count_sosed[isc] >= Maximumsosedcount) {
												Maximumsosedcount = count_sosed[isc];
												icandidate_shadow = ii_2;

												if (plist == NULL) {
													plist = new List;
													plist->next = NULL;
													plist->prev = NULL;
													plist->ii = ii_2;
													plist->countsosed = count_sosed[isc];
													plist->i = isc;
													plist_current = plist;
												}
												else {
													List *ptemp = new List;
													ptemp->ii = ii_2;
													ptemp->i = isc;
													ptemp->countsosed = count_sosed[isc];
													ptemp->next = NULL;
													ptemp->prev = plist_current;
													plist_current->next = ptemp;
													plist_current = ptemp;
													ptemp = NULL;
												}
											}
										}
									}
								}
							}
						}
					}

				}




				n_coarce++; // ��������� ���������� � �����.

				// ���� ������� ������.

			} // ���� �� ��� ��� ������� � �������.



			bcontinue = false;
			for (integer i_1 = istartflag_scan; i_1 <= n_a[ilevel - 1]; i_1++) {
				if (flag[i_1] == false) {
					bcontinue = true;
					istartflag_scan = i_1; // ��������� ������� ������������.
					break; // ��������� ����� �� ����� for.
					//if (maxsosed == -1) {
						//printf("ERROR!!!!  i_1=%d\n", i_1);
						//system("pause");
					//}
				}
			}

			// ���������� ���� � ������������ ����������� �������.
			maxsosed = -1;
			icandidate = 0;


			// TODO 6 november

			const integer ipool_size_limit = 128000;
			integer ipool[ipool_size_limit];
			integer isize_p = -1;
			for (integer isc = 0; isc < ic; isc++) {
				//integer ii_s = pool_sosed[isc];// ������� � �.
				integer ii_s = BinarySearchAi(A, set[isc], 1 + iadd, iadd + nnz_a[ilevel - 1]);
				integer ii_c = ii_s;
				//while ((ii_c >= 1 + iadd) && (A[ii_c].i == A[ii_s].i)) ii_c--;
				//ii_c++;
				// ��� ������ ������� ������� � ������� ii_c ������ ���� �������� � Atemp2;
				while ((ii_c <= iadd + nnz_a[ilevel - 1]) && (A[ii_c].i == A[ii_s].i)) {
					integer icandidateq = ii_c;
					bool found1 = false;
					for (integer i_7 = 0; i_7 <= isize_p; i_7++) {
						if (i_7 < ipool_size_limit) {
							if (ipool[i_7] == icandidateq) {
								found1 = true;
							}
						}
						else {
							printf("nado uvelichiti ipool bolee %d, string 4118\n", ipool_size_limit);
							system("pause");
							exit(1);
						}
					}
					// ������� � ������ �� ���������, ������� �������� ������.
					if (found1 == false) {
						isize_p++;
						if (isize_p < ipool_size_limit) {
							ipool[isize_p] = icandidateq;
						}
						else {
							printf("nado uvelichiti ipool bolee %d, string 4118\n", ipool_size_limit);
							system("pause");
							exit(1);
						}
					}
					ii_c++;
				}
			}
			// ipool ������ ���������� ��� ���������� � Atemp2.
			for (integer i_7 = 0; i_7 <= isize_p; i_7++) {
				// ������� ��������� � � �������� �� �����, ������� �������� ���� ��������.

				Ak temp = Atemp2[ibegining_start_index_found_maximum - iadd + i_7];
				Atemp2[ibegining_start_index_found_maximum - iadd + i_7] = A[ipool[i_7]];
				Atemp2[ibegining_start_index_found_maximum - iadd + i_7].ind = ipool[i_7];

				Atemp2[A[ipool[i_7]].ind] = temp;
				A[temp.ind].ind = A[ipool[i_7]].ind;
				A[ipool[i_7]].ind = ibegining_start_index_found_maximum - iadd + i_7;
			}
			ibegining_start_index_found_maximum += isize_p + 1;



			// �� ����� ������ ��������� ����� �� ����� for 19 ��� �� 20,
			// � ���� ���� ��� ��������� ���������� � ������������ ���������� �������.
			// ������ ����������� ��������� 17 ������� 2015 ����.
			// ��� ��������� ���������� ��������� �� 8% �� ���������� ������� ���������� 
			// ����� ���������.
			if (icountprohod % 200 == 0) {



				// TODO 6november start delete code
				/*
				// ������� ����� �� ���� ������� ���� ��������.
				integer i_2 = 1;
				for (integer i_1 = 1 + iadd; i_1 <= nnz_a[ilevel - 1] + iadd; i_1++) {
				if (bmarkervisit[A[i_1].i]) {
				Atemp2[i_2] = A[i_1];
				Atemp2[i_2].ind = i_1; // ����������� ���������� �������������� ������.
				i_2++;
				}
				}
				// ����� ����� ��� ������ ����.
				for (integer i_1 = 1 + iadd; i_1 <= nnz_a[ilevel - 1] + iadd; i_1++) {
				if (!bmarkervisit[A[i_1].i]) {
				Atemp2[i_2] = A[i_1];
				Atemp2[i_2].ind = i_1; // ����������� ���������� �������������� ������.
				i_2++;
				}
				}
				// TODO 6 november end delete code.
				*/

				/* // 7 novemver 2015.
				bool bfirst_loc = true; // ��� ����� ������ ������ �������� �������.

				for (integer i_2 = ibegining_start_index_found_maximum; i_2 <= nnz_a[ilevel - 1] + iadd; i_2++) {
				integer  i_1 = i_2 - iadd;


				if (!bmarkervisit[Atemp2[i_1].i]) {
				// �� ���������� ��������� ������� ������� � ������� ���������� ���
				// ������������ ����.
				if (bfirst_loc) {
				ibegining_start_index_found_maximum = i_1 + iadd;
				bfirst_loc = false;
				break;
				//printf("diagnostic =%d\n",i_1);
				//getchar();
				}
				}
				}
				*/


				if ((flag[A[icandidate_shadow].i] == false) && (count_sosed[A[icandidate_shadow].i] == Maximumsosedcount)) {
					// ���� � ��� ��� �� ��� ����� ���� � ���������� ������ ������� ����� � ����
					// ����������� ��������� ������� ����� F �����.
					// ������ ����� ��� ���� ���������� ������� �� ������������ ������.
					icandidate = icandidate_shadow;
					istat_new++;
				}
				else {

					istat_old++;

					for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
						flag_shadow[i_1] = flag[i_1];
					}


					for (integer i_2 = ibegining_start_index_found_maximum; i_2 <= nnz_a[ilevel - 1] + iadd; i_2++) {
						integer  i_1 = i_2 - iadd;



						if (flag_shadow[Atemp2[i_1].i] == false) {
							if (count_sosed[Atemp2[i_1].i] > maxsosed) {
								maxsosed = count_sosed[Atemp2[i_1].i];
								//icandidate = i_1;
								icandidate = Atemp2[i_1].ind;
							}
							flag_shadow[Atemp2[i_1].i] = true;
						}
					}

					Maximumsosedcount = maxsosed;
					bmaxsosedinfoactive = true;
				}

			}
			else {

				if ((flag[A[icandidate_shadow].i] == false) &&
					(count_sosed[A[icandidate_shadow].i] == Maximumsosedcount)) {
					// ���� � ��� ��� �� ��� ����� ���� � ���������� ������ ������� ����� � ����
					// ����������� ��������� ������� ����� F �����.
					// ������ ����� ��� ���� ���������� ������� �� ������������ ������.
					icandidate = icandidate_shadow;

					istat_new++;
				}
				else {


					bool found_candidate = false;
					if (plist != NULL) {
						// ��������� �������� ���� ����������.
						while ((plist_current != NULL) && (!(((flag[A[plist_current->ii].i] == false) &&
							(count_sosed[A[plist_current->ii].i] == Maximumsosedcount))))) {
							//while (plist_current != NULL) {
							//	if (flag[A[plist_current->ii].i]==true) {
							// ������� ������ ������� ������� ��� ���� �������� � ���������� �����.
							if (flag[A[plist_current->ii].i] == true) {
								List* temp;
								temp = plist_current;
								plist_current = plist_current->prev;
								if (plist_current != NULL) {
									plist_current->next = temp->next;
									if (temp->next != NULL) {
										List* temp2 = temp->next;
										temp2->prev = plist_current;
									}
								}
								temp->prev = NULL;
								temp->next = NULL;
								if (plist != temp) {
									delete temp;
								}
								else {
									plist = NULL;
									delete temp;
								}
							}
							else {
								// �����������.
								// ������ ������� ��� �� ��� ������� (������� � ���������),
								// �� � �������� ����� ������� ������ �������������.
								plist_current = plist_current->prev;
							}
						}
						if (plist != NULL) {
							if (plist_current != NULL) {
								icandidate_shadow = plist_current->ii;
								icandidate = icandidate_shadow;
								found_candidate = true;
								while (plist_current->next != NULL) plist_current = plist_current->next;
							}
							else {
								plist_current = plist;
								while (plist_current->next != NULL) plist_current = plist_current->next;
							}
						}
						// ����������������� �������.
						// ����������� ��������� (������������� ����� �������).
						// ������ ������������ ������� ���� ����������� ����� ������� �� �������� �������
						// ����������� �.�. �� ��������� �� ��� ���� � ���� ���� ������� ��� �� ���������� � ��������.
						List* pscan = plist_current;
						integer icountsosmax = -1; // ������������ ����� �������.
						integer candidatestart = -1;
						if (pscan != NULL) {
							while (pscan != NULL) {
								if (icountsosmax < pscan->countsosed) {
									icountsosmax = pscan->countsosed;
									candidatestart = pscan->ii;
								}
								pscan = pscan->prev;
							}
							if (candidatestart != -1) {
								found_candidate = true;
								icandidate = candidatestart;
							}
						}
						// ��������� ������������������ ����������.

					}


					/*
					// TODO 09_11_2015
					bool found_candidate = false;
					if (plist != NULL) {
					// ��������� �������� ���� ����������.
					//while ((plist_current != NULL) && (!(((flag[A[plist_current->ii].i] == false) &&
					//	(count_sosed[A[plist_current->ii].i] == Maximumsosedcount))))) {
					while (plist_current != NULL) {
					if (flag[A[plist_current->ii].i] == true) {
					// �������
					List* temp;
					temp = plist_current;
					plist_current = plist_current->prev;
					if (plist_current != NULL) {
					plist_current->next = NULL;
					}
					temp->prev = NULL;
					if (plist != temp) {
					delete temp;
					}
					else {
					plist = NULL;
					delete temp;
					}
					}
					}
					if (plist_current != NULL) {
					icandidate_shadow = plist_current->ii;
					icandidate = icandidate_shadow;
					found_candidate = true;
					}
					}
					*/

					if (found_candidate == false)
					{
						istat_old++;
						for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) {
							flag_shadow[i_1] = flag[i_1];
						}




						// ���� ��� �� ��� �� ������ ����� ��������� ������ ����������� ���.

						//bool bfirst_loc = true; // ��� ����� ������ ������ �������� �������.

						for (integer i_2 = ibegining_start_index_found_maximum; i_2 <= nnz_a[ilevel - 1] + iadd; i_2++) {


							integer i_1 = i_2 - iadd;
							// ������� ������ ������������ ������ ������ ��������� ��� �����.
							// �� ����� ������������� ��������� ������� ��� � 20 ���.
							//if (!bmarkervisit[Atemp2[i_1].i]) {
							// �� ���������� ��������� ������� ������� � ������� ���������� ���
							// ������������ ����.
							//if (bfirst_loc) {
							//	ibegining_start_index_found_maximum = i_1+iadd;
							//	bfirst_loc = false;
							//}
							//}

							if (flag_shadow[Atemp2[i_1].i] == false) {

								if (count_sosed[Atemp2[i_1].i] > maxsosed) {
									maxsosed = count_sosed[Atemp2[i_1].i];
									//icandidate = i_1;
									// icandidate ����� �������� � ������� � ���������� �� ���������� ����� �������.
									icandidate = Atemp2[i_1].ind;
									if (bmaxsosedinfoactive) {
										// ���������� ��������� ����� �� �����,
										// ��� ����� �������� ���������� C-F ���������.
										if (maxsosed == Maximumsosedcount) break;
									}

								}
								flag_shadow[Atemp2[i_1].i] = true;
							}
						}

						// statistics
						//integer i_11 = 0;
						//for (integer i_10 = 1; i_10 <= n_a[ilevel - 1]; i_10++) {
						//if (flag[i_10] == false) i_11++;
						//}
						//printf("%d %d\n", A[icandidate_shadow].i, icandidate); // 97%
						//printf("procent %f\n",(float)(100*i_11/n_a[ilevel-1]));
						//getchar();
					}
					else {
						istat_new2++;
					}

				}
			}

			//printf("maximum number of sosed=%d\n",maxsosed);
			if (maxsosed == -1) if (debug_reshime) system("pause");
			//getchar();

			if ((icandidate == 0) && (maxsosed == -1)) {
				bcontinue = false;
			}

			icountprohod++;

		} // ���������� C-F ���������. �������.

		delete[] bmarkervisit;
		// ����������� ������ �� �� ���� ����������.
		if (plist != NULL) {

			while (plist != NULL) {
				plist_current = plist;
				plist->prev = NULL;
				plist = plist->next;
				plist_current->next = NULL;
				plist->prev = NULL;
				delete plist_current;
			}
		}

		// � ������ ����������� ������������ ������������ ��� ���������� �������������,
		// ��� ���� ����� ��������� ���������������� ��� F ���������� C ����������� ����
		// ��������� ���������� � ����������.
		int ipromah = 0;
		int ipromah_one = 0;
		bool bweSholdbeContinue = true;
		while (bweSholdbeContinue) {
			bweSholdbeContinue = false;

			// ���������� ����������� ��� ����� ������� ���������� F nodes.
			// ������ F-nodes ������ C-nodes.
			for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_F_node[i_1] == true) {
				// ����� ������� ������� F-node ������� C-node.
				integer icsos = 0;
				integer i_2 = BinarySearchAi(A, i_1, 1 + iadd, nnz_a[ilevel - 1] + iadd);

				bool bvisit = false;
				for (integer is0 = i_2; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[i_2].i); is0++) {
					if (A[is0].j != A[i_2].i) {
						bvisit = true;
						if (this_is_C_node[A[is0].j] == true) {
							icsos++;
						}
						else {
							ipromah++; // ������������ �������� ������������ 
						}
					}
				}
				if (icsos == 1) ipromah_one++; // ���������� F ����� � ����� ������������ � �������.
				// ���� bvisit �� ��������������� �������� ���� �� ��� ��� Fnodes. ����� ��� ������������ ������� �������.
				if ((icsos == 0) && (bvisit)) {

					// � ���� �� F ���� ������� ��� �������, �� ����� ���� ����� ���� ������� � ��� ������� ������� �� ����.
					// ���� ������� ����� ���� ��� ������� �� ��������� �������, ��� ������������� � ����� ������ � ����
					// ��������� ������������ ���������� ����� � �� ���� ��������.
					// ����� ���������� ��� ����������� ����� �������� � �������� ������.

					// ��� � �������, ���� ���� ������ � �����.
					this_is_F_node[i_1] = false;
					this_is_C_node[i_1] = true;
					// F node ���� C_node!!! ���� ����������� ������������ 
					// �������� � ���������� ������������� ��������� ��������.
					bweSholdbeContinue = true;
				}

			}

			if (bweSholdbeContinue) {
				printf(" prohod succseful\n");
			}
			else {
				printf("prohod empty\n");
			}

		}


		printf("old=%d, new1=%d, new2=%d\n",istat_old,istat_new, istat_new2);
		//system("pause");

		// ����� ��������� ���������� ���� �������,
		// ���� F ���� �������� ����� ������� ��� ������� �� ��� ���� ������� � �����,
		// �� ������ ����� ���� ����� ���� � �������� ���������� ��������� ������ �� ���� ����������.
		// ������� ����� ������������� ��������� � ������ ������ (�������� �����).


		integer* C_numerate = new integer[n_a[ilevel - 1] + 1];
		integer icounter = 1;
		integer icount1;
		integer numberofcoarcenodes;
		Real* ap_coarse = NULL;

		bweSholdbeContinue = true;
		while (bweSholdbeContinue) {
			bweSholdbeContinue = false;

			for (int i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_C_node[i_1]) { n_coarce++; }
			n_coarce--;


			// debug
			// �������� �������� C-F ���������.
			//Real* exp1 = new Real[n_a[ilevel - 1] + 1];
			//for (int i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) exp1[i_1] = 0.0;
			//for (int i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_C_node[i_1]) exp1[i_1] = 2.0;
			//for (int i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_F_node[i_1]) exp1[i_1] = 1.0;
			//exporttecplot(exp1,n);
			//delete[] exp1;

			//printf("export ready");

			//system("pause");


			// C-F ��������� ���������, ����� ����� ��������� �������� ������������.
			// ����� ����� �������� ��������, ��� ����������������� �������� ������������.
			// �� ��������� ���������� ������� ������ ��������� ������ � ����� ��������� ����� �������.

			// ���������� ��������� ������������� : 
			// coarse 2 fine.
			//P*coarse==fine

			for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) C_numerate[i_1] = 0;
			icounter = 1;
			for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_C_node[i_1] == true) {
				//printf("C ind= %d", i_1); getchar();
				C_numerate[i_1] = icounter;
				icounter++;
			}




			// C_numerate - ������������� �� ��������� Coarse �����.
			// ���������� ����������� ��� ����� ������� ���������� ������ �����.
			icount1 = 1 + iaddR; // nnz_R
			for (integer i_1 = 1; i_1 <= n_a[ilevel - 1]; i_1++) if (this_is_C_node[i_1] == true) {
				P[icount1].aij = 1.0;
				P[icount1].i = C_numerate[i_1]; // coarse number
				P[icount1].j = i_1; // fine number.
				icount1++;
			}

			// �������� icount1 ����� �����.�� ������� !!!.
			numberofcoarcenodes = icount1 - 1 - iaddR;

			// ��� ����������� R  ���� transpose(P)/ap.
			printf("countloc=%d\n", numberofcoarcenodes);
			if (debug_reshime) system("pause");

			ap_coarse = new Real[numberofcoarcenodes + 1];
			if (ap_coarse == NULL) {
				printf("error cannot memory allocate.");
				system("pause");
			}
			ap_coarse[0] = 0.0;
			//integer countloc = 1;
			for (integer i8 = 1; i8 <= n_a[ilevel - 1]; i8++) if (this_is_C_node[i8] == true) {
				integer ii1 = BinarySearchAi(A, i8, 1 + iadd, nnz_a[ilevel - 1] + iadd);
				//integer ii2 = ii1 - 1;
				//if ((ii2 >= 1 + iadd) && (A[ii2].i == A[ii1].i)) {
				//printf("koren zla\n"); // �������� ����� ������ �������������� �������� ������ ������ �������������.
				//getchar();
				//}
				for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
					//printf("i=%d j=%d A[is0].aij=%e ", A[is0].i, A[is0].j, A[is0].aij);
					if (A[is0].j == A[ii1].i) {
						//if (countloc > icount1 - 1) { printf("system error\n"); getchar(); }
						if (fabs(A[is0].aij) > RealMAXIMUM) {
							printf("perepolnenie error!");
							getchar();
						}
						ap_coarse[C_numerate[i8]] = fabs(A[is0].aij);
						//printf("find = %e", fabs(A[is0].aij));
					}
				}
				//printf("\n");
				//getchar();

				//countloc++;
			}

			// ����� 2 �������.
			//for (integer i25 = 1; i25 < icount1; i25++) {
			//if (ap_coarse[i25]>1) {
			//printf("ap_coarse[%d]=%e\n", i25, ap_coarse[i25]);
			//getchar();
			//}
			//}

			ipromah = 0;
			ipromah_one = 0;
			// ���������� ����������� ��� ����� ������� ���������� F nodes.
			// ������ F-nodes ������ C-nodes.
			for (integer i8 = 1; i8 <= n_a[ilevel - 1]; i8++) if (this_is_F_node[i8] == true) {
				// ����� ������� ������� F-node ������� C-node.
				integer icsos = 0;
				integer ii1 = BinarySearchAi(A, i8, 1 + iadd, nnz_a[ilevel - 1] + iadd);
				Real sumP = 0.0;
				for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
					if (A[is0].j != A[ii1].i) {
						if (this_is_C_node[A[is0].j] == true) {
							sumP += fabs(A[is0].aij); // ����� ������� ��������������� ��������� ������� ����������� � �����.
							icsos++;
						}
						else {
							ipromah++; // ������������ �������� ������������ 
						}
					}
				}
				if (icsos == 1) ipromah_one++; // ���������� F ����� � ����� ������������ � �������.

				for (integer is0 = ii1; (is0 <= nnz_a[ilevel - 1] + iadd) && (A[is0].i == A[ii1].i); is0++) {
					if (A[is0].j != A[ii1].i) {
						if (this_is_C_node[A[is0].j] == true) {

							// ��������������� ������� �� ��������� � �����.

							if (fabs(sumP) < RealZERO) {
								printf("error interpolation zero diagonal sumP.\n");
								printf("Fnode all sosed is F");
								//system("pause");
								printf("i8 is Dirichlet node\n");
								this_is_F_node[i8] = false; // ���� ���� ������� ������ � �����.
								this_is_C_node[i8] = true;
								bweSholdbeContinue = true;
								//exit(1);
								// ����� ����� �������� �������������.
							}
							else {

								P[icount1].j = i8;
								P[icount1].i = C_numerate[A[is0].j];
								P[icount1].aij = fabs(A[is0].aij) / sumP;
								icount1++;
							}
						}

					}
				}


			}

			if (bweSholdbeContinue) {
				delete[] ap_coarse;
				ap_coarse = NULL;
				printf("obratnaq svqz restart...\n");
			}

		}

		nnzR = icount1 - iaddR;



		// ����� ���������� nnzR ���������� ��������� ��������� � ������� R � P.

		// �������� restriction �������� � �� ���������� �� i.
		// ����� ��������� ��������� nnzR-1.
		// P=Copy(R);
		for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
			R[ii] = P[ii];
			//if ((ilevel == 2) && (ii >= iaddR + nnzR - 1-30)) {
			//printf("ii=%d aij=%e, i=%d j=%d\n", ii, P[ii].aij, P[ii].i, P[ii].j);
			//getchar();
			//}
		}

		// heapsort(P,key==j,iaddR+1,iaddR+nnzR - 1);
		if (bquicktypesort) {
			QuickSort_j(P, 1 + iaddR, iaddR + nnzR - 1);
		}
		else {
			HeapSort_j(P, /*n_a[ilevel - 1],*/ 1 + iaddR, iaddR + nnzR - 1);
		}

		/*
		if (bquicktypesort) {
		QuickSort_j(R,  1 + iaddR, iaddR + nnzR - 1);
		}
		else {
		HeapSort_j(R, n_a[ilevel - 1], 1 + iaddR, iaddR + nnzR - 1);
		}

		printf("start now\n");
		for (integer ii5 = 1 + iaddR; ii5 <= iaddR + nnzR - 1; ii5++) {
		printf("R[%d].i=%d R[%d].j=%d R[%d].aij=%e\n", ii5, R[ii5].i, ii5, R[ii5].j, ii5, R[ii5].aij);
		system("pause");
		}
		*/
		// ��� �� ���� ��������� �� ap, �.�. 
		// R=P/ap.


		// heapsort(R,key==i,iaddR+1,iaddR+nnzR - 1);
		if (bquicktypesort) {
			QuickSort(R, 1 + iaddR, iaddR + nnzR - 1);
		}
		else {
			HeapSort(R, n_a[ilevel - 1], 1 + iaddR, iaddR + nnzR - 1);
		}


		printf("first level size n=%d numberofcoarcenodes=%d\n", n, numberofcoarcenodes);
		if (debug_reshime) system("pause");
		for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
			flag[i_1] = false; // init flag.
		}

		for (integer i_1 = 1 + iaddR; i_1 <= iaddR + nnzR - 1; i_1++) {
			if (flag[R[i_1].i] == false)
			{
				for (integer i_2 = i_1; (i_2 <= iaddR + nnzR - 1) && (R[i_2].i == R[i_1].i); i_2++) {
					if ((R[i_1].i<1) || (R[i_1].i>numberofcoarcenodes)) {
						printf("error R[%d].i=%d\n", i_1, R[i_1].i);
						system("pause");
					}
					if (fabs(ap_coarse[R[i_1].i]) < divisionZERO) {
						printf("error division by zero\n");
						system("pause");
					}
					Real delitel;
					if (ap_coarse[R[i_1].i] > 1.0) {
						// internal node
						delitel = 0.5*ap_coarse[R[i_1].i];
					}
					else {
						// Dirichlet
						delitel = ap_coarse[R[i_1].i];
					}
					R[i_2].aij = R[i_2].aij / (delitel);
				}
				flag[R[i_1].i] = true;
			}
		}


		delete[] ap_coarse;


		// debug.
		//for (integer i_1 = 1 + iaddR; i_1 <= iaddR + nnzR - 1; i_1++) {
		//printf("R[%d].i=%d R[%d].j=%d R[%d].aij=%e\n", i_1, R[i_1].i, i_1, R[i_1].j, i_1, R[i_1].aij);
		//system("pause");
		//}


		//for (integer i_1 = iaddR + nnzR - 1-20; i_1 <= iaddR + nnzR - 1; i_1++) {
		//printf("R[%d].i=%d R[%d].j=%d R[%d].aij=%e\n", i_1, R[i_1].i, i_1, R[i_1].j, i_1, R[i_1].aij);
		//system("pause");
		//}



		//for (integer i_1 = 1 + iaddR; i_1 <= iaddR + nnzR - 1; i_1++) {
		//printf("P[%d].i=%d P[%d].j=%d P[%d].aij=%e\n", i_1, P[i_1].i, i_1, P[i_1].j, i_1, P[i_1].aij);
		//system("pause");
		//}


		// ���������� � �� j.
		//heapsort(A, key=j*n_a[ilevel - 1] + i, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort_j(A, 1 + iadd, nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < heapsortsizelimit) {
				HeapSort_j(A, /*n_a[ilevel - 1]*/ 1 + iadd, nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[1 + iadd];
				MergeSort_j(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}

		// ���������� ������� �������������� ������ :
		// Acorse=R*Afine*P;
		// ����� 1 : R*Afine.
		//         xxxxxx
		//         xxxxxx
		//  xxxxxx xxxxxx xxxxxx
		//  xxxxxx xxxxxx xxxxxx
		//         xxxxxx
		//         xxxxxx
		//    R       A     [RA]
		/*
		integer istartAnew = nnz_a[ilevel - 1] + 1+iadd;
		for (integer jstr = 1; jstr <= n_a[ilevel - 1]; jstr++) {
		// jstr - ������� ������� �.
		// icounter-1 - ����� ����� �� ������ ������.
		for (integer i = 1; i <= icounter - 1; i++) {
		flag[i] = false;
		}
		// � (�� ������ �������) ������ ���� ������������� �� j.
		integer ii1 = BinarySearchAj(A, jstr, 1 + iadd, nnz_a[ilevel - 1] + iadd);
		// ��� ����������� ������ ��� ������� ������.
		integer istart = 1 + iaddR;
		integer iend = nnzR - 1 + iaddR;
		for (integer ii = istart; ii <= iend; ii++) {
		if (flag[R[ii].i] == false) {
		integer istr = R[ii].i;
		integer ic = ii;
		// i-coarse, j-fine
		Real sum1 = 0.0;
		while ((ic <= iend) && (R[ic].i == istr)) {
		// R[R[ii].i][R[ic].j]*A[R[ic].j][jstr]

		for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {
		// (A[ii2].j == jstr) {
		if (A[ii2].i == R[ic].j) {
		sum1 += R[ic].aij*A[ii2].aij;
		}
		//}
		}
		ic++;
		}
		if (fabs(sum1) > RealZERO) {
		A[istartAnew].aij = sum1;
		A[istartAnew].i = istr;
		A[istartAnew].j = jstr;
		if (jstr < 0) {
		printf("fatal error");
		printf("i=%d j=%d aij=%e\n", istr, jstr, sum1);
		system("pause");
		}
		istartAnew++;
		}
		flag[R[ii].i] = true;
		}
		}
		}
		*/

		// ���� droptolerance ������� � ��������� � ������� ��������� 
		// ������� ������ ��� ���� �������� �� �������������
		// � ���� ������������� �������� ��� �� ������ ����� �������� ������.
		//
		//
		//

		// ����� 1 : R*Afine.
		//         xxxxxx
		//         xxxxxx
		//  xxxxxx xxxxxx xxxxxx
		//  xxxxxx xxxxxx xxxxxx
		//         xxxxxx
		//         xxxxxx
		//    R       A     [RA]
		//integer istartAnew = nnz_a[ilevel - 1] + 1 + iadd;
		//for (integer jstr = 1; jstr <= n_a[ilevel - 1]; jstr++) {
		// jstr - ������� ������� �.
		// icounter-1 - ����� ����� �� ������ ������.
		//if ((icounter - 1 > n) || (icounter - 1 < 0)) {
		//printf("flag incorrupt 4...\n");
		//system("pause");
		//exit(1);
		//}
		//for (integer i = 1; i <= icounter - 1; i++) {
		//flag[i] = false;
		//}
		// � (�� ������ �������) ������ ���� ������������� �� j.
		//integer ii1 = BinarySearchAj(A, jstr, 1 + iadd, nnz_a[ilevel - 1] + iadd);
		// ��� ����������� ������ ��� ������� ������.
		//integer istart = 1 + iaddR;
		//integer iend = nnzR - 1 + iaddR;
		//for (integer ii = istart; ii <= iend; ii++) {
		//if ((R[ii].i > n) || (R[ii].i < 0)) {
		//printf("flag incorrupt 3...\n");
		//system("pause");
		//exit(1);
		//}
		//if (flag[R[ii].i] == false) {
		//integer istr = R[ii].i;
		//integer ic = ii;
		// i-coarse, j-fine
		//Real sum1 = 0.0;

		// ��� ��������� ������ ����.
		//while ((ic <= iend) && (R[ic].i == istr)) {
		// R[R[ii].i][R[ic].j]*A[R[ic].j][jstr]

		//for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {

		//if (A[ii2].i == R[ic].j) {
		//sum1 += R[ic].aij*A[ii2].aij;
		//}

		//}
		//ic++;
		//}

		// ��� ����� ������� ���.
		//integer ks = ic;
		//integer ls = ii1;
		//integer kf = ic;
		//bool bvis = false;
		//Real retalon = 0.0;
		//while ((kf <= iend) && (R[kf].i == istr)) {
		//if (R[kf].j == istr) {
		//	retalon = fabs(R[kf].aij);
		//	bvis = true;
		//}
		//kf++;
		//}
		//kf--;

		//if (bvis == false) {
		//kf = ic;
		//while ((kf <= iend) && (R[kf].i == istr)) {
		//	if (fabs(R[kf].aij) > retalon) retalon = fabs(R[kf].aij);
		//	kf++;
		//}
		//kf--;
		//}

		//integer lf = ii1;
		//for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {
		//if (fabs(A[ii2].aij) > retalon) retalon = fabs(A[ii2].aij);
		//if (A[ii2].i == istr) retalon *= fabs(A[ii2].aij);
		//lf++;
		//}
		//lf--;

		//while ((ks <= kf) && (ls <= lf)) {
		//if (A[ls].i < R[ks].j) {
		//	ls++;
		//}
		//else if (A[ls].i > R[ks].j) {
		//	ks++;
		//}
		//else {
		//	sum1 += R[ks].aij*A[ls].aij;
		//	ks++;
		//	ls++;
		//}
		//}




		//if (fabs(sum1) > 0.001*retalon) {
		//if (fabs(sum1)>1.0e-30) {
		//A[istartAnew].aij = sum1;
		//A[istartAnew].i = istr;
		//A[istartAnew].j = jstr;
		//if (jstr < 0) {
		//	printf("fatal error");
		//	printf("i=%d j=%d aij=%e\n", istr, jstr, sum1);
		//	system("pause");
		//}
		//istartAnew++;
		//}
		//flag[R[ii].i] = true;
		//}
		//}
		//}


		printf("nnz left operand=%d, nnz right operand=%d\n", nnzR, nnz_a[ilevel - 1]);

		integer istartAnew;
		integer* kf_array;



		if (0) {

			// ����� ������� ������ �� ������ ������� ������������� ��������.

			//����� ������� ������� ���������.
			// ������� ����� ���� �� ������ ���� ������� ������� ��� �� �����.
			// 17 ������� 2015. ����� ��������� � ������� ����������.
			// ����� 1 : R*Afine.
			//         xxxxxx
			//         xxxxxx
			//  xxxxxx xxxxxx xxxxxx
			//  xxxxxx xxxxxx xxxxxx
			//         xxxxxx
			//         xxxxxx
			//    R       A     [RA]
			kf_array = new integer[numberofcoarcenodes + 1];
			integer istart1 = 1 + iaddR;
			integer iend1 = nnzR - 1 + iaddR;
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			for (integer ii = istart1; ii <= iend1; ii++) {
				if (flag[R[ii].i] == false) {
					integer istr = R[ii].i;
					integer ic = ii;
					integer kf = ic;

					while ((kf <= iend1) && (R[kf].i == istr)) {
						kf++;
					}
					kf--;
					kf_array[istr] = kf;
					flag[R[ii].i] = true;
				}
			}

			integer *start_position_i_string_in_R = new integer[numberofcoarcenodes + 1];
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			integer istart3 = 1 + iaddR;
			integer iend3 = nnzR - 1 + iaddR;
			for (integer ii = istart3; ii <= iend3; ii++) {
				if (flag[R[ii].i] == false) {
					start_position_i_string_in_R[R[ii].i] = ii;
					flag[R[ii].i] = true;
				}
			}


			istartAnew = nnz_a[ilevel - 1] + 1 + iadd;
			for (integer jstr = 1; jstr <= n_a[ilevel - 1]; jstr++) {
				// jstr - ������� ������� �.
				// icounter-1 - ����� ����� �� ������ ������.
				//if ((icounter - 1 > n) || (icounter - 1 < 0)) {
				//printf("flag incorrupt 4...\n");
				//system("pause");
				//exit(1);
				//}
				for (integer i = 1; i <= icounter - 1; i++) {
					flag[i] = false;
				}
				// � (�� ������ �������) ������ ���� ������������� �� j.
				integer ii1 = BinarySearchAj(A, jstr, 1 + iadd, nnz_a[ilevel - 1] + iadd);
				integer lf = ii1;
				for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {
					lf++;
				}
				lf--;

				// ��� �����������  ��� ������  ������.
				//integer istart = 1 + iaddR;
				//integer iend = nnzR - 1 + iaddR;
				//for (integer ii = istart; ii <= iend; ii++) {

				//if (flag[R[ii].i] == false) {
				// �������� �� ������ ��� ������� ����.
				//flag[R[ii].i] = true;

				for (integer i_2 = 1; i_2 <= numberofcoarcenodes; i_2++) {
					//integer istr = R[ii].i;
					//integer ic = ii;

					integer istr = i_2;
					integer ic = start_position_i_string_in_R[i_2];

					// i-coarse, j-fine
					Real sum1 = 0.0;

					// ��� ��������� ������ ����.
					//while ((ic <= iend) && (R[ic].i == istr)) {
					// R[R[ii].i][R[ic].j]*A[R[ic].j][jstr]

					//for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {

					//if (A[ii2].i == R[ic].j) {
					//sum1 += R[ic].aij*A[ii2].aij;
					//}

					//}
					//ic++;
					//}

					// ��� ����� ������� ���.
					integer ks = ic;

					//integer kf = ic;

					//while ((kf <= iend) && (R[kf].i == istr)) {
					//kf++;
					//}
					//kf--;

					integer kf = kf_array[istr];

					integer ls = ii1;



					while ((ks <= kf) && (ls <= lf)) {

						if (A[ls].i < R[ks].j) {
							ls++;
						}
						else if (A[ls].i > R[ks].j) {
							ks++;
						}
						else /*if (A[ls].i == R[ks].j)*/ {
							sum1 += R[ks].aij*A[ls].aij;
							ks++;
							ls++;
						}

					}




					if (fabs(sum1) > 1.0e-30) {
						A[istartAnew].aij = sum1;
						A[istartAnew].i = istr;
						A[istartAnew].j = jstr;
						if (jstr < 0) {
							printf("fatal error");
							printf("i=%d j=%d aij=%e\n", istr, jstr, sum1);
							system("pause");
						}
						istartAnew++;
					}

					//}
				}
			}


			delete[] kf_array;
			delete[] start_position_i_string_in_R;

		}
		else if (0) {

			// ���� ����������.

			//����� ������� ������� ���������.
			// ������� ����� ���� �� ������ ���� ������� ������� ��� �� �����.
			// 22 ������� 2015. ����� ��������� � ������� ����������.
			// ����� 1 : R*Afine.
			//         xxxxxx
			//         xxxxxx
			//  xxxxxx xxxxxx xxxxxx
			//  xxxxxx xxxxxx xxxxxx
			//         xxxxxx
			//         xxxxxx
			//    R       A     [RA]
			kf_array = new integer[numberofcoarcenodes + 1];
			integer istart1 = 1 + iaddR;
			integer iend1 = nnzR - 1 + iaddR;
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			for (integer ii = istart1; ii <= iend1; ii++) {
				if (flag[R[ii].i] == false) {
					integer istr = R[ii].i;
					integer ic = ii;
					integer kf = ic;

					while ((kf <= iend1) && (R[kf].i == istr)) {
						kf++;
					}
					kf--;
					kf_array[istr] = kf;
					flag[R[ii].i] = true;
				}
			}

			integer *start_position_i_string_in_R = new integer[numberofcoarcenodes + 1];
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			integer istart3 = 1 + iaddR;
			integer iend3 = nnzR - 1 + iaddR;
			for (integer ii = istart3; ii <= iend3; ii++) {
				if (flag[R[ii].i] == false) {
					start_position_i_string_in_R[R[ii].i] = ii;
					flag[R[ii].i] = true;
				}
			}

			integer* ind = new integer[n_a[ilevel - 1] + 1];


			istartAnew = nnz_a[ilevel - 1] + 1 + iadd;
			for (integer jstr = 1; jstr <= n_a[ilevel - 1]; jstr++) {
				// jstr - ������� ������� �.
				// icounter-1 - ����� ����� �� ������ ������.
				//if ((icounter - 1 > n) || (icounter - 1 < 0)) {
				//printf("flag incorrupt 4...\n");
				//system("pause");
				//exit(1);
				//}

				for (integer i = 1; i <= n_a[ilevel - 1]; i++) {
					ind[i] = -1; // �������������.
				}

				for (integer i = 1; i <= icounter - 1; i++) {
					flag[i] = false;
				}
				// � (�� ������ �������) ������ ���� ������������� �� j.
				integer ii1 = BinarySearchAj(A, jstr, 1 + iadd, nnz_a[ilevel - 1] + iadd);
				//integer lf = ii1;
				for (integer ii2 = ii1; (ii2 <= nnz_a[ilevel - 1] + iadd) && (A[ii2].j == jstr); ii2++) {
					ind[A[ii2].i] = ii2; // ����������� �������.
					//lf++;
				}
				//lf--;

				// ��� �����������  ��� ������  ������.
				//integer istart = 1 + iaddR;
				//integer iend = nnzR - 1 + iaddR;
				//for (integer ii = istart; ii <= iend; ii++) {

				//if (flag[R[ii].i] == false) {
				// �������� �� ������ ��� ������� ����.
				//flag[R[ii].i] = true;

				for (integer i_2 = 1; i_2 <= numberofcoarcenodes; i_2++) {
					//integer istr = R[ii].i;
					//integer ic = ii;

					integer istr = i_2;
					integer ic = start_position_i_string_in_R[i_2];

					// i-coarse, j-fine
					Real sum1 = 0.0;



					// ��� ����� ������� ���.
					integer ks = ic;


					integer kf = kf_array[istr];

					//integer ls = ii1;


					while (ks <= kf) {
						if (ind[R[ks].j] != -1) {
							sum1 += R[ks].aij*A[ind[R[ks].j]].aij;
						}
						ks++;
					}

					/*
					while ((ks <= kf) && (ls <= lf)) {

					if (A[ls].i < R[ks].j) {
					ls++;
					}
					else if (A[ls].i > R[ks].j) {
					ks++;
					}
					else {
					sum1 += R[ks].aij*A[ls].aij;
					ks++;
					ls++;
					}

					}
					*/



					if (fabs(sum1) > 1.0e-30) {
						A[istartAnew].aij = sum1;
						A[istartAnew].i = istr;
						A[istartAnew].j = jstr;
						if (jstr < 0) {
							printf("fatal error");
							printf("i=%d j=%d aij=%e\n", istr, jstr, sum1);
							system("pause");
						}
						istartAnew++;
					}

					//}
				}
			}


			delete[] kf_array;
			delete[] start_position_i_string_in_R;
			delete[] ind;
		}
		else {

			if (0) {

				// ���� ��������� IBM 1978.
				// 23 ������� 2015 ����.

				// ����� 1 : R*Afine.
				//         xxxxxx
				//         xxxxxx
				//  xxxxxx xxxxxx xxxxxx
				//  xxxxxx xxxxxx xxxxxx
				//         xxxxxx
				//         xxxxxx
				//    R       A     [RA]
				// ���������� � �� �������.
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);

				// �������������� � ������� CRS.

				integer* row_ind_SR = new integer[numberofcoarcenodes + 1];
				integer* row_ind_ER = new integer[numberofcoarcenodes + 1];
				for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
					row_ind_SR[i_1] = -1;
					row_ind_ER[i_1] = -2;
				}
				integer istart1 = 1 + iaddR;
				integer iend1 = nnzR - 1 + iaddR;
				for (integer i = 1; i <= icounter - 1; i++) {
					flag[i] = false;
				}
				for (integer ii = istart1; ii <= iend1; ii++) {
					if (flag[R[ii].i] == false) {
						integer istr = R[ii].i;
						integer ic = ii;
						integer kf = ic;

						while ((kf <= iend1) && (R[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_SR[istr] = ic;
						row_ind_ER[istr] = kf;
						flag[R[ii].i] = true;
					}
				}

				// ������ ������ ������ �����������.
				//for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
				//if (row_ind_SR[i_1] == -1) {
				//printf("empty string %d\n", row_ind_ER[i_1]);
				//}
				//}

				integer* row_ind_SA = new integer[n_a[ilevel - 1] + 1];
				integer* row_ind_EA = new integer[n_a[ilevel - 1] + 1];
				integer istart3 = 1 + iadd;
				integer iend3 = nnz_a[ilevel - 1] + iadd;
				for (integer i = 1; i <= n_a[ilevel - 1]; i++) {
					flag[i] = false;
				}
				for (integer ii = istart3; ii <= iend3; ii++) {
					if (flag[A[ii].i] == false) {
						integer istr = A[ii].i;
						integer ic = ii;
						integer kf = ic;

						while ((kf <= iend3) && (A[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_SA[istr] = ic;
						row_ind_EA[istr] = kf;
						flag[A[ii].i] = true;
					}
				}

				istartAnew = nnz_a[ilevel - 1] + 1 + iadd;

				// ������ ������������ ��� ���������� ������������� �����.
				Real* vector_sum = new Real[n_a[ilevel - 1] + 1];
				//bool* b_visit_vec_sum = new bool[n_a[ilevel - 1] + 1];
				//integer size_v = sizeof(Real)*(1 + n_a[ilevel - 1]);

				// ��������� ������ ������� ���������.
				for (integer istr = 1; istr <= numberofcoarcenodes; istr++) {

					// �������� ������������ ����� ������.
					// ����� ������������� ����� � ����.
					//#pragma omp parallel for
					for (integer i_2 = 1; i_2 <= n_a[ilevel - 1]; i_2++) {
						vector_sum[i_2] = 0.0; // ������������� // 18.5
						//b_visit_vec_sum[i_2] = false;
					}
					// ����� ������� ���������
					// �� ������� � ������ ������ �����. �� ����� ������ ���������� ��-�� ��������� ��������� dll-��.
					//memset(vector_sum, 0,size_v );

					// ��������� ������� i-�� ������ �����������
					for (integer ii = row_ind_SR[istr]; ii <= row_ind_ER[istr]; ii++) {
						integer col_ind = R[ii].j;
						// ��������� col_ind ������ ������� ��������

						for (integer i_1 = row_ind_SA[col_ind]; i_1 <= row_ind_EA[col_ind]; i_1++) {
							Real left_operand = R[ii].aij;
							Real right_operand = A[i_1].aij;
							vector_sum[A[i_1].j] += left_operand*right_operand;
							//b_visit_vec_sum[A[i_1].j] = true;
						}
					}

					for (integer jstr = 1; jstr <= n_a[ilevel - 1]; jstr++) {
						// ������� ������� �������� 
						//if (b_visit_vec_sum[jstr]) {
						// � ����� ���������.
						if (fabs(vector_sum[jstr]) > 1.0e-30) { // 36.3
							A[istartAnew].aij = vector_sum[jstr];
							A[istartAnew].i = istr;
							A[istartAnew].j = jstr;
							istartAnew++;
						}
						//}
					}
				}

				delete[] row_ind_SR;
				delete[] row_ind_ER;
				delete[] row_ind_SA;
				delete[] row_ind_EA;
				delete[] vector_sum;
				//delete[] b_visit_vec_sum;

			}
			else {
				// ���� ��������� IBM 1978.
				// 23 ������� 2015 ����.

				// ����� 1 : R*Afine.
				//         xxxxxx
				//         xxxxxx
				//  xxxxxx xxxxxx xxxxxx
				//  xxxxxx xxxxxx xxxxxx
				//         xxxxxx
				//         xxxxxx
				//    R       A     [RA]
				// ���������� � �� �������.
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);

				// �������������� � ������� CRS.

				integer* row_ind_SR = new integer[numberofcoarcenodes + 1];
				integer* row_ind_ER = new integer[numberofcoarcenodes + 1];
				for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
					row_ind_SR[i_1] = -1;
					row_ind_ER[i_1] = -2;
				}
				integer istart1 = 1 + iaddR;
				integer iend1 = nnzR - 1 + iaddR;
				for (integer i = 1; i <= icounter - 1; i++) {
					flag[i] = false;
				}
				for (integer ii = istart1; ii <= iend1; ii++) {
					if (flag[R[ii].i] == false) {
						integer istr = R[ii].i;
						integer ic = ii;
						integer kf = ic;

						while ((kf <= iend1) && (R[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_SR[istr] = ic;
						row_ind_ER[istr] = kf;
						flag[R[ii].i] = true;
					}
				}

				// ������ ������ ������ �����������.
				//for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
				//if (row_ind_SR[i_1] == -1) {
				//printf("empty string %d\n", row_ind_ER[i_1]);
				//}
				//}

				integer* row_ind_SA = new integer[n_a[ilevel - 1] + 1];
				integer* row_ind_EA = new integer[n_a[ilevel - 1] + 1];
				integer istart3 = 1 + iadd;
				integer iend3 = nnz_a[ilevel - 1] + iadd;
				for (integer i = 1; i <= n_a[ilevel - 1]; i++) {
					flag[i] = false;
				}
				for (integer ii = istart3; ii <= iend3; ii++) {
					if (flag[A[ii].i] == false) {
						integer istr = A[ii].i;
						integer ic = ii;
						integer kf = ic;

						while ((kf <= iend3) && (A[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_SA[istr] = ic;
						row_ind_EA[istr] = kf;
						flag[A[ii].i] = true;
					}
				}

				istartAnew = nnz_a[ilevel - 1] + 1 + iadd;

				// ������ ������������ ��� ���������� ������������� �����.
				Real* vector_sum = new Real[n_a[ilevel - 1] + 1];
				//bool* b_visit_vec_sum = new bool[n_a[ilevel - 1] + 1];
				//integer size_v = sizeof(Real)*(1 + n_a[ilevel - 1]);
				// ������ ������� ��������� ��������� � ��������������� �������.
				integer* index_visit = new integer[n_a[ilevel - 1] + 1];
				integer index_size = 0;

				// ��������� ������ ������� ���������.
				for (integer istr = 1; istr <= numberofcoarcenodes; istr++) {

					// �������� ������������ ����� ������.
					// ����� ������������� ����� � ����.
					//#pragma omp parallel for
					//for (integer i_2 = 1; i_2 <= n_a[ilevel - 1]; i_2++) {
					//vector_sum[i_2] = 0.0; // ������������� // 18.5
					//b_visit_vec_sum[i_2] = false;
					//}
					// ����� ������� ���������
					// �� ������� � ������ ������ �����. �� ����� ������ ���������� ��-�� ��������� ��������� dll-��.
					//memset(vector_sum, 0,size_v );

					// ��������� ������� i-�� ������ �����������
					for (integer ii = row_ind_SR[istr]; ii <= row_ind_ER[istr]; ii++) {
						integer col_ind = R[ii].j;
						// ��������� col_ind ������ ������� ��������

						for (integer i_1 = row_ind_SA[col_ind]; i_1 <= row_ind_EA[col_ind]; i_1++) {
							Real left_operand = R[ii].aij;
							Real right_operand = A[i_1].aij;
							integer iaddind = A[i_1].j;
							bool foundnow = false;
							integer ifoundind = -1;
							// �������� ����� ������� � ������� �� ����������.
							for (integer i_6 = 1; i_6 <= index_size; i_6++) {
								if (index_visit[i_6] == iaddind) {
									foundnow = true;
									ifoundind = i_6;
									break;
								}
							}
							if (foundnow) {
								vector_sum[index_visit[ifoundind]] += left_operand*right_operand;
							}
							else {
								// ������ ����������.
								index_size++;
								index_visit[index_size] = iaddind;
								ifoundind = index_size;
								vector_sum[index_visit[ifoundind]] = left_operand*right_operand;
							}

							//vector_sum[A[i_1].j] += left_operand*right_operand;
							//b_visit_vec_sum[A[i_1].j] = true;
						}
					}

					for (integer i_6 = 1; i_6 <= index_size; i_6++) {
						integer jstr = index_visit[i_6];
						if (fabs(vector_sum[jstr]) > 1.0e-30) {
							A[istartAnew].aij = vector_sum[jstr];
							A[istartAnew].i = istr;
							A[istartAnew].j = jstr;
							istartAnew++;
						}
					}
					index_size = 0;


				}
				delete[] index_visit;
				delete[] row_ind_SR;
				delete[] row_ind_ER;
				delete[] row_ind_SA;
				delete[] row_ind_EA;
				delete[] vector_sum;
			}

		}

		// ���������� � �� i (���������.).
		//heapsort(A, key=i*n_a[ilevel - 1] + j, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort(A, 1 + iadd, nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < heapsortsizelimit) {
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[1 + iadd];
				MergeSort(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}

		// �������� �������� �������.
		for (integer i_1 = nnz_a[ilevel - 1] + 1 + iadd; i_1 <= istartAnew - 1; i_1++) {
			if (A[i_1].j < 0) {
				printf("error : negativ j index\n");
				system("pause");
			}
			//printf("A[%d].i=%d A[%d].j=%d A[%d].aij=%e\n", i_1, A[i_1].i, i_1, A[i_1].j, i_1, A[i_1].aij);
			//system("pause");
		}



		// ����� 2. [R*Afine]*P=Abuf*P.
		// ���������� [R*�] �� i.
		//heapsort(A, key=i*n_coarce + j, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort(A, nnz_a[ilevel - 1] + 1 + iadd, istartAnew - 1);
		}
		else {
			if (nnz_a[ilevel - 1] < heapsortsizelimit) {
				HeapSort(A, icounter - 1, nnz_a[ilevel - 1] + 1 + iadd, istartAnew - 1);
			}
			else {
				Ak* Aorig = &A[nnz_a[ilevel - 1] + 1 + iadd];
				MergeSort(Aorig, istartAnew - 1 - (nnz_a[ilevel - 1] + 1 + iadd) + 1);
				Aorig = NULL;
			}
		}


		// �������� �������� �������.
		for (integer i_1 = nnz_a[ilevel - 1] + 1 + iadd; i_1 <= istartAnew - 1; i_1++) {
			if (A[i_1].j < 0) {
				printf("error : negativ j index\n");
				system("pause");
			}
			//-->	//printf("A[%d].i=%d A[%d].j=%d A[%d].aij=%e\n", i_1, A[i_1].i, i_1, A[i_1].j, i_1, A[i_1].aij);
			//system("pause");
		}

		// ����� ��������� � ���� BubbleSort.
		// ����� ��� �������� ����� ������� ���������� ����������.
		//integer k3 = 0;
		//for (integer k1 = nnz_a[ilevel - 1] + 1 + iadd; k1 < istartAnew - 1; k1++,k3++) {
		//for (integer k2 = nnz_a[ilevel - 1] + 1 + iadd; k2 < istartAnew - 1 - k3; k2++) {
		//if (A[k2].i>A[k2 + 1].i) {
		// change
		//Ak Temp = A[k2];
		//	A[k2] = A[k2 + 1];
		//A[k2 + 1] = Temp;
		//}
		//else if (A[k2].i == A[k2 + 1].i) {
		//if (A[k2].j>A[k2 + 1].j) {
		// change
		//Ak Temp = A[k2];
		//A[k2] = A[k2 + 1];
		//A[k2 + 1] = Temp;
		//}
		//}
		//}
		//}

		// �������� [R*A] debug
		//for (int i_1 = nnz_a[ilevel - 1] + 1 + iadd; i_1 <= istartAnew - 1; i_1++) {
		//printf("A[%d].i=%d A[%d].j=%d A[%d].aij=%e\n", i_1, A[i_1].i, i_1, A[i_1].j, i_1, A[i_1].aij);
		//system("pause");
		//}

		if (bquicktypesort) {
			QuickSort(P, 1 + iaddR, iaddR + nnzR - 1);
		}
		else {
			HeapSort(P, n_a[ilevel - 1], 1 + iaddR, iaddR + nnzR - 1);
		}

		// Prolongation ������ ���� ����������� �� j.
		// ��������� ������� ��������� ������� �������������� ������.
		integer istartAnew2 = istartAnew;

		/*
		// icounter - 1; // ���������� ����� �� ������������� ������.
		for (integer i = 1; i <= n_coarce; i++) {
		flag[i] = false;
		}
		// P ������ ���� ���������� �� �������.
		// �������� ��������� � P
		for (integer ii77 = 1; ii77 <= nnzR; ii77++) {
		printf("i=%d j=%d %e\n",P[ii77].i,P[ii77].j,P[ii77].aij);
		getchar();
		}
		*/

		//begin medlennji
		/*
		// ��������� �� ��������
		for (integer jstr = 1; jstr <= icounter-1; jstr++) {
		for (integer i = 1; i <= n_coarce; i++) {
		flag[i] = false;
		}
		//integer ii1 = BinarySearchAj(P, jstr, 1+iaddR, nnzR - 1+iaddR);
		// ���� � ��� ��� � ������� P �� �������� � ������������ (� ��������� �� ���������������� ����).
		integer ii1 = BinarySearchAi(P, jstr, 1 + iaddR, nnzR - 1 + iaddR);
		// ��� ����������� ������ ��� ������� ������.
		integer istart = nnz_a[ilevel - 1] + 1 + iadd;
		integer iend = istartAnew - 1;
		for (integer ii = istart; ii <= iend; ii++) {
		if (flag[A[ii].i] == false) {
		// ��������� ���������.
		integer istr = A[ii].i;
		integer ic = ii;
		// i-coarse, j-fine
		Real sum1 = 0.0;
		while ((ic <= iend) && (A[ic].i == istr)) {
		// [R*A][A[ii].i][A[ic].j]*P[A[ic].j][jstr]
		// � ������� P �� ���������� � ��������� �� ����������������.
		// [R*A][A[ii].i][A[ic].j]*P[jstr][A[ic].j]
		for (integer ii2 = ii1; (ii2 <= nnzR- 1+iaddR) && (P[ii2].i == jstr); ii2++) {

		if (P[ii2].j == A[ic].j) {
		sum1 += A[ic].aij*P[ii2].aij;
		//printf("%e i=%d j=%d k=%d\n", A[ic].aij*P[ii2].aij,istr,P[ii2].j,jstr);
		//getchar();
		}
		}

		ic++;
		}

		if (fabs(sum1) > RealZERO) {
		A[istartAnew2].aij = sum1;
		A[istartAnew2].i = istr;
		A[istartAnew2].j = jstr;
		istartAnew2++;
		}
		flag[A[ii].i] = true;
		}
		}
		}
		*/




		// ��������� �� ��������
		//for (integer jstr = 1; jstr <= icounter - 1; jstr++) {

		//for (integer i = 1; i <= n; i++) {
		//flag[i] = false;
		//}
		//integer ii1 = BinarySearchAj(P, jstr, 1+iaddR, nnzR - 1+iaddR);
		// ���� � ��� ��� � ������� P �� �������� � ������������ (� ��������� �� ���������������� ����).
		//integer ii1 = BinarySearchAi(P, jstr, 1 + iaddR, nnzR - 1 + iaddR);
		// ��� ����������� ������ ��� ������� ������.
		//integer istart = nnz_a[ilevel - 1] + 1 + iadd;
		//integer iend = istartAnew - 1;
		//for (integer ii = istart; ii <= iend; ii++) {
		//if ((A[ii].i > n)||(A[ii].i<0)) {
		//printf("flag incorrupt 1...\n");
		//system("pause");
		//exit(1);
		//}
		//if (flag[A[ii].i] == false) {
		// ��������� ���������.
		//integer istr = A[ii].i;
		//integer ic = ii;
		// i-coarse, j-fine
		//	Real sum1 = 0.0;

		// ������� ��������� ������� ���� �� �������.
		//while ((ic <= iend) && (A[ic].i == istr)) {
		// [R*A][A[ii].i][A[ic].j]*P[A[ic].j][jstr]
		// � ������� P �� ���������� � ��������� �� ����������������.
		// [R*A][A[ii].i][A[ic].j]*P[jstr][A[ic].j]
		//for (integer ii2 = ii1; (ii2 <= nnzR - 1 + iaddR) && (P[ii2].i == jstr); ii2++) {

		//	if (P[ii2].j == A[ic].j) {
		//sum1 += A[ic].aij*P[ii2].aij;
		//	}
		//}

		//ic++;
		//}

		// ����� ������� ��� �� ������ �������.
		//integer ks = ic;
		//integer ls = ii1;
		//integer kf = ic;
		//Real retalon = 0.0;
		//bool bvis = false;
		//while ((kf <= iend) && (A[kf].i == istr)) {
		//if (fabs(A[kf].aij) > retalon) retalon = fabs(A[kf].aij);
		//if (A[kf].j == istr) {
		//	retalon = fabs(A[kf].aij);
		//	bvis = true;
		//}
		///kf++;
		//}
		//kf--;
		//if (bvis == false) {
		//kf = ic;
		//while ((kf <= iend) && (A[kf].i == istr)) {
		//	if (fabs(A[kf].aij) > retalon) retalon = fabs(A[kf].aij);
		//	kf++;
		//}
		//kf--;
		//}
		//integer lf = ii1;
		//for (integer ii2 = ii1; (ii2 <= nnzR - 1 + iaddR) && (P[ii2].i == jstr); ii2++) {
		//if (P[ii2].j == istr) retalon *= fabs(P[ii2].aij); // ��� ������������ �������.
		//lf++;
		//}
		//lf--;
		//while ((ks <= kf) && (ls <= lf)) {
		//if (P[ls].j<A[ks].j) {
		//	ls++;
		//}
		//else if (P[ls].j > A[ks].j) {
		//	ks++;
		//}
		//else {
		//	sum1 += A[ks].aij*P[ls].aij;
		//	ks++;
		//	ls++;
		//}
		//}
		//if (fabs(retalon) < 1.0e-30) {
		//printf("RAP retalon=%e string %d is zero\n",retalon,istr);
		//getchar();
		//}

		//---//if (fabs(sum1) > 0.001*retalon) {
		//if (fabs(sum1)>1.0e-30) {
		//A[istartAnew2].aij = sum1;
		//A[istartAnew2].i = istr;
		//A[istartAnew2].j = jstr;
		//istartAnew2++;
		//}
		//flag[A[ii].i] = true;
		//}
		//}
		//}

		// ������� ����� ���� �� ������ ���� ������� ������� ��� �� �����.
		// 17 ������� 2015. ����� ��������� � ������� ����������.
		printf("nnz left operand=%d, nnz right operand=%d\n", istartAnew - (nnz_a[ilevel - 1] + 1 + iadd), nnzR);

		if (0) {

			// ��� �� ������ ������� ������������� ��������.

			kf_array = new integer[numberofcoarcenodes + 1];
			integer istart2 = nnz_a[ilevel - 1] + 1 + iadd;
			integer iend2 = istartAnew - 1;
			for (integer i = 1; i <= n; i++) {
				flag[i] = false;
			}
			for (integer ii = istart2; ii <= iend2; ii++) {
				if (flag[A[ii].i] == false) {
					// ��������� ���������.
					integer istr = A[ii].i;
					integer ic = ii;

					integer kf = ic;

					while ((kf <= iend2) && (A[kf].i == istr)) {
						kf++;
					}
					kf--;
					kf_array[istr] = kf;
					flag[A[ii].i] = true;

				}
			}

			// ���������� ����� � ������� � ���� ����� numberofcoarcenodes
			integer *start_position_i_string_in_RA = new integer[numberofcoarcenodes + 1];
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			integer istart4 = nnz_a[ilevel - 1] + 1 + iadd;
			integer iend4 = istartAnew - 1;
			for (integer ii = istart4; ii <= iend4; ii++) {
				if (flag[A[ii].i] == false) {
					start_position_i_string_in_RA[A[ii].i] = ii;
					flag[A[ii].i] = true;
				}
			}


			// ����� ������� ������ ���� : 15 ������� 2015
			// ��������� �� ��������
			for (integer jstr = 1; jstr <= icounter - 1; jstr++) {

				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				//integer ii1 = BinarySearchAj(P, jstr, 1+iaddR, nnzR - 1+iaddR);
				// ���� � ��� ��� � ������� P �� �������� � ������������ (� ��������� �� ���������������� ����).
				integer ii1 = BinarySearchAi(P, jstr, 1 + iaddR, nnzR - 1 + iaddR);

				integer lf = ii1;
				for (integer ii2 = ii1; (ii2 <= nnzR - 1 + iaddR) && (P[ii2].i == jstr); ii2++) {
					lf++;
				}
				lf--;

				// ��� ����������� ������ ��� ������� ������.
				//integer istart = nnz_a[ilevel - 1] + 1 + iadd;
				//integer iend = istartAnew - 1;
				//for (integer ii = istart; ii <= iend; ii++) {

				//if (flag[A[ii].i] == false) {
				// �� � ���� ������ �� �������� �������������� ����.
				//flag[A[ii].i] = true;
				// ��������� ���������.
				//integer istr = A[ii].i;
				//integer ic = ii;

				for (integer i_2 = 1; i_2 <= numberofcoarcenodes; i_2++) {

					integer istr = i_2;
					integer ic = start_position_i_string_in_RA[i_2];

					// i-coarse, j-fine
					Real sum1 = 0.0;

					// ������� ��������� ������� ���� �� �������.
					//while ((ic <= iend) && (A[ic].i == istr)) {
					// [R*A][A[ii].i][A[ic].j]*P[A[ic].j][jstr]
					// � ������� P �� ���������� � ��������� �� ����������������.
					// [R*A][A[ii].i][A[ic].j]*P[jstr][A[ic].j]
					//for (integer ii2 = ii1; (ii2 <= nnzR - 1 + iaddR) && (P[ii2].i == jstr); ii2++) {

					//	if (P[ii2].j == A[ic].j) {
					//sum1 += A[ic].aij*P[ii2].aij;
					//	}
					//}

					//ic++;
					//}

					// ����� ������� ��� �� ������ �������.
					integer ks = ic;

					//integer kf = ic;

					//while ((kf <= iend) && (A[kf].i == istr)) {
					//kf++;
					//}
					//kf--;
					integer kf = kf_array[istr];

					integer ls = ii1;

					while ((ks <= kf) && (ls <= lf)) {

						if (P[ls].j < A[ks].j) {
							ls++;
						}
						else if (P[ls].j > A[ks].j) {
							ks++;
						}
						else /*if (P[ls].j==A[ks].j)*/ {
							sum1 += A[ks].aij*P[ls].aij;
							ks++;
							ls++;
						}

					}

					if (fabs(sum1) > 1.0e-30) {
						A[istartAnew2].aij = sum1;
						A[istartAnew2].i = istr;
						A[istartAnew2].j = jstr;
						istartAnew2++;
					}

					//}
				}
			}

			delete[] kf_array;
			delete[] start_position_i_string_in_RA;

		}
		else if (0) {
			// ���� ���������� 22 ������� 2015.

			kf_array = new integer[numberofcoarcenodes + 1];
			integer istart2 = nnz_a[ilevel - 1] + 1 + iadd;
			integer iend2 = istartAnew - 1;
			for (integer i = 1; i <= n; i++) {
				flag[i] = false;
			}
			for (integer ii = istart2; ii <= iend2; ii++) {
				if (flag[A[ii].i] == false) {
					// ��������� ���������.
					integer istr = A[ii].i;
					integer ic = ii;

					integer kf = ic;

					while ((kf <= iend2) && (A[kf].i == istr)) {
						kf++;
					}
					kf--;
					kf_array[istr] = kf;
					flag[A[ii].i] = true;

				}
			}

			// ���������� ����� � ������� � ���� ����� numberofcoarcenodes
			integer *start_position_i_string_in_RA = new integer[numberofcoarcenodes + 1];
			for (integer i = 1; i <= icounter - 1; i++) {
				flag[i] = false;
			}
			integer istart4 = nnz_a[ilevel - 1] + 1 + iadd;
			integer iend4 = istartAnew - 1;
			for (integer ii = istart4; ii <= iend4; ii++) {
				if (flag[A[ii].i] == false) {
					start_position_i_string_in_RA[A[ii].i] = ii;
					flag[A[ii].i] = true;
				}
			}

			integer *ind = new integer[n_a[ilevel - 1] + 1];


			// ����� ������� ������ ���� : 15 ������� 2015
			// ��������� �� ��������
			for (integer jstr = 1; jstr <= icounter - 1; jstr++) {

				for (integer i = 1; i <= n_a[ilevel - 1]; i++) {
					ind[i] = -1; // �������������.
				}

				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				//integer ii1 = BinarySearchAj(P, jstr, 1+iaddR, nnzR - 1+iaddR);
				// ���� � ��� ��� � ������� P �� �������� � ������������ (� ��������� �� ���������������� ����).
				integer ii1 = BinarySearchAi(P, jstr, 1 + iaddR, nnzR - 1 + iaddR);

				//integer lf = ii1;
				for (integer ii2 = ii1; (ii2 <= nnzR - 1 + iaddR) && (P[ii2].i == jstr); ii2++) {
					ind[P[ii2].j] = ii2;
					//lf++;
				}
				//lf--;

				// ��� ����������� ������ ��� ������� ������.
				//integer istart = nnz_a[ilevel - 1] + 1 + iadd;
				//integer iend = istartAnew - 1;
				//for (integer ii = istart; ii <= iend; ii++) {

				//if (flag[A[ii].i] == false) {
				// �� � ���� ������ �� �������� �������������� ����.
				//flag[A[ii].i] = true;
				// ��������� ���������.
				//integer istr = A[ii].i;
				//integer ic = ii;

				for (integer i_2 = 1; i_2 <= numberofcoarcenodes; i_2++) {

					integer istr = i_2;
					integer ic = start_position_i_string_in_RA[i_2];

					// i-coarse, j-fine
					Real sum1 = 0.0;



					// ����� ������� ��� �� ������ �������.
					integer ks = ic;


					integer kf = kf_array[istr];

					//integer ls = ii1;

					while (ks <= kf) {
						if (ind[A[ks].j] != -1) {
							sum1 += A[ks].aij*P[ind[A[ks].j]].aij;
						}
						ks++;
					}

					//while ((ks <= kf) && (ls <= lf)) {

					//if (P[ls].j < A[ks].j) {
					//ls++;
					//}
					//else if (P[ls].j > A[ks].j) {
					//ks++;
					//}
					//else /*if (P[ls].j==A[ks].j)*/ {
					//sum1 += A[ks].aij*P[ls].aij;
					//ks++;
					//ls++;
					//}

					//}

					if (fabs(sum1) > 1.0e-30) {
						A[istartAnew2].aij = sum1;
						A[istartAnew2].i = istr;
						A[istartAnew2].j = jstr;
						istartAnew2++;
					}

					//}
				}
			}

			delete[] kf_array;
			delete[] start_position_i_string_in_RA;
			delete[] ind;

		}
		else {
			// ���� ��������� IBM 1978
			// � ���� ���� ���������� ���� �� ������ ���������,
			// � �� ����� ��� � ���������� ����������� ���������� ������ ���� :
			// (�������, �������, ����������) ������� ���� �������������� ������ �������
			// �� ��������� (���������) � ��������� �������� 30 � 1. 30 ��������� �� ���� �����������.
			// 23 ������� 2015 ����.

			if (0) {
				// �������������� ����� ������ � ������ CRS.
				HeapSort_j(P, 1 + iaddR, iaddR + nnzR - 1);

				integer* row_ind_AS = new integer[numberofcoarcenodes + 1];
				integer* row_ind_AE = new integer[numberofcoarcenodes + 1];
				integer istart2 = nnz_a[ilevel - 1] + 1 + iadd;
				integer iend2 = istartAnew - 1;
				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				for (integer ii = istart2; ii <= iend2; ii++) {
					if (flag[A[ii].i] == false) {
						// ��������� ���������.
						integer istr = A[ii].i;
						integer ic = ii;

						integer kf = ic;

						while ((kf <= iend2) && (A[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_AS[istr] = ic;
						row_ind_AE[istr] = kf;
						flag[A[ii].i] = true;

					}
				}

				integer* row_ind_PS = new integer[n_a[ilevel - 1] + 1];
				integer* row_ind_PE = new integer[n_a[ilevel - 1] + 1];
				// ������������� ����������� �����, �.�. 
				// ����������� ������������ ������ ������ �������
				// ���� ��������� ������������.
				for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
					row_ind_PS[ii] = -1; // �������������.
					row_ind_PE[ii] = -2;
				}
				integer istart4 = 1 + iaddR;
				integer iend4 = nnzR - 1 + iaddR;
				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				for (integer ii = istart4; ii <= iend4; ii++) {
					if (flag[P[ii].j] == false) {
						// ��������� ���������.
						integer istr = P[ii].j;
						integer ic = ii;

						integer kf = ic;

						while ((kf <= iend4) && (P[kf].j == istr)) {
							kf++;
						}
						kf--;
						row_ind_PS[istr] = ic;
						row_ind_PE[istr] = kf;
						flag[P[ii].j] = true;

					}
				}

				// ������ ��� ������������ ��� ����������� ������������
				// ������ ������.
				//for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
				//if (row_ind_PS[ii] == -1) {
				//printf("propusk string %d\n", row_ind_PE[ii]);
				//getchar();
				//}
				//}

				// ���������� ����������.
				Real* vector_sum = new Real[numberofcoarcenodes + 1];
				//integer size_v = sizeof(Real)*(1 + numberofcoarcenodes);

				// �� ����� ����������� ����� ������� ���������, �
				// ����� ��������� ��������� ����� ������ ������ ��������
				// �������� ������� ������ ����������.

				for (integer istr = 1; istr <= numberofcoarcenodes; istr++) {

					// ������� � ����� ������, ����� ���������� ����������.
					//#pragma omp parallel for
					for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
						vector_sum[i_1] = 0.0; // ���������.
					}
					// ���� ��������� � ���������� ��� �� memset ��������� ������ ������������� �������,
					// �� ��� ��������� ��������� ����� �� ������� ��������� ������� �� ������� ��� � ������.
					// ������ ������������ �� ������ ����� � ������.
					// ����� ������� ���������.
					//memset(vector_sum, 0, size_v);

					// ��������� ��� �������� ������ ������ ��������.
					for (integer ii1 = row_ind_AS[istr]; ii1 <= row_ind_AE[istr]; ii1++) {
						integer col_ind = A[ii1].j;

						// ��������� col_ind ������ ������� �������� ���������� �����.
						for (integer ii2 = row_ind_PS[col_ind]; ii2 <= row_ind_PE[col_ind]; ii2++) {
							Real rleft = A[ii1].aij;
							Real rright = P[ii2].aij;

							vector_sum[P[ii2].i] += rleft*rright;
						}
					}

					for (integer jstr = 1; jstr <= numberofcoarcenodes; jstr++) {
						if (fabs(vector_sum[jstr]) > 1.0e-30) {
							A[istartAnew2].aij = vector_sum[jstr];
							A[istartAnew2].i = istr;
							A[istartAnew2].j = jstr;
							istartAnew2++;
						}
					}

				}

				delete[] vector_sum;



				delete[] row_ind_AS;
				delete[] row_ind_AE;
				delete[] row_ind_PS;
				delete[] row_ind_PE;
			}
			else {

				// ������� ������ ��������� ����� ����������.
				// IBM 1978 Sparse Matrix multiplication.

				// �������������� ����� ������ � ������ CRS.
				HeapSort_j(P, 1 + iaddR, iaddR + nnzR - 1);

				integer* row_ind_AS = new integer[numberofcoarcenodes + 1];
				integer* row_ind_AE = new integer[numberofcoarcenodes + 1];
				integer istart2 = nnz_a[ilevel - 1] + 1 + iadd;
				integer iend2 = istartAnew - 1;
				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				for (integer ii = istart2; ii <= iend2; ii++) {
					if (flag[A[ii].i] == false) {
						// ��������� ���������.
						integer istr = A[ii].i;
						integer ic = ii;

						integer kf = ic;

						while ((kf <= iend2) && (A[kf].i == istr)) {
							kf++;
						}
						kf--;
						row_ind_AS[istr] = ic;
						row_ind_AE[istr] = kf;
						flag[A[ii].i] = true;

					}
				}

				integer* row_ind_PS = new integer[n_a[ilevel - 1] + 1];
				integer* row_ind_PE = new integer[n_a[ilevel - 1] + 1];
				// ������������� ����������� �����, �.�. 
				// ����������� ������������ ������ ������ �������
				// ���� ��������� ������������.
				for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
					row_ind_PS[ii] = -1; // �������������.
					row_ind_PE[ii] = -2;
				}
				integer istart4 = 1 + iaddR;
				integer iend4 = nnzR - 1 + iaddR;
				for (integer i = 1; i <= n; i++) {
					flag[i] = false;
				}
				for (integer ii = istart4; ii <= iend4; ii++) {
					if (flag[P[ii].j] == false) {
						// ��������� ���������.
						integer istr = P[ii].j;
						integer ic = ii;

						integer kf = ic;

						while ((kf <= iend4) && (P[kf].j == istr)) {
							kf++;
						}
						kf--;
						row_ind_PS[istr] = ic;
						row_ind_PE[istr] = kf;
						flag[P[ii].j] = true;

					}
				}

				// ������ ��� ������������ ��� ����������� ������������
				// ������ ������.
				//for (integer ii = 1; ii <= n_a[ilevel - 1]; ii++) {
				//if (row_ind_PS[ii] == -1) {
				//printf("propusk string %d\n", row_ind_PE[ii]);
				//getchar();
				//}
				//}

				// ���������� ����������.
				Real* vector_sum = new Real[numberofcoarcenodes + 1];
				//integer size_v = sizeof(Real)*(1 + numberofcoarcenodes);
				// ������ ������� ��������� ��������� � ��������������� �������.
				integer* index_visit = new integer[n_a[ilevel - 1] - 1];
				integer index_size = 0;

				// �� ����� ����������� ����� ������� ���������, �
				// ����� ��������� ��������� ����� ������ ������ ��������
				// �������� ������� ������ ����������.

				for (integer istr = 1; istr <= numberofcoarcenodes; istr++) {

					// ������� � ����� ������, ����� ���������� ����������.
					//#pragma omp parallel for
					//for (integer i_1 = 1; i_1 <= numberofcoarcenodes; i_1++) {
					//vector_sum[i_1] = 0.0; // ���������.
					//}
					// ���� ��������� � ���������� ��� �� memset ��������� ������ ������������� �������,
					// �� ��� ��������� ��������� ����� �� ������� ��������� ������� �� ������� ��� � ������.
					// ������ ������������ �� ������ ����� � ������.
					// ����� ������� ���������.
					//memset(vector_sum, 0, size_v);

					// ��������� ��� �������� ������ ������ ��������.
					for (integer ii1 = row_ind_AS[istr]; ii1 <= row_ind_AE[istr]; ii1++) {
						integer col_ind = A[ii1].j;

						// ��������� col_ind ������ ������� �������� ���������� �����.
						for (integer ii2 = row_ind_PS[col_ind]; ii2 <= row_ind_PE[col_ind]; ii2++) {
							Real left_operand = A[ii1].aij;
							Real right_operand = P[ii2].aij;

							integer iaddind = P[ii2].i;
							bool foundnow = false;
							integer ifoundind = -1;
							// �������� ����� ������� � ������� �� ����������.
							for (integer i_6 = 1; i_6 <= index_size; i_6++) {
								if (index_visit[i_6] == iaddind) {
									foundnow = true;
									ifoundind = i_6;
									break;
								}
							}
							if (foundnow) {
								vector_sum[index_visit[ifoundind]] += left_operand*right_operand;
							}
							else {
								// ������ ����������.
								index_size++;
								index_visit[index_size] = iaddind;
								ifoundind = index_size;
								vector_sum[index_visit[ifoundind]] = left_operand*right_operand;
							}



							//vector_sum[P[ii2].i] += rleft*rright;
						}
					}


					for (integer i_6 = 1; i_6 <= index_size; i_6++) {
						integer jstr = index_visit[i_6];
						if (fabs(vector_sum[jstr]) > 1.0e-30) {
							A[istartAnew2].aij = vector_sum[jstr];
							A[istartAnew2].i = istr;
							A[istartAnew2].j = jstr;
							istartAnew2++;
						}
					}
					index_size = 0;

				}

				delete[] vector_sum;
				delete[] index_visit;


				delete[] row_ind_AS;
				delete[] row_ind_AE;
				delete[] row_ind_PS;
				delete[] row_ind_PE;
			}

		}

		if (bquicktypesort) {
			QuickSort_j(P, 1 + iaddR, iaddR + nnzR - 1);
		}
		else {
			HeapSort_j(P, /*n_a[ilevel - 1],*/ 1 + iaddR, iaddR + nnzR - 1);
		}

		// �������� ������� � ���������� ������ ����� �������� � ������ ��������������� ������.
		//integer icounter3 = 1;
		integer nsize = istartAnew2 - (istartAnew);
		for (integer i_1 = nnz_a[ilevel - 1] + 1 + iadd, i_2 = 1; i_2 <= nsize; i_1++, i_2++) {
			integer i_right_position = istartAnew - 1 + i_2;
			A[i_1] = A[i_right_position];
		}


		printf("Prolongation is construct.\n");
		printf("Error interpolation is count %d\n", ipromah);
		printf("diagnostic ipromah_one=%d\n", ipromah_one);
		if (debug_reshime) system("pause");

		delete[] C_numerate;

		nnz_aRP[ilevel - 1] = nnzR - 1;
		iaddR += nnzR - 1;
		n_a[ilevel] = icounter - 1;
		nnz_a[ilevel] = nsize;
		iadd += nnz_a[ilevel - 1];


		ilevel++;

		// ���������� � �� i.
		//heapsort(A, key=i*n_a[ilevel - 1] + j, 1, nnz_a[ilevel - 1]);
		if (bquicktypesort) {
			QuickSort(A, /*n_a[ilevel - 1],*/ 1 + iadd, nnz_a[ilevel - 1] + iadd);
		}
		else {
			if (nnz_a[ilevel - 1] < heapsortsizelimit) {
				HeapSort(A, n_a[ilevel - 1], 1 + iadd, nnz_a[ilevel - 1] + iadd);
			}
			else {
				Ak* Aorig = &A[1 + iadd];
				MergeSort(Aorig, nnz_a[ilevel - 1]);
				Aorig = NULL;
			}
		}


		// debug
		//for (integer i_1 = 1 + iadd; i_1 <= iadd + nnz_a[ilevel - 1]; i_1++) {
		//if (A[i_1].i > n_a[ilevel - 1]) {
		//		printf("matrix incorrect i\n");
		//}
		//if (A[i_1].j > n_a[ilevel - 1]) {
		//	printf("%d ",A[i_1].j);
		//}
		//printf("A[%d].i=%d A[%d].j=%d A[%d].aij=%e\n",i_1,A[i_1].i,i_1,A[i_1].j,i_1,A[i_1].aij);
		//system("pause");
		//}


		//exit(1);
		printf("one level construct OK.\n");
		if (debug_reshime) system("pause");


		//printf("export b\n");
		//exporttecplot(b,n);

		//Real *test_coarse = new Real[n_a[1] + 1];

		// restriction
		//restriction(R, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);
		//for (integer ii = 1; ii <= n_a[0]; ii++) {
		//b[ii] = 0.0;
		//}

		/*{
		Real *test_coarse1 = new Real[n_a[2] + 1];

		// restriction
		restriction(R, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
		for (integer ii = 1; ii <= n_a[1]; ii++) {
		test_coarse[ii] = 0.0;
		}

		{
		Real *test_coarse2 = new Real[n_a[3] + 1];

		// restriction
		restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
		for (integer ii = 1; ii <= n_a[2]; ii++) {
		test_coarse1[ii] = 0.0;
		}

		prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
		}

		prolongation(P, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
		}
		*/
		//prolongation(P, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);

		//exporttecplot(b, n);
		// proverka start
		// �� ����� 81�81 �������� ������� ����������.


		printf("proverka start\n");
		// ������ ������� �����������.
		if (ilevel > 1) {
			for (integer i = 1; i <= n; i++) {
				flag[i] = false;
			}

			for (integer ii77 = nnz_a[0] + 1; ii77 <= nnz_a[0] + nnz_a[1]; ii77++) {
				if (flag[A[ii77].i] == false) {
					integer istr77 = A[ii77].i;
					integer ic77 = ii77;
					//integer icdiag = ii77;
					Real ap = 0.0;
					//x[istr] = b[istr];
					while ((ic77 <= nnz_a[0] + nnz_a[1]) && (A[ic77].i == istr77)) {
						if (A[ic77].j != istr77) {
							//x[istr] += -A[ic].aij*x[A[ic].j];
						}
						else {
							ap = A[ic77].aij;
							//icdiag = ic77;
						}
						ic77++;
					}
					if (fabs(ap) < RealZERO) {
						printf("zero diagonal element %e in string %d in level 1 matrix", ap, istr77);
						system("PAUSE");
						//exit(1);
					}

					flag[A[ii77].i] = true;

				}
			}
		}


		//�������� �����

		delete[] count_sosed;
		delete[] row_startA;

	}// �������� ����� ���������.

	ilevel--;

	// 31.224s [50.986] 2D m=81 debug x64 acumulqtor
	// 13.792 [18.156] 2D m=81 realese x64 acumulqtor
	// 8.028s 2D m=81 debug x64 rozetka
	// 3.827 2D m=81 realese x64 rozetka

	printf("ilevel=%d\n", ilevel);
	for (integer i_1 = 0; i_1 <= ilevel; i_1++) {
		printf("n_a[%d]=%d nnz_a[%d]=%d\n", i_1, n_a[i_1], i_1, nnz_a[i_1]);
	}
	printf("Graph(Mesh) ierarhion is construct sucsseful...\n");
	if (debug_reshime) system("pause");
	//system("pause");
	//exit(1);

	/*
	// ���������� ������ � ������� ������ ��������� ���������������.
	for (integer ii = 1; ii <= n; ii++) {
	flag_[ii] = false;
	}
	for (integer ii = 1 + iaddR; ii <= iaddR + nnzR - 1; ii++) {
	if (flag_[R[ii].i] == false) {
	integer istr = R[ii].i;
	integer ic7 = ii;
	while ((ic7 <= iaddR + nnzR - 1) && (R[ic7].i == istr)) {
	printf("%e ", R[ic7].aij);
	ic7++;
	}
	printf("\n");
	system("pause");
	flag_[R[ii].i] = true;
	}
	}
	*/



	/*
	//exporttecplot(b,n);

	Real *test_coarse = new Real[n_a[1] + 1];

	// restriction
	restriction(R, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);
	for (integer ii = 1; ii <= n_a[0]; ii++) {
	b[ii] = 0.0;
	}

	{
	Real *test_coarse1 = new Real[n_a[2] + 1];

	// restriction
	restriction(R, 1+nnz_aRP[0], nnz_aRP[0]+nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
	for (integer ii = 1; ii <= n_a[1]; ii++) {
	test_coarse[ii] = 0.0;
	}

	{
	Real *test_coarse2 = new Real[n_a[3] + 1];

	// restriction
	restriction(R, 1 + nnz_aRP[0]+nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1]+nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
	for (integer ii = 1; ii <= n_a[2]; ii++) {
	test_coarse1[ii] = 0.0;
	}

	prolongation(P, 1 + nnz_aRP[0]+ nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, test_coarse1, test_coarse2, n_a[2], n_a[3]);
	}

	prolongation(P, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, test_coarse, test_coarse1, n_a[1], n_a[2]);
	}

	prolongation(P, 1, nnz_aRP[0], flag, b, test_coarse, n_a[0], n_a[1]);

	exporttecplot(b, n);
	*/

	// ���������� ������� � cycling:
	/*
	// smoother.
	// 1 september 2015.
	void seidel(Ak* &A, integer istart, integer iend, Real* &x, Real* &b, bool* &flag, integer n)
	{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	for (integer i = 1; i <= n; i++) {
	flag[i] = false;
	}
	for (integer ii = istart; ii <= iend; ii++) {
	if (flag[A[ii].i] == false) {
	integer istr = A[ii].i;
	integer ic = ii;
	Real ap = 0.0;
	x[istr] = b[istr];
	while ((ic<=iend)&&(A[ic].i == istr)) {
	if (A[ic].j != istr) {
	x[istr] += -A[ic].aij*x[A[ic].j];
	}
	else ap = A[ic].aij;
	ic++;
	}
	if (fabs(ap) < RealZERO) {
	printf("zero diagonal elements in string %d",istr);
	getchar();
	exit(1);
	}
	else {
	x[istr] /= ap;
	}
	flag[A[ii].i] = true;
	}
	}


	} // seidel

	*/
	integer *row_ptr_start = new integer[4 * n_a[0] + 1];
	integer *row_ptr_end = new integer[4 * n_a[0] + 1];
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	for (integer i = 1; i <= n; i++) {
		flag[i] = false;
	}
	for (integer ii = 1; ii <= nnz_a[0]; ii++) {
		if (flag[A[ii].i] == false) {
			integer istr = A[ii].i;
			integer ic = ii;
			integer icdiag = ii;
			row_ptr_start[istr] = ii;
			Real ap = 0.0;
			//x[istr] = b[istr];
			while ((ic <= nnz_a[0]) && (A[ic].i == istr)) {
				if (A[ic].j != istr) {
					//x[istr] += -A[ic].aij*x[A[ic].j];
				}
				else {
					ap = A[ic].aij;
					icdiag = ic;
				}
				ic++;
			}
			row_ptr_end[istr] = ic - 1;
			if (fabs(ap) < RealZERO) {
				printf("zero diagonal elements in string %d in basic matrix", istr);
				system("PAUSE");
				exit(1);
			}
			else {
				//x[istr] /= ap;
			}

			flag[A[ii].i] = true;
			Ak temp = A[ii];
			A[ii] = A[icdiag];
			A[icdiag] = temp;
			A[ii].aij = 1.0 / ap; // ��������� ������� �������.
		}
	}

	bool bstop = false;
	// ������ ������� �����������.
	if (ilevel > 1) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}

		for (integer ii = nnz_a[0] + 1; ii <= nnz_a[0] + nnz_a[1]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= nnz_a[0] + nnz_a[1]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal element %e in string %d in level 1 matrix", ap, istr);
					system("PAUSE");
					//exit(1);
					bstop = true;
				}
				else {

					flag[A[ii].i] = true;
					Ak temp = A[ii];
					A[ii] = A[icdiag];
					A[icdiag] = temp;
					A[ii].aij = 1.0 / ap; // ��������� ������� �������.

				}


			}
		}
	}

	if (bstop) exit(1);

	// ������ ������� �����������.

	if (ilevel > 2) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		for (integer ii = nnz_a[0] + nnz_a[1] + 1; ii <= nnz_a[0] + nnz_a[1] + nnz_a[2]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= nnz_a[0] + nnz_a[1] + nnz_a[2]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal elements in string %d in level 2 matrix", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// ������ ������� �����������.

	if (ilevel > 3) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		for (integer ii = nnz_a[0] + nnz_a[1] + nnz_a[2] + 1; ii <= nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3]; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3]) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal elements in string %d in level 3 matrix", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// 14 �������� 2015 �����������
	// �������� ������� �����������.

	if (ilevel > 4) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + 1;
		integer iend = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal elements in string %d in level 4 matrix", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}


	// ����� ������� �����������.

	if (ilevel > 5) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + 1;
		integer iend = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal elements in string %d in level 5 matrix", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}

	// ������ ������� �����������.

	if (ilevel > 6) {
		for (integer i = 1; i <= n; i++) {
			flag[i] = false;
		}
		integer ist = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + 1;
		integer iend = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6];
		for (integer ii = ist; ii <= iend; ii++) {
			if (flag[A[ii].i] == false) {
				integer istr = A[ii].i;
				integer ic = ii;
				integer icdiag = ii;
				row_ptr_start[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]] = ii;
				Real ap = 0.0;
				//x[istr] = b[istr];
				while ((ic <= iend) && (A[ic].i == istr)) {
					if (A[ic].j != istr) {
						//x[istr] += -A[ic].aij*x[A[ic].j];
					}
					else {
						ap = A[ic].aij;
						icdiag = ic;
					}
					ic++;
				}
				row_ptr_end[istr + n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]] = ic - 1;
				if (fabs(ap) < RealZERO) {
					printf("zero diagonal elements in string %d in level 6 matrix", istr);
					system("PAUSE");
					exit(1);
				}
				else {
					//x[istr] /= ap;
				}

				flag[A[ii].i] = true;
				Ak temp = A[ii];
				A[ii] = A[icdiag];
				A[icdiag] = temp;
				A[ii].aij = 1.0 / ap; // ��������� ������� �������.
			}
		}
	}




	// smoother.
	// 9 september 2015.
	// q - quick.
	// seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);
	//void seidelq(Ak* &A, integer istartq, integer iendq, Real* &x, Real* &b, integer * &row_ptr_start, integer * &row_ptr_end, integer iadd)
	//{
	// istart - ��������� ������� ��������� ��������� � ������� �.
	// iend - �������� ������� ��������� ��������� � ������� �.
	//integer startpos = istartq + iadd;
	//integer endpos = iendq+iadd;
	//for (integer ii = startpos; ii <= endpos; ii++) {
	//integer istr = ii - iadd;
	//x[istr] = b[istr];
	//for (integer ii1 = row_ptr_start[ii] + 1; ii1 <= row_ptr_end[ii]; ii1++)
	//{
	//x[istr] += -A[ii1].aij*x[A[ii1].j];
	//}
	//x[istr] *= A[row_ptr_start[ii]].aij;
	//}


	//} // seidelq


	delete[] this_is_C_node;
	delete[] this_is_F_node;


	printf("cycling: V cycle.\n");
	printf("level=%d\n", ilevel);
	printf("multigrid R.P.Fedorenko 1961.\n");
	printf("standart aglomerative algebraic multigrid method.\n");
	if (debug_reshime) system("pause");
	//exit(1);

	// 10 11 21 multigrid tutorial ����� �����.
	// ������������������� ��������� �������� � DavisTest,
	// �������� ������� �� x-���������� ��������. ����� ���������
	// � ����������� �������� ���������� ������. ��� ���� ������������
	// amg v0.08 �������� �� ������ ������ � ����������� nu1=4, nu2=3.
	// ��������� nu1=8, nu2=7 ���������� ���������� ��������������� ��������.

	// �������� ����� ����� ������� ����������� ����� �� ������������, ��������
	// ���� ������� ���������� ���� �������������� � 0.1 ��� �� ����� ����� �������� 
	// �������� �������� ������������.


	integer nu1 = 9;  // 4 // 9
	integer nu2 = 8;  // 3 // 8

	//ilevel = 1; //debug
	Real rho = 1.0;
	Real dres = 1.0;
	int iiter = 1;
	const Real tolerance = 1.0e-12;


	Real *residual_fine = new Real[n_a[0] + 1];
	Real *residual_coarse = NULL;
	Real* error_approx_coarse = NULL;
	Real *residual_fine1 = NULL;
	Real *residual_coarse1 = NULL;
	Real* error_approx_coarse1 = NULL;
	Real *error_approx_fine1 = NULL;
	Real *residual_fine2 = NULL;
	Real *residual_coarse2 = NULL;
	Real* error_approx_coarse2 = NULL;
	Real *error_approx_fine2 = NULL;
	Real *residual_fine3 = NULL;
	Real *residual_coarse3 = NULL;
	Real* error_approx_coarse3 = NULL;
	Real *error_approx_fine3 = NULL;
	Real *residual_fine4 = NULL;
	Real *residual_coarse4 = NULL;
	Real *error_approx_coarse4 = NULL;
	Real *error_approx_fine4 = NULL;
	Real *residual_fine5 = NULL;
	Real *residual_coarse5 = NULL;
	Real* error_approx_coarse5 = NULL;
	Real *error_approx_fine5 = NULL;
	Real *residual_fine6 = NULL;
	Real *residual_coarse6 = NULL;
	Real* error_approx_coarse6 = NULL;
	Real *error_approx_fine6 = NULL;

	if (ilevel > 1) {
		residual_coarse = new Real[n_a[1] + 1];
		error_approx_coarse = new Real[n_a[1] + 1];
		if (ilevel > 2) {
			// residual
			residual_fine1 = new Real[n_a[1] + 1];
			residual_coarse1 = new Real[n_a[2] + 1];
			error_approx_coarse1 = new Real[n_a[2] + 1];
			error_approx_fine1 = new Real[n_a[1] + 1];
			if (ilevel > 3) {
				// residual
				residual_fine2 = new Real[n_a[2] + 1];
				residual_coarse2 = new Real[n_a[3] + 1];
				error_approx_coarse2 = new Real[n_a[3] + 1];
				error_approx_fine2 = new Real[n_a[2] + 1];
				if (ilevel > 4) {
					// residual
					residual_fine3 = new Real[n_a[3] + 1];
					residual_coarse3 = new Real[n_a[4] + 1];
					error_approx_coarse3 = new Real[n_a[4] + 1];
					error_approx_fine3 = new Real[n_a[3] + 1];
					if (ilevel > 5) {
						// residual
						residual_fine4 = new Real[n_a[4] + 1];
						residual_coarse4 = new Real[n_a[5] + 1];
						error_approx_coarse4 = new Real[n_a[5] + 1];
						error_approx_fine4 = new Real[n_a[4] + 1];
						if (ilevel > 6) {
							// residual
							residual_fine5 = new Real[n_a[5] + 1];
							residual_coarse5 = new Real[n_a[6] + 1];
							error_approx_coarse5 = new Real[n_a[6] + 1];
							error_approx_fine5 = new Real[n_a[5] + 1];
							if (ilevel > 7) {
								// residual
								residual_fine6 = new Real[n_a[6] + 1];
								residual_coarse6 = new Real[n_a[7] + 1];
								error_approx_coarse6 = new Real[n_a[7] + 1];
								error_approx_fine6 = new Real[n_a[6] + 1];
							}
						}
					}
				}
			}
		}
	}
	Real *error_approx_fine = new Real[n_a[0] + 1];


	// ��� �������� �������� ��������� ������ ����� �� ���� �������� ����� ������� �������,
	// ��� �������� � ���� ��� ����� �������� ���������� ����� � �� ����� �������, ������� ����� 
	// �������� �������� �������� �� ���������� ���������� ���������� �������� (�� ����� 1000 ��������).
	// 1000 �������� ��� ����� ����� ������� ��� �������� �������� ���� ��������� �������� ���������� 
	// �������� �.�. �� ����� ������������ ������� ������� �������������� ������������������ ���������.
	integer iter_limit=0;

	//for (integer iprohod = 0; iprohod < 20; iprohod++) {
	while (dres>tolerance) {

		
		if (iter_limit>1000) break; // ��������� ����� �� while �����.
		iter_limit++;

		if (_finite(dres) == 0) {
			bamgdivergencedetected=true;
			break;
			//printf("divergence AMG detected\n");
			//printf("\a\a\a\a\a\a\a\a");
			//system("pause");
			//exit(1);
		}

		// smother
		for (integer iter = 0; iter < nu1; iter++) {
			//seidel(A, 1, nnz_a[0], x, b, flag, n_a[0]);
			//quick seidel
			seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);

		}

		//exporttecplot(x, n);

		// residual_r
		//Real *residual_fine = new Real[n_a[0] + 1];
		//residual(A, 1, nnz_a[0], x, b, flag, n_a[0], residual_fine);
		residualq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0, residual_fine);
		dres = norma(residual_fine, n_a[0]);
		printf("%d %e rho=%e\n", iiter, dres, dres / rho);
		iiter++;
		//rho=norma(residual_fine, n_a[0]);
		rho = dres;
		//if (iprohod%5==0) getchar();
		if (ilevel > 1) {

			//Real *residual_coarse = new Real[n_a[1] + 1];

			// restriction
			restriction(R, 1, nnz_aRP[0], flag, residual_fine, residual_coarse, n_a[0], n_a[1]);

			// A*e=r;
			//Real* error_approx_coarse = new Real[n_a[1] + 1];
			for (integer ii = 1; ii <= n_a[1]; ii++) {
				error_approx_coarse[ii] = 0.0;
			}
			// pre smothing
			for (integer iter = 0; iter < nu1; iter++) {
				//seidel(A, 1 + 2 * nnz_a[0], 2 * nnz_a[0] + nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1]);
				seidelq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0]);
			}

			if (ilevel > 2) {
				// residual
				//Real *residual_fine1 = new Real[n_a[1] + 1];
				//residual(A, 1+2*nnz_a[0], 2*nnz_a[0]+nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1], residual_fine1);
				residualq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0], residual_fine1);
				//residualqspeshial(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0], residual_fine1);


				//Real *residual_coarse1 = new Real[n_a[2] + 1];

				// restriction
				restriction(R, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, residual_fine1, residual_coarse1, n_a[1], n_a[2]);

				// A*e=r;
				//Real* error_approx_coarse1 = new Real[n_a[2] + 1];
				for (integer ii = 1; ii <= n_a[2]; ii++) {
					error_approx_coarse1[ii] = 0.0;
				}
				// pre smothing
				for (integer iter = 0; iter < nu1; iter++) {
					//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2]);
					seidelq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1]);
				}
				if (ilevel > 3) {
					// residual
					//Real *residual_fine2 = new Real[n_a[2] + 1];
					//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2], residual_fine2);
					residualq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1], residual_fine2);
					//residualqspeshial(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1], residual_fine2);

					//Real *residual_coarse2 = new Real[n_a[3] + 1];

					// restriction
					restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, residual_fine2, residual_coarse2, n_a[2], n_a[3]);

					// A*e=r;
					//Real* error_approx_coarse2 = new Real[n_a[3] + 1];
					for (integer ii = 1; ii <= n_a[3]; ii++) {
						error_approx_coarse2[ii] = 0.0;
					}
					// pre smothing
					for (integer iter = 0; iter < nu1; iter++) {
						//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3]);
						seidelq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2]);

					}
					if (ilevel > 4) {
						// residual
						//Real *residual_fine3 = new Real[n_a[3] + 1];
						//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3], residual_fine3);
						residualq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2], residual_fine3);
						//speshial
						//residualqspeshial(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2], residual_fine3);



						//Real *residual_coarse3 = new Real[n_a[4] + 1];

						// restriction
						restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], flag, residual_fine3, residual_coarse3, n_a[3], n_a[4]);

						// A*e=r;
						//Real* error_approx_coarse3 = new Real[n_a[4] + 1];
						for (integer ii = 1; ii <= n_a[4]; ii++) {
							error_approx_coarse3[ii] = 0.0;
						}
						// pre smothing
						for (integer iter = 0; iter < nu1; iter++) {
							//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4]);
							seidelq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3]);
						}
						if (ilevel > 5) {
							// residual
							//Real *residual_fine4 = new Real[n_a[4] + 1];
							//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4], residual_fine4);
							residualq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3], residual_fine4);
							//speshial 14 september 2015.
							//residualqspeshial(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3], residual_fine4);


							//Real *residual_coarse4 = new Real[n_a[5] + 1];

							// restriction
							restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], flag, residual_fine4, residual_coarse4, n_a[4], n_a[5]);

							// A*e=r;
							//Real* error_approx_coarse4 = new Real[n_a[5] + 1];
							for (integer ii = 1; ii <= n_a[5]; ii++) {
								error_approx_coarse4[ii] = 0.0;
							}
							// pre smothing
							for (integer iter = 0; iter < nu1; iter++) {
								//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5]);
								seidelq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]);
							}
							if (ilevel > 6) {
								// residual
								//Real *residual_fine5 = new Real[n_a[5] + 1];
								//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5], residual_fine5);
								//if (ilevel <= 15) {
								residualq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4], residual_fine5);
								//}
								//else {
								// �������� � ������������.
								//speshial 14 september 2015.
								// ��� ��� �������� � ���������� ����� �������� �� ������� ����� � 1��� �����. �����������.
								//residualqspeshial(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4], residual_fine5);
								//}

								//Real *residual_coarse5 = new Real[n_a[6] + 1];

								// restriction
								restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], flag, residual_fine5, residual_coarse5, n_a[5], n_a[6]);

								// A*e=r;
								//Real* error_approx_coarse5 = new Real[n_a[6] + 1];
								for (integer ii = 1; ii <= n_a[6]; ii++) {
									error_approx_coarse5[ii] = 0.0;
								}
								// pre smothing
								for (integer iter = 0; iter < nu1; iter++) {
									//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6]);
									seidelq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]);
								}

								if (ilevel > 7) {
									// residual
									//Real *residual_fine6 = new Real[n_a[6] + 1];
									//residual(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] +2*nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6], residual_fine6);
									residualq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5], residual_fine6);

									//Real *residual_coarse6 = new Real[n_a[7] + 1];

									// restriction
									restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], flag, residual_fine6, residual_coarse6, n_a[6], n_a[7]);

									// A*e=r;
									//Real* error_approx_coarse6 = new Real[n_a[7] + 1];
									for (integer ii = 1; ii <= n_a[7]; ii++) {
										error_approx_coarse6[ii] = 0.0;
									}
									// pre smothing
									for (integer iter = 0; iter < nu1; iter++) {
										seidel(A, 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6], nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7]);
									}

									if (ilevel > 8) {
										// residual
										Real *residual_fine7 = new Real[n_a[7] + 1];
										residual(A, 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6], nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7], residual_fine7);


										Real *residual_coarse7 = new Real[n_a[8] + 1];

										// restriction
										restriction(R, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7], flag, residual_fine7, residual_coarse7, n_a[7], n_a[8]);

										// A*e=r;
										Real* error_approx_coarse7 = new Real[n_a[8] + 1];
										for (integer ii = 1; ii <= n_a[8]; ii++) {
											error_approx_coarse7[ii] = 0.0;
										}
										// pre smothing
										for (integer iter = 0; iter < nu1; iter++) {
											seidel(A, 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7], nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8], error_approx_coarse7, residual_coarse7, flag, n_a[8]);
										}


										if (ilevel > 9) {
											// residual
											Real *residual_fine8 = new Real[n_a[8] + 1];
											integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7];
											integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8];
											residual(A, n1, n2, error_approx_coarse7, residual_coarse7, flag, n_a[8], residual_fine8);


											Real *residual_coarse8 = new Real[n_a[9] + 1];

											// restriction
											integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7];
											integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
											restriction(R, n3, n4, flag, residual_fine8, residual_coarse8, n_a[8], n_a[9]);

											// A*e=r;
											Real* error_approx_coarse8 = new Real[n_a[9] + 1];
											for (integer ii = 1; ii <= n_a[9]; ii++) {
												error_approx_coarse8[ii] = 0.0;
											}
											// pre smothing
											for (integer iter = 0; iter < nu1; iter++) {
												integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8];
												integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
												seidel(A, n5, n6, error_approx_coarse8, residual_coarse8, flag, n_a[9]);
											}

											if (ilevel > 10) {
												// 8 �������� 2015 ������ ���� 

												// residual
												Real *residual_fine9 = new Real[n_a[9] + 1];
												integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8];
												integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
												residual(A, n1, n2, error_approx_coarse8, residual_coarse8, flag, n_a[9], residual_fine9);


												Real *residual_coarse9 = new Real[n_a[10] + 1];

												// restriction
												integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
												integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
												restriction(R, n3, n4, flag, residual_fine9, residual_coarse9, n_a[9], n_a[10]);

												// A*e=r;
												Real* error_approx_coarse9 = new Real[n_a[10] + 1];
												for (integer ii = 1; ii <= n_a[10]; ii++) {
													error_approx_coarse9[ii] = 0.0;
												}
												// pre smothing
												for (integer iter = 0; iter < nu1; iter++) {
													integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
													integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
													seidel(A, n5, n6, error_approx_coarse9, residual_coarse9, flag, n_a[10]);
												}

												if (ilevel > 11) {
													// 8 �������� 2015 ������ ���� 

													// residual
													Real *residual_fine10 = new Real[n_a[10] + 1];
													integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
													integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
													residual(A, n1, n2, error_approx_coarse9, residual_coarse9, flag, n_a[10], residual_fine10);


													Real *residual_coarse10 = new Real[n_a[11] + 1];

													// restriction
													integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
													integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
													restriction(R, n3, n4, flag, residual_fine10, residual_coarse10, n_a[10], n_a[11]);

													// A*e=r;
													Real* error_approx_coarse10 = new Real[n_a[11] + 1];
													for (integer ii = 1; ii <= n_a[11]; ii++) {
														error_approx_coarse10[ii] = 0.0;
													}
													// pre smothing
													for (integer iter = 0; iter < nu1; iter++) {
														integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
														integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
														seidel(A, n5, n6, error_approx_coarse10, residual_coarse10, flag, n_a[11]);
													}

													if (ilevel > 12) {
														// 11 �������� 2015 ������ ���� 

														// residual
														Real *residual_fine11 = new Real[n_a[11] + 1];
														integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
														integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
														residual(A, n1, n2, error_approx_coarse10, residual_coarse10, flag, n_a[11], residual_fine11);


														Real *residual_coarse11 = new Real[n_a[12] + 1];

														// restriction
														integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
														integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
														restriction(R, n3, n4, flag, residual_fine11, residual_coarse11, n_a[11], n_a[12]);

														// A*e=r;
														Real* error_approx_coarse11 = new Real[n_a[12] + 1];
														for (integer ii = 1; ii <= n_a[12]; ii++) {
															error_approx_coarse11[ii] = 0.0;
														}
														// pre smothing
														for (integer iter = 0; iter < nu1; iter++) {
															integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
															integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
															seidel(A, n5, n6, error_approx_coarse11, residual_coarse11, flag, n_a[12]);
														}

														if (ilevel > 13) {
															// 11 �������� 2015 ������ ���� 

															// residual
															Real *residual_fine12 = new Real[n_a[12] + 1];
															integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
															integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
															residual(A, n1, n2, error_approx_coarse11, residual_coarse11, flag, n_a[12], residual_fine12);


															Real *residual_coarse12 = new Real[n_a[13] + 1];

															// restriction
															integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
															integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
															restriction(R, n3, n4, flag, residual_fine12, residual_coarse12, n_a[12], n_a[13]);

															// A*e=r;
															Real* error_approx_coarse12 = new Real[n_a[13] + 1];
															for (integer ii = 1; ii <= n_a[13]; ii++) {
																error_approx_coarse12[ii] = 0.0;
															}
															// pre smothing
															for (integer iter = 0; iter < nu1; iter++) {
																integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
																integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																seidel(A, n5, n6, error_approx_coarse12, residual_coarse12, flag, n_a[13]);
															}


															if (ilevel > 14) {
																// 11 �������� 2015 ������ ���� 

																// residual
																Real *residual_fine13 = new Real[n_a[13] + 1];
																integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
																integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																residual(A, n1, n2, error_approx_coarse12, residual_coarse12, flag, n_a[13], residual_fine13);


																Real *residual_coarse13 = new Real[n_a[14] + 1];

																// restriction
																integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
																integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																restriction(R, n3, n4, flag, residual_fine13, residual_coarse13, n_a[13], n_a[14]);

																// A*e=r;
																Real* error_approx_coarse13 = new Real[n_a[14] + 1];
																for (integer ii = 1; ii <= n_a[14]; ii++) {
																	error_approx_coarse13[ii] = 0.0;
																}
																// pre smothing
																for (integer iter = 0; iter < nu1; iter++) {
																	integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																	integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																	seidel(A, n5, n6, error_approx_coarse13, residual_coarse13, flag, n_a[14]);
																}

																if (ilevel > 15) {
																	// 14 �������� 2015 ������ �� ������ � ��. 

																	// residual
																	Real *residual_fine14 = new Real[n_a[14] + 1];
																	integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																	integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																	residual(A, n1, n2, error_approx_coarse13, residual_coarse13, flag, n_a[14], residual_fine14);


																	Real *residual_coarse14 = new Real[n_a[15] + 1];

																	// restriction
																	integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																	integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																	restriction(R, n3, n4, flag, residual_fine14, residual_coarse14, n_a[14], n_a[15]);

																	// A*e=r;
																	Real* error_approx_coarse14 = new Real[n_a[15] + 1];
																	for (integer ii = 1; ii <= n_a[15]; ii++) {
																		error_approx_coarse14[ii] = 0.0;
																	}
																	// pre smothing
																	for (integer iter = 0; iter < nu1; iter++) {
																		integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																		integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																		seidel(A, n5, n6, error_approx_coarse14, residual_coarse14, flag, n_a[15]);
																	}

																	if (ilevel > 16) {
																		// 10 ������� 2015. 

																		// residual
																		Real *residual_fine15 = new Real[n_a[15] + 1];
																		integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																		integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																		residual(A, n1, n2, error_approx_coarse14, residual_coarse14, flag, n_a[15], residual_fine15);


																		Real *residual_coarse15 = new Real[n_a[16] + 1];

																		// restriction
																		integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																		integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15];
																		restriction(R, n3, n4, flag, residual_fine15, residual_coarse15, n_a[15], n_a[16]);

																		// A*e=r;
																		Real* error_approx_coarse15 = new Real[n_a[16] + 1];
																		for (integer ii = 1; ii <= n_a[16]; ii++) {
																			error_approx_coarse15[ii] = 0.0;
																		}
																		// pre smothing
																		for (integer iter = 0; iter < nu1; iter++) {
																			integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																			integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16];
																			seidel(A, n5, n6, error_approx_coarse15, residual_coarse15, flag, n_a[16]);
																		}

																		if (ilevel > 17) {
																			// 10 ������� 2015. 

																			// residual
																			Real *residual_fine16 = new Real[n_a[16] + 1];
																			integer n1 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																			integer n2 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16];
																			residual(A, n1, n2, error_approx_coarse15, residual_coarse15, flag, n_a[16], residual_fine16);


																			Real *residual_coarse16 = new Real[n_a[17] + 1];

																			// restriction
																			integer n3 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15];
																			integer n4 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15] + nnz_aRP[16];
																			restriction(R, n3, n4, flag, residual_fine16, residual_coarse16, n_a[16], n_a[17]);

																			// A*e=r;
																			Real* error_approx_coarse16 = new Real[n_a[17] + 1];
																			for (integer ii = 1; ii <= n_a[17]; ii++) {
																				error_approx_coarse16[ii] = 0.0;
																			}
																			// pre smothing
																			for (integer iter = 0; iter < nu1; iter++) {
																				integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16];
																				integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16] + nnz_a[17];
																				seidel(A, n5, n6, error_approx_coarse16, residual_coarse16, flag, n_a[17]);
																			}

																			// post smothing
																			for (integer iter = 0; iter < nu2; iter++) {
																				integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16];
																				integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16] + nnz_a[17];
																				seidel(A, n5, n6, error_approx_coarse16, residual_coarse16, flag, n_a[17]);
																			}


																			// prolongation
																			// residual_r
																			Real *error_approx_fine16 = new Real[n_a[16] + 1];
																			for (integer ii = 1; ii <= n_a[16]; ii++) {
																				error_approx_fine16[ii] = 0.0;
																			}



																			integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15];
																			integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15] + nnz_aRP[16];
																			prolongation(P, n7, n8, flag, error_approx_fine16, error_approx_coarse16, n_a[16], n_a[17]);

																			// correction
																			for (integer ii = 1; ii <= n_a[16]; ii++) {
																				error_approx_coarse15[ii] += error_approx_fine16[ii];
																			}

																			// free
																			delete[] error_approx_fine16;
																			delete[] error_approx_coarse16;
																			delete[] residual_coarse16;
																			delete[] residual_fine16;

																		}


																		// post smothing
																		for (integer iter = 0; iter < nu2; iter++) {
																			integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																			integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15] + nnz_a[16];
																			seidel(A, n5, n6, error_approx_coarse15, residual_coarse15, flag, n_a[16]);
																		}


																		// prolongation
																		// residual_r
																		Real *error_approx_fine15 = new Real[n_a[15] + 1];
																		for (integer ii = 1; ii <= n_a[15]; ii++) {
																			error_approx_fine15[ii] = 0.0;
																		}



																		integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																		integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14] + nnz_aRP[15];
																		prolongation(P, n7, n8, flag, error_approx_fine15, error_approx_coarse15, n_a[15], n_a[16]);

																		// correction
																		for (integer ii = 1; ii <= n_a[15]; ii++) {
																			error_approx_coarse14[ii] += error_approx_fine15[ii];
																		}

																		// free
																		delete[] error_approx_fine15;
																		delete[] error_approx_coarse15;
																		delete[] residual_coarse15;
																		delete[] residual_fine15;

																	}

																	// post smothing
																	for (integer iter = 0; iter < nu2; iter++) {
																		integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																		integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14] + nnz_a[15];
																		seidel(A, n5, n6, error_approx_coarse14, residual_coarse14, flag, n_a[15]);
																	}


																	// prolongation
																	// residual_r
																	Real *error_approx_fine14 = new Real[n_a[14] + 1];
																	for (integer ii = 1; ii <= n_a[14]; ii++) {
																		error_approx_fine14[ii] = 0.0;
																	}



																	integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																	integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13] + nnz_aRP[14];
																	prolongation(P, n7, n8, flag, error_approx_fine14, error_approx_coarse14, n_a[14], n_a[15]);

																	// correction
																	for (integer ii = 1; ii <= n_a[14]; ii++) {
																		error_approx_coarse13[ii] += error_approx_fine14[ii];
																	}

																	// free
																	delete[] error_approx_fine14;
																	delete[] error_approx_coarse14;
																	delete[] residual_coarse14;
																	delete[] residual_fine14;

																}


																// post smothing
																for (integer iter = 0; iter < nu2; iter++) {
																	integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																	integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13] + nnz_a[14];
																	seidel(A, n5, n6, error_approx_coarse13, residual_coarse13, flag, n_a[14]);
																}


																// prolongation
																// residual_r
																Real *error_approx_fine13 = new Real[n_a[13] + 1];
																for (integer ii = 1; ii <= n_a[13]; ii++) {
																	error_approx_fine13[ii] = 0.0;
																}

																//for (integer ii = 1; ii <= n_a[14]; ii++) {// debug
																//printf("error_approx_coarse13[%d]=%e\n",ii, error_approx_coarse13[ii]);

																//printf("residual_coarse13[%d]=%e\n", ii, residual_coarse13[ii]);
																//getchar();
																//}
																//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]+2*nnz_a[13]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12] +2*nnz_a[13]+ nnz_a[14]; ii++) {// debug
																//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
																//if (ii % 20 == 0) getchar();
																//}

																integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
																integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12] + nnz_aRP[13];
																prolongation(P, n7, n8, flag, error_approx_fine13, error_approx_coarse13, n_a[13], n_a[14]);

																// correction
																for (integer ii = 1; ii <= n_a[13]; ii++) {
																	error_approx_coarse12[ii] += error_approx_fine13[ii];
																}

																// free
																delete[] error_approx_fine13;
																delete[] error_approx_coarse13;
																delete[] residual_coarse13;
																delete[] residual_fine13;

															}


															// post smothing
															for (integer iter = 0; iter < nu2; iter++) {
																integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
																integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12] + nnz_a[13];
																seidel(A, n5, n6, error_approx_coarse12, residual_coarse12, flag, n_a[13]);
															}


															// prolongation
															// residual_r
															Real *error_approx_fine12 = new Real[n_a[12] + 1];
															for (integer ii = 1; ii <= n_a[12]; ii++) {
																error_approx_fine12[ii] = 0.0;
															}

															//for (integer ii = 1; ii <= n_a[13]; ii++) {// debug
															//printf("error_approx_coarse12[%d]=%e\n",ii, error_approx_coarse12[ii]);

															//printf("residual_coarse12[%d]=%e\n", ii, residual_coarse12[ii]);
															//getchar();
															//}
															//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+2*nnz_a[12]+ nnz_a[13]; ii++) {// debug
															//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
															//if (ii % 20 == 0) getchar();
															//}

															integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
															integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11] + nnz_aRP[12];
															prolongation(P, n7, n8, flag, error_approx_fine12, error_approx_coarse12, n_a[12], n_a[13]);

															// correction
															for (integer ii = 1; ii <= n_a[12]; ii++) {
																error_approx_coarse11[ii] += error_approx_fine12[ii];
															}

															// free
															delete[] error_approx_fine12;
															delete[] error_approx_coarse12;
															delete[] residual_coarse12;
															delete[] residual_fine12;

														}



														// post smothing
														for (integer iter = 0; iter < nu2; iter++) {
															integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
															integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11] + nnz_a[12];
															seidel(A, n5, n6, error_approx_coarse11, residual_coarse11, flag, n_a[12]);
														}


														// prolongation
														// residual_r
														Real *error_approx_fine11 = new Real[n_a[11] + 1];
														for (integer ii = 1; ii <= n_a[11]; ii++) {
															error_approx_fine11[ii] = 0.0;
														}

														//for (integer ii = 1; ii <= n_a[12]; ii++) {// debug
														//printf("error_approx_coarse11[%d]=%e\n",ii, error_approx_coarse11[ii]);

														//printf("residual_coarse11[%d]=%e\n", ii, residual_coarse11[ii]);
														//getchar();
														//}
														//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+2*nnz_a[11]+ nnz_a[12]; ii++) {// debug
														//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
														//if (ii % 20 == 0) getchar();
														//}

														integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
														integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10] + nnz_aRP[11];
														prolongation(P, n7, n8, flag, error_approx_fine11, error_approx_coarse11, n_a[11], n_a[12]);

														// correction
														for (integer ii = 1; ii <= n_a[11]; ii++) {
															error_approx_coarse10[ii] += error_approx_fine11[ii];
														}

														// free
														delete[] error_approx_fine11;
														delete[] error_approx_coarse11;
														delete[] residual_coarse11;
														delete[] residual_fine11;

													}


													// post smothing
													for (integer iter = 0; iter < nu2; iter++) {
														integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
														integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10] + nnz_a[11];
														seidel(A, n5, n6, error_approx_coarse10, residual_coarse10, flag, n_a[11]);
													}


													// prolongation
													// residual_r
													Real *error_approx_fine10 = new Real[n_a[10] + 1];
													for (integer ii = 1; ii <= n_a[10]; ii++) {
														error_approx_fine10[ii] = 0.0;
													}

													//for (integer ii = 1; ii <= n_a[11]; ii++) {// debug
													//printf("error_approx_coarse10[%d]=%e\n",ii, error_approx_coarse10[ii]);

													//printf("residual_coarse10[%d]=%e\n", ii, residual_coarse10[ii]);
													//getchar();
													//}
													//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+2*nnz_a[10]+ nnz_a[11]; ii++) {// debug
													//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
													//if (ii % 20 == 0) getchar();
													//}

													integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
													integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9] + nnz_aRP[10];
													prolongation(P, n7, n8, flag, error_approx_fine10, error_approx_coarse10, n_a[10], n_a[11]);

													// correction
													for (integer ii = 1; ii <= n_a[10]; ii++) {
														error_approx_coarse9[ii] += error_approx_fine10[ii];
													}

													// free
													delete[] error_approx_fine10;
													delete[] error_approx_coarse10;
													delete[] residual_coarse10;
													delete[] residual_fine10;

												}



												// post smothing
												for (integer iter = 0; iter < nu2; iter++) {
													integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
													integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9] + nnz_a[10];
													seidel(A, n5, n6, error_approx_coarse9, residual_coarse9, flag, n_a[10]);
												}


												// prolongation
												// residual_r
												Real *error_approx_fine9 = new Real[n_a[9] + 1];
												for (integer ii = 1; ii <= n_a[9]; ii++) {
													error_approx_fine9[ii] = 0.0;
												}

												//for (integer ii = 1; ii <= n_a[10]; ii++) {// debug
												//printf("error_approx_coarse9[%d]=%e\n",ii, error_approx_coarse9[ii]);

												//printf("residual_coarse9[%d]=%e\n", ii, residual_coarse9[ii]);
												//getchar();
												//}
												//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+2*nnz_a[9]+ nnz_a[10]; ii++) {// debug
												//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
												//if (ii % 20 == 0) getchar();
												//}

												integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
												integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8] + nnz_aRP[9];
												prolongation(P, n7, n8, flag, error_approx_fine9, error_approx_coarse9, n_a[9], n_a[10]);

												// correction
												for (integer ii = 1; ii <= n_a[9]; ii++) {
													error_approx_coarse8[ii] += error_approx_fine9[ii];
												}

												// free
												delete[] error_approx_fine9;
												delete[] error_approx_coarse9;
												delete[] residual_coarse9;
												delete[] residual_fine9;

											}

											// post smothing
											for (integer iter = 0; iter < nu2; iter++) {
												integer n5 = 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8];
												integer n6 = nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8] + nnz_a[9];
												seidel(A, n5, n6, error_approx_coarse8, residual_coarse8, flag, n_a[9]);
											}


											// prolongation
											// residual_r
											Real *error_approx_fine8 = new Real[n_a[8] + 1];
											for (integer ii = 1; ii <= n_a[8]; ii++) {
												error_approx_fine8[ii] = 0.0;
											}

											//for (integer ii = 1; ii <= n_a[9]; ii++) {// debug
											//printf("error_approx_coarse8[%d]=%e\n",ii, error_approx_coarse8[ii]);

											//printf("residual_coarse8[%d]=%e\n", ii, residual_coarse8[ii]);
											//getchar();
											//}
											//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+2*nnz_a[8]+ nnz_a[9]; ii++) {// debug
											//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
											//if (ii % 20 == 0) getchar();
											//}

											integer n7 = 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7];
											integer n8 = nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7] + nnz_aRP[8];
											prolongation(P, n7, n8, flag, error_approx_fine8, error_approx_coarse8, n_a[8], n_a[9]);

											// correction
											for (integer ii = 1; ii <= n_a[8]; ii++) {
												error_approx_coarse7[ii] += error_approx_fine8[ii];
											}

											// free
											delete[] error_approx_fine8;
											delete[] error_approx_coarse8;
											delete[] residual_coarse8;
											delete[] residual_fine8;

										}

										// post smothing
										for (integer iter = 0; iter < nu2; iter++) {
											seidel(A, 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7], nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7] + nnz_a[8], error_approx_coarse7, residual_coarse7, flag, n_a[8]);
										}


										// prolongation
										// residual_r
										Real *error_approx_fine7 = new Real[n_a[7] + 1];
										for (integer ii = 1; ii <= n_a[7]; ii++) {
											error_approx_fine7[ii] = 0.0;
										}

										//for (integer ii = 1; ii <= n_a[8]; ii++) {// debug
										//printf("error_approx_coarse7[%d]=%e\n",ii, error_approx_coarse7[ii]);

										//printf("residual_coarse7[%d]=%e\n", ii, residual_coarse7[ii]);
										//getchar();
										//}
										//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+2*nnz_a[7]+ nnz_a[8]; ii++) {// debug
										//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
										//if (ii % 20 == 0) getchar();
										//}

										prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6] + nnz_aRP[7], flag, error_approx_fine7, error_approx_coarse7, n_a[7], n_a[8]);

										// correction
										for (integer ii = 1; ii <= n_a[7]; ii++) {
											error_approx_coarse6[ii] += error_approx_fine7[ii];
										}

										// free
										delete[] error_approx_fine7;
										delete[] error_approx_coarse7;
										delete[] residual_coarse7;
										delete[] residual_fine7;

									}


									// post smothing
									for (integer iter = 0; iter < nu2; iter++) {
										seidel(A, 1 + nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6], nnz_a[0] + nnz_a[1] + nnz_a[2] + nnz_a[3] + nnz_a[4] + nnz_a[5] + nnz_a[6] + nnz_a[7], error_approx_coarse6, residual_coarse6, flag, n_a[7]);
									}


									// prolongation
									// residual_r
									//Real *error_approx_fine6 = new Real[n_a[6] + 1];
									for (integer ii = 1; ii <= n_a[6]; ii++) {
										error_approx_fine6[ii] = 0.0;
									}

									//for (integer ii = 1; ii <= n_a[7]; ii++) {// debug
									//printf("error_approx_coarse6[%d]=%e\n",ii, error_approx_coarse6[ii]);

									//printf("residual_coarse6[%d]=%e\n", ii, residual_coarse6[ii]);
									//getchar();
									//}
									//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+2*nnz_a[6]+ nnz_a[7]; ii++) {// debug
									//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
									//if (ii % 20 == 0) getchar();
									//}

									prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5] + nnz_aRP[6], flag, error_approx_fine6, error_approx_coarse6, n_a[6], n_a[7]);

									// correction
									for (integer ii = 1; ii <= n_a[6]; ii++) {
										error_approx_coarse5[ii] += error_approx_fine6[ii];
									}

									// free
									//delete[] error_approx_fine6;
									//delete[] error_approx_coarse6;
									//delete[] residual_coarse6;
									//delete[] residual_fine6;

								}

								// post smothing
								for (integer iter = 0; iter < nu2; iter++) {
									//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + 2 * nnz_a[5] + nnz_a[6], error_approx_coarse5, residual_coarse5, flag, n_a[6]);
									seidelq(A, 1, n_a[6], error_approx_coarse5, residual_coarse5, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4] + n_a[5]);
								}

								// prolongation
								// residual_r
								//Real *error_approx_fine5 = new Real[n_a[5] + 1];
								for (integer ii = 1; ii <= n_a[5]; ii++) {
									error_approx_fine5[ii] = 0.0;
								}

								//for (integer ii = 1; ii <= n_a[6]; ii++) {// debug
								//printf("error_approx_coarse5[%d]=%e\n",ii, error_approx_coarse5[ii]);

								//printf("residual_coarse5[%d]=%e\n", ii, residual_coarse5[ii]);
								//getchar();
								//}
								//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ 2 * nnz_a[5]+ nnz_a[6]; ii++) {// debug
								//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
								//if (ii % 20 == 0) getchar();
								//}

								prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4] + nnz_aRP[5], flag, error_approx_fine5, error_approx_coarse5, n_a[5], n_a[6]);

								// correction
								for (integer ii = 1; ii <= n_a[5]; ii++) {
									error_approx_coarse4[ii] += error_approx_fine5[ii];
								}

								// free
								//delete[] error_approx_fine5;
								//delete[] error_approx_coarse5;
								//delete[] residual_coarse5;
								//delete[] residual_fine5;

							}
							// post smothing
							for (integer iter = 0; iter < nu2; iter++) {
								//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + 2 * nnz_a[4] + nnz_a[5], error_approx_coarse4, residual_coarse4, flag, n_a[5]);
								seidelq(A, 1, n_a[5], error_approx_coarse4, residual_coarse4, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3] + n_a[4]);
							}

							// prolongation
							// residual_r
							//Real *error_approx_fine4 = new Real[n_a[4] + 1];
							for (integer ii = 1; ii <= n_a[4]; ii++) {
								error_approx_fine4[ii] = 0.0;
							}

							//for (integer ii = 1; ii <= n_a[5]; ii++) {// debug
							//printf("error_approx_coarse4[%d]=%e\n",ii, error_approx_coarse4[ii]);

							//printf("residual_coarse4[%d]=%e\n", ii, residual_coarse4[ii]);
							//getchar();
							//}
							//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ 2 * nnz_a[4]+ nnz_a[5]; ii++) {// debug
							//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
							//if (ii % 20 == 0) getchar();
							//}

							prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3] + nnz_aRP[4], flag, error_approx_fine4, error_approx_coarse4, n_a[4], n_a[5]);

							// correction
							for (integer ii = 1; ii <= n_a[4]; ii++) {
								error_approx_coarse3[ii] += error_approx_fine4[ii];
							}

							// free
							//delete[] error_approx_fine4;
							//delete[] error_approx_coarse4;
							//delete[] residual_coarse4;
							//delete[] residual_fine4;

						}
						// post smothing
						for (integer iter = 0; iter < nu2; iter++) {
							//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + 2 * nnz_a[3] + nnz_a[4], error_approx_coarse3, residual_coarse3, flag, n_a[4]);
							seidelq(A, 1, n_a[4], error_approx_coarse3, residual_coarse3, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2] + n_a[3]);
						}

						// prolongation
						// residual_r
						//Real *error_approx_fine3 = new Real[n_a[3] + 1];
						for (integer ii = 1; ii <= n_a[3]; ii++) {
							error_approx_fine3[ii] = 0.0;
						}

						//for (integer ii = 1; ii <= n_a[4]; ii++) {// debug
						//printf("error_approx_coarse3[%d]=%e\n",ii, error_approx_coarse3[ii]);

						//printf("residual_coarse3[%d]=%e\n", ii, residual_coarse3[ii]);
						//getchar();
						//}
						//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]+ 2 * nnz_a[3]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ 2 * nnz_a[3]+ nnz_a[4]; ii++) {// deug
						//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
						//if (ii % 20 == 0) getchar();
						//}

						prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2] + nnz_aRP[3], flag, error_approx_fine3, error_approx_coarse3, n_a[3], n_a[4]);

						// correction
						for (integer ii = 1; ii <= n_a[3]; ii++) {
							error_approx_coarse2[ii] += error_approx_fine3[ii];
						}

						// free
						//delete[] error_approx_fine3;
						//delete[] error_approx_coarse3;
						//delete[] residual_coarse3;
						//delete[] residual_fine3;

					}
					// post smothing
					for (integer iter = 0; iter < nu2; iter++) {
						//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2], 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2] + nnz_a[3], error_approx_coarse2, residual_coarse2, flag, n_a[3]);
						seidelq(A, 1, n_a[3], error_approx_coarse2, residual_coarse2, row_ptr_start, row_ptr_end, n_a[0] + n_a[1] + n_a[2]);

					}

					// prolongation
					// residual_r
					//Real *error_approx_fine2 = new Real[n_a[2] + 1];
					for (integer ii = 1; ii <= n_a[2]; ii++) {
						error_approx_fine2[ii] = 0.0;
					}

					//for (integer ii = 1; ii <= n_a[3]; ii++) {// deug
					//printf("error_approx_coarse2[%d]=%e\n",ii, error_approx_coarse2[ii]);

					//printf("residual_coarse2[%d]=%e\n", ii, residual_coarse2[ii]);
					//getchar();
					//}
					//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]+ 2 * nnz_a[2]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + 2 * nnz_a[2]+ nnz_a[3]; ii++) {// deug
					//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
					//if (ii % 20 == 0) getchar();
					//}

					prolongation(P, 1 + nnz_aRP[0] + nnz_aRP[1], nnz_aRP[0] + nnz_aRP[1] + nnz_aRP[2], flag, error_approx_fine2, error_approx_coarse2, n_a[2], n_a[3]);

					// correction
					for (integer ii = 1; ii <= n_a[2]; ii++) {
						error_approx_coarse1[ii] += error_approx_fine2[ii];
					}

					// free
					//delete[] error_approx_fine2;
					//delete[] error_approx_coarse2;
					//delete[] residual_coarse2;
					//delete[] residual_fine2;

				}
				// post smothing
				for (integer iter = 0; iter < nu2; iter++) {
					//seidel(A, 1 + 2 * nnz_a[0] + 2 * nnz_a[1], 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2], error_approx_coarse1, residual_coarse1, flag, n_a[2]);
					seidelq(A, 1, n_a[2], error_approx_coarse1, residual_coarse1, row_ptr_start, row_ptr_end, n_a[0] + n_a[1]);
				}

				// prolongation
				// residual_r
				//Real *error_approx_fine1 = new Real[n_a[1] + 1];
				for (integer ii = 1; ii <= n_a[1]; ii++) {
					error_approx_fine1[ii] = 0.0;
				}

				//for (integer ii = 1; ii <= n_a[2]; ii++) {// deug
				//printf("error_approx_coarse1[%d]=%e\n",ii, error_approx_coarse1[ii]);

				//printf("residual_coarse1[%d]=%e\n", ii, residual_coarse1[ii]);
				//getchar();
				//}
				//for (integer ii = 1 + 2 * nnz_a[0] + 2 * nnz_a[1]; ii <= 2 * nnz_a[0] + 2 * nnz_a[1] + nnz_a[2]; ii++) {// deug
				//printf("A[%d].aij=%e, A[%d].i=%d, A[%d].j=%d\n", ii, A[ii].aij, ii, A[ii].i, ii, A[ii].j);
				//if (ii % 20 == 0) getchar();
				//}

				prolongation(P, 1 + nnz_aRP[0], nnz_aRP[0] + nnz_aRP[1], flag, error_approx_fine1, error_approx_coarse1, n_a[1], n_a[2]);

				// correction
				for (integer ii = 1; ii <= n_a[1]; ii++) {
					error_approx_coarse[ii] += error_approx_fine1[ii];
				}

				// free
				//delete[] error_approx_fine1;
				//delete[] error_approx_coarse1;
				//delete[] residual_coarse1;
				//delete[] residual_fine1;

			}

			// post smothing
			for (integer iter = 0; iter < nu2; iter++) {
				//seidel(A, 1 + 2 * nnz_a[0], 2 * nnz_a[0] + nnz_a[1], error_approx_coarse, residual_coarse, flag, n_a[1]);
				seidelq(A, 1, n_a[1], error_approx_coarse, residual_coarse, row_ptr_start, row_ptr_end, n_a[0]);
			}

			// prolongation
			// residual_r
			//Real *error_approx_fine = new Real[n_a[0] + 1];
			for (integer ii = 1; ii <= n_a[0]; ii++) {
				error_approx_fine[ii] = 0.0;
			}

			prolongation(P, 1, nnz_aRP[0], flag, error_approx_fine, error_approx_coarse, n_a[0], n_a[1]);

			// correction
			for (integer ii = 1; ii <= n_a[0]; ii++) {
				x[ii] += error_approx_fine[ii];
			}

			// free
			//delete[] error_approx_fine;
			//delete[] error_approx_coarse;
			//delete[] residual_coarse;
			//delete[] residual_fine;
		}
		// post smother
		for (integer iter = 0; iter < nu2; iter++) {
			//seidel(A, 1, nnz_a[0], x, b, flag, n_a[0]);
			//quick seidel
			seidelq(A, 1, n_a[0], x, b, row_ptr_start, row_ptr_end, 0);
		}

		//system("pause");
	}

	if (debug_reshime) system("pause");
	//system("pause");

	// free
	delete[] error_approx_fine;
	if (ilevel > 1) {
		delete[] error_approx_coarse;
		delete[] residual_coarse;
		if (ilevel > 2) {
			// free
			delete[] error_approx_fine1;
			delete[] error_approx_coarse1;
			delete[] residual_coarse1;
			delete[] residual_fine1;
			if (ilevel > 3) {
				// free
				delete[] error_approx_fine2;
				delete[] error_approx_coarse2;
				delete[] residual_coarse2;
				delete[] residual_fine2;
				if (ilevel > 4) {
					// free
					delete[] error_approx_fine3;
					delete[] error_approx_coarse3;
					delete[] residual_coarse3;
					delete[] residual_fine3;
					if (ilevel > 5) {
						// free
						delete[] error_approx_fine4;
						delete[] error_approx_coarse4;
						delete[] residual_coarse4;
						delete[] residual_fine4;
						if (ilevel > 6) {
							// free
							delete[] error_approx_fine5;
							delete[] error_approx_coarse5;
							delete[] residual_coarse5;
							delete[] residual_fine5;
							if (ilevel > 7) {
								// free
								delete[] error_approx_fine6;
								delete[] error_approx_coarse6;
								delete[] residual_coarse6;
								delete[] residual_fine6;
							}
						}
					}
				}
			}
		}
	}


	delete[] residual_fine;

	delete[] row_ptr_start;
	delete[] row_ptr_end;


	delete[] flag_shadow;
	delete[] flag;
	//delete[] flag_;
	return 0;

} // classic_aglomerative_amg1

typedef struct nodeAMG {
	double val;
	int i,j;
} TnodeAMG;

// 21 ��� 2015. ����� ����������� ���������� � ����������, ����� ����� ������� ����� ���.
// 6 september 2015 ������� ����������.
// ��������� ���������� � ����, �������� 0 ������������.
EXPORT void my_aglomerative_external_amg(
	int n, int nnz, double * &db,
	double * &resultat, TnodeAMG * &MatrixAmg, bool &bamgdivergencedetected)
{

	// ������� : band_size � ���������� ���������� ��������� ���������� ����� ������ �����������.
	// �������������� ���������.

	// �������� �������.
	// ���������� ������� ������������ ���������� ������� �������, ������� ������� ���������� ��������� ������.
	// ���������� ������ �� ������� ������� ���������� �������������� ������������ ������ � ����� �� ��������������� ����.
	// 14 �������� 2015 ���� �������� ������������ �� ������� ������� ��������� ������������� ������������� ���������, 
	// ��������� ��� � AliceFlow.

	// ������� ������� ������������� ������ ��������� ����������. ���� ����� ������� ��� ��������� 1/16  �� �������� � � ��� 
	// �������� ����������.


	// 30min 25s 40x40x40. (7min 50s ���������) (1min 18s , 3min 32s ���������) (1min 04s ��������� �� ����)
	// 6min 201x201 5.40 lite and quick  15 it
	// 201x201  37.132, 35.761
	// ��������� ��������� 50.0% �� ��������� � ������� 0.04.
	// 1.01min 121x121 v0_03time=29.983, v0_04time=20.116; PGO=19.695. (v0_05=12.136 ���������).

	// m=81; 9.3Mb.
	// m=101; 14.3Mb.
	// speed up 38%
	// ���� ���������� �������� ��� �� 15% �� ������ 0.04.
	// time cube (40) 33.54s band_size ON.
	// ��������� �������������� cube(40) �� ����:
	// ��� �������� ����������� : 1min 12s. (11 iteracii)
	// � ��������� ����������� (band_size ON) : 
	integer m = 1000; // 37.6�     (������� 2.24-2.29min) (2.02-2.07 ����������).
	Real h = 1.0 / (m - 1);
	Real h2 = h*h;

	// 4040

	Real theta = 0.25; // �������� ����� ������� ������ ����� �����������.

	const integer dim_2D = 1;
	//integer band_size = -1; // ��� ���������� � �����.

	switch (dim_2D) {
	case 1: theta = 0.25; break; // 2D
	case 0: theta = 0.5; break; // 3D
	}

	Ak* A = NULL;
	Ak* Atemp = NULL;
	Ak* Atemp2 = NULL;
	Ak* R = NULL;
	Ak* P = NULL;
	integer n_, nnz_;
	Real* x = NULL;
	Real* b = NULL;

	if (1) {
		// dll code
		n_=n;
		x = new Real[n_ + 1]; // �������.
		for (integer i = 0; i <= n_; i++) x[i] = 0.0; // ������������.
       	b = new Real[n_ + 1]; // ������ �����.
		b[0] = 0.0;
		for (integer i_1 = 1; i_1 <= n_; i_1++) {
			b[i_1]=db[i_1-1];
		}
		nnz_=nnz;
		A = new Ak[8 * nnz_ + 1];
		Atemp = new Ak[3 * nnz_ + 1];
		Atemp2 = new Ak[3 * nnz_ + 1];
		R = new Ak[10 * n_ + 1];
		P = new Ak[10 * n_ + 1];
		integer i_2 = 1;
		for (integer i_1 = 1; i_1 <= nnz_; i_1++) {
			if (fabs(MatrixAmg[i_1-1].val) > 1.0e-30) {
				  A[i_2].aij = MatrixAmg[i_1-1].val;
				  A[i_2].i = MatrixAmg[i_1-1].i;
				  A[i_2].j = MatrixAmg[i_1-1].j;
				  i_2++;
			}
		}
	    nnz_ = i_2 - 1;

		classic_aglomerative_amg1(A, nnz_, n_, R, P, Atemp, Atemp2, x, b, theta,bamgdivergencedetected);
		// �������� ����������.
		for (integer i = 1; i <= n_; i++) resultat[i-1]=x[i]; 

	}
	else {
	  if (1) {
		  // 18 ������ �������� ������������ � ������������ ���� DavisTestDelphi.

		FILE* fp;
		errno_t err;
		if ((err = fopen_s(&fp, "amg_input.txt", "r")) != 0) {
			printf("error input file : amg_input.txt \n");
			getchar();
			exit(1);
		}
		else {
			integer din=0;
			float fin=0.0;

			fscanf_s(fp, "%d", &din);
			n_ = din;
			printf("%d\n", n_);
			system("pause");
			x = new Real[n_ + 1]; // �������.
			for (integer i = 0; i <= n_; i++) x[i] = 0.0; // ������������.
			
			b = new Real[n_ + 1]; // ������ �����.
			b[0] = 0.0;
			for (integer i_1 = 1; i_1 <= n_; i_1++) {
				fscanf_s(fp, "%f", &fin);
				b[i_1] = fin;
			}
			fscanf_s(fp, "%d", &din);
			nnz_ = din;
			printf("nnz=%d\n",nnz_);
			system("pause");
			// 31 aug 2015
			A = new Ak[8 * nnz_ + 1];
			Atemp = new Ak[3 * nnz_ + 1];
			Atemp2 = new Ak[3 * nnz_ + 1];
			R = new Ak[10 * n_ + 1];
			P = new Ak[10 * n_ + 1];
			integer i_2 = 1;
			for (integer i_1 = 1; i_1 <= nnz_; i_1++) {
				fscanf_s(fp, "%f", &fin);
				if (fabs(fin) > 1.0e-30) {
					A[i_2].aij = fin;
					fscanf_s(fp, "%d", &din);
					A[i_2].i = din;
					fscanf_s(fp, "%d", &din);
					A[i_2].j = din;
					i_2++;
				}
				else {
					fscanf_s(fp, "%d", &din);
					fscanf_s(fp, "%d", &din);
				}
			}
			nnz_ = i_2 - 1;
			printf("nnz=%d\n", nnz_);
			system("pause");

			fclose(fp);
			classic_aglomerative_amg1(A, nnz_, n_, R, P, Atemp, Atemp2, x, b, theta,bamgdivergencedetected);
		}
	}
	else {


		if (dim_2D) {
			// Finite Volume Method matrix assemble. 6 september 2015

			printf("%dx%d\n", m, m);


			//band_size = 5 * m; // ������ ������������.
			n_ = m*m;
			nnz_ = 5 * ((m - 2)*(m - 2)) + 4 + 4 * (m - 2);
			printf("nnz=%d\n", nnz_);
			//getchar();

			// 31 aug 2015
			A = new Ak[8 * nnz_ + 1];
			Atemp = new Ak[3 * nnz_ + 1];
			Atemp2 = new Ak[3 * nnz_ + 1];
			R = new Ak[10 * n_ + 1];
			P = new Ak[10 * n_ + 1];
			// 19684 3*n_+1.
			//printf("%d",3*n_+1);
			//getchar();
			integer ic = 1;
			for (integer i = 1; i <= m; i++) {
				for (integer j = 1; j <= m; j++) {
					if ((i > 1) && (j > 1) && (i < m) && (j < m)) {
						//A[ic].aij = 4.0 / h2;
						A[ic].aij = 4.0; // h/h
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j;
						ic++;
						//A[ic].aij = -1.0 / h2;
						A[ic].aij = -1.0;
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j + 1;
						ic++;
						//A[ic].aij = -1.0 / h2;
						A[ic].aij = -1.0;
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j - 1;
						ic++;
						//A[ic].aij = -1.0 / h2;
						A[ic].aij = -1.0;
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j + m;
						ic++;
						//A[ic].aij = -1.0 / h2;
						A[ic].aij = -1.0;
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j - m;
						ic++;
					}
					if (((i == m) && (j == m)) || ((i == m) && (j == 1)) || ((i == 1) && (j == m)) || ((i == 1) && (j == 1)) || ((i == 1) && (j > 1) && (j < m)) || ((i == m) && (j>1) && (j < m)) || ((j == 1) && (i>1) && (i < m)) || ((j == m) && (i>1) && (i < m))) {
						A[ic].aij = 1.0;
						A[ic].i = (i - 1)*m + j;
						A[ic].j = (i - 1)*m + j;
						ic++;

					}
				}
			}

			printf("nnz=%d ic-1=%d\n", nnz_, ic - 1);


			x = new Real[n_ + 1]; // �������.
			for (integer i = 0; i <= n_; i++) x[i] = 0.0;
			b = new Real[n_ + 1]; // ������ �����.

			ic = 1;
			for (integer i = 1; i <= m; i++) {
				for (integer j = 1; j <= m; j++) {
					if ((i > 1) && (j > 1) && (i < m) && (j < m)) {
						b[ic++] = 8.0*3.141*3.141*sin(2 * 3.141*(i - 1)*h)*sin(2 * 3.141*(j - 1)*h)*h2;
					}
					if (((i == m) && (j == m)) || ((i == m) && (j == 1)) || ((i == 1) && (j == m)) || ((i == 1) && (j == 1)) || ((i == 1) && (j > 1) && (j < m)) || ((i == m) && (j>1) && (j < m)) || ((j == 1) && (i>1) && (i < m)) || ((j == m) && (i>1) && (i < m))) {
						b[ic++] = sin(2 * 3.141*(i - 1)*h)*sin(2 * 3.141*(j - 1)*h);
					}
				}
			}

		}
		else {
			// 6 �������� ���� ������

			// Finite volume method matrix assemble. 
			// volume = h2*h; Square=h2; delta_x=delta_y=delta_z=h;
			// ������������ ���� ����������� ��������� ������������.

			// 3D
			//band_size = 7 * m*m; // ������ ������������.
			n_ = m*m*m;
			nnz_ = 7 * ((m - 2)*(m - 2)*(m - 2)) + 8 + 6 * (m - 2)*(m - 2) + 12 * (m - 2);
			// ��� : 8 ������, 12 ����, 6 ������.

			printf("%dx%dx%d\n", m, m, m);
			printf("nnz=%d\n", nnz_);

			// 31 aug 2015
			// 6 3 3 � �������. ������� 4.52 2.26 2.26
			// real size 22.6 on thermal resistance.
			A = new Ak[(integer)(13 * nnz_) + 1]; // 6
			// ������ �� ��������� ������ ����������� ����� ��������� ��������� ������ ��� 
			// � ��������� �������.
			// real size 9.4 for resistor thermal resistor.
			// 
			Atemp = new Ak[3 * nnz_ + 1];
			// real size 9.4 for resistor thermal resistor.
			Atemp2 = new Ak[3 * nnz_ + 1];
			R = new Ak[(integer)(10 * n_) + 1]; // 3*nnz 2.4
			P = new Ak[(integer)(10 * n_) + 1]; // 3*nnz 2.4
			integer ic = 1;
			for (integer i = 1; i <= m; i++) {
				for (integer j = 1; j <= m; j++) {
					for (integer k = 1; k <= m; k++) {
						if ((i > 1) && (j > 1) && (k > 1) && (i < m) && (j < m) && (k < m)) {
							A[ic].aij = 6.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j + 1;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j - 1;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j + m;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j - m;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j + m*m;
							ic++;
							A[ic].aij = -1.0 *h;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j - m*m;
							ic++;
						}
						else {
							//if (((i == m) && (j == m)) || ((i == m) && (j == 1)) || ((i == 1) && (j == m)) || ((i == 1) && (j == 1)) || ((i == 1) && (j > 1) && (j < m)) || ((i == m) && (j>1) && (j < m)) || ((j == 1) && (i>1) && (i < m)) || ((j == m) && (i>1) && (i < m))) {
							A[ic].aij = 1.0;
							A[ic].i = (k - 1)*m*m + (i - 1)*m + j;
							A[ic].j = (k - 1)*m*m + (i - 1)*m + j;
							ic++;

						}
					}
				}
			}

			printf("nnz=%d ic-1=%d\n", nnz_, ic - 1);


			x = new Real[n_ + 1]; // �������.
			for (integer i = 0; i <= n_; i++) x[i] = 0.0; // ������������.
			b = new Real[n_ + 1]; // ������ �����.

			ic = 1;
			for (integer i = 1; i <= m; i++) {
				for (integer j = 1; j <= m; j++) {
					for (integer k = 1; k <= m; k++) {
						if ((i > 1) && (j > 1) && (k > 1) && (i < m) && (j < m) && (k < m)) {
							b[ic++] = 16.0*3.141*3.141*3.141*sin(2 * 3.141*(i - 1)*h)*sin(2 * 3.141*(j - 1)*h)*sin(2 * 3.141*(k - 1)*h)*h2*h;
						}
						else {
							//if (((i == m) && (j == m)) || ((i == m) && (j == 1)) || ((i == 1) && (j == m)) || ((i == 1) && (j == 1)) || ((i == 1) && (j>1) && (j < m)) || ((i == m) && (j>1) && (j < m)) || ((j == 1) && (i>1) && (i < m)) || ((j == m) && (i>1) && (i < m))) {
							b[ic++] = sin(2 * 3.141*(k - 1)*h)*sin(2 * 3.141*(i - 1)*h)*sin(2 * 3.141*(j - 1)*h);
						}
					}
				}
			}
		}

		classic_aglomerative_amg1(A, nnz_, n_, R, P, Atemp, Atemp2, x, b, theta,bamgdivergencedetected);
	}
	}

	

	// m in 3D memorysize mb
	// 21  14.8Mb
	// 31  49.7Mb
	// 41  119.4Mb

	//getchar();
	delete[] A;
	delete[] R;
	delete[] P;
	delete[] Atemp;
	delete[] Atemp2;
	delete[] x;
	delete[] b;

	// 2D m=81 debug �� �����������. 
	// nu1=1 nu2=0 47.904
	// nu1=1 nu2=1 34.548
	// nu1=2 nu2=1 29.465
	// nu1=2 nu2=2 27.76
	// 2D m=81 realese �� �����������.
	// nu1=2 nu2=1 8.898
	// nu1=2 nu2=2 8.109
	// nu1=3 nu2=2 7.247
	// nu1=3 nu2=3 6.962
	// nu1=4 nu2=3 6.555 6.799
	// seidelq 1 level
	// nu1=4 nu2=3 5.691 5.605 
	// �� ����.
	// seidelq 2 level
	// nu1=4 nu2=3 1.121 1.9 1.672
	// 1.9 792 0.982
	// 1.174 273 0.94248 // �������� residual �� ������ ������ � �� residualq.
	// �� ������������.
	// nu1=4 nu2=3 3.412  �������� residual �� ������ ������ � �� residualq.
	// nu1=4 nu2=3 5.503 residualq.
	// �������� residual �� ������ ������ � �� residualq.
	// m=81 12 level
	// nu1=4 nu2=3 2.916 3.081 2.899 2.89
	// nu1=4 nu2=3 2.487  (������ ���� 1.715)


	// �� ����������� 1.091
	//(msvcr120.dll 3.94 2.06 2.33 3.1) 1.234 1.072
	// 2.893 2.788 2.892 2.8 2.814
	// m=121 �� �����������. 13 level.
	// 2.556 2.546 2.627 2.533 2.602 2.501 2.542 2.487 2.589 5.131
	// 1.686 1.742 �� ����. 1.763
	// m=221 2D 14 level
	// 33.857 32.649 (6.809s 3 �����. 6.984).


	// m=24 3D �� ����
	// ��� ����� 957��.
	// ��� ����� m=48 8.713c. � ������ 5.7s. 110��� �����.

	// etalon 27s. ��� 36�. �� ����. etalon 47s �� ������������.
	// m=100 3D 1 million nodes
	// 15 level 117 iteration.
	// 2 min 42s. � 6 ��� ���������.
	// 47.16s �� ����. 47.276
	//system("pause");
	//return 0;
}


