#include <iostream>
#include <regex>
#include <string>
#include <vector>

using namespace std;

// ============== REGEX BASICS ==============

void demo_regex_match() {
    cout << "\n=== REGEX - MATCH ===" << endl;
    
    regex pattern("^[0-9]+$");  // Matches strings with only digits
    
    string s1 = "12345";
    string s2 = "123abc";
    
    cout << "Pattern: ^[0-9]+$" << endl;
    cout << "\"" << s1 << "\" matches: " << (regex_match(s1, pattern) ? "yes" : "no") << endl;
    cout << "\"" << s2 << "\" matches: " << (regex_match(s2, pattern) ? "yes" : "no") << endl;
}

void demo_regex_search() {
    cout << "\n=== REGEX - SEARCH ===" << endl;
    
    regex pattern("[0-9]+");  // Finds sequences of digits
    
    string text = "The price is 250 dollars and 50 cents";
    smatch match;
    
    cout << "Pattern: [0-9]+" << endl;
    cout << "Text: " << text << endl;
    
    if (regex_search(text, match, pattern)) {
        cout << "Found: " << match[0] << endl;
        cout << "Position: " << match.position() << endl;
    }
}

void demo_regex_findall() {
    cout << "\n=== REGEX - FIND ALL ===" << endl;
    
    regex pattern("[0-9]+");
    string text = "I have 2 apples, 5 oranges, and 10 bananas";
    
    smatch match;
    string::const_iterator searchStart(text.cbegin());
    
    cout << "Pattern: [0-9]+" << endl;
    cout << "Text: " << text << endl;
    cout << "Found numbers: ";
    
    while (regex_search(searchStart, text.cend(), match, pattern)) {
        cout << match[0] << " ";
        searchStart = match.suffix().first;
    }
    cout << endl;
}

// ============== REGEX PATTERNS ==============

void demo_regex_character_classes() {
    cout << "\n=== REGEX - CHARACTER CLASSES ===" << endl;
    
    // Digit: [0-9] or \d
    cout << "Digits:" << endl;
    regex digit("[0-9]");
    cout << "  '5' matches [0-9]: " << (regex_match("5", digit) ? "yes" : "no") << endl;
    cout << "  'a' matches [0-9]: " << (regex_match("a", digit) ? "yes" : "no") << endl;
    
    // Alphanumeric: [a-zA-Z0-9] or \w
    cout << "Alphanumeric:" << endl;
    regex word("[a-zA-Z0-9]");
    cout << "  'a' matches [a-zA-Z0-9]: " << (regex_match("a", word) ? "yes" : "no") << endl;
    cout << "  '5' matches [a-zA-Z0-9]: " << (regex_match("5", word) ? "yes" : "no") << endl;
    cout << "  '_' matches [a-zA-Z0-9]: " << (regex_match("_", word) ? "yes" : "no") << endl;
    
    // Space: [ ] or \s
    cout << "Whitespace:" << endl;
    regex space("[ ]");
    cout << "  ' ' matches [ ]: " << (regex_match(" ", space) ? "yes" : "no") << endl;
    cout << "  'a' matches [ ]: " << (regex_match("a", space) ? "yes" : "no") << endl;
    
    // Negation: [^...]
    cout << "Negation [^0-9]:" << endl;
    regex not_digit("[^0-9]");
    cout << "  'a' matches [^0-9]: " << (regex_match("a", not_digit) ? "yes" : "no") << endl;
    cout << "  '5' matches [^0-9]: " << (regex_match("5", not_digit) ? "yes" : "no") << endl;
}

void demo_regex_quantifiers() {
    cout << "\n=== REGEX - QUANTIFIERS ===" << endl;
    
    // * (zero or more)
    cout << "* (zero or more):" << endl;
    regex star("a*");
    cout << "  \"\" matches a*: " << (regex_match("", star) ? "yes" : "no") << endl;
    cout << "  \"a\" matches a*: " << (regex_match("a", star) ? "yes" : "no") << endl;
    cout << "  \"aaa\" matches a*: " << (regex_match("aaa", star) ? "yes" : "no") << endl;
    
    // + (one or more)
    cout << "+ (one or more):" << endl;
    regex plus("a+");
    cout << "  \"\" matches a+: " << (regex_match("", plus) ? "yes" : "no") << endl;
    cout << "  \"a\" matches a+: " << (regex_match("a", plus) ? "yes" : "no") << endl;
    cout << "  \"aaa\" matches a+: " << (regex_match("aaa", plus) ? "yes" : "no") << endl;
    
    // ? (zero or one)
    cout << "? (zero or one):" << endl;
    regex question("a?");
    cout << "  \"\" matches a?: " << (regex_match("", question) ? "yes" : "no") << endl;
    cout << "  \"a\" matches a?: " << (regex_match("a", question) ? "yes" : "no") << endl;
    cout << "  \"aa\" matches a?: " << (regex_match("aa", question) ? "yes" : "no") << endl;
    
    // {n} (exactly n)
    cout << "{2} (exactly 2):" << endl;
    regex exact("a{2}");
    cout << "  \"a\" matches a{2}: " << (regex_match("a", exact) ? "yes" : "no") << endl;
    cout << "  \"aa\" matches a{2}: " << (regex_match("aa", exact) ? "yes" : "no") << endl;
    cout << "  \"aaa\" matches a{2}: " << (regex_match("aaa", exact) ? "yes" : "no") << endl;
    
    // {n,m} (between n and m)
    cout << "{2,4} (between 2 and 4):" << endl;
    regex range("a{2,4}");
    cout << "  \"a\" matches a{2,4}: " << (regex_match("a", range) ? "yes" : "no") << endl;
    cout << "  \"aa\" matches a{2,4}: " << (regex_match("aa", range) ? "yes" : "no") << endl;
    cout << "  \"aaa\" matches a{2,4}: " << (regex_match("aaa", range) ? "yes" : "no") << endl;
    cout << "  \"aaaaa\" matches a{2,4}: " << (regex_match("aaaaa", range) ? "yes" : "no") << endl;
}

void demo_regex_anchors() {
    cout << "\n=== REGEX - ANCHORS ===" << endl;
    
    // ^ (start)
    cout << "^ (start of line):" << endl;
    regex start("^hello");
    cout << "  \"hello world\" matches ^hello: " << (regex_search("hello world", start) ? "yes" : "no") << endl;
    cout << "  \"say hello\" matches ^hello: " << (regex_search("say hello", start) ? "yes" : "no") << endl;
    
    // $ (end)
    cout << "$ (end of line):" << endl;
    regex end("world$");
    cout << "  \"hello world\" matches world$: " << (regex_search("hello world", end) ? "yes" : "no") << endl;
    cout << "  \"world peace\" matches world$: " << (regex_search("world peace", end) ? "yes" : "no") << endl;
}

void demo_regex_groups() {
    cout << "\n=== REGEX - GROUPS ===" << endl;
    
    // Capture groups
    regex pattern("([a-z]+)([0-9]+)");
    string text = "abc123";
    smatch match;
    
    if (regex_match(text, match, pattern)) {
        cout << "Text: " << text << endl;
        cout << "Full match: " << match[0] << endl;
        cout << "Group 1 (letters): " << match[1] << endl;
        cout << "Group 2 (digits): " << match[2] << endl;
    }
}

// ============== EMAIL & URL VALIDATION ==============

void demo_email_validation() {
    cout << "\n=== EMAIL VALIDATION ===" << endl;
    
    // Simple email pattern
    regex email_pattern(R"([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})");
    
    vector<string> emails = {
        "user@example.com",
        "test.email@domain.co.uk",
        "invalid.email@",
        "noemailformat.com"
    };
    
    cout << "Email pattern: [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}" << endl;
    for (auto& email : emails) {
        cout << "  \"" << email << "\": " 
             << (regex_match(email, email_pattern) ? "valid" : "invalid") << endl;
    }
}

void demo_url_validation() {
    cout << "\n=== URL VALIDATION ===" << endl;
    
    regex url_pattern(R"(https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})");
    
    vector<string> urls = {
        "http://www.example.com",
        "https://github.com",
        "ftp://files.example.org",
        "not a url"
    };
    
    cout << "URL pattern: https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}" << endl;
    for (auto& url : urls) {
        cout << "  \"" << url << "\": " 
             << (regex_search(url, url_pattern) ? "valid" : "invalid") << endl;
    }
}

// ============== REGEX REPLACE ==============

void demo_regex_replace() {
    cout << "\n=== REGEX REPLACE ===" << endl;
    
    string text = "Hello World World";
    regex pattern("World");
    string replacement = "C++";
    
    cout << "Original: " << text << endl;
    string result = regex_replace(text, pattern, replacement);
    cout << "After replace (first): " << result << endl;
    
    // Replace all
    result = regex_replace(text, pattern, replacement);
    cout << "After replace (all): " << result << endl;
}

void demo_regex_replace_groups() {
    cout << "\n=== REGEX REPLACE WITH GROUPS ===" << endl;
    
    string text = "John,30 Jane,25 Bob,28";
    regex pattern(R"(([a-zA-Z]+),([0-9]+))");
    string replacement = "$1 is $2 years old";
    
    cout << "Original: " << text << endl;
    
    // Use smatch to find and replace with groups
    smatch match;
    string result;
    string::const_iterator searchStart(text.cbegin());
    
    while (regex_search(searchStart, text.cend(), match, pattern)) {
        result += string(searchStart, match[0].first) + 
                  match[1].str() + " is " + match[2].str() + " years old ";
        searchStart = match.suffix().first;
    }
    result += string(searchStart, text.cend());
    
    cout << "Replaced: " << result << endl;
}

// ============== REGEX FLAGS ==============

void demo_regex_flags() {
    cout << "\n=== REGEX FLAGS ===" << endl;
    
    // Case-insensitive
    cout << "Case-insensitive (icase):" << endl;
    regex pattern("hello", regex::icase);
    cout << "  \"HELLO\" matches \"hello\" (icase): " 
         << (regex_match("HELLO", pattern) ? "yes" : "no") << endl;
    
    // Without flag
    regex pattern2("hello");
    cout << "  \"HELLO\" matches \"hello\" (normal): " 
         << (regex_match("HELLO", pattern2) ? "yes" : "no") << endl;
}

// ============== PRACTICAL EXAMPLES ==============

void demo_extract_numbers() {
    cout << "\n=== EXTRACT NUMBERS ===" << endl;
    
    string text = "The phone number is 123-456-7890 and email is test@example.com";
    regex pattern(R"(\d{3}-\d{3}-\d{4})");
    
    smatch match;
    if (regex_search(text, match, pattern)) {
        cout << "Phone number: " << match[0] << endl;
    }
}

void demo_split_string() {
    cout << "\n=== SPLIT STRING ===" << endl;
    
    string text = "apple,banana,orange,grape";
    regex pattern(",");
    
    vector<string> parts(
        sregex_token_iterator(text.begin(), text.end(), pattern, -1),
        sregex_token_iterator()
    );
    
    cout << "String: " << text << endl;
    cout << "Split by ',': ";
    for (auto& part : parts) {
        cout << part << " ";
    }
    cout << endl;
}

int main() {
    cout << "=== REGULAR EXPRESSIONS ===" << endl;
    
    // Basic operations
    demo_regex_match();
    demo_regex_search();
    demo_regex_findall();
    
    // Patterns
    demo_regex_character_classes();
    demo_regex_quantifiers();
    demo_regex_anchors();
    demo_regex_groups();
    
    // Validation
    demo_email_validation();
    demo_url_validation();
    
    // Replace
    demo_regex_replace();
    demo_regex_replace_groups();
    
    // Flags
    demo_regex_flags();
    
    // Practical
    demo_extract_numbers();
    demo_split_string();
    
    return 0;
}
