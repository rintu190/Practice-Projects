package org.orderBook;

import java.util.TreeMap;

public class SellBook {
    private TreeMap<Long, PriceLevel> levels = new TreeMap<>();
    public TreeMap<Long, PriceLevel> getLevels(){
        return levels;
    }
}
