package leetCode;

// Complexity
// Time Complexity:
// Best Case: O(n log n), When the array is already sorted or nearly sorted.
// Average Case: O(n log n), When the array is randomly ordered.
// Worst Case: O(n log n), When the array is sorted in reverse order.
// Auxiliary Space: O(n), Additional space is required for the temporary array used during merging.

// Process
// Divide: Divide the list or array recursively into two halves until it can no more be divided.
// Conquer: Each subarray is sorted individually using the merge sort algorithm.
// Merge: The sorted subarrays are merged back together in sorted order. The process continues until all elements from both subarrays have been merged.
public class MergeSort {
    public static void main(String args[]){
        int arr[] = {64,34,25,12,22,11,90};
        sort(arr,0,arr.length-1);
        System.out.println("sorted array: ");
        printArray(arr);
    }

    private static void printArray(int[] arr) {
        for(int i=0;i<arr.length;i++){
            System.out.println(arr[i]+" ");
        }
        System.out.println();
    }

    private static void sort(int[] arr, int l,int r) {
       if(l < r){
        int m = l + (r-l) /2;
        sort(arr,l,m);
        sort(arr,m+1,r);
        merge(arr,l,m,r);
       }        
    }

    private static void merge(int[] arr,int l, int m, int r) {
        
        // find size of subarrays
        int n1 = m-l+1;
        int n2 = r-m;

        // create temp array
        int L[] = new int[n1];
        int R[] = new int[n2];

        // copy data
        for(int i = 0; i < n1; i++){
            L[i] =arr[l+i];
        }
        for(int j = 0;j < n2; j++){
            R[j] = arr[m+1+j];
        }
        // merge temp arrays
        int i=0,j=0;
        int k = l;
        while(i < n1 && j < n2){
            if(L[i] <= R[j]){
                arr[k] = L[i];
                i++;
            } else {
                arr[k] = R[j];
                j++;
            }
            k++;
        }
        // copy remaining of L[]
        while(i < n1){
            arr[k] = L[i];
            i++;
            k++;
        }
        // copy remaining of R[]
        while(j < n2){
            arr[k] = R[j];
            j++;
            k++;
        }




    }


}
