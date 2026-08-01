package org.execution;

import org.common.Trade;

import java.util.ArrayList;
import java.util.List;

public class TradeStore {
    private List<Trade> trades = new ArrayList<>();
    public void addTrade(Trade trade) {
        trades.add(trade);
    }
    public void printTrades() {
        trades.forEach(System.out::println);
    }
}
