#include <iostream>
#include <thread>
#include <mutex>
#include <vector>
#include <chrono>
#include <condition_variable>
#include <atomic>
#include <memory>
#include <queue>
#include <functional>

using namespace std;

// ============== BASIC THREADS ==============

void simple_task() {
    cout << "Task running in thread " << this_thread::get_id() << endl;
}

void task_with_sleep() {
    for (int i = 0; i < 3; i++) {
        cout << "Task iteration " << i << endl;
        this_thread::sleep_for(chrono::milliseconds(500));
    }
}

void demo_basic_thread() {
    cout << "\n=== BASIC THREAD ===" << endl;
    cout << "Main thread: " << this_thread::get_id() << endl;
    
    // Create thread
    thread t(simple_task);
    
    // Wait for thread to finish
    t.join();
    
    cout << "Main thread continues after join" << endl;
}

void demo_thread_with_parameter(int value) {
    cout << "Thread parameter: " << value << endl;
}

void demo_thread_parameters() {
    cout << "\n=== THREAD WITH PARAMETERS ===" << endl;
    
    thread t1(demo_thread_with_parameter, 42);
    thread t2(demo_thread_with_parameter, 100);
    
    t1.join();
    t2.join();
    
    cout << "Both threads completed" << endl;
}

void demo_multiple_threads() {
    cout << "\n=== MULTIPLE THREADS ===" << endl;
    
    vector<thread> threads;
    
    // Create 5 threads
    for (int i = 0; i < 5; i++) {
        threads.push_back(thread([i]() {
            cout << "Thread " << i << " running" << endl;
            this_thread::sleep_for(chrono::milliseconds(100 * (i + 1)));
            cout << "Thread " << i << " finished" << endl;
        }));
    }
    
    // Join all threads
    for (auto& t : threads) {
        t.join();
    }
    
    cout << "All threads completed" << endl;
}

void demo_detach() {
    cout << "\n=== DETACH THREADS ===" << endl;
    
    thread t([]() {
        this_thread::sleep_for(chrono::seconds(1));
        cout << "Detached thread finished" << endl;
    });
    
    cout << "Thread detached" << endl;
    t.detach();  // Don't wait for thread
    
    this_thread::sleep_for(chrono::seconds(2));  // Give time for detached thread
    cout << "Main thread continues" << endl;
}

// ============== MUTEX ==============

int shared_counter = 0;
mutex counter_mutex;

void increment_without_mutex(int iterations) {
    for (int i = 0; i < iterations; i++) {
        shared_counter++;
    }
}

void increment_with_mutex(int iterations) {
    for (int i = 0; i < iterations; i++) {
        {
            lock_guard<mutex> lock(counter_mutex);
            shared_counter++;
        }
    }
}

void demo_race_condition() {
    cout << "\n=== RACE CONDITION (WITHOUT MUTEX) ===" << endl;
    
    shared_counter = 0;
    vector<thread> threads;
    
    // Create threads that increment without mutex
    for (int i = 0; i < 10; i++) {
        threads.push_back(thread(increment_without_mutex, 1000));
    }
    
    for (auto& t : threads) {
        t.join();
    }
    
    cout << "Expected: 10000, Actual: " << shared_counter << endl;
    cout << "(Value will likely be less than 10000 due to race condition)" << endl;
}

void demo_mutex_protection() {
    cout << "\n=== MUTEX PROTECTION ===" << endl;
    
    shared_counter = 0;
    vector<thread> threads;
    
    // Create threads that increment with mutex
    for (int i = 0; i < 10; i++) {
        threads.push_back(thread(increment_with_mutex, 1000));
    }
    
    for (auto& t : threads) {
        t.join();
    }
    
    cout << "Expected: 10000, Actual: " << shared_counter << endl;
    cout << "(Value will be exactly 10000)" << endl;
}

void demo_lock_guard() {
    cout << "\n=== LOCK_GUARD ===" << endl;
    
    mutex m;
    int value = 0;
    
    auto increment = [&]() {
        lock_guard<mutex> lock(m);  // Automatically locks
        value++;
        cout << "Value: " << value << endl;
    };  // Automatically unlocks when lock_guard goes out of scope
    
    thread t1(increment);
    thread t2(increment);
    
    t1.join();
    t2.join();
}

void demo_unique_lock() {
    cout << "\n=== UNIQUE_LOCK ===" << endl;
    
    mutex m;
    int value = 0;
    
    auto task = [&](int id) {
        unique_lock<mutex> lock(m);
        cout << "Thread " << id << " locked" << endl;
        value += id;
        this_thread::sleep_for(chrono::milliseconds(100));
        cout << "Thread " << id << " value: " << value << endl;
        lock.unlock();  // Manually unlock
        cout << "Thread " << id << " unlocked" << endl;
        
        // Can lock again
        lock.lock();
        cout << "Thread " << id << " locked again" << endl;
        lock.unlock();
    };
    
    thread t1(task, 1);
    thread t2(task, 2);
    
    t1.join();
    t2.join();
}

// ============== CONDITION VARIABLE ==============

mutex cv_mutex;
condition_variable cv;
bool data_ready = false;
int shared_data = 0;

void producer() {
    this_thread::sleep_for(chrono::seconds(1));
    
    {
        lock_guard<mutex> lock(cv_mutex);
        shared_data = 42;
        data_ready = true;
        cout << "Producer: Data produced" << endl;
    }
    
    cv.notify_one();  // Notify one waiting thread
}

void consumer() {
    unique_lock<mutex> lock(cv_mutex);
    
    while (!data_ready) {
        cout << "Consumer: Waiting for data..." << endl;
        cv.wait(lock);  // Release lock and wait
    }
    
    cout << "Consumer: Data received: " << shared_data << endl;
}

void demo_condition_variable() {
    cout << "\n=== CONDITION VARIABLE ===" << endl;
    
    data_ready = false;
    
    thread p(producer);
    thread c(consumer);
    
    p.join();
    c.join();
}

void demo_condition_variable_multiple() {
    cout << "\n=== CONDITION VARIABLE - MULTIPLE CONSUMERS ===" << endl;
    
    data_ready = false;
    
    thread p(producer);
    
    thread c1([](){ consumer(); });
    thread c2([](){ consumer(); });
    
    p.join();
    c1.join();
    c2.join();
}

// ============== ATOMIC ==============

atomic<int> atomic_counter(0);

void increment_atomic() {
    for (int i = 0; i < 1000; i++) {
        atomic_counter++;  // Thread-safe atomic operation
    }
}

void demo_atomic() {
    cout << "\n=== ATOMIC OPERATIONS ===" << endl;
    
    atomic_counter = 0;
    vector<thread> threads;
    
    for (int i = 0; i < 10; i++) {
        threads.push_back(thread(increment_atomic));
    }
    
    for (auto& t : threads) {
        t.join();
    }
    
    cout << "Atomic counter: " << atomic_counter << endl;
    cout << "(Always 10000 without mutex!)" << endl;
}

void demo_atomic_operations() {
    cout << "\n=== ATOMIC ADVANCED OPERATIONS ===" << endl;
    
    atomic<int> x(10);
    
    cout << "Initial: " << x << endl;
    
    // Store
    x.store(20);
    cout << "After store(20): " << x << endl;
    
    // Load
    int val = x.load();
    cout << "After load(): " << val << endl;
    
    // Compare and swap
    bool swapped = x.compare_exchange_strong(val, 30);
    cout << "Compare exchange (20->30): " << (swapped ? "success" : "failed") << endl;
    cout << "Value now: " << x << endl;
}

// ============== THREAD POOL / WORKER PATTERN ==============

class ThreadPool {
private:
    vector<thread> workers;
    queue<function<void()>> tasks;
    mutex queue_mutex;
    condition_variable cv;
    bool stop = false;
    
public:
    ThreadPool(int num_threads) {
        for (int i = 0; i < num_threads; i++) {
            workers.emplace_back([this]() {
                while (true) {
                    unique_lock<mutex> lock(queue_mutex);
                    
                    cv.wait(lock, [this]() { return !tasks.empty() || stop; });
                    
                    if (stop && tasks.empty()) break;
                    
                    auto task = move(tasks.front());
                    tasks.pop();
                    lock.unlock();
                    
                    task();
                }
            });
        }
    }
    
    ~ThreadPool() {
        {
            lock_guard<mutex> lock(queue_mutex);
            stop = true;
        }
        cv.notify_all();
        for (auto& worker : workers) {
            worker.join();
        }
    }
    
    template<typename F>
    void enqueue(F f) {
        {
            lock_guard<mutex> lock(queue_mutex);
            tasks.emplace(f);
        }
        cv.notify_one();
    }
};

void demo_thread_pool() {
    cout << "\n=== THREAD POOL ===" << endl;
    
    ThreadPool pool(4);
    
    for (int i = 0; i < 10; i++) {
        pool.enqueue([i]() {
            cout << "Task " << i << " executed" << endl;
            this_thread::sleep_for(chrono::milliseconds(100));
        });
    }
    
    // Pool destructor waits for all tasks
    cout << "All tasks submitted" << endl;
}

// ============== SHARED DATA STRUCTURE ==============

class SafeQueue {
private:
    queue<int> q;
    mutable mutex m;
    condition_variable cv;
    
public:
    void push(int value) {
        {
            lock_guard<mutex> lock(m);
            q.push(value);
        }
        cv.notify_one();
    }
    
    bool try_pop(int& value) {
        lock_guard<mutex> lock(m);
        if (q.empty()) return false;
        value = q.front();
        q.pop();
        return true;
    }
    
    void wait_pop(int& value) {
        unique_lock<mutex> lock(m);
        cv.wait(lock, [this]() { return !q.empty(); });
        value = q.front();
        q.pop();
    }
};

void demo_safe_queue() {
    cout << "\n=== SAFE QUEUE ===" << endl;
    
    SafeQueue sq;
    
    thread producer_thread([&]() {
        for (int i = 0; i < 5; i++) {
            sq.push(i);
            cout << "Produced: " << i << endl;
            this_thread::sleep_for(chrono::milliseconds(100));
        }
    });
    
    thread consumer_thread([&]() {
        for (int i = 0; i < 5; i++) {
            int value;
            sq.wait_pop(value);
            cout << "Consumed: " << value << endl;
        }
    });
    
    producer_thread.join();
    consumer_thread.join();
}

// ============== THREAD INFO ==============

void demo_thread_info() {
    cout << "\n=== THREAD INFORMATION ===" << endl;
    
    cout << "Number of CPU cores: " << thread::hardware_concurrency() << endl;
    
    thread t([]() {
        cout << "Thread ID: " << this_thread::get_id() << endl;
    });
    
    cout << "Main thread ID: " << this_thread::get_id() << endl;
    
    t.join();
}

// ============== DEADLOCK EXAMPLE ==============

mutex m1, m2;

void task_a() {
    lock_guard<mutex> lock1(m1);
    cout << "Task A locked m1" << endl;
    this_thread::sleep_for(chrono::milliseconds(100));
    lock_guard<mutex> lock2(m2);
    cout << "Task A locked m2" << endl;
}

void task_b() {
    lock_guard<mutex> lock2(m2);
    cout << "Task B locked m2" << endl;
    this_thread::sleep_for(chrono::milliseconds(100));
    lock_guard<mutex> lock1(m1);
    cout << "Task B locked m1" << endl;
}

void demo_deadlock_risk() {
    cout << "\n=== DEADLOCK RISK ===" << endl;
    cout << "WARNING: This may deadlock! Uncomment carefully." << endl;
    cout << "(Deadlock prevention: always acquire locks in same order)" << endl;
    
    // Uncomment to see deadlock (will hang):
    // thread a(task_a);
    // thread b(task_b);
    // a.join();
    // b.join();
}

// ============== ONCE_FLAG ==============

once_flag init_flag;
int initialized_value = 0;

void initialize() {
    cout << "Initializing..." << endl;
    this_thread::sleep_for(chrono::milliseconds(100));
    initialized_value = 42;
    cout << "Initialization complete" << endl;
}

void demo_once_flag() {
    cout << "\n=== ONCE_FLAG ===" << endl;
    
    initialized_value = 0;
    
    auto init_once = [](int id) {
        cout << "Thread " << id << " trying to initialize..." << endl;
        call_once(init_flag, initialize);
        cout << "Thread " << id << " value: " << initialized_value << endl;
    };
    
    thread t1(init_once, 1);
    thread t2(init_once, 2);
    thread t3(init_once, 3);
    
    t1.join();
    t2.join();
    t3.join();
}

int main() {
    cout << "=== CONCURRENCY (THREADS & MUTEX) ===" << endl;
    
    // Basic threads
    demo_basic_thread();
    demo_thread_parameters();
    demo_multiple_threads();
    demo_detach();
    
    // Mutex
    demo_race_condition();
    demo_mutex_protection();
    demo_lock_guard();
    demo_unique_lock();
    
    // Condition variables
    demo_condition_variable();
    demo_condition_variable_multiple();
    
    // Atomic
    demo_atomic();
    demo_atomic_operations();
    
    // Thread pool
    demo_thread_pool();
    
    // Safe queue
    demo_safe_queue();
    
    // Thread info
    demo_thread_info();
    
    // Deadlock
    demo_deadlock_risk();
    
    // Once flag
    demo_once_flag();
    
    return 0;
}


// Basic Threads (5 demos)

// Creating threads
// Thread parameters
// Multiple threads
// join() vs detach()
// Mutex (Mutual Exclusion) (4 demos)

// Race conditions (problem demonstration)
// Mutex protection
// lock_guard<mutex> (RAII-style locking)
// unique_lock<mutex> (more flexible)
// Condition Variables (2 demos)

// Producer-consumer pattern
// Multiple consumers with notifications
// Atomic Operations (2 demos)

// Lock-free thread-safe operations
// Atomic vs mutex comparison
// Advanced atomic operations (compare_exchange)
// Thread Pool Pattern (1 demo)

// Complete thread pool implementation
// Task queue
// Worker threads
// Safe Data Structures (1 demo)

// Thread-safe queue implementation
// push(), try_pop(), wait_pop()
// Thread Information (1 demo)

// Get thread ID
// Hardware concurrency info
// Deadlock Risk (1 demo)

// How deadlock occurs
// Prevention strategies
// Once Flag (1 demo)

// One-time initialization
// call_once() and once_flag
