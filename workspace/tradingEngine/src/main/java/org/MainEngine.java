package org;

import org.common.Order;
import org.common.OrderSide;
import org.execution.TradeStore;
import org.matchingEngine.MatchingEngine;
import org.orderBook.OrderBook;

public class MainEngine {
    public static void main() {
        System.out.println("Exchange Started");
        OrderBook orderBook = new OrderBook();
        TradeStore tradeStore = new TradeStore();
        MatchingEngine engine = new MatchingEngine(orderBook, tradeStore);
        Order sell = new Order(1,"TCS", OrderSide.SELL,100,3500);
        System.out.println("Submitting SELL");
        engine.process(sell);
        orderBook.printOrderBook();
        Order buy = new Order(2,"TCS", OrderSide.BUY,100,3500);
        System.out.println("Submitting BUY");
        engine.process(buy);
        orderBook.printOrderBook();
        System.out.println("Exchange Finished");
        System.out.println("\nExecuted Trades");
        tradeStore.printTrades();

    }
}
