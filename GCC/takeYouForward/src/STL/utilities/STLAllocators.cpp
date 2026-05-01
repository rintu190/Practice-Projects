#include <iostream>
#include <vector>
#include <memory>
#include <list>
#include <map>

using namespace std;

// ============== DEFAULT ALLOCATOR ==============

void demo_default_allocator() {
    cout << "\n=== DEFAULT ALLOCATOR ===" << endl;
    
    // std::allocator is the default
    vector<int> v1 = {1, 2, 3, 4, 5};
    cout << "Vector with default allocator: ";
    for (int x : v1) cout << x << " ";
    cout << endl;
    
    // Get allocator
    auto alloc = v1.get_allocator();
    cout << "Allocator type: " << typeid(alloc).name() << endl;
}

// ============== CUSTOM ALLOCATOR ==============

template <typename T>
class CountingAllocator {
public:
    using value_type = T;
    
    static int allocation_count;
    static int deallocation_count;
    
    CountingAllocator() {
        cout << "  CountingAllocator created" << endl;
    }
    
    T* allocate(size_t n) {
        cout << "  Allocating " << n << " elements" << endl;
        allocation_count++;
        return new T[n];
    }
    
    void deallocate(T* p, size_t n) {
        cout << "  Deallocating " << n << " elements" << endl;
        deallocation_count++;
        delete[] p;
    }
    
    bool operator==(const CountingAllocator& other) const {
        return true;
    }
    
    bool operator!=(const CountingAllocator& other) const {
        return false;
    }
};

template <typename T>
int CountingAllocator<T>::allocation_count = 0;

template <typename T>
int CountingAllocator<T>::deallocation_count = 0;

void demo_custom_allocator() {
    cout << "\n=== CUSTOM ALLOCATOR ===" << endl;
    
    {
        cout << "Creating vector with CountingAllocator:" << endl;
        vector<int, CountingAllocator<int>> v;
        
        cout << "Pushing elements:" << endl;
        for (int i = 0; i < 5; i++) {
            v.push_back(i);
        }
        
        cout << "Vector size: " << v.size() << endl;
        cout << "Vector capacity: " << v.capacity() << endl;
    }
    
    cout << "Total allocations: " << CountingAllocator<int>::allocation_count << endl;
    cout << "Total deallocations: " << CountingAllocator<int>::deallocation_count << endl;
}

// ============== POOL ALLOCATOR ==============

template <typename T>
class PoolAllocator {
private:
    static const size_t POOL_SIZE = 100;
    T* pool[POOL_SIZE];
    int pool_index = 0;
    
public:
    using value_type = T;
    
    PoolAllocator() {
        cout << "  Pool initialized with " << POOL_SIZE << " slots" << endl;
        for (int i = 0; i < POOL_SIZE; i++) {
            pool[i] = nullptr;
        }
    }
    
    T* allocate(size_t n) {
        if (pool_index < POOL_SIZE) {
            pool[pool_index] = new T[n];
            cout << "  Allocated from pool slot " << pool_index << endl;
            return pool[pool_index++];
        } else {
            cout << "  Pool exhausted! Using new" << endl;
            return new T[n];
        }
    }
    
    void deallocate(T* p, size_t n) {
        cout << "  Deallocating (returning to pool)" << endl;
        // In real implementation, mark as reusable
        delete[] p;
    }
    
    bool operator==(const PoolAllocator& other) const {
        return true;
    }
    
    bool operator!=(const PoolAllocator& other) const {
        return false;
    }
};

void demo_pool_allocator() {
    cout << "\n=== POOL ALLOCATOR ===" << endl;
    
    cout << "Creating vectors with PoolAllocator:" << endl;
    
    {
        vector<int, PoolAllocator<int>> v1;
        v1.push_back(10);
        v1.push_back(20);
        
        vector<int, PoolAllocator<int>> v2;
        v2.push_back(30);
        v2.push_back(40);
    }
    
    cout << "Vectors destroyed" << endl;
}

// ============== ALIGNED ALLOCATOR ==============

template <typename T>
class AlignedAllocator {
private:
    static const size_t ALIGNMENT = 32;  // 32-byte alignment for SIMD
    
public:
    using value_type = T;
    
    T* allocate(size_t n) {
        cout << "  Allocating " << n << " elements with " 
             << ALIGNMENT << "-byte alignment" << endl;
        
        size_t size = n * sizeof(T);
        void* ptr = nullptr;
        
        #ifdef _WIN32
            ptr = _aligned_malloc(size, ALIGNMENT);
        #else
            posix_memalign(&ptr, ALIGNMENT, size);
        #endif
        
        if (!ptr) throw bad_alloc();
        return static_cast<T*>(ptr);
    }
    
    void deallocate(T* p, size_t n) {
        cout << "  Deallocating aligned memory" << endl;
        
        #ifdef _WIN32
            _aligned_free(p);
        #else
            free(p);
        #endif
    }
    
    bool operator==(const AlignedAllocator& other) const {
        return true;
    }
    
    bool operator!=(const AlignedAllocator& other) const {
        return false;
    }
};

void demo_aligned_allocator() {
    cout << "\n=== ALIGNED ALLOCATOR ===" << endl;
    
    cout << "Creating vector with aligned allocator:" << endl;
    
    try {
        vector<double, AlignedAllocator<double>> v;
        
        for (int i = 0; i < 5; i++) {
            v.push_back(i * 1.5);
        }
        
        cout << "Vector created with " << v.size() << " elements" << endl;
        cout << "Memory is aligned for SIMD operations" << endl;
    } catch (const exception& e) {
        cout << "Error: " << e.what() << endl;
    }
}

// ============== STATEFUL ALLOCATOR ==============

template <typename T>
class StatefulAllocator {
private:
    int id;
    
public:
    using value_type = T;
    
    StatefulAllocator(int id = 0) : id(id) {
        cout << "  StatefulAllocator " << id << " created" << endl;
    }
    
    StatefulAllocator(const StatefulAllocator& other) : id(other.id) {
        cout << "  StatefulAllocator " << id << " copied" << endl;
    }
    
    template <typename U>
    StatefulAllocator(const StatefulAllocator<U>& other) : id(other.id) {}
    
    T* allocate(size_t n) {
        cout << "  Allocator " << id << " allocating " << n << " elements" << endl;
        return new T[n];
    }
    
    void deallocate(T* p, size_t n) {
        cout << "  Allocator " << id << " deallocating " << n << " elements" << endl;
        delete[] p;
    }
    
    bool operator==(const StatefulAllocator& other) const {
        return id == other.id;
    }
    
    bool operator!=(const StatefulAllocator& other) const {
        return id != other.id;
    }
    
    template <typename U>
    friend class StatefulAllocator;
};

void demo_stateful_allocator() {
    cout << "\n=== STATEFUL ALLOCATOR ===" << endl;
    
    {
        cout << "Vector with StatefulAllocator(1):" << endl;
        vector<int, StatefulAllocator<int>> v(StatefulAllocator<int>(1));
        v.push_back(10);
        v.push_back(20);
    }
    
    cout << "\nVector with StatefulAllocator(2):" << endl;
    {
        vector<int, StatefulAllocator<int>> v(StatefulAllocator<int>(2));
        v.push_back(30);
        v.push_back(40);
    }
}

// ============== ALLOCATOR WITH DIFFERENT CONTAINERS ==============

void demo_allocator_with_list() {
    cout << "\n=== ALLOCATOR WITH LIST ===" << endl;
    
    cout << "Creating list with CountingAllocator:" << endl;
    
    {
        list<int, CountingAllocator<int>> lst;
        lst.push_back(1);
        lst.push_back(2);
        lst.push_back(3);
        
        cout << "List size: " << lst.size() << endl;
    }
}

void demo_allocator_with_map() {
    cout << "\n=== ALLOCATOR WITH MAP ===" << endl;
    
    cout << "Creating map with CountingAllocator:" << endl;
    
    {
        using pair_type = pair<const int, string>;
        map<int, string, less<int>, CountingAllocator<pair_type>> m;
        
        m[1] = "one";
        m[2] = "two";
        m[3] = "three";
        
        cout << "Map size: " << m.size() << endl;
    }
}

// ============== MEMORY TRAITS ==============

void demo_allocator_traits() {
    cout << "\n=== ALLOCATOR TRAITS ===" << endl;
    
    using MyAllocator = CountingAllocator<int>;
    using traits = allocator_traits<MyAllocator>;
    
    cout << "Value type: " << typeid(traits::value_type).name() << endl;
    cout << "Pointer type: " << typeid(traits::pointer).name() << endl;
    cout << "Size type: " << typeid(traits::size_type).name() << endl;
    
    MyAllocator alloc;
    
    // Allocate using traits
    auto ptr = traits::allocate(alloc, 5);
    cout << "Allocated 5 elements at: " << ptr << endl;
    
    traits::deallocate(alloc, ptr, 5);
    cout << "Deallocated" << endl;
}

int main() {
    cout << "=== ALLOCATORS (CUSTOM MEMORY ALLOCATION) ===" << endl;
    
    // Default allocator
    demo_default_allocator();
    
    // Custom allocators
    demo_custom_allocator();
    demo_pool_allocator();
    demo_aligned_allocator();
    demo_stateful_allocator();
    
    // With different containers
    demo_allocator_with_list();
    demo_allocator_with_map();
    
    // Allocator traits
    demo_allocator_traits();
    
    return 0;
}
