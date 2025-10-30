package geeksForGeeks;

import java.util.Arrays;
import java.util.HashSet;

public class ArrayTwoSum {
	public static void main(String[] args) {
		int[] arr = {0,-1,2,-3,1};
		int target = -2;
		
//		boolean result = twoSumNaive(arr,target);
//		boolean result = twoSumBinarySearch(arr,target);
//		boolean result = twoSumTwoPointer(arr,target);
		boolean result = twoSumHashSet(arr,target);
		System.out.println(result?true:false);
	}

	private static boolean twoSumHashSet(int[] arr, int target) {
		HashSet<Integer> set = new HashSet<>();
		
		for(int i = 0;i < arr.length;i++) {
			int complement = target - arr[i];
			if(set.contains(complement))
				return true;
			set.add(arr[i]);
		}
		return false;
	}

	private static boolean twoSumTwoPointer(int[] arr, int target) {
		Arrays.sort(arr);
		int left = 0,right = arr.length - 1;
		
		while(left < right) {
			int sum =  arr[left] + arr[right];
			if(sum == target)
				return true;
			else if(sum < target)
				left++;
			else
				right--;
		}
		return false;
	}

	private static boolean twoSumBinarySearch(int[] arr, int target) {
		Arrays.sort(arr);		
		
		for(int i =0;i < arr.length;i++) {
			int complement = target - arr[i];
			if(binarySearch(arr,i+1,arr.length-1,complement)) {
				return true;
			}
		}
		return false;
	}

	private static boolean binarySearch(int[] arr, int left, int right, int target) {
		while(left <= right){
			int mid = left + (right - left) / 2;
			if(arr[mid] == target)
				return true;
			if(arr[mid] < target)
				left = mid + 1;
			else
				right = mid -1;
		}
		return false;
	}

	private static boolean twoSumNaive(int[] arr, int target) {
		int length = arr.length;
		
		for(int i = 0;i < length;i++) {
			for(int j = i + 1;j < length;j++) {
				if(arr[i]+arr[j] == target) {
					return true;
				}
			}
		}		
		return false;
	}

}
