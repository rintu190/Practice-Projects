#include <iostream>
#include <memory>
#include <vector>

using namespace std;

// ============== UNIQUE_PTR ==============

class Resource {
public:
    Resource(int id) : id_(id) { cout << "Resource " << id_ << " created" << endl; }
    ~Resource() { cout << "Resource " << id_ << " destroyed" << endl; }
    
    void display() { cout << "Resource " << id_ << endl; }
    
private:
    int id_;
};

void demo_unique_ptr_basics() {
    cout << "\n=== UNIQUE_PTR BASICS ===" << endl;
    
    // Create unique_ptr
    unique_ptr<Resource> ptr1(new Resource(1));
    
    // Access
    ptr1->display();
    
    // Use get() to get raw pointer
    cout << "Raw pointer: " << ptr1.get() << endl;
    
    // Dereferencing
    (*ptr1).display();
    
    cout << "Resource will be deleted here:" << endl;
}  // Automatic deletion

void demo_unique_ptr_make_unique() {
    cout << "\n=== UNIQUE_PTR - MAKE_UNIQUE ===" << endl;
    
    // Preferred way - make_unique
    auto ptr = make_unique<Resource>(2);
    
    ptr->display();
    
    cout << "Resource will be deleted here:" << endl;
}  // Automatic deletion

void demo_unique_ptr_move() {
    cout << "\n=== UNIQUE_PTR - MOVE SEMANTICS ===" << endl;
    
    unique_ptr<Resource> ptr1 = make_unique<Resource>(3);
    
    cout << "Before move:" << endl;
    cout << "ptr1 owns resource: " << (ptr1 != nullptr ? "yes" : "no") << endl;
    
    // Move ownership
    unique_ptr<Resource> ptr2 = move(ptr1);
    
    cout << "After move:" << endl;
    cout << "ptr1 owns resource: " << (ptr1 != nullptr ? "yes" : "no") << endl;
    cout << "ptr2 owns resource: " << (ptr2 != nullptr ? "yes" : "no") << endl;
    
    cout << "Resources will be deleted here:" << endl;
}  // Only ptr2's resource deleted

void demo_unique_ptr_array() {
    cout << "\n=== UNIQUE_PTR - ARRAY ===" << endl;
    
    // Array specialization
    unique_ptr<int[]> arr(new int[5]);
    
    for (int i = 0; i < 5; i++) {
        arr[i] = i * 10;
    }
    
    cout << "Array values: ";
    for (int i = 0; i < 5; i++) {
        cout << arr[i] << " ";
    }
    cout << endl;
    
    cout << "Array will be deleted here:" << endl;
}  // Automatic array deletion

void demo_unique_ptr_functions() {
    cout << "\n=== UNIQUE_PTR - RELEASE & RESET ===" << endl;
    
    auto ptr1 = make_unique<Resource>(4);
    
    // Release ownership
    Resource* raw = ptr1.release();
    cout << "After release, ptr1 is: " << (ptr1 == nullptr ? "null" : "not null") << endl;
    
    // Manual cleanup
    delete raw;
    
    // Reset
    auto ptr2 = make_unique<Resource>(5);
    cout << "Before reset" << endl;
    ptr2.reset();
    cout << "After reset, ptr2 is: " << (ptr2 == nullptr ? "null" : "not null") << endl;
}

// ============== SHARED_PTR ==============

void demo_shared_ptr_basics() {
    cout << "\n=== SHARED_PTR BASICS ===" << endl;
    
    // Create shared_ptr
    shared_ptr<Resource> ptr1(new Resource(6));
    cout << "Reference count: " << ptr1.use_count() << endl;
    
    // Copy - increases reference count
    shared_ptr<Resource> ptr2 = ptr1;
    cout << "After copy, reference count: " << ptr1.use_count() << endl;
    
    ptr1->display();
    ptr2->display();
    
    cout << "Resource still alive (multiple owners)" << endl;
}  // Deleted when last owner destroyed

void demo_shared_ptr_make_shared() {
    cout << "\n=== SHARED_PTR - MAKE_SHARED ===" << endl;
    
    // Preferred way - more efficient
    auto ptr1 = make_shared<Resource>(7);
    cout << "Reference count: " << ptr1.use_count() << endl;
    
    // Share ownership
    auto ptr2 = ptr1;
    auto ptr3 = ptr1;
    cout << "After 2 copies, count: " << ptr1.use_count() << endl;
    
    cout << "All pointers point to same resource" << endl;
}  // Deleted when last pointer destroyed

void demo_shared_ptr_containers() {
    cout << "\n=== SHARED_PTR - CONTAINERS ===" << endl;
    
    vector<shared_ptr<Resource>> resources;
    
    for (int i = 8; i < 11; i++) {
        resources.push_back(make_shared<Resource>(i));
    }
    
    cout << "Created " << resources.size() << " resources" << endl;
    
    // Access
    resources[0]->display();
    
    cout << "Clearing vector:" << endl;
    resources.clear();
    cout << "All resources deleted" << endl;
}

void demo_shared_ptr_circular_reference() {
    cout << "\n=== SHARED_PTR - CIRCULAR REFERENCE PROBLEM ===" << endl;
    
    // This demonstrates potential circular reference issue
    // Solution is to use weak_ptr
    
    struct Node {
        int data;
        shared_ptr<Node> next;
        
        Node(int d) : data(d) { cout << "Node " << d << " created" << endl; }
        ~Node() { cout << "Node " << data << " destroyed" << endl; }
    };
    
    auto node1 = make_shared<Node>(100);
    auto node2 = make_shared<Node>(200);
    
    // Creating circular reference
    node1->next = node2;
    // node2->next = node1;  // This would create circular reference!
    
    cout << "node1 ref count: " << node1.use_count() << endl;
    cout << "node2 ref count: " << node2.use_count() << endl;
    
    cout << "Leaving scope:" << endl;
}  // Both deleted

void demo_weak_ptr() {
    cout << "\n=== WEAK_PTR ===" << endl;
    
    struct Node {
        int data;
        shared_ptr<Node> next;
        weak_ptr<Node> prev;  // Use weak_ptr to avoid circular reference
        
        Node(int d) : data(d) { cout << "Node " << d << " created" << endl; }
        ~Node() { cout << "Node " << data << " destroyed" << endl; }
    };
    
    auto node1 = make_shared<Node>(300);
    auto node2 = make_shared<Node>(400);
    
    node1->next = node2;
    node2->prev = node1;  // weak_ptr - doesn't increase count
    
    cout << "node1 ref count: " << node1.use_count() << endl;  // 1
    cout << "node2 ref count: " << node2.use_count() << endl;  // 1
    
    // Convert weak_ptr to shared_ptr when needed
    if (auto prev = node2->prev.lock()) {
        cout << "Previous node data: " << prev->data << endl;
    }
    
    cout << "Leaving scope:" << endl;
}  // No circular reference, both deleted

// ============== CUSTOM DELETERS ==============

void demo_custom_deleter() {
    cout << "\n=== CUSTOM DELETER ===" << endl;
    
    // Custom deleter function
    auto deleter = [](Resource* r) {
        cout << "Custom deleter called" << endl;
        delete r;
    };
    
    unique_ptr<Resource, decltype(deleter)> ptr(new Resource(11), deleter);
    
    cout << "Custom deleter will be used:" << endl;
}  // Custom deleter called

// ============== POINTER CONVERSIONS ==============

class Base {
public:
    virtual ~Base() { cout << "Base destroyed" << endl; }
    virtual void display() { cout << "Base" << endl; }
};

class Derived : public Base {
public:
    ~Derived() { cout << "Derived destroyed" << endl; }
    void display() override { cout << "Derived" << endl; }
};

void demo_smart_ptr_casting() {
    cout << "\n=== SMART POINTER CASTING ===" << endl;
    
    // dynamic_pointer_cast
    auto ptr = make_shared<Derived>();
    ptr->display();
    
    shared_ptr<Base> base_ptr = ptr;
    base_ptr->display();
    
    // Cast back
    if (auto derived = dynamic_pointer_cast<Derived>(base_ptr)) {
        cout << "Successfully cast to Derived" << endl;
        derived->display();
    }
    
    cout << "Pointers destroyed:" << endl;
}

// ============== BEST PRACTICES ==============

void demo_best_practices() {
    cout << "\n=== BEST PRACTICES ===" << endl;
    
    cout << "1. Use make_unique/make_shared (safer, more efficient)" << endl;
    cout << "2. Use unique_ptr for exclusive ownership" << endl;
    cout << "3. Use shared_ptr for shared ownership" << endl;
    cout << "4. Use weak_ptr to break circular references" << endl;
    cout << "5. Avoid raw pointers in modern C++" << endl;
    
    auto up = make_unique<Resource>(12);
    auto sp = make_shared<Resource>(13);
    
    cout << "Example of best practice:" << endl;
}  // Automatic cleanup

int main() {
    cout << "=== SMART POINTERS ===" << endl;
    
    // unique_ptr
    demo_unique_ptr_basics();
    demo_unique_ptr_make_unique();
    demo_unique_ptr_move();
    demo_unique_ptr_array();
    demo_unique_ptr_functions();
    
    // shared_ptr
    demo_shared_ptr_basics();
    demo_shared_ptr_make_shared();
    demo_shared_ptr_containers();
    demo_shared_ptr_circular_reference();
    
    // weak_ptr
    demo_weak_ptr();
    
    // Custom deleters
    demo_custom_deleter();
    
    // Casting
    demo_smart_ptr_casting();
    
    // Best practices
    demo_best_practices();
    
    return 0;
}
