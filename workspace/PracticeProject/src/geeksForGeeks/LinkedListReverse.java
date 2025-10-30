package geeksForGeeks;

import java.util.Stack;

public class LinkedListReverse {

	public static void main(String[] args) {
		Node head = new Node(1);
		head.next = new Node(2);
		head.next.next = new Node(3);
		head.next.next.next = new Node(4);
		head.next.next.next.next = new Node(5);
		
//		head = reverseListIterative(head);
//		head = reverseListRecursive(head);
		head = reverseListStack(head);
		printList(head);
	}

	private static Node reverseListStack(Node head) {
		Stack<Node> stack = new Stack<>();
		Node temp = head;
		
		while(temp != null) {
			stack.push(temp);
			temp = temp.next;
		}
		
		if(!stack.isEmpty()) {
			head = stack.pop();
			temp = head;
			while(!stack.isEmpty()) {
				temp.next = stack.pop();
				temp = temp.next;
			}
			temp.next = null;
		}
		return head;
	}

	private static Node reverseListRecursive(Node head) {
		if(head == null || head.next == null)
			return head;
		Node rest = reverseListRecursive(head.next);
		head.next.next = head;
		head.next = null;
		return rest;
	}

	private static Node reverseListIterative(Node head) {
		Node current = head, previous = null, next;
		while(current != null) {
			next = current.next;
			current.next = previous;			
			previous = current;
			current = next;
		}
		return previous;
	}

	private static void printList(Node head) {
		while(head != null) {
			System.out.print(head.data);
			if(head.next != null)
				System.out.print(" -> ");
			head = head.next;
		}
		
	}

}
