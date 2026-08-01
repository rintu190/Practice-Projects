package org.orderBook;

public class PriceLevel {
    private long price;
    private OrderQueue queue = new OrderQueue();

    public PriceLevel(long price, OrderQueue queue) {
        this.price = price;
        this.queue = queue;
    }

    public PriceLevel(Long aLong) {
    }

    public long getPrice() {
        return price;
    }

    public void setPrice(long price) {
        this.price = price;
    }

    public OrderQueue getQueue() {
        return queue;
    }
}
