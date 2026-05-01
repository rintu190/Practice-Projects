#include <iostream>
#include <vector>
#include <list>
#include <forward_list>
#include <deque>
#include <set>
#include <map>
#include <unordered_set>
#include <iterator>
#include <algorithm>

using namespace std;

// ============== INPUT ITERATOR ==============

void demo_input_iterator() {
    cout << "\n=== INPUT ITERATOR ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    vector<int>::iterator it = v.begin();
    
    // Can read: *it
    cout << "First element: " << *it << endl;  // Output: 1
    
    // Can increment: ++it
    ++it;
    cout << "Second element: " << *it << endl;  // Output: 2
}

// ============== OUTPUT ITERATOR ==============

void demo_output_iterator() {
    cout << "\n=== OUTPUT ITERATOR ===" << endl;
    vector<int> v(5);
    vector<int>::iterator it = v.begin();
    
    // Can write: *it = value
    *it = 10;
    ++it;
    *it = 20;
    ++it;
    *it = 30;
    
    cout << "Vector after writing: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

// ============== FORWARD ITERATOR ==============

void demo_forward_iterator() {
    cout << "\n=== FORWARD ITERATOR ===" << endl;
    forward_list<int> fl = {1, 2, 3, 4, 5};
    forward_list<int>::iterator it = fl.begin();
    
    // Can read and write
    cout << "First: " << *it << endl;  // Output: 1
    *it = 10;
    
    // Can only move forward
    ++it;
    cout << "Second: " << *it << endl;  // Output: 2
    
    cout << "Forward list: ";
    for (int x : fl) cout << x << " ";
    cout << endl;
}

// ============== BIDIRECTIONAL ITERATOR ==============

void demo_bidirectional_iterator() {
    cout << "\n=== BIDIRECTIONAL ITERATOR ===" << endl;
    list<int> lst = {1, 2, 3, 4, 5};
    list<int>::iterator it = lst.end();
    
    // Can move forward and backward
    --it;
    cout << "Last element: " << *it << endl;  // Output: 5
    
    ++it;
    --it;
    cout << "Still last: " << *it << endl;  // Output: 5
    
    cout << "List (forward): ";
    for (int x : lst) cout << x << " ";
    cout << endl;
}

// ============== RANDOM ACCESS ITERATOR ==============

void demo_random_access_iterator() {
    cout << "\n=== RANDOM ACCESS ITERATOR ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    vector<int>::iterator it = v.begin();
    
    // Can access any element
    cout << "Element [0]: " << it[0] << endl;  // Output: 10
    cout << "Element [2]: " << it[2] << endl;  // Output: 30
    
    // Can jump directly
    it += 3;
    cout << "After it += 3: " << *it << endl;  // Output: 40
    
    // Can compare
    cout << "it > v.begin(): " << (it > v.begin()) << endl;  // Output: 1
    cout << "it < v.end(): " << (it < v.end()) << endl;     // Output: 1
}

// ============== REVERSE ITERATOR ==============

void demo_reverse_iterator() {
    cout << "\n=== REVERSE ITERATOR ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    
    cout << "Forward: ";
    for (auto it = v.begin(); it != v.end(); ++it) {
        cout << *it << " ";  // Output: 1 2 3 4 5
    }
    cout << endl;
    
    cout << "Reverse: ";
    for (auto it = v.rbegin(); it != v.rend(); ++it) {
        cout << *it << " ";  // Output: 5 4 3 2 1
    }
    cout << endl;
}

// ============== CONST ITERATOR ==============

void demo_const_iterator() {
    cout << "\n=== CONST ITERATOR ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    
    // const_iterator - cannot modify
    vector<int>::const_iterator cit = v.begin();
    cout << "Read via const_iterator: " << *cit << endl;  // OK
    // *cit = 10;  // Error: cannot modify
    
    // cbegin() - always returns const_iterator
    auto it = v.cbegin();
    cout << "Read via cbegin(): " << *it << endl;
    
    // Reverse const iterator
    auto crit = v.crbegin();
    cout << "Reverse const: " << *crit << endl;
}

// ============== ITERATOR ADAPTERS ==============

void demo_reverse_iterator_adapter() {
    cout << "\n=== REVERSE ITERATOR ADAPTER ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    reverse_iterator<vector<int>::iterator> rit(v.end());
    
    cout << "Using reverse_iterator: ";
    while (rit != reverse_iterator<vector<int>::iterator>(v.begin())) {
        cout << *rit << " ";
        ++rit;
    }
    cout << endl;  // Output: 5 4 3 2 1
}

void demo_insert_iterator() {
    cout << "\n=== INSERT ITERATOR ===" << endl;
    vector<int> v1 = {1, 2, 3};
    vector<int> v2 = {4, 5, 6};
    
    // back_inserter - inserts at end
    copy(v2.begin(), v2.end(), back_inserter(v1));
    cout << "After back_inserter: ";
    for (int x : v1) cout << x << " ";
    cout << endl;  // Output: 1 2 3 4 5 6
    
    // front_inserter - inserts at beginning (works with deque/list)
    deque<int> v3 = {1, 2, 3};
    copy(v2.begin(), v2.end(), front_inserter(v3));
    cout << "After front_inserter: ";
    for (int x : v3) cout << x << " ";
    cout << endl;  // Output: 6 5 4 1 2 3
    
    // inserter - inserts at specific position
    vector<int> v4 = {1, 2, 3};
    copy(v2.begin(), v2.end(), inserter(v4, v4.begin() + 1));
    cout << "After inserter at pos 1: ";
    for (int x : v4) cout << x << " ";
    cout << endl;  // Output: 1 4 5 6 2 3
}

void demo_stream_iterator() {
    cout << "\n=== STREAM ITERATOR ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    
    // ostream_iterator - write to output
    cout << "Using ostream_iterator: ";
    copy(v.begin(), v.end(), ostream_iterator<int>(cout, " "));
    cout << endl;
}

// ============== ITERATOR FUNCTIONS ==============

void demo_iterator_distance() {
    cout << "\n=== distance() FUNCTION ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    
    auto it1 = v.begin();
    auto it2 = v.end();
    cout << "Distance between begin and end: " << distance(it1, it2) << endl;  // Output: 5
    
    auto it3 = v.begin() + 2;
    cout << "Distance from begin to position 2: " << distance(it1, it3) << endl;  // Output: 2
}

void demo_iterator_advance() {
    cout << "\n=== advance() FUNCTION ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    
    auto it = v.begin();
    advance(it, 2);
    cout << "After advance(it, 2): " << *it << endl;  // Output: 30
    
    advance(it, 1);
    cout << "After advance(it, 1): " << *it << endl;  // Output: 40
    
    // Negative advance (only for bidirectional/random access)
    advance(it, -1);
    cout << "After advance(it, -1): " << *it << endl;  // Output: 30
}

void demo_iterator_next() {
    cout << "\n=== next() FUNCTION ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    
    auto it = next(v.begin(), 2);
    cout << "next(v.begin(), 2): " << *it << endl;  // Output: 30
    
    auto it2 = next(v.begin(), 4);
    cout << "next(v.begin(), 4): " << *it2 << endl;  // Output: 50
}

void demo_iterator_prev() {
    cout << "\n=== prev() FUNCTION ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    
    auto it = prev(v.end(), 1);
    cout << "prev(v.end(), 1): " << *it << endl;  // Output: 50
    
    auto it2 = prev(v.end(), 3);
    cout << "prev(v.end(), 3): " << *it2 << endl;  // Output: 30
}

// ============== ITERATOR OPERATIONS BY CONTAINER ==============

void demo_vector_iterator() {
    cout << "\n=== VECTOR ITERATOR (Random Access) ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    auto it = v.begin();
    
    cout << "Arithmetic: it[2] = " << it[2] << endl;
    cout << "Comparison: it < v.end() = " << (it < v.end()) << endl;
    cout << "Subscript: *(it+3) = " << *(it + 3) << endl;
}

void demo_deque_iterator() {
    cout << "\n=== DEQUE ITERATOR (Random Access) ===" << endl;
    deque<int> dq = {10, 20, 30, 40, 50};
    auto it = dq.begin();
    
    cout << "Arithmetic: it[1] = " << it[1] << endl;
    cout << "Comparison: it < dq.end() = " << (it < dq.end()) << endl;
}

void demo_list_iterator() {
    cout << "\n=== LIST ITERATOR (Bidirectional) ===" << endl;
    list<int> lst = {10, 20, 30, 40, 50};
    auto it = lst.begin();
    
    cout << "Can move forward: ";
    ++it;
    cout << *it << endl;
    
    cout << "Can move backward: ";
    --it;
    cout << *it << endl;
    
    // Cannot do: it[2] (no random access)
    // Cannot do: it + 2 (no random access)
}

void demo_set_iterator() {
    cout << "\n=== SET ITERATOR (Bidirectional) ===" << endl;
    set<int> s = {50, 30, 10, 40, 20};
    auto it = s.begin();
    
    cout << "Set (sorted): ";
    for (int x : s) cout << x << " ";
    cout << endl;
    
    cout << "Can increment: ";
    ++it;
    cout << *it << endl;
}

void demo_map_iterator() {
    cout << "\n=== MAP ITERATOR (Bidirectional) ===" << endl;
    map<string, int> m = {{"apple", 5}, {"banana", 3}, {"orange", 7}};
    auto it = m.begin();
    
    cout << "Map (key-value pairs):" << endl;
    for (auto& p : m) {
        cout << "  " << p.first << " -> " << p.second << endl;
    }
}

void demo_unordered_set_iterator() {
    cout << "\n=== UNORDERED_SET ITERATOR (Forward) ===" << endl;
    unordered_set<int> us = {5, 2, 8, 1, 9};
    
    cout << "Unordered set (forward only): ";
    for (int x : us) cout << x << " ";
    cout << endl;
    // No reverse iteration, no random access
}

void demo_forward_list_iterator() {
    cout << "\n=== FORWARD_LIST ITERATOR (Forward) ===" << endl;
    forward_list<int> fl = {1, 2, 3, 4, 5};
    
    cout << "Forward list (forward only): ";
    for (int x : fl) cout << x << " ";
    cout << endl;
    // No reverse iteration, no bidirectional operations
}

// ============== ITERATOR COMPARISONS ==============

void demo_iterator_comparisons() {
    cout << "\n=== ITERATOR COMPARISONS ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    auto it1 = v.begin();
    auto it2 = v.begin() + 2;
    auto it3 = v.end();
    
    cout << "it1 == it1: " << (it1 == it1) << endl;  // 1
    cout << "it1 != it2: " << (it1 != it2) << endl;  // 1
    cout << "it1 < it2: " << (it1 < it2) << endl;    // 1
    cout << "it1 <= it2: " << (it1 <= it2) << endl;  // 1
    cout << "it2 > it1: " << (it2 > it1) << endl;    // 1
    cout << "it2 >= it1: " << (it2 >= it1) << endl;  // 1
}

// ============== ITERATOR ARITHMETIC ==============

void demo_iterator_arithmetic() {
    cout << "\n=== ITERATOR ARITHMETIC ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    auto it = v.begin();
    
    cout << "it + 2: " << *(it + 2) << endl;         // 30
    cout << "it + 4: " << *(it + 4) << endl;         // 50
    
    auto it2 = v.end() - 1;
    cout << "v.end() - 1: " << *it2 << endl;         // 50
    
    cout << "Distance: " << (it2 - it) << endl;      // 4
    
    // Compound assignment
    it += 2;
    cout << "After it += 2: " << *it << endl;        // 30
    
    it -= 1;
    cout << "After it -= 1: " << *it << endl;        // 20
}

int main() {
    // Non-modifying iterators
    demo_input_iterator();
    demo_output_iterator();
    demo_forward_iterator();
    demo_bidirectional_iterator();
    demo_random_access_iterator();
    
    // Reverse and const iterators
    demo_reverse_iterator();
    demo_const_iterator();
    
    // Iterator adapters
    demo_reverse_iterator_adapter();
    demo_insert_iterator();
    demo_stream_iterator();
    
    // Iterator functions
    demo_iterator_distance();
    demo_iterator_advance();
    demo_iterator_next();
    demo_iterator_prev();
    
    // Container-specific iterators
    demo_vector_iterator();
    demo_deque_iterator();
    demo_list_iterator();
    demo_set_iterator();
    demo_map_iterator();
    demo_unordered_set_iterator();
    demo_forward_list_iterator();
    
    // Iterator operations
    demo_iterator_comparisons();
    demo_iterator_arithmetic();
    
    return 0;
}
