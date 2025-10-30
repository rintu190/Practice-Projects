package leetCode;

// Complexity
// Time Complexity of Insertion Sort
// Best case: O(n) , If the list is already sorted, where n is the number of elements in the list.
// Average case: O(n 2 ) , If the list is randomly ordered
// Worst case: O(n 2 ) , If the list is in reverse order
// Space Complexity of Insertion Sort
// Auxiliary Space: O(1), Insertion sort requires O(1) additional space, making it a space-efficient sorting algorithm.

//Process
// We start with second element of the array as first element in the array is assumed to be sorted.
// Compare second element with the first element and check if the second element is smaller then swap them.
// Move to the third element and compare it with the first two elements and put at its correct position
// Repeat until the entire array is sorted.

public class InsertionSort {
    public static void main(String args[]){
        int arr[] = {64,34,25,12,22,11,90};
        insertionSort(arr);
        System.out.println("sorted array: ");
        printArray(arr);
    }

    private static void printArray(int[] arr) {
        for(int i=0;i<arr.length;i++){
            System.out.println(arr[i]+" ");
        }
        System.out.println();
    }

    private static void insertionSort(int[] arr) {
        int n = arr.length;
        for(int i = 1;i < n;i++){
            int key = arr[i];
            int j =i-1;

            while(j >= 0 && arr[j] > key){
                arr[j+1] = arr[j];
                j =j-1;
            }
            arr[j+1] = key;
        }
    }


}
