#include <iostream>
#include <vector>
#include <ranges>
#include <algorithm>
#include <numeric>

using namespace std;

// ============== RANGE BASICS ==============

void demo_range_concepts() {
    cout << "\n=== RANGE CONCEPTS ===" << endl;
    
    vector<int> vec = {1, 2, 3, 4, 5};
    
    // All ranges are iterable
    cout << "Using range-based for loop:" << endl;
    for (int x : vec) {
        cout << x << " ";
    }
    cout << endl;
    
    // Check if vector is a range (has begin and end)
    cout << "Vector size: " << vec.size() << endl;
    cout << "Satisfies range concept: Yes" << endl;
}

// ============== RANGE VIEWS ==============

void demo_range_filter() {
    cout << "\n=== RANGE FILTER VIEW ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Filter even numbers using views::filter
    auto evens = nums | views::filter([](int x) { return x % 2 == 0; });
    
    cout << "Original: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    cout << "Even numbers: ";
    for (int x : evens) cout << x << " ";
    cout << endl;
}

void demo_range_transform() {
    cout << "\n=== RANGE TRANSFORM VIEW ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5};
    
    // Transform: multiply by 2
    auto doubled = nums | views::transform([](int x) { return x * 2; });
    
    cout << "Original: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    cout << "Doubled: ";
    for (int x : doubled) cout << x << " ";
    cout << endl;
}

void demo_range_take() {
    cout << "\n=== RANGE TAKE VIEW ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Take first 5 elements
    auto first_five = nums | views::take(5);
    
    cout << "First 5 elements: ";
    for (int x : first_five) cout << x << " ";
    cout << endl;
}

void demo_range_drop() {
    cout << "\n=== RANGE DROP VIEW ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Drop first 3 elements
    auto without_first_three = nums | views::drop(3);
    
    cout << "After dropping 3: ";
    for (int x : without_first_three) cout << x << " ";
    cout << endl;
}

void demo_range_reverse() {
    cout << "\n=== RANGE REVERSE VIEW ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5};
    
    // Reverse view
    auto reversed = nums | views::reverse;
    
    cout << "Original: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    cout << "Reversed: ";
    for (int x : reversed) cout << x << " ";
    cout << endl;
}

// ============== PIPING RANGES ==============

void demo_range_pipe_chain() {
    cout << "\n=== RANGE PIPING (COMPOSITION) ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    // Chain: filter even -> take 3 -> multiply by 2
    auto result = nums 
        | views::filter([](int x) { return x % 2 == 0; })
        | views::take(3)
        | views::transform([](int x) { return x * 10; });
    
    cout << "Original: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    cout << "Pipeline result (filter even, take 3, multiply by 10): ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

// ============== RANGE ALGORITHMS ==============

void demo_range_algorithm_any() {
    cout << "\n=== RANGE ALGORITHM: ANY_OF ===" << endl;
    
    vector<int> nums = {2, 4, 6, 8, 10};
    
    bool has_odd = ranges::any_of(nums, [](int x) { return x % 2 != 0; });
    cout << "Has odd number: " << (has_odd ? "yes" : "no") << endl;
    
    bool has_gt_5 = ranges::any_of(nums, [](int x) { return x > 5; });
    cout << "Has number > 5: " << (has_gt_5 ? "yes" : "no") << endl;
}

void demo_range_algorithm_all() {
    cout << "\n=== RANGE ALGORITHM: ALL_OF ===" << endl;
    
    vector<int> nums = {2, 4, 6, 8, 10};
    
    bool all_even = ranges::all_of(nums, [](int x) { return x % 2 == 0; });
    cout << "All even: " << (all_even ? "yes" : "no") << endl;
    
    bool all_gt_0 = ranges::all_of(nums, [](int x) { return x > 0; });
    cout << "All > 0: " << (all_gt_0 ? "yes" : "no") << endl;
}

void demo_range_algorithm_find() {
    cout << "\n=== RANGE ALGORITHM: FIND ===" << endl;
    
    vector<int> nums = {1, 2, 3, 4, 5, 6};
    
    auto it = ranges::find(nums, 4);
    if (it != nums.end()) {
        cout << "Found 4 at position: " << distance(nums.begin(), it) << endl;
    }
    
    auto it2 = ranges::find_if(nums, [](int x) { return x > 4; });
    if (it2 != nums.end()) {
        cout << "Found first number > 4: " << *it2 << endl;
    }
}

void demo_range_algorithm_count() {
    cout << "\n=== RANGE ALGORITHM: COUNT ===" << endl;
    
    vector<int> nums = {1, 2, 2, 3, 3, 3, 4, 4, 4, 4};
    
    auto count_3 = ranges::count(nums, 3);
    cout << "Count of 3: " << count_3 << endl;
    
    auto count_even = ranges::count_if(nums, [](int x) { return x % 2 == 0; });
    cout << "Count of even: " << count_even << endl;
}

void demo_range_algorithm_sort() {
    cout << "\n=== RANGE ALGORITHM: SORT ===" << endl;
    
    vector<int> nums = {5, 3, 8, 1, 9, 2};
    
    cout << "Original: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    ranges::sort(nums);
    cout << "Sorted: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
    
    ranges::sort(nums, greater<int>());
    cout << "Reverse sorted: ";
    for (int x : nums) cout << x << " ";
    cout << endl;
}

// ============== IOTA VIEW ==============

void demo_range_iota() {
    cout << "\n=== RANGE IOTA VIEW ===" << endl;
    
    // Generate sequence 0-9
    auto sequence = views::iota(0, 10);
    
    cout << "Iota(0, 10): ";
    for (int x : sequence) cout << x << " ";
    cout << endl;
    
    // With transform
    auto squares = views::iota(1, 6) | views::transform([](int x) { return x * x; });
    
    cout << "Squares of 1-5: ";
    for (int x : squares) cout << x << " ";
    cout << endl;
}

// ============== DISTANCE AND ADVANCE ==============

void demo_range_distance_advance() {
    cout << "\n=== RANGE DISTANCE AND ADVANCE ===" << endl;
    
    vector<int> nums = {10, 20, 30, 40, 50};
    
    // Range distance (simpler than std::distance)
    int dist = ranges::distance(nums);
    cout << "Distance of range: " << dist << endl;
    
    // Getting subset with distance
    auto first_three = nums | views::take(3);
    cout << "First 3 elements: ";
    for (int x : first_three) cout << x << " ";
    cout << endl;
}

// ============== VIEWS WITH STRINGS ==============

void demo_range_string_view() {
    cout << "\n=== RANGE WITH STRING_VIEW ===" << endl;
    
    string text = "Hello World C++20 Ranges";
    
    // Split by space using filters (manual approach)
    cout << "Characters > 'M': ";
    auto filtered = text | views::filter([](char c) { return c > 'M'; });
    for (char c : filtered) cout << c;
    cout << endl;
    
    // Uppercase transformation simulation
    cout << "Text length: " << ranges::distance(text) << endl;
}

// ============== LAZY EVALUATION ==============

void demo_range_lazy_evaluation() {
    cout << "\n=== RANGE LAZY EVALUATION ===" << endl;
    
    cout << "Creating pipeline (lazy - no computation yet):" << endl;
    vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    
    auto pipeline = nums 
        | views::filter([](int x) {
            cout << "  Filtering " << x << endl;
            return x % 2 == 0;
          })
        | views::transform([](int x) {
            cout << "  Transforming " << x << endl;
            return x * 2;
          });
    
    cout << "\nIterating (now computation happens):" << endl;
    for (int x : pipeline) {
        cout << "Result: " << x << " ";
    }
    cout << endl;
}

int main() {
    cout << "=== RANGES (C++20 RANGES LIBRARY) ===" << endl;
    
    // Range concepts
    demo_range_concepts();
    
    // Individual views
    demo_range_filter();
    demo_range_transform();
    demo_range_take();
    demo_range_drop();
    demo_range_reverse();
    
    // Piping/chaining
    demo_range_pipe_chain();
    
    // Range algorithms
    demo_range_algorithm_any();
    demo_range_algorithm_all();
    demo_range_algorithm_find();
    demo_range_algorithm_count();
    demo_range_algorithm_sort();
    
    // Special views
    demo_range_iota();
    
    // Utility functions
    demo_range_distance_advance();
    
    // With strings
    demo_range_string_view();
    
    // Lazy evaluation
    demo_range_lazy_evaluation();
    
    return 0;
}
