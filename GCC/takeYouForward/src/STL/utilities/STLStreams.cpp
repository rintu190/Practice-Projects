#include <iostream>
#include <iomanip>
#include <locale>
#include <sstream>
#include <cmath>
#include <bitset>

using namespace std;

// ============== STREAM FORMATTING ==============

void demo_width() {
    cout << "\n=== WIDTH ===" << endl;
    
    cout << "Default: |" << 42 << "|" << endl;
    cout << setw(10) << "Width 10: |" << 42 << "|" << endl;
    cout << setw(15) << "Width 15: |" << 42 << "|" << endl;
    
    // Width affects only next output
    cout << setw(10) << 100 << endl;
    cout << 200 << endl;  // No width
}

void demo_fill() {
    cout << "\n=== FILL ===" << endl;
    
    cout << setfill('*') << setw(10) << 42 << endl;
    cout << setfill('=') << setw(10) << 42 << endl;
    cout << setfill(' ');  // Reset to space
}

void demo_alignment() {
    cout << "\n=== ALIGNMENT ===" << endl;
    
    string text = "Hello";
    
    cout << "Left: |" << left << setw(10) << text << "|" << endl;
    cout << "Right: |" << right << setw(10) << text << "|" << endl;
    cout << "Internal: |" << internal << setw(10) << -42 << "|" << endl;
}

void demo_base() {
    cout << "\n=== BASE (HEX, OCT, DEC) ===" << endl;
    
    int num = 255;
    
    cout << "Decimal: " << dec << num << endl;
    cout << "Hexadecimal: " << hex << num << endl;
    cout << "Octal: " << oct << num << endl;
    cout << "Binary (manual): " << bitset<8>(num) << endl;
    
    cout << dec;  // Reset to decimal
}

void demo_showbase() {
    cout << "\n=== SHOWBASE ===" << endl;
    
    int num = 255;
    
    cout << "With showbase:" << endl;
    cout << showbase;
    cout << "  Hex: " << hex << num << endl;
    cout << "  Oct: " << oct << num << endl;
    cout << "  Dec: " << dec << num << endl;
    
    cout << noshowbase;  // Reset
}

void demo_float_format() {
    cout << "\n=== FLOAT FORMATTING ===" << endl;
    
    double pi = 3.14159265359;
    double small = 0.000001;
    double large = 1000000.5;
    
    cout << "Default: " << pi << endl;
    
    cout << "\nFixed notation:" << endl;
    cout << fixed;
    cout << "  pi: " << pi << endl;
    cout << "  small: " << small << endl;
    
    cout << "\nScientific notation:" << endl;
    cout << scientific;
    cout << "  pi: " << pi << endl;
    cout << "  large: " << large << endl;
    
    cout << "\nDefault notation:" << endl;
    cout << defaultfloat;
    cout << "  pi: " << pi << endl;
}

void demo_precision() {
    cout << "\n=== PRECISION ===" << endl;
    
    double pi = 3.14159265359;
    
    cout << "Default precision (6): " << pi << endl;
    
    cout << setprecision(2) << "Precision 2: " << pi << endl;
    cout << setprecision(5) << "Precision 5: " << pi << endl;
    cout << setprecision(10) << "Precision 10: " << pi << endl;
    
    cout << fixed << setprecision(3) << "Fixed precision 3: " << pi << endl;
}

void demo_sign() {
    cout << "\n=== SIGN FORMATTING ===" << endl;
    
    cout << "Default: " << 42 << ", " << -42 << endl;
    
    cout << showpos;  // Show + sign
    cout << "With showpos: " << 42 << ", " << -42 << endl;
    
    cout << noshowpos;  // Reset
}

void demo_bool_format() {
    cout << "\n=== BOOLEAN FORMATTING ===" << endl;
    
    bool flag = true;
    
    cout << "Default (numeric): " << flag << ", " << !flag << endl;
    
    cout << boolalpha;  // Show as true/false
    cout << "With boolalpha: " << flag << ", " << !flag << endl;
    
    cout << noboolalpha;  // Reset
}

// ============== MANIPULATORS ==============

void demo_manipulators() {
    cout << "\n=== MANIPULATORS ===" << endl;
    
    cout << "endl: " << "test" << endl;
    cout << "ends: |" << "test" << ends << "|" << endl;
    
    string input;
    cout << "flush: ";
    cout << "Enter text: " << flush;
    // getline(cin, input);
}

void demo_custom_manipulator() {
    cout << "\n=== CUSTOM MANIPULATOR ===" << endl;
    
    // Create custom manipulator
    auto ruler = [](ostream& os) -> ostream& {
        return os << "----+----+----+----+" << endl;
    };
    
    cout << ruler;
    cout << "Line 1" << endl;
    cout << ruler;
    cout << "Line 2" << endl;
}

// ============== STRINGSTREAM FORMATTING ==============

void demo_stringstream_format() {
    cout << "\n=== STRINGSTREAM FORMATTING ===" << endl;
    
    stringstream ss;
    
    ss << fixed << setprecision(2);
    ss << "Pi = " << 3.14159 << endl;
    ss << "Result = " << 42 << endl;
    
    cout << ss.str();
}

void demo_number_formatting() {
    cout << "\n=== NUMBER FORMATTING ===" << endl;
    
    stringstream ss;
    
    int num = 255;
    double val = 3.14159;
    
    ss << "Hex: " << hex << num << ", "
       << "Dec: " << dec << num << ", "
       << "Float: " << fixed << setprecision(2) << val;
    
    cout << ss.str() << endl;
}

// ============== LOCALES ==============

void demo_locale_basics() {
    cout << "\n=== LOCALE BASICS ===" << endl;
    
    // Get current locale
    locale current = cout.getloc();
    cout << "Current locale: " << current.name() << endl;
    
    // Get C locale
    locale c_locale("C");
    cout << "C locale: " << c_locale.name() << endl;
    
    // Get system locale
    try {
        locale system_locale("");
        cout << "System locale: " << system_locale.name() << endl;
    } catch (const exception& e) {
        cout << "System locale not available: " << e.what() << endl;
    }
}

void demo_number_formatting_with_locale() {
    cout << "\n=== NUMBER FORMATTING WITH LOCALE ===" << endl;
    
    double value = 1234567.89;
    
    cout << "Default locale: " << value << endl;
    
    // Try different locales
    try {
        cout.imbue(locale("en_US.UTF-8"));
        cout << "US locale: " << value << endl;
    } catch (...) {
        cout << "US locale not available" << endl;
    }
    
    try {
        cout.imbue(locale("de_DE.UTF-8"));
        cout << "German locale: " << value << endl;
    } catch (...) {
        cout << "German locale not available" << endl;
    }
    
    // Reset to C locale
    cout.imbue(locale("C"));
    cout << "C locale: " << value << endl;
}

void demo_currency_formatting() {
    cout << "\n=== CURRENCY FORMATTING ===" << endl;
    
    double amount = 1234.56;
    
    try {
        locale::global(locale("en_US.UTF-8"));
        cout.imbue(locale::classic());
        cout << "Amount: $" << fixed << setprecision(2) << amount << endl;
    } catch (...) {
        cout << "Locale not available" << endl;
    }
}

void demo_time_locale() {
    cout << "\n=== TIME WITH LOCALE ===" << endl;
    
    time_t now = time(nullptr);
    tm* timeinfo = localtime(&now);
    
    stringstream ss;
    ss.imbue(locale("en_US.UTF-8"));
    
    cout << "Time format may vary by locale" << endl;
    cout << "Current implementation: " << ctime(&now);
}

// ============== TABLE FORMATTING ==============

void demo_table_formatting() {
    cout << "\n=== TABLE FORMATTING ===" << endl;
    
    cout << left << setfill('-');
    cout << setw(10) << "Name" << setw(10) << "Age" << setw(10) << "Score" << endl;
    cout << setfill('-') << setw(30) << "-" << endl;
    
    cout << left << setfill(' ');
    cout << setw(10) << "Alice" << setw(10) << 25 << setw(10) << fixed << setprecision(1) << 95.5 << endl;
    cout << setw(10) << "Bob" << setw(10) << 30 << setw(10) << 88.3 << endl;
    cout << setw(10) << "Charlie" << setw(10) << 28 << setw(10) << 92.7 << endl;
}

int main() {
    cout << "=== STREAMS & LOCALES (IOMANIP) ===" << endl;
    
    // Stream formatting
    demo_width();
    demo_fill();
    demo_alignment();
    demo_base();
    demo_showbase();
    demo_float_format();
    demo_precision();
    demo_sign();
    demo_bool_format();
    
    // Manipulators
    demo_manipulators();
    demo_custom_manipulator();
    
    // StringStream
    demo_stringstream_format();
    demo_number_formatting();
    
    // Locales
    demo_locale_basics();
    demo_number_formatting_with_locale();
    demo_currency_formatting();
    demo_time_locale();
    
    // Table formatting
    demo_table_formatting();
    
    return 0;
}
