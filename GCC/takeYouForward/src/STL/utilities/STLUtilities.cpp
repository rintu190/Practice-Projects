#include <iostream>
#include <utility>
#include <tuple>
#include <vector>
#include <algorithm>

using namespace std;

// ============== STD::PAIR ==============

void demo_pair_creation() {
    cout << "\n=== PAIR CREATION ===" << endl;
    
    // Default construction
    pair<int, string> p1;
    cout << "Default: (" << p1.first << ", " << p1.second << ")" << endl;
    
    // Direct initialization
    pair<int, string> p2(42, "Hello");
    cout << "Direct init: (" << p2.first << ", " << p2.second << ")" << endl;
    
    // Copy construction
    pair<int, string> p3 = p2;
    cout << "Copy: (" << p3.first << ", " << p3.second << ")" << endl;
    
    // Using make_pair
    auto p4 = make_pair(100, "World");
    cout << "make_pair: (" << p4.first << ", " << p4.second << ")" << endl;
    
    // Brace initialization (C++17)
    pair<int, string> p5{99, "Braces"};
    cout << "Brace init: (" << p5.first << ", " << p5.second << ")" << endl;
}

void demo_pair_access() {
    cout << "\n=== PAIR ACCESS ===" << endl;
    
    pair<string, int> person = {"Alice", 30};
    
    cout << "Name: " << person.first << endl;
    cout << "Age: " << person.second << endl;
    
    // Modify
    person.first = "Bob";
    person.second = 25;
    cout << "Modified: " << person.first << ", " << person.second << endl;
}

void demo_pair_comparison() {
    cout << "\n=== PAIR COMPARISON ===" << endl;
    
    pair<int, string> p1{1, "one"};
    pair<int, string> p2{1, "one"};
    pair<int, string> p3{2, "two"};
    
    cout << "p1 == p2: " << (p1 == p2 ? "true" : "false") << endl;
    cout << "p1 != p3: " << (p1 != p3 ? "true" : "false") << endl;
    cout << "p1 < p3: " << (p1 < p3 ? "true" : "false") << endl;
    
    // Lexicographic comparison
    pair<int, int> a{1, 5};
    pair<int, int> b{1, 3};
    cout << "a > b (lexicographic): " << (a > b ? "true" : "false") << endl;
}

void demo_pair_with_containers() {
    cout << "\n=== PAIR WITH CONTAINERS ===" << endl;
    
    vector<pair<string, int>> students = {
        {"Alice", 85},
        {"Bob", 92},
        {"Charlie", 78}
    };
    
    cout << "Students:" << endl;
    for (auto& p : students) {
        cout << "  " << p.first << ": " << p.second << endl;
    }
    
    // Sort by score
    sort(students.begin(), students.end(), 
         [](const auto& a, const auto& b) { return a.second > b.second; });
    
    cout << "\nSorted by score:" << endl;
    for (auto& p : students) {
        cout << "  " << p.first << ": " << p.second << endl;
    }
}

// ============== STD::TUPLE ==============

void demo_tuple_creation() {
    cout << "\n=== TUPLE CREATION ===" << endl;
    
    // Default construction
    tuple<int, string, double> t1;
    cout << "Default tuple created" << endl;
    
    // Direct initialization
    tuple<int, string, double> t2(42, "Hello", 3.14);
    cout << "Direct init: (" << get<0>(t2) << ", " << get<1>(t2) 
         << ", " << get<2>(t2) << ")" << endl;
    
    // make_tuple
    auto t3 = make_tuple(100, "World", 2.71);
    cout << "make_tuple: (" << get<0>(t3) << ", " << get<1>(t3) 
         << ", " << get<2>(t3) << ")" << endl;
    
    // Empty tuple
    tuple<> t4;
    cout << "Empty tuple created" << endl;
    
    // Single element
    auto t5 = make_tuple(99);
    cout << "Single element: " << get<0>(t5) << endl;
}

void demo_tuple_access() {
    cout << "\n=== TUPLE ACCESS ===" << endl;
    
    tuple<int, string, double> t = {42, "Answer", 3.14};
    
    // Access by index
    cout << "Element 0: " << get<0>(t) << endl;
    cout << "Element 1: " << get<1>(t) << endl;
    cout << "Element 2: " << get<2>(t) << endl;
    
    // Modify
    get<0>(t) = 100;
    get<1>(t) = "Modified";
    cout << "After modification: (" << get<0>(t) << ", " << get<1>(t) 
         << ", " << get<2>(t) << ")" << endl;
    
    // Size
    cout << "Tuple size: " << tuple_size<decltype(t)>::value << endl;
}

void demo_tuple_structured_binding() {
    cout << "\n=== TUPLE STRUCTURED BINDING (C++17) ===" << endl;
    
    tuple<int, string, double> t = {42, "Hello", 3.14};
    
    // Structured binding
    auto [num, str, dbl] = t;
    cout << "num: " << num << endl;
    cout << "str: " << str << endl;
    cout << "dbl: " << dbl << endl;
    
    // Modify through binding
    auto [a, b, c] = t;
    a = 999;
    cout << "After modification (local copy): " << get<0>(t) << endl;  // Original unchanged
}

void demo_tuple_comparison() {
    cout << "\n=== TUPLE COMPARISON ===" << endl;
    
    tuple<int, string> t1{1, "one"};
    tuple<int, string> t2{1, "one"};
    tuple<int, string> t3{2, "two"};
    
    cout << "t1 == t2: " << (t1 == t2 ? "true" : "false") << endl;
    cout << "t1 != t3: " << (t1 != t3 ? "true" : "false") << endl;
    cout << "t1 < t3: " << (t1 < t3 ? "true" : "false") << endl;
}

void demo_tuple_unpacking() {
    cout << "\n=== TUPLE UNPACKING ===" << endl;
    
    // Return multiple values
    auto create_person = []() -> tuple<string, int, string> {
        return make_tuple("Alice", 30, "Engineer");
    };
    
    auto [name, age, job] = create_person();
    cout << "Name: " << name << ", Age: " << age << ", Job: " << job << endl;
}

void demo_tuple_with_containers() {
    cout << "\n=== TUPLE WITH CONTAINERS ===" << endl;
    
    vector<tuple<string, int, double>> data = {
        {"Alice", 85, 4.0},
        {"Bob", 92, 3.8},
        {"Charlie", 78, 3.5}
    };
    
    cout << "Data:" << endl;
    for (auto& t : data) {
        cout << "  " << get<0>(t) << ": " << get<1>(t) 
             << " (" << get<2>(t) << ")" << endl;
    }
}

void demo_tuple_functions() {
    cout << "\n=== TUPLE FUNCTIONS ===" << endl;
    
    tuple<int, double, string> t1{1, 1.5, "one"};
    tuple<int, double, string> t2{2, 2.5, "two"};
    
    // tuple_cat - concatenate tuples
    auto combined = tuple_cat(t1, t2);
    cout << "Combined tuple size: " << tuple_size<decltype(combined)>::value << endl;
    
    // Forward tuple
    auto forward_tuple = forward_as_tuple(3, 3.5, "three");
    cout << "Forward tuple created" << endl;
}

// ============== PAIR VS TUPLE ==============

void demo_pair_vs_tuple() {
    cout << "\n=== PAIR VS TUPLE ===" << endl;
    
    // Pair - 2 elements
    auto p = make_pair(42, "Hello");
    cout << "Pair (2): (" << p.first << ", " << p.second << ")" << endl;
    
    // Tuple - any number of elements
    auto t = make_tuple(42, "Hello", 3.14, true);
    cout << "Tuple (4): (" << get<0>(t) << ", " << get<1>(t) 
         << ", " << get<2>(t) << ", " << get<3>(t) << ")" << endl;
    
    // Pair is simpler, Tuple is more flexible
    cout << "Use Pair for 2 values, Tuple for multiple values" << endl;
}

int main() {
    // Pair demonstrations
    demo_pair_creation();
    demo_pair_access();
    demo_pair_comparison();
    demo_pair_with_containers();
    
    // Tuple demonstrations
    demo_tuple_creation();
    demo_tuple_access();
    demo_tuple_structured_binding();
    demo_tuple_comparison();
    demo_tuple_unpacking();
    demo_tuple_with_containers();
    demo_tuple_functions();
    
    // Comparison
    demo_pair_vs_tuple();
    
    return 0;
}
