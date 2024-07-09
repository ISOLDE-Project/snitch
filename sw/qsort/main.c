


#include "printf.h"
#include "snrt.h"

void quickSort(int arr[], int low, int high) ;

// Function to print an array
void printArray(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

int data[] = {10, 78, 8, 90, 1, 5};


int test() {
    int n = sizeof(data) / sizeof(data[0]);
    printf("Original array: \n");
    printArray(data, n);
    quickSort(data, 0, n - 1);
    printf("Sorted array: \n");
    printArray(data, n);
    return 0;
}

int main() {
    uint32_t core_idx = snrt_global_core_idx();
    uint32_t core_num = snrt_global_core_num();
    if (0 == core_idx){
        printf("# quicksort, core_idx=%d, core_num=%d\n", core_idx,
               core_num);
       test();
    }
    return 0;
}               