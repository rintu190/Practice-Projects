#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>
#include <string>

using namespace std;

// ============== FUNCTION POINTERS ==============

int compare_int(int a, int b) {
    return a - b;
}

void demo_function_pointer() {
    cout << "\n=== FUNCTION POINTER ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    
    // Using function pointer
    int (*fp)(int, int) = compare_int;
    cout << "Result: " << fp(5, 3) << endl;
    
    cout << "Unsorted: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

// ============== FUNCTORS (FUNCTION OBJECTS) ==============

class Add {
public:
    int operator()(int a, int b) const {
        return a + b;
    }
};

class Multiply {
public:
    Multiply(int factor) : factor_(factor) {}
    int operator()(int x) const {
        return x * factor_;
    }
private:
    int factor_;
};

class Greater {
public:
    bool operator()(int a, int b) const {
        return a > b;
    }
};

class Person {
public:
    Person(string name, int age) : name_(name), age_(age) {}
    
    bool operator()(const Person& other) const {
        return age_ > other.age_;
    }
    
    void display() const {
        cout << "Name: " << name_ << ", Age: " << age_ << endl;
    }
private:
    string name_;
    int age_;
};

void demo_functor_basic() {
    cout << "\n=== FUNCTOR - BASIC ===" << endl;
    Add add;
    cout << "add(5, 3) = " << add(5, 3) << endl;
    
    Multiply mult(5);
    cout << "mult(4) = " << mult(4) << endl;
}

void demo_functor_with_state() {
    cout << "\n=== FUNCTOR - WITH STATE ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    
    cout << "Original: ";
    for (int x : v) cout << x << " ";
    cout << endl;
    
    // Transform using functor with state
    vector<int> v2(v.size());
    Multiply mult2(10);
    transform(v.begin(), v.end(), v2.begin(), mult2);
    
    cout << "Multiplied by 10: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
}

void demo_functor_comparator() {
    cout << "\n=== FUNCTOR - COMPARATOR ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    
    cout << "Original: ";
    for (int x : v) cout << x << " ";
    cout << endl;
    
    // Sort in descending order using functor
    sort(v.begin(), v.end(), Greater());
    
    cout << "Sorted descending: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_functor_with_objects() {
    cout << "\n=== FUNCTOR - WITH OBJECTS ===" << endl;
    vector<Person> people = {
        Person("Alice", 30),
        Person("Bob", 25),
        Person("Charlie", 35)
    };
    
    cout << "All people:" << endl;
    for (auto& p : people) p.display();
    
    // Find people older than 28
    Person filter("", 28);
    auto it = find_if(people.begin(), people.end(), filter);
    
    cout << "\nFirst person older than 28:" << endl;
    if (it != people.end()) it->display();
}

// ============== STANDARD FUNCTORS ==============

void demo_standard_functors() {
    cout << "\n=== STANDARD FUNCTORS ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    
    // plus<int>
    cout << "plus<int>(5, 3) = " << plus<int>()(5, 3) << endl;
    
    // minus<int>
    cout << "minus<int>(10, 3) = " << minus<int>()(10, 3) << endl;
    
    // multiplies<int>
    cout << "multiplies<int>(5, 6) = " << multiplies<int>()(5, 6) << endl;
    
    // divides<int>
    cout << "divides<int>(20, 4) = " << divides<int>()(20, 4) << endl;
    
    // modulus<int>
    cout << "modulus<int>(10, 3) = " << modulus<int>()(10, 3) << endl;
    
    // negate<int>
    cout << "negate<int>()(5) = " << negate<int>()(5) << endl;
    
    // greater<int>
    cout << "greater<int>()(10, 5) = " << greater<int>()(10, 5) << endl;
    
    // less<int>
    cout << "less<int>()(3, 8) = " << less<int>()(3, 8) << endl;
}

void demo_standard_functors_with_algorithms() {
    cout << "\n=== STANDARD FUNCTORS WITH ALGORITHMS ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    
    cout << "Original: ";
    for (int x : v) cout << x << " ";
    cout << endl;
    
    // Sort using greater
    sort(v.begin(), v.end(), greater<int>());
    cout << "Sorted (descending): ";
    for (int x : v) cout << x << " ";
    cout << endl;
    
    // Find using less
    vector<int> v2 = {1, 2, 3, 4, 5};
    auto it = find_if(v2.begin(), v2.end(), [](int x) { return x < 4; });
    cout << "First element < 4: " << *it << endl;
}

// ============== LAMBDA EXPRESSIONS ==============

void demo_lambda_basic() {
    cout << "\n=== LAMBDA - BASIC ===" << endl;
    
    // Simple lambda
    auto add = [](int a, int b) { return a + b; };
    cout << "add(5, 3) = " << add(5, 3) << endl;
    
    // Lambda with no parameters
    auto greet = []() { cout << "Hello from lambda!" << endl; };
    greet();
    
    // Lambda with auto parameters (C++14)
    auto mult = [](auto a, auto b) { return a * b; };
    cout << "mult(4, 5) = " << mult(4, 5) << endl;
    cout << "mult(2.5, 4) = " << mult(2.5, 4) << endl;
}

void demo_lambda_capture_by_value() {
    cout << "\n=== LAMBDA - CAPTURE BY VALUE ===" << endl;
    
    int x = 10;
    int y = 20;
    
    // Capture specific variables by value
    auto add = [x, y]() { return x + y; };
    cout << "add() = " << add() << endl;
    
    // Modify original variables (lambda copy not affected)
    x = 100;
    cout << "After modifying x, add() = " << add() << endl;  // Still 30
    
    // Capture all by value [=]
    auto multiply = [=]() { return x * y; };
    cout << "multiply() = " << multiply() << endl;
}

void demo_lambda_capture_by_reference() {
    cout << "\n=== LAMBDA - CAPTURE BY REFERENCE ===" << endl;
    
    int counter = 0;
    
    // Capture by reference
    auto increment = [&counter]() { counter++; };
    
    cout << "Initial: " << counter << endl;
    increment();
    cout << "After increment(): " << counter << endl;
    increment();
    cout << "After 2nd increment(): " << counter << endl;
    
    // Capture all by reference [&]
    int a = 5, b = 10;
    auto update = [&]() { a += 5; b += 10; };
    update();
    cout << "After update: a = " << a << ", b = " << b << endl;
}

void demo_lambda_mixed_capture() {
    cout << "\n=== LAMBDA - MIXED CAPTURE ===" << endl;
    
    int x = 10, y = 20, z = 30;
    
    // Capture x by value, others by reference
    auto compute = [x, &y, &z]() {
        cout << "x (by value) = " << x << endl;
        cout << "y (by ref) = " << y << endl;
        cout << "z (by ref) = " << z << endl;
    };
    
    compute();
    
    y = 200;
    z = 300;
    cout << "After modifying y and z:" << endl;
    compute();
}

void demo_lambda_with_algorithms() {
    cout << "\n=== LAMBDA WITH ALGORITHMS ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // find_if with lambda
    auto it = find_if(v.begin(), v.end(), [](int x) { return x > 5; });
    cout << "First element > 5: " << *it << endl;
    
    // count_if with lambda
    int cnt = count_if(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
    cout << "Even numbers: " << cnt << endl;
    
    // transform with lambda
    vector<int> v2(v.size());
    transform(v.begin(), v.end(), v2.begin(), [](int x) { return x * x; });
    cout << "Squares: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
    
    // sort with lambda
    vector<int> v3 = {30, 10, 50, 20, 40};
    sort(v3.begin(), v3.end(), [](int a, int b) { return a > b; });
    cout << "Sorted descending: ";
    for (int x : v3) cout << x << " ";
    cout << endl;
}

void demo_lambda_stateful() {
    cout << "\n=== LAMBDA - STATEFUL ===" << endl;
    
    int sum = 0;
    vector<int> v = {1, 2, 3, 4, 5};
    
    // Lambda with captured state
    for_each(v.begin(), v.end(), [&sum](int x) { sum += x; });
    cout << "Sum using lambda: " << sum << endl;
    
    // Count words
    vector<string> words = {"hello", "world", "cpp", "lambda"};
    int word_count = 0;
    for_each(words.begin(), words.end(), [&word_count](const string& w) {
        word_count++;
        cout << w << " ";
    });
    cout << "\nTotal words: " << word_count << endl;
}

// ============== PREDICATES ==============

class IsEven {
public:
    bool operator()(int x) const {
        return x % 2 == 0;
    }
};

class IsPrime {
public:
    bool operator()(int n) const {
        if (n < 2) return false;
        for (int i = 2; i * i <= n; i++) {
            if (n % i == 0) return false;
        }
        return true;
    }
};

void demo_predicate_functor() {
    cout << "\n=== PREDICATE - FUNCTOR ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Count even numbers
    IsEven is_even;
    int even_count = count_if(v.begin(), v.end(), is_even);
    cout << "Even numbers: " << even_count << endl;
    
    // Find first prime
    IsPrime is_prime;
    auto it = find_if(v.begin(), v.end(), is_prime);
    cout << "First prime: " << *it << endl;
}

void demo_predicate_lambda() {
    cout << "\n=== PREDICATE - LAMBDA ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Count numbers > 5
    int cnt = count_if(v.begin(), v.end(), [](int x) { return x > 5; });
    cout << "Numbers > 5: " << cnt << endl;
    
    // Remove odd numbers
    vector<int> v2 = v;
    auto new_end = remove_if(v2.begin(), v2.end(), [](int x) { return x % 2 != 0; });
    v2.erase(new_end, v2.end());
    cout << "After removing odds: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
}

// ============== COMPARATORS ==============

class CustomCompare {
public:
    bool operator()(const pair<string, int>& a, const pair<string, int>& b) const {
        return a.second > b.second;  // Descending by value
    }
};

void demo_comparator_functor() {
    cout << "\n=== COMPARATOR - FUNCTOR ===" << endl;
    vector<pair<string, int>> students = {
        {"Alice", 85},
        {"Bob", 92},
        {"Charlie", 78},
        {"David", 88}
    };
    
    cout << "Original: " << endl;
    for (auto& p : students) {
        cout << p.first << ": " << p.second << endl;
    }
    
    // Sort by score descending
    CustomCompare comp;
    sort(students.begin(), students.end(), comp);
    
    cout << "\nSorted by score (descending):" << endl;
    for (auto& p : students) {
        cout << p.first << ": " << p.second << endl;
    }
}

void demo_comparator_lambda() {
    cout << "\n=== COMPARATOR - LAMBDA ===" << endl;
    vector<pair<string, int>> data = {
        {"Z", 30},
        {"A", 50},
        {"M", 20}
    };
    
    cout << "Original:" << endl;
    for (auto& p : data) cout << p.first << " " << p.second << " ";
    cout << endl;
    
    // Sort by string ascending
    sort(data.begin(), data.end(), [](const auto& a, const auto& b) {
        return a.first < b.first;
    });
    
    cout << "Sorted by string:" << endl;
    for (auto& p : data) cout << p.first << " " << p.second << " ";
    cout << endl;
}

// ============== STD::FUNCTION ==============

void demo_std_function() {
    cout << "\n=== STD::FUNCTION ===" << endl;
    
    // Function pointer
    function<int(int, int)> f1 = [](int a, int b) { return a + b; };
    cout << "Lambda as function: " << f1(5, 3) << endl;
    
    // Functor
    function<int(int, int)> f2 = Add();
    cout << "Functor as function: " << f2(5, 3) << endl;
    
    // Standard functor
    function<int(int, int)> f3 = multiplies<int>();
    cout << "Standard functor: " << f3(5, 3) << endl;
    
    // Store different callables
    vector<function<int(int, int)>> operations = {
        [](int a, int b) { return a + b; },
        [](int a, int b) { return a - b; },
        [](int a, int b) { return a * b; }
    };
    
    cout << "\nUsing vector of functions:" << endl;
    cout << "Add: " << operations[0](10, 5) << endl;
    cout << "Subtract: " << operations[1](10, 5) << endl;
    cout << "Multiply: " << operations[2](10, 5) << endl;
}

// ============== BIND ==============

int add_three(int a, int b, int c) {
    return a + b + c;
}

void demo_bind() {
    cout << "\n=== BIND ===" << endl;
    
    // Bind first argument
    auto add_5 = bind(add_three, 5, placeholders::_1, placeholders::_2);
    cout << "add_5(3, 2) = " << add_5(3, 2) << endl;  // 5 + 3 + 2 = 10
    
    // Bind with functor
    auto multiply_by_10 = bind(Multiply(10), placeholders::_1);
    cout << "multiply_by_10(5) = " << multiply_by_10(5) << endl;
}

// ============== MAIN ==============

int main() {
    // Function pointers
    demo_function_pointer();
    
    // Functors
    demo_functor_basic();
    demo_functor_with_state();
    demo_functor_comparator();
    demo_functor_with_objects();
    
    // Standard functors
    demo_standard_functors();
    demo_standard_functors_with_algorithms();
    
    // Lambda expressions
    demo_lambda_basic();
    demo_lambda_capture_by_value();
    demo_lambda_capture_by_reference();
    demo_lambda_mixed_capture();
    demo_lambda_with_algorithms();
    demo_lambda_stateful();
    
    // Predicates
    demo_predicate_functor();
    demo_predicate_lambda();
    
    // Comparators
    demo_comparator_functor();
    demo_comparator_lambda();
    
    // std::function and bind
    demo_std_function();
    demo_bind();
    
    return 0;
}


// File Created: STLFunctions.cpp
// Topics Covered:
// Function Pointers (1)

// Basic function pointer usage
// Functors (Function Objects) (5)

// Basic functors
// Functors with state
// Functors as comparators
// Functors with objects
// Stateful functors
// Standard Functors (7)

// Arithmetic: plus, minus, multiplies, divides, modulus, negate
// Comparison: greater, less
// Usage with algorithms
// Lambda Expressions (6)

// Basic lambda syntax
// Capture by value [x, y]
// Capture by reference [&x, &y]
// Mixed capture [x, &y]
// Lambdas with algorithms
// Stateful lambdas
// Predicates (2)

// Unary predicate functors
// Unary predicate lambdas
// Comparators (2)

// Custom comparator functors
// Lambda comparators
// std::function (1)

// Storing different callable types
// Vector of functions
// std::bind (1)

// Binding function arguments
// Partial application
// Total: 31 Demo Functions

