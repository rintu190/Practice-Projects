package geeksForGeeks;

public class ArrayMinimumSortedRotated {
    public static void main(String[] args) {
        int[] arr = {5,6,1,2,3,4};
//        int result = findMinimumLinearSearch(arr);
        int result = findMinimumBinarySearch(arr);
        System.out.println(result);
        
    }

	private static int findMinimumBinarySearch(int[] arr) {
		int low = 0, high = arr.length - 1;
		while(low < high) {
			if(arr[low] < arr[high]) {
				return arr[low];
			}
			int mid = (low + high)/2;
			if(arr[mid] > arr[high]) {
				low = mid + 1;
			} else {
				high = mid;
			}
		}
		return arr[low];
	}

	private static int findMinimumLinearSearch(int[] arr) {
		int result = arr[0];
		for(int i = 0;i < arr.length;i++) {
			result = Math.min(result, arr[i]);
		}
		return result;
	}
}
