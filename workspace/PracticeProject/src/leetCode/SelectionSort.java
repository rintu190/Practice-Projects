package leetCode;

// Complexity
// Complexity Analysis of Selection Sort
// Time Complexity: O(n2) ,as there are two nested loops:

// One loop to select an element of Array one by one = O(n)
// Another loop to compare that element with every other Array element = O(n)
// Therefore overall complexity = O(n) * O(n) = O(n*n) = O(n2)
// Auxiliary Space: O(1) as the only extra memory used is for temporary variables.

// Process
// First we find the smallest element and swap it with the first element. This way we get the smallest element at its correct position.
// Then we find the smallest among remaining elements (or second smallest) and move it to its correct position by swapping.
// We keep doing this until we get all elements moved to correct position.
public class SelectionSort {
    public static void main(String[] args){
        int[] arr = {64,25,12,22,11};
        System.err.println("Original Array:");
        printArray(arr);
        SelectionSorts(arr);
        System.err.println("Sorted Array:");
        printArray(arr);
    }
    static void printArray(int[] arr){
        for(int val :arr){
            System.err.println(val +" ");
        }
        System.err.println();
    }
    static void SelectionSorts(int[] arr){
        int n = arr.length;

        for(int i = 0; i < n-1; i++){
            int min_idx=i;
            for(int j=i+1;j<n;j++){
                if(arr[j] < arr[min_idx]){
                    min_idx = j;
                }
            }
            int temp = arr[i];
            arr[i] = arr[min_idx];
            arr[min_idx] = temp;
        }
    }
    
}
