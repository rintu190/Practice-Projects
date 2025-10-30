package geeksForGeeks;

import java.util.Arrays;

public class ArrayProductExceptSelf {

	public static void main(String[] args) {
		int[] arr = {10,3,5,6,2};
//		int[] result = productNaive(arr);
//		int[] result = productPrefixSuffix(arr);
		int[] result = productUsingProductArray(arr);
		
		for(int value:result) {
			System.out.print(value + " ");
		}

	}

	private static int[] productUsingProductArray(int[] arr) {
		int zero = 0,idx = -1,product = 1;
		int n = arr.length;
		int[] result = new int[n];
		Arrays.fill(result, 0);
		
		
		for(int i = 0;i < n;i++) {
			if(arr[i] == 0) {
				zero++;
				idx = i;
			}else {
				product *= arr[i];
			}
		}
		if(zero == 0) {
			for(int i = 0;i < n;i++) {
				result[i] = product/arr[i];
			}
		}else if(zero == 1) {
			result[idx] = product;
		}
		return result;
	}

	private static int[] productPrefixSuffix(int[] arr) {
		int n = arr.length;
		int[] prefixArray = new int[n];
		int[] suffixArray = new int[n];
		int[] result = new int[n];
		
		prefixArray[0] = 1;
		for(int i = 1;i < n;i++) {
			prefixArray[i] = arr[i - 1] * prefixArray[i - 1];
		}
		suffixArray[n - 1] = 1;
		for(int j = n - 2;j >= 0;j--) {
			suffixArray[j] = arr[j + 1] * suffixArray[j + 1];
		}
		
		for(int i = 0;i < n;i++) {
			result[i] = prefixArray[i] * suffixArray[i];
		}
		return result;
	}

	private static int[] productNaive(int[] arr) {
		int n = arr.length;
		int[] result = new int[n];
		Arrays.fill(result, 1);
		
		for(int i = 0;i < n;i++) {
			for(int j = 0;j < n;j++) {
				if(i != j)
					result[i] *= arr[j];
			}
		}
		return result;
	}
}
