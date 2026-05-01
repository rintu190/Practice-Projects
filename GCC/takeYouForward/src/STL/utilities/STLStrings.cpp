#include <iostream>
#include <string>
#include <string_view>
#include <algorithm>
#include <cctype>

using namespace std;

// ============== STD::STRING BASICS ==============

void demo_string_creation() {
    cout << "\n=== STRING CREATION ===" << endl;
    
    string s1;                              // Empty string
    cout << "s1 (empty): \"" << s1 << "\"" << endl;
    
    string s2 = "Hello";                    // From C-string
    cout << "s2: " << s2 << endl;
    
    string s3("World");                     // Constructor
    cout << "s3: " << s3 << endl;
    
    string s4(5, 'A');                      // Repeat character
    cout << "s4 (5 A's): " << s4 << endl;
    
    string s5 = s2 + " " + s3;              // Concatenation
    cout << "s5 (concatenated): " << s5 << endl;
    
    string s6(s2);                          // Copy
    cout << "s6 (copy of s2): " << s6 << endl;
}

void demo_string_access() {
    cout << "\n=== STRING ACCESS ===" << endl;
    
    string s = "Hello World";
    
    cout << "String: " << s << endl;
    cout << "Length: " << s.length() << endl;
    cout << "Size: " << s.size() << endl;
    
    // Access by index
    cout << "s[0]: " << s[0] << endl;
    cout << "s[6]: " << s[6] << endl;
    
    // Safe access with at()
    try {
        cout << "s.at(0): " << s.at(0) << endl;
        cout << "s.at(100): " << s.at(100) << endl;  // Throws exception
    } catch (out_of_range& e) {
        cout << "Exception: " << e.what() << endl;
    }
    
    // First and last
    cout << "First char: " << s.front() << endl;
    cout << "Last char: " << s.back() << endl;
}

void demo_string_modification() {
    cout << "\n=== STRING MODIFICATION ===" << endl;
    
    string s = "Hello";
    cout << "Original: " << s << endl;
    
    // Append
    s.append(" World");
    cout << "After append: " << s << endl;
    
    // Push back
    s.push_back('!');
    cout << "After push_back: " << s << endl;
    
    // Pop back
    s.pop_back();
    cout << "After pop_back: " << s << endl;
    
    // Insert
    s.insert(5, " Beautiful");
    cout << "After insert: " << s << endl;
    
    // Erase
    s.erase(5, 10);
    cout << "After erase: " << s << endl;
    
    // Replace
    s.replace(0, 5, "Hi");
    cout << "After replace: " << s << endl;
    
    // Clear
    string s2 = "test";
    s2.clear();
    cout << "After clear (empty?): " << (s2.empty() ? "yes" : "no") << endl;
}

void demo_string_search() {
    cout << "\n=== STRING SEARCH ===" << endl;
    
    string s = "Hello World Hello";
    
    // Find substring
    size_t pos = s.find("World");
    cout << "Position of 'World': " << pos << endl;
    
    // Find character
    pos = s.find('o');
    cout << "Position of first 'o': " << pos << endl;
    
    // Find from position
    pos = s.find('o', 5);
    cout << "Position of 'o' from index 5: " << pos << endl;
    
    // Reverse find
    pos = s.rfind("Hello");
    cout << "Last position of 'Hello': " << pos << endl;
    
    // Find first of
    pos = s.find_first_of("aeiou");
    cout << "First vowel at: " << pos << endl;
    
    // Find last of
    pos = s.find_last_of("aeiou");
    cout << "Last vowel at: " << pos << endl;
    
    // Not found
    pos = s.find("xyz");
    cout << "Position of 'xyz': " << (pos == string::npos ? "not found" : to_string(pos)) << endl;
}

void demo_string_substring() {
    cout << "\n=== STRING SUBSTRING ===" << endl;
    
    string s = "Hello World";
    
    // Extract substring
    string sub = s.substr(0, 5);
    cout << "substr(0, 5): " << sub << endl;
    
    sub = s.substr(6);
    cout << "substr(6): " << sub << endl;
    
    sub = s.substr(6, 3);
    cout << "substr(6, 3): " << sub << endl;
}

void demo_string_comparison() {
    cout << "\n=== STRING COMPARISON ===" << endl;
    
    string s1 = "Hello";
    string s2 = "Hello";
    string s3 = "World";
    
    cout << "s1 == s2: " << (s1 == s2 ? "true" : "false") << endl;
    cout << "s1 != s3: " << (s1 != s3 ? "true" : "false") << endl;
    cout << "s1 < s3: " << (s1 < s3 ? "true" : "false") << endl;
    
    // compare() method
    cout << "s1.compare(s2): " << s1.compare(s2) << endl;      // 0 (equal)
    cout << "s1.compare(s3): " << s1.compare(s3) << endl;      // negative
    cout << "s3.compare(s1): " << s3.compare(s1) << endl;      // positive
    
    // Case-insensitive comparison
    string a = "Hello";
    string b = "HELLO";
    transform(a.begin(), a.end(), a.begin(), ::tolower);
    transform(b.begin(), b.end(), b.begin(), ::tolower);
    cout << "Case-insensitive equal: " << (a == b ? "true" : "false") << endl;
}

void demo_string_conversion() {
    cout << "\n=== STRING CONVERSION ===" << endl;
    
    // String to numbers
    string s1 = "42";
    int i = stoi(s1);
    cout << "stoi(\"42\"): " << i << endl;
    
    string s2 = "3.14";
    double d = stod(s2);
    cout << "stod(\"3.14\"): " << d << endl;
    
    string s3 = "100";
    long l = stol(s3);
    cout << "stol(\"100\"): " << l << endl;
    
    // Numbers to string
    cout << "to_string(42): " << to_string(42) << endl;
    cout << "to_string(3.14): " << to_string(3.14) << endl;
    
    // From other bases
    string s4 = "1010";
    int binary = stoi(s4, nullptr, 2);
    cout << "stoi(\"1010\", nullptr, 2): " << binary << endl;
}

void demo_string_case() {
    cout << "\n=== STRING CASE CONVERSION ===" << endl;
    
    string s = "Hello World";
    
    // To uppercase
    string upper = s;
    transform(upper.begin(), upper.end(), upper.begin(), ::toupper);
    cout << "Uppercase: " << upper << endl;
    
    // To lowercase
    string lower = s;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    cout << "Lowercase: " << lower << endl;
}

void demo_string_trim() {
    cout << "\n=== STRING TRIM ===" << endl;
    
    string s = "  Hello World  ";
    cout << "Original: \"" << s << "\"" << endl;
    
    // Trim left
    size_t start = s.find_first_not_of(" ");
    string trimmed_left = (start == string::npos) ? "" : s.substr(start);
    cout << "Trim left: \"" << trimmed_left << "\"" << endl;
    
    // Trim right
    size_t end = s.find_last_not_of(" ");
    string trimmed_right = (end == string::npos) ? "" : s.substr(0, end + 1);
    cout << "Trim right: \"" << trimmed_right << "\"" << endl;
    
    // Trim both
    string trimmed = (start == string::npos) ? "" : s.substr(start, end - start + 1);
    cout << "Trim both: \"" << trimmed << "\"" << endl;
}

// ============== STD::STRING_VIEW (C++17) ==============

void demo_string_view() {
    cout << "\n=== STRING_VIEW ===" << endl;
    
    string str = "Hello World";
    string_view sv(str);
    
    cout << "string_view: " << sv << endl;
    cout << "Length: " << sv.length() << endl;
    cout << "Substring: " << sv.substr(0, 5) << endl;
    
    // string_view from literals
    string_view sv2 = "Direct literal";
    cout << "From literal: " << sv2 << endl;
    
    // No memory allocation
    cout << "No memory allocation with string_view!" << endl;
}

// ============== STRING OPERATIONS WITH ALGORITHMS ==============

void demo_string_algorithms() {
    cout << "\n=== STRING ALGORITHMS ===" << endl;
    
    string s = "Hello World";
    
    // Find character
    auto it = find(s.begin(), s.end(), 'o');
    cout << "Position of first 'o': " << distance(s.begin(), it) << endl;
    
    // Count character
    int count = std::count(s.begin(), s.end(), 'l');
    cout << "Count of 'l': " << count << endl;
    
    // Replace character
    string s2 = s;
    replace(s2.begin(), s2.end(), 'o', '0');
    cout << "Replace 'o' with '0': " << s2 << endl;
    
    // Reverse
    string s3 = s;
    reverse(s3.begin(), s3.end());
    cout << "Reversed: " << s3 << endl;
    
    // Sort
    string s4 = "hello";
    sort(s4.begin(), s4.end());
    cout << "Sorted: " << s4 << endl;
}

int main() {
    demo_string_creation();
    demo_string_access();
    demo_string_modification();
    demo_string_search();
    demo_string_substring();
    demo_string_comparison();
    demo_string_conversion();
    demo_string_case();
    demo_string_trim();
    demo_string_view();
    demo_string_algorithms();
    
    return 0;
}
