package geeksForGeeks;

public class StringLongestSubstring {

	public static void main(String[] args) {
		String s = "GeeksForGeeks";
		System.out.println(longestUnqiueSubstringNaive(s));

	}

	private static int longestUnqiueSubstringNaive(String s) {
		int n = s.length();
		int result = 0;
		
		for(int i = 0;i < n;i++) {
			boolean[] visited = new boolean[256];
			for(int j = i;j < n;j++) {
				if(visited[s.charAt(j)])
					break;
				else {
					result = Math.max(result, j - i +1);
					visited[s.charAt(j)] = true;
				}
			}
		}
		return result;
	}

}
