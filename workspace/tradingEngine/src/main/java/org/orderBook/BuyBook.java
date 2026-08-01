package org.orderBook;

import java.util.Comparator;
import java.util.TreeMap;

public class BuyBook {
    private TreeMap<Long, PriceLevel> levels = new TreeMap<>(Comparator.reverseOrder());
    public TreeMap<Long, PriceLevel> getLevels() {
        return levels;
    }
}
