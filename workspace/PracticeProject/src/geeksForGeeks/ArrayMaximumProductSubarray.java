package geeksForGeeks;

public class ArrayMaximumProductSubarray {

	public static void main(String[] args) {
		int[] arr = {-2,6,-3,-10,-0,2};
//		int result = maxProductNaive(arr);
//		int result = maxProductUsingMinMaxProd(arr);
		int result = maxProductUsingTraversal(arr);
		System.out.println(result);

	}

	private static int maxProductUsingTraversal(int[] arr) {
		int n = arr.length;
		int maxProduct = Integer.MIN_VALUE;
		int leftToRight = 1;
		int rightToLeft = 1;
		
		for(int i = 0;i < n;i++) {
			if(leftToRight == 0)
				leftToRight = 1;
			if(rightToLeft == 0)
				rightToLeft = 1;
			
			leftToRight *= arr[i];
			int j = n - i - 1;
			rightToLeft *= arr[j];
			maxProduct = Math.max(leftToRight, Math.max(rightToLeft, maxProduct));
		}
		return maxProduct;
	}

	private static int maxProductUsingMinMaxProd(int[] arr) {
		int n = arr.length;
		int currentMax = arr[0];
		int currentMin = arr[0];
		int maxProduct = arr[0];
		
		for(int i = 1;i < n;i++) {
			int temp = max(arr[i],arr[i]*currentMax,arr[i]* currentMin);
			currentMin = min(arr[i],arr[i]*currentMax,arr[i]*currentMin);
			currentMax = temp;
			maxProduct = Math.max(maxProduct, currentMax);
		}
		return maxProduct;
	}

	private static int min(int i, int j, int k) {
		return Math.min(i, Math.min(j, k));
	}

	private static int max(int i, int j, int k) {
		return Math.max(i, Math.max(j, k));
	}

	private static int maxProductNaive(int[] arr) {
		int n = arr.length;
		int result = arr[0];
		
		for(int i = 0;i < n;i++) {
			int product = 1;
			for(int j = i;j < n;j++) {
				product *= arr[j];
				result = Math.max(result, product);
			}
		}
		return result;
	}

}
