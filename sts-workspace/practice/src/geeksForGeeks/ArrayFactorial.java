package geeksForGeeks;

import java.math.BigInteger;

public class ArrayFactorial {
	public static void main(String[] args) {
//		factorial(50);
//		factorialBigInt(50);
		factorialinkedList();
	}

	private static void factorialinkedList() {
		int n = 50;
		Node head = new Node(1);
		for(int i = 2;i <= n;i++) {
			multiply(head,i);			
		}
		System.out.println("factorial of "+ n +" is: ");
		print(head);
		System.out.println();
	}

	private static void multiply(Node head, int i) {
		Node temp = head;
		Node previousPointer = head;
		int carry = 0;
		while(temp !=null) {
			int product = temp.data * i + carry;
			carry = product / 10;
			previousPointer = temp;
			temp = temp.previous;
		}
		while(carry != 0) {
			previousPointer.previous = new Node((int)(carry % 10));
			carry /= 10;
			previousPointer = previousPointer.previous;
		}
	}

	private static void print(Node head) {
		if(head == null)
			return;
		print(head.previous);
		System.out.print(head.data);		
	}

	private static void factorialBigInt(int n) {
		BigInteger f = new BigInteger("1");
		for(int i = 2;i <= n;i++) {
			f = f.multiply(BigInteger.valueOf(i));
		}		
		System.out.println(f);;
	}

	private static void factorial(int n) {
		int result[] = new int[500];
		result[0] = 1;
		int res_size = 1;
		
		for(int i = 2;i <= n;i++) {
			res_size = multiply(i,result,res_size);
		}
		System.out.print("factorial of "+ n +" is: ");
		for(int i = res_size - 1; i >= 0;i--) {
			System.out.print(result[i]);
		}		
	}

	private static int multiply(int x, int[] result, int res_size) {
		int carry = 0;
		
		for(int i = 0;i < res_size;i++) {
			int product = result[i]*x + carry;
			result[i] = product % 10;
			carry = product / 10;
		}
		while(carry != 0) {
			result[res_size] = carry % 10;
			carry = carry / 10;
			res_size++;
		}
		return res_size;
	}
}
class Node{
	public int data;
	public Node previous;
	
	public Node(int n) {
		data = n;
		previous = null;
		
	}
}