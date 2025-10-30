package geeksForGeeks;

public class MatrixBoolean {

	public static void main(String[] args) {
		int[][] matrix = {
				{1,0,0,1},
				{0,0,1,0},
				{0,0,0,0}
		};
//		booleanWithMarking(matrix);
//		booleanWithSpace(matrix);
		booleanWithoutSpace(matrix);
		
		for(int[] row : matrix) {
			for(int value : row) {
				System.out.print(value + " ");
			}
			System.out.println();
		}
	}

	private static void booleanWithoutSpace(int[][] matrix) {
		int colZero = 0;
		int row = matrix.length,col = matrix[0].length;
		
		for(int i = 0;i < row;i++) {
			if(matrix[i][0] == 1) colZero = 1;
			for(int j = 1;j < col;j++) {
				if(matrix[i][j] == 1) {
					matrix[i][0] = 1;
					matrix[0][j] = 1;
				}
			}
		}
		
		for(int i = row - 1;i >= 0;i--) {
			for(int j = col - 1;j >= 1;j--) {
				if(matrix[i][0] == 1 || matrix[0][j] == 1) {
					matrix[i][j] = 1;
				}
			}
			if(colZero == 1) {
				matrix[i][0] = 1;
			}
		}		
	}

	private static void booleanWithSpace(int[][] matrix) {
		int row = matrix.length;
		int col = matrix[0].length;
		
		boolean[] rowMarker = new boolean[row];
		boolean[] colMarker = new boolean[col];
		
		for(int i =0;i <row;i++) {
			for(int j = 0;j < col;j++) {
				if(matrix[i][j] == 1) {
					rowMarker[i] = true;
					colMarker[j] = true;
				}
			}
		}
		
		for(int i = 0;i < row;i++) {
			for(int j = 0;j <col;j++) {
				if(rowMarker[i] || colMarker[j]) {
					matrix[i][j] = 1;
				}
			}
		}
	}

	private static void booleanWithMarking(int[][] matrix) {
		int row = matrix.length, col = matrix[0].length;
		
		for(int i = 0;i < row;i++) {
			for(int j = 0;j < col;j++) {
				if(matrix[i][j] == 1) {
					for(int idx = 0;idx < row;idx++) {
						if(matrix[idx][j] == 0) {
							matrix[idx][j] = -1;
						}
					}
					for(int idx = 0;idx < col;idx++) {
						if(matrix[i][idx] == 0) {
							matrix[i][idx] = -1;
						}
					}
				}
			}
		}
		
		for(int i = 0;i < row;i++) {
			for(int j = 0;j < col; j++) {
				if(matrix[i][j] == -1) {
					matrix[i][j] = 1;
				}
			}
		}
	}

}
