package geeksForGeeks;

import java.util.HashSet;

public class LinkedListCycleDetection {

	public static void main(String[] args) {
		Node head = new Node(1);
		head.next = new Node(3);
		head.next.next = new Node(5);
		head.next.next.next = head.next;
		
//		Boolean result = detectCycleHashset(head);
		Boolean result = detectCycleFloydAlgorithm(head);
		System.out.println(result);
	}

	private static Boolean detectCycleFloydAlgorithm(Node head) {
		Node slow = head, fast = head;
		while(slow != null && fast != null && fast.next != null) {
			slow = slow.next;
			fast = fast.next.next;
			
			if(slow == fast)
				return true;
		}
		return false;
	}

	private static Boolean detectCycleHashset(Node head) {
		HashSet<Node> set = new HashSet<>();
		
		while(head != null) {
			if(set.contains(head))
				return true;
			set.add(head);
			head = head.next;
		}
		return false;
	}

}
