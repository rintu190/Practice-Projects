package org.orderBook;

public class OrderBook {
    private BuyBook buyBook = new BuyBook();
    private SellBook sellBook = new SellBook();

    public BuyBook getBuyBook() {
        return buyBook;
    }

    public SellBook getSellBook() {
        return sellBook;
    }

    public void printOrderBook() {

        System.out.println("\n========================");
        System.out.println("ORDER BOOK");
        System.out.println("========================");

        System.out.println("\nSELL SIDE");

        sellBook.getLevels()
                .forEach((price, level) -> {

                    System.out.println(
                            "Price: " + price
                    );
                });

        System.out.println("\nBUY SIDE");

        buyBook.getLevels()
                .forEach((price, level) -> {

                    System.out.println(
                            "Price: " + price
                    );
                });

        System.out.println("========================");
    }
}
