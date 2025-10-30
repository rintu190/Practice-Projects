package leetCode;

// Complexity
// Time Complexity: O(n2)
// Auxiliary Space: O(1)

// Process
// We sort the array using multiple passes. After the first pass, the maximum element goes to end (its correct position). 
// Same way, after second pass, the second largest element goes to second last position and so on.
// In every pass, we process only those elements that have already not moved to correct position. After k passes, 
// the largest k elements must have been moved to the last k positions.
// In a pass, we consider remaining elements and compare all adjacent and swap if larger element is before a smaller element.
//  If we keep doing this, we get the largest (among the remaining elements) at its correct position
public class BubbleSort {
    public static void main(String args[]){
        int arr[] = {64,34,25,12,22,11,90};
        bubbleSort(arr);
        System.out.println("sorted array: ");
        printArray(arr);
    }

    private static void printArray(int[] arr) {
        for(int i=0;i<arr.length;i++){
            System.out.println(arr[i]+" ");
        }
        System.out.println();
    }

    private static void bubbleSort(int[] arr) {
        int temp;
        boolean swapped;
        int n = arr.length;
        for(int i = 0;i < n-1;i++){
            swapped =false;
            for(int j = 0;j < n-i-1;j++){
                if(arr[j] > arr[j+1]){
                    temp =arr[j];
                    arr[j] =arr[j+1];
                    arr[j+1] = temp;
                    swapped = true;
                }
            }
            if(swapped == false)
            break;
        }
    }
    
}
