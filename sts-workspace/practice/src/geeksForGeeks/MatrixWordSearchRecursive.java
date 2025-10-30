package geeksForGeeks;

import java.util.ArrayList;
import java.util.List;

public class MatrixWordSearchRecursive {

	public static void main(String[] args) {
		char[][] grid = {
				{'a','b','a','b'},
				{'a','b','e','b'},
				{'e','b','e','b'}
		};
		String word = "abe";
		int[][] answer = searchWord(grid,word);
		printresult(answer);
		}

	private static int[][] searchWord(char[][] grid, String word) {
		int m = grid.length;
		int n = grid[0].length;
		List<int[]> answer = new ArrayList<>();
		
		int[] xDir = {-1,-1,-1,0,0,1,1,1};
		int[] yDir = {-1,0,1,-1,1,-1,0,1};
		
		for(int i = 0;i < m;i++) {
			for(int j = 0;j < n;j++) {
				for(int k = 0;k < 8;k++) {
					if(findWord(0,word,grid,i,j,xDir[k],yDir[k])) {
						answer.add(new int[] {i,j});
						break;
					}
				}				
			}
		}	
		return answer.toArray(new int[0][]);
	}

	private static boolean findWord(int index, String word, char[][] grid, int x, int y, int dirX, int dirY) {
		if(index == word.length()) return true;
		if(validCoord(x,y,grid.length,grid[0].length) && word.charAt(index) == grid[x][y]) {
			return findWord(index+1,word,grid,x+dirX,y+dirY,dirX,dirY);
		}
		return false;
	}

	private static boolean validCoord(int x, int y, int m, int n) {
		if(x >= 0 && x < m && y >=0 && y <n)
			return true;
		return false;
	}

	private static void printresult(int[][] answer) {
		for(int[] a : answer) {
			System.out.println("{"+a[0]+","+a[1]+"}");
		}
	}

}

