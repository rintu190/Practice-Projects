package geeksForGeeks;

public class ArraysStockMaxProfit {

	public static void main(String[] args) {
		int[] prices = {7,10,1,3,6,9,2};
//		int result = maxProfitNaive(prices);
		int result = maxProfitOneTraversal(prices);
		System.out.println(result);
	}

	private static int maxProfitOneTraversal(int[] prices) {
		int minSoFar = prices[0];
		int res = 0;
		
		for(int i = 1;i < prices.length;i++) {
			minSoFar = Math.min(minSoFar, prices[i]);
			res = Math.max(res, prices[i] - minSoFar);
		}
		return res;
	}

	private static int maxProfitNaive(int[] prices) {
		int n = prices.length;
		int res = 0;
		
		for(int i = 0;i < n-1;i++) {
			for(int j = i+1;j < n;j++) {
				res = Math.max(res, prices[j] - prices[i]);
			}
		}
		return res;
	}

}
