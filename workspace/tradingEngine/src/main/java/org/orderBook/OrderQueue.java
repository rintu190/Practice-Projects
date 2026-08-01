package org.orderBook;

import org.common.Order;

import java.util.LinkedList;
import java.util.Queue;

public class OrderQueue {
    private Queue<Order> orders = new LinkedList<>();

    public void add(Order order) {
        orders.add(order);
    }

    public Order peek(){
        return orders.peek();
    }

    public Order poll()  {
        return orders.poll();
    }

    public boolean isEmpty() {
        return orders.isEmpty();
    }
}
