package geeksForGeeks;

import java.util.ArrayList;
import java.util.Collections;

public class LinkedListSortedMerge {

	public static void main(String[] args) {
		Node head1 = new Node(5);
		head1.next = new Node(10);
		head1.next.next = new Node(15);
		head1.next.next.next = new Node(30);
		
		Node head2 = new Node(4);
		head2.next = new Node(8);
		head2.next.next = new Node(20);
		
//		Node result = sortedMergeArray(head1, head2);
//		Node result = sortedMergeRecursive(head1, head2);
		Node result = sortedMergeIterative(head1, head2);
		printList(result);		
	}

	private static Node sortedMergeIterative(Node head1, Node head2) {
		Node dummy = new Node(-1);
		Node current = dummy;
		
		while(head1 != null & head2 != null) {
			if(head1.data < head2.data) {
				current.next = head1;
				head1 = head1.next;
			} else {
				current.next = head2;
				head2 = head2.next;
			}
			current = current.next;
			
			if(head1 != null)
				current.next = head1;
			else
				current.next = head2;
		}
		return dummy.next;
	}

	private static Node sortedMergeRecursive(Node head1, Node head2) {
		if(head1 == null)
			return head2;
		if(head2 == null)
			return head1;
		
		if(head1.data < head2.data) {
			head1.next = sortedMergeRecursive(head1.next, head2);
			return head1;
		} else {
			head2.next = sortedMergeRecursive(head1, head2.next);
			return head2;
		}
	}

	private static Node sortedMergeArray(Node head1, Node head2) {
		ArrayList<Integer> arr = new ArrayList<>();
		while(head1 != null) {
			arr.add(head1.data);
			head1 = head1.next;
		}
		while(head2 != null) {
			arr.add(head2.data);
			head2 = head2.next;
		}
		Collections.sort(arr);
		Node dummy = new Node(-1);
		Node current = dummy;
		
		for(int i = 0; i < arr.size(); i++) {
			current.next =  new Node(arr.get(i));
			current = current.next;
		}
		
		return dummy.next;
	}

	private static void printList(Node current) {
		while(current != null) {
			System.out.print(current.data);
			if(current.next != null) {
				System.out.print(" -> ");
			}
			current = current.next;
		}
		System.out.println();
		
	}

}
