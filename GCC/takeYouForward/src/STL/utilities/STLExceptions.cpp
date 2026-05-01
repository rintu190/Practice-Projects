#include <iostream>
#include <exception>
#include <stdexcept>
#include <string>
#include <vector>

using namespace std;

// ============== STANDARD EXCEPTIONS ==============

void demo_standard_exceptions() {
    cout << "\n=== STANDARD EXCEPTIONS ===" << endl;
    
    // logic_error
    cout << "logic_error: " << endl;
    try {
        throw logic_error("Logic error occurred");
    } catch (const logic_error& e) {
        cout << "  Caught: " << e.what() << endl;
    }
    
    // runtime_error
    cout << "runtime_error: " << endl;
    try {
        throw runtime_error("Runtime error occurred");
    } catch (const runtime_error& e) {
        cout << "  Caught: " << e.what() << endl;
    }
    
    // invalid_argument
    cout << "invalid_argument: " << endl;
    try {
        throw invalid_argument("Invalid argument");
    } catch (const invalid_argument& e) {
        cout << "  Caught: " << e.what() << endl;
    }
    
    // out_of_range
    cout << "out_of_range: " << endl;
    try {
        throw out_of_range("Out of range");
    } catch (const out_of_range& e) {
        cout << "  Caught: " << e.what() << endl;
    }
    
    // bad_alloc
    cout << "bad_alloc: " << endl;
    try {
        // Rarely caught, but example:
        throw bad_alloc();
    } catch (const bad_alloc& e) {
        cout << "  Caught: Memory allocation failed" << endl;
    }
}

// ============== CUSTOM EXCEPTIONS ==============

class CustomException : public exception {
private:
    string message_;
    
public:
    CustomException(const string& msg) : message_(msg) {}
    
    const char* what() const noexcept override {
        return message_.c_str();
    }
};

class DivideByZeroException : public runtime_error {
public:
    DivideByZeroException() : runtime_error("Division by zero!") {}
};

class NegativeValueException : public logic_error {
private:
    int value_;
    
public:
    NegativeValueException(int val) 
        : logic_error("Negative value not allowed: " + to_string(val)), 
          value_(val) {}
    
    int getValue() const { return value_; }
};

void demo_custom_exception_basic() {
    cout << "\n=== CUSTOM EXCEPTION - BASIC ===" << endl;
    
    try {
        throw CustomException("Something went wrong!");
    } catch (const CustomException& e) {
        cout << "Caught custom exception: " << e.what() << endl;
    }
}

void demo_custom_exception_derived() {
    cout << "\n=== CUSTOM EXCEPTION - DERIVED ===" << endl;
    
    // Division by zero
    try {
        int numerator = 10;
        int denominator = 0;
        
        if (denominator == 0) {
            throw DivideByZeroException();
        }
        
        cout << numerator / denominator << endl;
    } catch (const DivideByZeroException& e) {
        cout << "Caught: " << e.what() << endl;
    }
    
    // Negative value
    try {
        int value = -5;
        
        if (value < 0) {
            throw NegativeValueException(value);
        }
    } catch (const NegativeValueException& e) {
        cout << "Caught: " << e.what() << endl;
        cout << "Invalid value was: " << e.getValue() << endl;
    }
}

// ============== TRY-CATCH BASICS ==============

void demo_try_catch_basics() {
    cout << "\n=== TRY-CATCH BASICS ===" << endl;
    
    try {
        cout << "In try block" << endl;
        throw runtime_error("Error in try block");
        cout << "This won't execute" << endl;
    } catch (const exception& e) {
        cout << "Caught in catch: " << e.what() << endl;
    }
    cout << "After catch block" << endl;
}

void demo_multiple_catch() {
    cout << "\n=== MULTIPLE CATCH ===" << endl;
    
    vector<int> values = {1, 2, 0, 3};
    
    for (int denominator : values) {
        try {
            if (denominator == 0) {
                throw invalid_argument("Zero denominator");
            } else if (denominator < 0) {
                throw out_of_range("Negative denominator");
            }
            
            cout << "10 / " << denominator << " = " << 10 / denominator << endl;
        } catch (const invalid_argument& e) {
            cout << "  Invalid argument: " << e.what() << endl;
        } catch (const out_of_range& e) {
            cout << "  Out of range: " << e.what() << endl;
        } catch (const exception& e) {
            cout << "  Other exception: " << e.what() << endl;
        }
    }
}

void demo_catch_by_value_vs_reference() {
    cout << "\n=== CATCH BY VALUE VS REFERENCE ===" << endl;
    
    // Catch by reference (preferred)
    try {
        throw runtime_error("Error 1");
    } catch (const runtime_error& e) {
        cout << "Caught by reference: " << e.what() << endl;
    }
    
    // Catch by value (less efficient, object is copied)
    try {
        throw runtime_error("Error 2");
    } catch (runtime_error e) {
        cout << "Caught by value: " << e.what() << endl;
    }
    
    // Never catch by pointer
    // try {
    //     throw runtime_error("Error");
    // } catch (runtime_error* e) {  // Bad!
    //     cout << e->what() << endl;
    // }
}

void demo_exception_hierarchy() {
    cout << "\n=== EXCEPTION HIERARCHY ===" << endl;
    
    // Catch derived before base
    try {
        throw out_of_range("Out of range!");
    } catch (const out_of_range& e) {  // Derived
        cout << "Caught out_of_range: " << e.what() << endl;
    } catch (const logic_error& e) {   // Base
        cout << "Caught logic_error: " << e.what() << endl;
    } catch (const exception& e) {     // Most base
        cout << "Caught exception: " << e.what() << endl;
    }
}

// ============== THROW IN FUNCTION ==============

int divide(int a, int b) {
    if (b == 0) {
        throw DivideByZeroException();
    }
    return a / b;
}

void demo_function_exceptions() {
    cout << "\n=== FUNCTION EXCEPTIONS ===" << endl;
    
    try {
        cout << "10 / 2 = " << divide(10, 2) << endl;
        cout << "10 / 0 = " << divide(10, 0) << endl;
    } catch (const DivideByZeroException& e) {
        cout << "Caught: " << e.what() << endl;
    }
}

// ============== NOEXCEPT ==============

void safe_function() noexcept {
    cout << "This function won't throw" << endl;
}

void unsafe_function() {
    throw runtime_error("This function can throw");
}

void demo_noexcept() {
    cout << "\n=== NOEXCEPT ===" << endl;
    
    safe_function();
    cout << "safe_function is noexcept" << endl;
    
    try {
        unsafe_function();
    } catch (const exception& e) {
        cout << "unsafe_function threw: " << e.what() << endl;
    }
}

// ============== EXCEPTION SAFETY ==============

class Container {
private:
    int* data = nullptr;
    int size = 0;
    
public:
    Container(int s) {
        if (s < 0) {
            throw invalid_argument("Negative size");
        }
        size = s;
        data = new int[size];
        cout << "Container created with size " << size << endl;
    }
    
    ~Container() {
        delete[] data;
        cout << "Container destroyed" << endl;
    }
    
    void setValue(int index, int value) {
        if (index < 0 || index >= size) {
            throw out_of_range("Index out of range");
        }
        data[index] = value;
    }
    
    int getValue(int index) const {
        if (index < 0 || index >= size) {
            throw out_of_range("Index out of range");
        }
        return data[index];
    }
};

void demo_exception_safety() {
    cout << "\n=== EXCEPTION SAFETY ===" << endl;
    
    try {
        Container c(5);
        c.setValue(0, 10);
        cout << "Value at 0: " << c.getValue(0) << endl;
        c.setValue(10, 20);  // Will throw
    } catch (const out_of_range& e) {
        cout << "Caught: " << e.what() << endl;
    }
    cout << "Container cleaned up properly" << endl;
}

// ============== RETHROW ==============

void demo_rethrow() {
    cout << "\n=== RETHROW ===" << endl;
    
    try {
        try {
            throw runtime_error("Inner exception");
        } catch (const runtime_error& e) {
            cout << "Inner catch: " << e.what() << endl;
            throw;  // Rethrow same exception
        }
    } catch (const runtime_error& e) {
        cout << "Outer catch: " << e.what() << endl;
    }
}

// ============== EXCEPTION CHAINS ==============

void demo_exception_chain() {
    cout << "\n=== EXCEPTION CHAIN ===" << endl;
    
    try {
        try {
            throw runtime_error("Original error");
        } catch (const exception& e) {
            cout << "Caught: " << e.what() << endl;
            throw logic_error("Error processing file");
        }
    } catch (const exception& e) {
        cout << "Final catch: " << e.what() << endl;
    }
}

int main() {
    cout << "=== EXCEPTION HANDLING ===" << endl;
    
    // Standard exceptions
    demo_standard_exceptions();
    
    // Custom exceptions
    demo_custom_exception_basic();
    demo_custom_exception_derived();
    
    // Try-catch
    demo_try_catch_basics();
    demo_multiple_catch();
    demo_catch_by_value_vs_reference();
    demo_exception_hierarchy();
    
    // Functions throwing exceptions
    demo_function_exceptions();
    
    // noexcept
    demo_noexcept();
    
    // Exception safety
    demo_exception_safety();
    
    // Rethrow
    demo_rethrow();
    
    // Exception chain
    demo_exception_chain();
    
    return 0;
}
