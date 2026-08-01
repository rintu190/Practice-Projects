package org.matchingEngine;

import org.common.Order;
import org.common.OrderSide;
import org.common.Trade;
import org.execution.TradeStore;
import org.orderBook.BuyBook;
import org.orderBook.OrderBook;
import org.orderBook.PriceLevel;
import org.orderBook.SellBook;

public class MatchingEngine {
    private final OrderBook orderBook;
    private final TradeStore tradeStore;
    private long tradeSequence = 1;

    public MatchingEngine(OrderBook orderBook, TradeStore tradeStore) {
        this.orderBook = orderBook;
        this.tradeStore = tradeStore;
    }

    public void process(Order order) {
        if(order.getSide() == OrderSide.BUY) {
            processBuy(order);
        } else {
            processSell(order);
        }
    }

    private void processSell(Order order) {
        addSellOrder(order);
    }

    private void processBuy(Order buyOrder) {
        SellBook sellBook = orderBook.getSellBook();
        while(buyOrder.getQuantity() > 0 && !sellBook.getLevels().isEmpty()) {
            Long bestAsk = sellBook.getLevels().firstKey();

            if(bestAsk > buyOrder.getPrice())
                break;

            PriceLevel level = sellBook.getLevels().get(bestAsk);
            Order sellOrder = level.getQueue().peek();
            long qty = Math.min(buyOrder.getQuantity(), sellOrder.getQuantity());
            buyOrder.reduceQuantity(qty);
            sellOrder.reduceQuantity(qty);

            Trade trade =
                    new Trade(
                            tradeSequence++,
                            buyOrder.getOrderId(),
                            sellOrder.getOrderId(),
                            qty,
                            bestAsk,
                            System.currentTimeMillis()
                    );
            tradeStore.addTrade(trade);
            System.out.println(trade);

            if(sellOrder.getQuantity() == 0)
                level.getQueue().poll();
            if(level.getQueue().isEmpty()){
                sellBook.getLevels().remove(bestAsk);
            }
        }
        if(buyOrder.getQuantity() > 0)
            addBuyOrder(buyOrder);
    }

    private void addBuyOrder(Order order) {
        BuyBook buyBook = orderBook.getBuyBook();
        buyBook.getLevels().computeIfAbsent(order.getPrice(),PriceLevel::new).getQueue().add(order);
    }

    private void addSellOrder(Order order) {
        SellBook sellBook = orderBook.getSellBook();
        sellBook.getLevels().computeIfAbsent(order.getPrice(), PriceLevel::new).getQueue().add(order);
    }


}
