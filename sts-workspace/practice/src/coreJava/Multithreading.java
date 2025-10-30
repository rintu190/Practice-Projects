package coreJava;

import java.util.List;
import java.util.concurrent.*;

public class Multithreading {
    public static void main(String[] args) throws InterruptedException {

        //using runnable interface
        Thread t1= new Thread(new Task());
        t1.start();

        // create a Thread pool
        ExecutorService service = Executors.newFixedThreadPool(10);

        // CPU intensive tasks
        int coreCounts = Runtime.getRuntime().availableProcessors();
        ExecutorService service2 = Executors.newFixedThreadPool(coreCounts);

        //submit tasks for execution
        for(int i=0; i<100; i++){
            service.execute(new Task());
        }

        //High io or db operations have thread count high

        // CachedThreadPool
        ExecutorService service3 = Executors.newCachedThreadPool();


        //Scheduled Thread Pool
        ScheduledExecutorService service4 = Executors.newScheduledThreadPool(10);
        service4.schedule(new Task(), 10, TimeUnit.SECONDS);
        service4.scheduleAtFixedRate(new Task(),15,10, TimeUnit.SECONDS);
        service4.scheduleWithFixedDelay(new Task(),15, 10, TimeUnit.SECONDS);

        // Lifecycles
        //initiates shutdown
        service.shutdown();
        // return true if shutdown is initiated
        service.isShutdown();
        //return true if all tasks completed
        service.isTerminated();
        try{
            //block until all tasks completed or timeouts
            service.awaitTermination(10, TimeUnit.SECONDS);
        }catch (Exception e){
            throw e;
        }

        //terminates and return pending tasks
        List<Runnable> tasks= service.shutdownNow();



        System.out.println("Thread name" + Thread.currentThread().getName());
    }
}
class Task implements Runnable{
    public void run(){
        System.out.println("Thread name" + Thread.currentThread().getName());
    }
}
