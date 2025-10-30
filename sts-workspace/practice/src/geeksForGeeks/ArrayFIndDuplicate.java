package geeksForGeeks;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

public class ArrayFIndDuplicate {

	public static void main(String[] args) {
		Integer[] arr = {1,6,5,2,3,3,2};
		List<Integer> duplicates =  findDuplicateHashMap(arr);
		
		for(int element : duplicates) {
			System.out.println(element + " ");
		}
		
		int[] arr2 = {1,6,5,2,3,3,2};
		int[] duplicates2 = findDuplicatesAuxArray(arr);
		
		for(int element : duplicates2) {
			System.out.println(element + " ");
		}
		
	}

	private static int[] findDuplicatesAuxArray(Integer[] arr) {
		int n = arr.length;
		int[] freqArray = new int[n];
		List<Integer> result = new ArrayList<>();
		
		for(int i = 0;i < n;i++) {
			freqArray[arr[i]]++;
		}
		
		for(int i = 0;i < n;i++) {
			if(freqArray[arr[i]] > 1) {
				result.add(arr[i]);
				freqArray[arr[i]] = 0;
			}
		}
		if(result.isEmpty()) {
			result.add(-1);
		}
		return result.stream().mapToInt(i -> i).toArray();
	}

	private static List<Integer> findDuplicateHashMap(Integer[] arr) {
		int n = arr.length;
		Map<Integer,Integer> freqMap = new HashMap<>();
		List<Integer> result = new ArrayList<>();
		
		for(int i = 0;i < n;i++) {
			freqMap.put(arr[i], freqMap.getOrDefault(arr[i], 0)+1);
		}
		for(Entry<Integer, Integer> entry : freqMap.entrySet()) {
			if(entry.getValue() > 1)
				result.add(entry.getKey());
		}
		if(result.isEmpty())
			result.add(-1);		
		return result;
	}

}
