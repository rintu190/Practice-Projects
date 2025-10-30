package geeksForGeeks;

import java.util.ArrayList;

public class MatrixSpiral {
	public static void main(String[] args) {
		int[][] matrix = {
				{1,2,3,4},
				{5,6,7,8},
				{9,10,11,12},
				{13,14,15,16}
		};
//		ArrayList<Integer> result = spirallyTraverse(matrix);
		ArrayList<Integer> result = boundaryTraverse(matrix);
		
		for(int num : result)
			System.out.print(num+" ");		
	}

	private static ArrayList<Integer> spirallyTraverse(int[][] matrix) {
		int m = matrix.length;
		int n = matrix[0].length;
		
		ArrayList<Integer> result = new ArrayList<>();
		boolean[][] visited = new boolean[m][n];
		int[] dr = {0,1,0,-1};
		int[] dc = {1,0,-1,0};
		int r =0, c = 0, idx = 0;
		
		for(int i = 0;i < m*n;++i) {
			result.add(matrix[r][c]);
			visited[r][c] = true;
			
			int newR = r + dr[idx];
			int newC = c + dc[idx];
			
			if(0 <= newR && newR < m && 0 <= newC && newC < n && !visited[newR][newC]) {
				r = newR;
				c = newC;
			} else {
				idx = (idx+1)%4;
				r += dr[idx];
				c += dc[idx];
			}
		}		
		return result;
	}
	
	private static ArrayList<Integer> boundaryTraverse(int[][] matrix){
		ArrayList<Integer> result = new ArrayList<>();
		int m = matrix.length;
		int n = matrix.length;
		int top =0, bottom = m-1, left = 0, right = n-1;
		
		while(top <= bottom && left <= right) {
			for(int i = left;i <=right;i++) {
				result.add(matrix[top][i]);
			}
			top++;
			for(int i = top;i <= bottom;i++) {
				result.add(matrix[i][right]);
			}
			right--;
			if(top <= bottom) {
				for(int i = right;i >= left; --i) {
					result.add(matrix[bottom][i]);
				}
				bottom--;
			}
			if(left <= right) {
				for(int i = bottom;i >= top; --i) {
					result.add(matrix[i][left]);
				}
				left++;
			}
		}
		return result;
		
	}

}
