package leetCode;

// Complexity
// Time Complexity:

// Best Case: (Ω(n log n)), Occurs when the pivot element divides the array into two equal halves.
// Average Case (θ(n log n)), On average, the pivot divides the array into two parts, but not necessarily equal.
// Worst Case: (O(n²)), Occurs when the smallest or largest element is always chosen as the pivot (e.g., sorted arrays).
// Auxiliary Space: O(n), due to recursive call stack

// Process
// QuickSort works on the principle of divide and conquer, breaking down the problem into smaller sub-problems.

// There are mainly three steps in the algorithm:

// Choose a Pivot: Select an element from the array as the pivot. The choice of pivot can vary (e.g., first element, last element, random element, or median).
// Partition the Array: Rearrange the array around the pivot. After partitioning, all elements smaller than the pivot will be on its left, 
// and all elements greater than the pivot will be on its right. The pivot is then in its correct position, and we obtain the index of the pivot.
// Recursively Call: Recursively apply the same process to the two partitioned sub-arrays (left and right of the pivot).
// Base Case: The recursion stops when there is only one element left in the sub-array, as a single element is already sorted.

// Choice of Pivot
// Always pick the first (or last) element as a pivot. The below implementation is picks the last element as pivot.
//  The problem with this approach is it ends up in the worst case when array is already sorted.
// Pick a random element as a pivot. This is a preferred approach because it does not have a pattern for which the worst case happens.
// Pick the median element is pivot. This is an ideal approach in terms of time complexity as we can find median in linear time and 
// the partition function will always divide the input array into two halves. But it is low on average as median finding has high constants.

// Partition Algorithm
// Naive Partition: Here we create copy of the array. First put all smaller elements and then all greater.
//  Finally we copy the temporary array back to original array. This requires O(n) extra space.
// Lomuto Partition: We have used this partition in this article. This is a simple algorithm, we keep track of index of smaller elements and keep swapping.
//  We have used it here in this article because of its simplicity.
// Hoare’s Partition: This is the fastest of all. Here we traverse array from both sides and keep swapping greater element on left with smaller on right 
// while the array is not partitioned. Please refer Hoare’s vs Lomuto for details.

public class QuickSort {
    public static void main(String[] args){
        int arr[] = {64,34,25,12,22,11,90};
        int n = arr.length;
        quickSort(arr,0,n-1);
        for(int val:arr){
           System.out.println(val+" ");
        }
    }
        
    private static void swap(int[] arr, int i, int j) {
        int temp = arr[i];
        arr[i] =arr[j];
        arr[j] = temp;
    }

    private static int partition(int[] arr, int low, int high) {
        int pivot = arr[high];
        int i = low - 1;
        for(int j = low;j <= high-1;j++){
            if(arr[j] < pivot){
                i++;
                swap(arr,i,j);
            }
        }
        swap(arr,i+1,high);
        return i+1;
    }

    private static void quickSort(int[] arr, int low, int high) {
        if(low < high){
            int pi = partition(arr, low, high);
            quickSort(arr,low, pi-1);
            quickSort(arr,pi + 1, high);
        }
    }
    
}
