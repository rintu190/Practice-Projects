package org.common;

public class Trade {
    private long tradeId;
    private long buyOrderId;
    private long sellOrderId;
    private long quantity;
    private long price;
    private long timestamp;

    public Trade(long tradeId, long buyOrderId, long sellOrderId, long quantity, long price, long timestamp) {
        this.tradeId = tradeId;
        this.buyOrderId = buyOrderId;
        this.sellOrderId = sellOrderId;
        this.quantity = quantity;
        this.price = price;
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "Trade{" +
                "qty=" + quantity +
                ", price=" + price +
                '}';
    }
}
