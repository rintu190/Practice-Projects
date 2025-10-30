package geeksForGeeks;

public class ArrayMaximumSumSubarray {

	public static void main(String[] args) {
		int[] arr = {2,3,-8,7,-1,2,3};
//		int result = maximumSubarrayNaive(arr);
		int result = maximumSubarrayKadane(arr);
		System.out.println(result);
	}

	private static int maximumSubarrayKadane(int[] arr) {
		int result =  arr[0];
		int maxEnding = arr[0];
		
		for(int i = 1;i < arr.length;i++) {
			maxEnding = Math.max(maxEnding + arr[i], arr[i]);
			result = Math.max(result, maxEnding);
		}
		return result;
	}

	private static int maximumSubarrayNaive(int[] arr) {
		int result = arr[0];
		for(int i = 0;i < arr.length;i++) {
			int currentSum = 0;
			for(int j = i;j < arr.length;j++) {
				currentSum += arr[j];
				result = Math.max(result, currentSum);
			}
		}
		return result;
	}
}
