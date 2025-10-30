package geeksForGeeks;

import java.util.Arrays;

public class MatrixTranspose {

	public static void main(String[] args) {
		int[][] matrix = {
				{1,2,3},
				{4,5,6}
		};
        int[][] squareMatrix = {
                { 1, 1, 1, 1 },
                { 2, 2, 2, 2 },
                { 3, 3, 3, 3 },
                { 4, 4, 4, 4 }
            };
		int[][] result = new int[matrix[0].length][matrix.length];
		transposeN2Space(matrix,result);
		transponseConstantSpace(squareMatrix);
		
		for(int[] row : result) {
			System.out.println(Arrays.toString(row));
		}
		
		for(int[] row : squareMatrix) {
			System.out.println(Arrays.toString(row));
		}
	}

	private static void transposeN2Space(int[][] matrix, int[][] result) {
		int row = matrix.length;
		int col = matrix[0].length;
		for(int i = 0;i < row;i++) {
			for(int j = 0;j < col;j++) {
				result[j][i] = matrix[i][j];
			}
		}
	}
	
	private static void transponseConstantSpace(int[][] matrix) {
		int n = matrix.length;
		for(int i = 0;i < n;i++) {
			for(int j = i+1;j < n;j++) {
				int temp = matrix[i][j];
				matrix[i][j] = matrix[j][i];
				matrix[j][i] = temp;
			}
		}	
	}

}
