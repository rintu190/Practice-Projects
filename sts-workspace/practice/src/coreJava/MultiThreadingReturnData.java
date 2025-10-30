package coreJava;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.*;

public class MultiThreadingReturnData {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService service = Executors.newFixedThreadPool(10);
        List<Future> futureList = new ArrayList<>();

        // submit the tasks to get values in return
        for(int i=0; i<=100;i++){
            Future<Integer> future = service.submit(new CallableTask());
            futureList.add(future);
        }

        //get future values
        for(int i=0; i<=100; i++){
            Future future = futureList.get(i);
            Integer result = (Integer) future.get();
            System.out.println("value of future is #" + result);

            //cancel the task
            future.cancel(false);
            //if cancelled
            future.isCancelled();
            //if completed
            future.isDone();
        }


    }
    public void completableFuture(){

        ExecutorService cpuBound = Executors.newFixedThreadPool(4);
        ExecutorService ioBound = Executors.newCachedThreadPool();

        for (int i =0; i<100; i++){
            //single thread Pool
            CompletableFuture.supplyAsync(()-> getOrder())
                    .thenApply(order -> enrichOrder(order))
                    .thenApply((order -> payment(order)))
                    .thenApply(order -> dispatch(order))
                    .thenApply(order -> sendMain(order));

            //multiple thread pool
            CompletableFuture.supplyAsync(()-> getOrder(), ioBound)
                    .thenApplyAsync(order -> enrichOrder(order), cpuBound)
                    .thenApplyAsync((order -> payment(order)), ioBound)
                    .exceptionally((e -> failedOrder()))
                    .thenApply(order -> dispatch(order))
                    .thenApply(order -> sendMain(order));
        }

    }

    private Object failedOrder() {
        return null;
    }

    private Object sendMain(Object order) {
        return null;
    }

    private Object dispatch(Object order) {
        return null;
    }

    private Object payment(Object order) {
        return null;
    }

    private Object enrichOrder(Object order) {
        return null;
    }

    private <U> U getOrder() {
        return null;
    }
}
class CallableTask implements Callable<Integer> {
    @Override
    public Integer call() throws Exception {
        return new Random().nextInt();
    }
}
