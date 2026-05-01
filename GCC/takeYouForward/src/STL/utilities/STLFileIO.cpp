#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <iomanip>

using namespace std;

// ============== OFSTREAM (OUTPUT FILE) ==============

void demo_ofstream_basic() {
    cout << "\n=== OFSTREAM - BASIC ===" << endl;
    
    // Create and write to file
    ofstream outfile("output.txt");
    
    if (!outfile.is_open()) {
        cerr << "Error opening file" << endl;
        return;
    }
    
    outfile << "Hello, World!" << endl;
    outfile << "This is a test file" << endl;
    outfile << "Line 3" << endl;
    
    outfile.close();
    cout << "File written successfully" << endl;
}

void demo_ofstream_append() {
    cout << "\n=== OFSTREAM - APPEND ===" << endl;
    
    // Append to existing file
    ofstream outfile("output.txt", ios::app);
    
    if (!outfile.is_open()) {
        cerr << "Error opening file" << endl;
        return;
    }
    
    outfile << "Appended line 1" << endl;
    outfile << "Appended line 2" << endl;
    
    outfile.close();
    cout << "Data appended successfully" << endl;
}

void demo_ofstream_binary() {
    cout << "\n=== OFSTREAM - BINARY ===" << endl;
    
    ofstream outfile("binary.bin", ios::binary);
    
    int data[] = {100, 200, 300, 400};
    outfile.write((char*)data, sizeof(data));
    
    outfile.close();
    cout << "Binary file written" << endl;
}

void demo_ofstream_formatted() {
    cout << "\n=== OFSTREAM - FORMATTED ===" << endl;
    
    ofstream outfile("formatted.txt");
    
    outfile << "Integer: " << 42 << endl;
    outfile << "Float: " << 3.14159 << endl;
    outfile << "Hex: " << hex << 255 << endl;
    outfile << dec;  // Back to decimal
    outfile << "String: " << "Hello" << endl;
    
    outfile.close();
    cout << "Formatted file written" << endl;
}

// ============== IFSTREAM (INPUT FILE) ==============

void demo_ifstream_read_lines() {
    cout << "\n=== IFSTREAM - READ LINES ===" << endl;
    
    // First create a file to read
    ofstream temp("temp.txt");
    temp << "Line 1\n" << "Line 2\n" << "Line 3\n";
    temp.close();
    
    // Now read it
    ifstream infile("temp.txt");
    
    if (!infile.is_open()) {
        cerr << "Error opening file" << endl;
        return;
    }
    
    string line;
    cout << "File contents:" << endl;
    while (getline(infile, line)) {
        cout << "  " << line << endl;
    }
    
    infile.close();
}

void demo_ifstream_read_words() {
    cout << "\n=== IFSTREAM - READ WORDS ===" << endl;
    
    // Create test file
    ofstream temp("words.txt");
    temp << "Hello World This Is A Test";
    temp.close();
    
    // Read word by word
    ifstream infile("words.txt");
    
    string word;
    cout << "Words: ";
    while (infile >> word) {
        cout << word << " ";
    }
    cout << endl;
    
    infile.close();
}

void demo_ifstream_read_numbers() {
    cout << "\n=== IFSTREAM - READ NUMBERS ===" << endl;
    
    // Create file with numbers
    ofstream temp("numbers.txt");
    temp << "10 20 30 40 50" << endl;
    temp.close();
    
    // Read numbers
    ifstream infile("numbers.txt");
    
    vector<int> numbers;
    int num;
    while (infile >> num) {
        numbers.push_back(num);
    }
    
    cout << "Numbers read: ";
    for (int n : numbers) {
        cout << n << " ";
    }
    cout << endl;
    
    infile.close();
}

void demo_ifstream_binary() {
    cout << "\n=== IFSTREAM - BINARY ===" << endl;
    
    // Create binary file
    int original[] = {100, 200, 300};
    ofstream temp("temp.bin", ios::binary);
    temp.write((char*)original, sizeof(original));
    temp.close();
    
    // Read binary file
    ifstream infile("temp.bin", ios::binary);
    
    int data[3];
    infile.read((char*)data, sizeof(data));
    
    cout << "Binary data read: ";
    for (int i = 0; i < 3; i++) {
        cout << data[i] << " ";
    }
    cout << endl;
    
    infile.close();
}

void demo_ifstream_error_checking() {
    cout << "\n=== IFSTREAM - ERROR CHECKING ===" << endl;
    
    ifstream infile("nonexistent.txt");
    
    if (!infile) {
        cerr << "File does not exist" << endl;
    }
    
    if (!infile.is_open()) {
        cout << "File is not open" << endl;
    }
    
    // Check for read errors
    ifstream validfile("temp.txt");
    if (validfile.good()) {
        cout << "File is in good state" << endl;
    }
    
    validfile.close();
}

// ============== FSTREAM (READ-WRITE) ==============

void demo_fstream() {
    cout << "\n=== FSTREAM (READ-WRITE) ===" << endl;
    
    // Write
    fstream file("readwrite.txt", ios::out);
    file << "Line 1\n" << "Line 2\n" << "Line 3\n";
    file.close();
    
    // Read
    file.open("readwrite.txt", ios::in);
    cout << "File contents:" << endl;
    string line;
    while (getline(file, line)) {
        cout << "  " << line << endl;
    }
    file.close();
}

// ============== STRINGSTREAM ==============

void demo_stringstream_output() {
    cout << "\n=== STRINGSTREAM - OUTPUT ===" << endl;
    
    stringstream ss;
    
    ss << "Number: " << 42 << endl;
    ss << "Float: " << 3.14 << endl;
    ss << "String: " << "Hello" << endl;
    
    cout << "StringStream content:" << endl;
    cout << ss.str() << endl;
}

void demo_stringstream_input() {
    cout << "\n=== STRINGSTREAM - INPUT ===" << endl;
    
    string input = "10 20 30 40 50";
    stringstream ss(input);
    
    vector<int> numbers;
    int num;
    while (ss >> num) {
        numbers.push_back(num);
    }
    
    cout << "Numbers extracted: ";
    for (int n : numbers) {
        cout << n << " ";
    }
    cout << endl;
}

void demo_stringstream_parsing() {
    cout << "\n=== STRINGSTREAM - PARSING ===" << endl;
    
    string data = "Alice,30,Engineer";
    stringstream ss(data);
    
    string name, job;
    int age;
    char comma;
    
    ss >> name >> comma >> age >> comma >> job;
    
    cout << "Parsed data:" << endl;
    cout << "  Name: " << name << endl;
    cout << "  Age: " << age << endl;
    cout << "  Job: " << job << endl;
}

void demo_stringstream_conversion() {
    cout << "\n=== STRINGSTREAM - CONVERSION ===" << endl;
    
    // Number to string
    stringstream ss1;
    ss1 << 42;
    string str1 = ss1.str();
    cout << "Int to string: " << str1 << endl;
    
    // String to number
    stringstream ss2("123");
    int num;
    ss2 >> num;
    cout << "String to int: " << num << endl;
    
    // Multiple conversions
    stringstream ss3;
    double pi = 3.14159;
    ss3 << fixed << setprecision(2) << pi;
    cout << "Formatted: " << ss3.str() << endl;
}

// ============== FILE OPERATIONS ==============

void demo_file_info() {
    cout << "\n=== FILE INFORMATION ===" << endl;
    
    // Create a test file
    ofstream temp("info.txt");
    temp << "Test file content" << endl;
    temp.close();
    
    ifstream file("info.txt");
    
    // Get file size
    file.seekg(0, ios::end);
    streampos size = file.tellg();
    file.seekg(0, ios::beg);
    
    cout << "File size: " << size << " bytes" << endl;
    
    // Count lines
    int lines = 0;
    string line;
    while (getline(file, line)) {
        lines++;
    }
    cout << "Number of lines: " << lines << endl;
    
    file.close();
}

void demo_line_by_line_processing() {
    cout << "\n=== LINE BY LINE PROCESSING ===" << endl;
    
    // Create test file
    ofstream temp("data.txt");
    temp << "10\n20\n30\n40\n50\n";
    temp.close();
    
    // Process line by line
    ifstream file("data.txt");
    int sum = 0;
    int num;
    int count = 0;
    
    while (file >> num) {
        sum += num;
        count++;
    }
    
    cout << "Sum: " << sum << endl;
    cout << "Count: " << count << endl;
    cout << "Average: " << (double)sum / count << endl;
    
    file.close();
}

// ============== ERROR HANDLING ==============

void demo_file_error_handling() {
    cout << "\n=== FILE ERROR HANDLING ===" << endl;
    
    ofstream outfile("test.txt");
    
    if (outfile.fail()) {
        cerr << "Failed to open file for writing" << endl;
        return;
    }
    
    outfile << "Data" << endl;
    
    if (outfile.bad()) {
        cerr << "Critical error writing to file" << endl;
    }
    
    outfile.close();
    cout << "File operations completed" << endl;
}

int main() {
    cout << "=== FILE I/O ===" << endl;
    
    // Output
    demo_ofstream_basic();
    demo_ofstream_append();
    demo_ofstream_binary();
    demo_ofstream_formatted();
    
    // Input
    demo_ifstream_read_lines();
    demo_ifstream_read_words();
    demo_ifstream_read_numbers();
    demo_ifstream_binary();
    demo_ifstream_error_checking();
    
    // Read-Write
    demo_fstream();
    
    // StringStream
    demo_stringstream_output();
    demo_stringstream_input();
    demo_stringstream_parsing();
    demo_stringstream_conversion();
    
    // File operations
    demo_file_info();
    demo_line_by_line_processing();
    
    // Error handling
    demo_file_error_handling();
    
    return 0;
}
