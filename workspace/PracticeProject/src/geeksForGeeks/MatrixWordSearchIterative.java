package geeksForGeeks;

public class MatrixWordSearchIterative {

	public static void main(String[] args) {
		char[][] grid = {
				{'a','b','a','b'},
				{'a','b','e','b'},
				{'e','b','e','b'}
		};
		String word = "abe";
		int[][] answer = searchWord(grid,word);
		printResult(answer);
	}

	private static int[][] searchWord(char[][] grid, String word) {
		int m = grid.length;
		int n = grid[0].length;
		
		int[][] answer = new int[m*n][2];
		int count = 0;
		
		for(int i = 0;i < m;i++) {
			for(int j = 0;j < n;j++) {
				if(search2D(grid,i,j,word)) {
					answer[count][0] = i;
					answer[count][1] = j;
					count++;					
				}
			}
		}
		int[][] result = new int[count][2];
		for(int i = 0;i < count;i++) {
			result[i] = answer[i];
		}
		return result;
	}

	private static boolean search2D(char[][] grid, int row, int col, String word) {
		int m = grid.length;
		int n = grid[0].length;
		
		if(grid[row][col] != word.charAt(0))
			return false;
		int length = word.length();
		int[] x = {-1,-1,-1,0,0,1,1,1};
		int[] y = {-1,0,1,-1,1,-1,0,1};
		
		for(int dir = 0;dir < 8;dir++) {
			int k, currX = row + x[dir],currY = col + y[dir];
			for(k = 1;k < length;k++) {
				if(currX >=m || currX < 0 || currY >=n || currY <0) {
					break;
				}
				if(grid[currX][currY] != word.charAt(k)) {
					break;
				}
				currX += x[dir];
				currY += y[dir];
					
			}
			if(k == length)
				return true;
		}
		return false;
	}

	private static void printResult(int[][] answer) {
		for(int[] coords : answer) {
			System.out.println("{"+coords[0]+","+coords[1]+"}");
		}
		System.out.println();
	}

}
