#include <iostream>
#include <vector>
#include <concepts>
#include <memory>
#include <string>

using namespace std;

// ============== BUILT-IN CONCEPTS ==============

void demo_builtin_concepts() {
    cout << "\n=== BUILT-IN CONCEPTS ===" << endl;
    
    // std::integral
    static_assert(integral<int>);
    static_assert(integral<long>);
    static_assert(!integral<double>);
    cout << "int is integral: " << integral<int> << endl;
    cout << "double is integral: " << integral<double> << endl;
    
    // std::floating_point
    static_assert(floating_point<float>);
    static_assert(floating_point<double>);
    static_assert(!floating_point<int>);
    cout << "float is floating_point: " << floating_point<float> << endl;
    cout << "int is floating_point: " << floating_point<int> << endl;
    
    // std::same_as
    static_assert(same_as<int, int>);
    static_assert(!same_as<int, float>);
    cout << "int same as int: " << same_as<int, int> << endl;
    cout << "int same as float: " << same_as<int, float> << endl;
}

// ============== DERIVED CONCEPTS ==============

void demo_derived_concepts() {
    cout << "\n=== DERIVED CONCEPTS ===" << endl;
    
    // std::signed_integral
    static_assert(signed_integral<int>);
    static_assert(signed_integral<long>);
    static_assert(!signed_integral<unsigned int>);
    cout << "int is signed_integral: " << signed_integral<int> << endl;
    cout << "unsigned int is signed_integral: " << signed_integral<unsigned int> << endl;
    
    // std::unsigned_integral
    static_assert(unsigned_integral<unsigned int>);
    static_assert(!unsigned_integral<int>);
    cout << "unsigned int is unsigned_integral: " << unsigned_integral<unsigned int> << endl;
    
    // std::totally_ordered
    static_assert(totally_ordered<int>);
    static_assert(totally_ordered<double>);
    static_assert(totally_ordered<string>);
}

// ============== CUSTOM CONCEPT ==============

// Simple custom concept for numeric types
template <typename T>
concept Numeric = integral<T> || floating_point<T>;

void demo_custom_numeric_concept() {
    cout << "\n=== CUSTOM NUMERIC CONCEPT ===" << endl;
    
    static_assert(Numeric<int>);
    static_assert(Numeric<double>);
    static_assert(!Numeric<string>);
    
    cout << "int is Numeric: " << Numeric<int> << endl;
    cout << "double is Numeric: " << Numeric<double> << endl;
    cout << "string is Numeric: " << Numeric<string> << endl;
}

// ============== CONCEPT WITH REQUIREMENTS ==============

// Concept: type must be convertible to int
template <typename T>
concept ConvertibleToInt = convertible_to<T, int>;

void demo_concept_requirements() {
    cout << "\n=== CONCEPT WITH REQUIREMENTS ===" << endl;
    
    static_assert(ConvertibleToInt<int>);
    static_assert(ConvertibleToInt<bool>);
    static_assert(!ConvertibleToInt<string>);
    
    cout << "int is ConvertibleToInt: " << ConvertibleToInt<int> << endl;
    cout << "bool is ConvertibleToInt: " << ConvertibleToInt<bool> << endl;
    cout << "string is ConvertibleToInt: " << ConvertibleToInt<string> << endl;
}

// ============== COMPLEX CONCEPT ==============

template <typename T>
concept Printable = requires(T t, ostream& os) {
    { os << t } -> convertible_to<ostream&>;
};

void demo_complex_concept() {
    cout << "\n=== COMPLEX CONCEPT (PRINTABLE) ===" << endl;
    
    static_assert(Printable<int>);
    static_assert(Printable<double>);
    static_assert(Printable<string>);
    
    cout << "int is Printable: " << Printable<int> << endl;
    cout << "double is Printable: " << Printable<double> << endl;
    cout << "string is Printable: " << Printable<string> << endl;
}

// ============== USING CONCEPTS IN FUNCTIONS ==============

template <Numeric T>
T add(T a, T b) {
    return a + b;
}

void demo_concept_in_function() {
    cout << "\n=== USING CONCEPT IN FUNCTION ===" << endl;
    
    cout << "add(5, 3) = " << add(5, 3) << endl;
    cout << "add(2.5, 3.7) = " << add(2.5, 3.7) << endl;
    
    // This would not compile:
    // add("hello", "world");  // Error: string doesn't satisfy Numeric
}

// ============== MULTIPLE CONCEPTS ==============

template <typename T>
concept Addable = requires(T a, T b) {
    { a + b } -> convertible_to<T>;
};

template <typename T>
concept Multipliable = requires(T a, T b) {
    { a * b } -> convertible_to<T>;
};

template <typename T>
concept Algebraic = Addable<T> && Multipliable<T>;

template <Algebraic T>
T dotProduct(T a1, T b1, T a2, T b2) {
    return a1 * a2 + b1 * b2;
}

void demo_multiple_concepts() {
    cout << "\n=== MULTIPLE CONCEPTS ===" << endl;
    
    cout << "int is Algebraic: " << Algebraic<int> << endl;
    cout << "double is Algebraic: " << Algebraic<double> << endl;
    
    int result1 = dotProduct(2, 3, 4, 5);  // 2*4 + 3*5 = 23
    cout << "dotProduct(2, 3, 4, 5) = " << result1 << endl;
    
    double result2 = dotProduct(1.5, 2.5, 3.0, 4.0);  // 1.5*3 + 2.5*4 = 14.5
    cout << "dotProduct(1.5, 2.5, 3.0, 4.0) = " << result2 << endl;
}

// ============== REQUIRES CLAUSE ==============

template <typename T>
void processNumber(T value) requires integral<T> {
    cout << "Processing integral: " << value << endl;
}

template <typename T>
void processNumber(T value) requires floating_point<T> {
    cout << "Processing float: " << value << endl;
}

void demo_requires_clause() {
    cout << "\n=== REQUIRES CLAUSE ===" << endl;
    
    processNumber(42);
    processNumber(3.14);
}

// ============== CONCEPT WITH OPERATORS ==============

template <typename T>
concept Comparable = requires(T a, T b) {
    { a < b } -> convertible_to<bool>;
    { a > b } -> convertible_to<bool>;
    { a == b } -> convertible_to<bool>;
};

template <Comparable T>
T findMax(T a, T b) {
    return (a > b) ? a : b;
}

void demo_comparable_concept() {
    cout << "\n=== COMPARABLE CONCEPT ===" << endl;
    
    cout << "findMax(5, 10) = " << findMax(5, 10) << endl;
    cout << "findMax(3.2, 2.1) = " << findMax(3.2, 2.1) << endl;
    cout << "findMax('a', 'z') = " << findMax('a', 'z') << endl;
}

// ============== CONTAINER CONCEPT ==============

template <typename T>
concept Container = requires(T c) {
    typename T::value_type;
    typename T::iterator;
    typename T::const_iterator;
    { c.begin() } -> convertible_to<typename T::iterator>;
    { c.end() } -> convertible_to<typename T::iterator>;
    { c.size() } -> convertible_to<size_t>;
};

template <Container C>
void printContainer(const C& container) {
    cout << "Container (size " << container.size() << "): ";
    for (const auto& item : container) {
        cout << item << " ";
    }
    cout << endl;
}

void demo_container_concept() {
    cout << "\n=== CONTAINER CONCEPT ===" << endl;
    
    vector<int> v = {1, 2, 3, 4, 5};
    printContainer(v);
    
    cout << "vector<int> is Container: " << Container<vector<int>> << endl;
}

// ============== FUNCTION CONCEPT ==============

template <typename T>
concept Callable = requires(T f) {
    { f() } -> convertible_to<void>;
};

template <Callable F>
void executeCallable(F f) {
    cout << "Executing callable..." << endl;
    f();
}

void demo_callable_concept() {
    cout << "\n=== CALLABLE CONCEPT ===" << endl;
    
    auto lambda = []() { cout << "  Lambda executed!" << endl; };
    executeCallable(lambda);
    
    cout << "Lambda is Callable: " << Callable<decltype(lambda)> << endl;
}

// ============== POINTER CONCEPT ==============

template <typename T>
concept Pointer = requires(T p) {
    { *p };
    { p.operator->() };
};

void demo_pointer_concept() {
    cout << "\n=== POINTER CONCEPT ===" << endl;
    
    int x = 42;
    int* ptr = &x;
    
    cout << "int* is Pointer: " << Pointer<int*> << endl;
    cout << "int is Pointer: " << Pointer<int> << endl;
    
    // Dereferencing
    cout << "Dereferencing int*: " << *ptr << endl;
}

// ============== ITERATOR CONCEPT ==============

template <typename T>
concept InputIterator = requires(T it) {
    typename T::value_type;
    typename T::difference_type;
    typename T::reference;
    typename T::pointer;
    typename T::iterator_category;
};

void demo_iterator_concept() {
    cout << "\n=== ITERATOR CONCEPT ===" << endl;
    
    vector<int> v = {1, 2, 3};
    
    cout << "vector<int>::iterator is InputIterator: " 
         << InputIterator<vector<int>::iterator> << endl;
    
    auto it = v.begin();
    cout << "Dereferencing: " << *it << endl;
}

int main() {
    cout << "=== CONCEPTS (C++20 CONCEPTS) ===" << endl;
    
    // Built-in concepts
    demo_builtin_concepts();
    
    // Derived concepts
    demo_derived_concepts();
    
    // Custom concept
    demo_custom_numeric_concept();
    
    // Concept requirements
    demo_concept_requirements();
    
    // Complex concept
    demo_complex_concept();
    
    // Using concepts in functions
    demo_concept_in_function();
    
    // Multiple concepts
    demo_multiple_concepts();
    
    // Requires clause
    demo_requires_clause();
    
    // Comparable concept
    demo_comparable_concept();
    
    // Container concept
    demo_container_concept();
    
    // Callable concept
    demo_callable_concept();
    
    // Pointer concept
    demo_pointer_concept();
    
    // Iterator concept
    demo_iterator_concept();
    
    return 0;
}
