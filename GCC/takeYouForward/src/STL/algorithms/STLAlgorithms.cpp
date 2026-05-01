#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>
#include <string>
#include <set>
#include <map>

using namespace std;

// ============== NON-MODIFYING ALGORITHMS ==============

void demo_find() {
    cout << "\n=== find ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    auto it = find(v.begin(), v.end(), 30);
    if (it != v.end()) {
        cout << "Found: " << *it << endl;
    }
}

void demo_find_if() {
    cout << "\n=== find_if ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    auto it = find_if(v.begin(), v.end(), [](int x) { return x > 25; });
    if (it != v.end()) {
        cout << "First element > 25: " << *it << endl;
    }
}

void demo_count() {
    cout << "\n=== count ===" << endl;
    vector<int> v = {1, 2, 2, 3, 2, 4, 2};
    int cnt = count(v.begin(), v.end(), 2);
    cout << "Count of 2: " << cnt << endl;
}

void demo_count_if() {
    cout << "\n=== count_if ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    int cnt = count_if(v.begin(), v.end(), [](int x) { return x > 25; });
    cout << "Elements > 25: " << cnt << endl;
}

void demo_all_of() {
    cout << "\n=== all_of ===" << endl;
    vector<int> v = {2, 4, 6, 8, 10};
    bool all_even = all_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
    cout << "All even: " << (all_even ? "Yes" : "No") << endl;
}

void demo_any_of() {
    cout << "\n=== any_of ===" << endl;
    vector<int> v = {1, 3, 5, 8, 9};
    bool has_even = any_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
    cout << "Has even: " << (has_even ? "Yes" : "No") << endl;
}

void demo_none_of() {
    cout << "\n=== none_of ===" << endl;
    vector<int> v = {1, 3, 5, 7, 9};
    bool no_even = none_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
    cout << "No even numbers: " << (no_even ? "Yes" : "No") << endl;
}

void demo_search() {
    cout << "\n=== search ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6, 7};
    vector<int> pattern = {4, 5, 6};
    auto it = search(v.begin(), v.end(), pattern.begin(), pattern.end());
    if (it != v.end()) {
        cout << "Pattern found at position: " << (it - v.begin()) << endl;
    }
}

void demo_min_element() {
    cout << "\n=== min_element ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    auto it = min_element(v.begin(), v.end());
    cout << "Min: " << *it << endl;
}

void demo_max_element() {
    cout << "\n=== max_element ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    auto it = max_element(v.begin(), v.end());
    cout << "Max: " << *it << endl;
}

// ============== MODIFYING ALGORITHMS ==============

void demo_copy() {
    cout << "\n=== copy ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    vector<int> v2(5);
    copy(v.begin(), v.end(), v2.begin());
    cout << "Copied: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
}

void demo_copy_if() {
    cout << "\n=== copy_if ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6};
    vector<int> v2;
    copy_if(v.begin(), v.end(), back_inserter(v2), [](int x) { return x % 2 == 0; });
    cout << "Even numbers: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
}

void demo_transform() {
    cout << "\n=== transform ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    vector<int> v2(v.size());
    transform(v.begin(), v.end(), v2.begin(), [](int x) { return x * 2; });
    cout << "Doubled: ";
    for (int x : v2) cout << x << " ";
    cout << endl;
}

void demo_fill() {
    cout << "\n=== fill ===" << endl;
    vector<int> v(5);
    fill(v.begin(), v.end(), 42);
    cout << "Filled with 42: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_replace() {
    cout << "\n=== replace ===" << endl;
    vector<int> v = {1, 2, 3, 2, 4, 2};
    replace(v.begin(), v.end(), 2, 99);
    cout << "Replaced 2 with 99: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_replace_if() {
    cout << "\n=== replace_if ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    replace_if(v.begin(), v.end(), [](int x) { return x > 3; }, 0);
    cout << "Replace > 3 with 0: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_reverse() {
    cout << "\n=== reverse ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    reverse(v.begin(), v.end());
    cout << "Reversed: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_rotate() {
    cout << "\n=== rotate ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    rotate(v.begin(), v.begin() + 2, v.end());
    cout << "Rotated left by 2: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_remove() {
    cout << "\n=== remove ===" << endl;
    vector<int> v = {1, 2, 3, 2, 4, 2, 5};
    auto new_end = remove(v.begin(), v.end(), 2);
    v.erase(new_end, v.end());
    cout << "After removing 2: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_remove_if() {
    cout << "\n=== remove_if ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5, 6};
    auto new_end = remove_if(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
    v.erase(new_end, v.end());
    cout << "After removing evens: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_unique() {
    cout << "\n=== unique ===" << endl;
    vector<int> v = {1, 1, 2, 2, 3, 3, 3, 4};
    auto new_end = unique(v.begin(), v.end());
    v.erase(new_end, v.end());
    cout << "After removing duplicates: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_shuffle() {
    cout << "\n=== shuffle ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    random_shuffle(v.begin(), v.end());
    cout << "Shuffled: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

// ============== SORTING ALGORITHMS ==============

void demo_sort() {
    cout << "\n=== sort ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    sort(v.begin(), v.end());
    cout << "Sorted: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_sort_descending() {
    cout << "\n=== sort (descending) ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    sort(v.begin(), v.end(), greater<int>());
    cout << "Sorted descending: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_stable_sort() {
    cout << "\n=== stable_sort ===" << endl;
    vector<pair<int, char>> v = {{3, 'a'}, {1, 'b'}, {3, 'c'}, {2, 'd'}};
    stable_sort(v.begin(), v.end());
    cout << "Stable sorted: ";
    for (auto p : v) cout << "(" << p.first << "," << p.second << ") ";
    cout << endl;
}

void demo_partial_sort() {
    cout << "\n=== partial_sort ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    partial_sort(v.begin(), v.begin() + 3, v.end());
    cout << "Partial sorted (first 3): ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_nth_element() {
    cout << "\n=== nth_element ===" << endl;
    vector<int> v = {30, 10, 50, 20, 40};
    nth_element(v.begin(), v.begin() + 2, v.end());
    cout << "After nth_element (n=2): ";
    for (int x : v) cout << x << " ";
    cout << " (3rd smallest = " << v[2] << ")" << endl;
}

// ============== BINARY SEARCH ALGORITHMS ==============

void demo_binary_search() {
    cout << "\n=== binary_search ===" << endl;
    vector<int> v = {10, 20, 30, 40, 50};
    bool found = binary_search(v.begin(), v.end(), 30);
    cout << "30 found: " << (found ? "Yes" : "No") << endl;
}

void demo_lower_bound() {
    cout << "\n=== lower_bound ===" << endl;
    vector<int> v = {10, 20, 30, 30, 40, 50};
    auto it = lower_bound(v.begin(), v.end(), 30);
    cout << "Lower bound of 30: position " << (it - v.begin()) << endl;
}

void demo_upper_bound() {
    cout << "\n=== upper_bound ===" << endl;
    vector<int> v = {10, 20, 30, 30, 40, 50};
    auto it = upper_bound(v.begin(), v.end(), 30);
    cout << "Upper bound of 30: position " << (it - v.begin()) << endl;
}

void demo_equal_range() {
    cout << "\n=== equal_range ===" << endl;
    vector<int> v = {10, 20, 30, 30, 30, 40, 50};
    auto range = equal_range(v.begin(), v.end(), 30);
    cout << "Range of 30: [" << (range.first - v.begin()) << ", " 
         << (range.second - v.begin()) << ")" << endl;
}

// ============== NUMERIC ALGORITHMS ==============

void demo_accumulate() {
    cout << "\n=== accumulate ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    int sum = accumulate(v.begin(), v.end(), 0);
    cout << "Sum: " << sum << endl;
}

void demo_inner_product() {
    cout << "\n=== inner_product ===" << endl;
    vector<int> v1 = {1, 2, 3};
    vector<int> v2 = {4, 5, 6};
    int product = inner_product(v1.begin(), v1.end(), v2.begin(), 0);
    cout << "Dot product: " << product << endl;
}

void demo_partial_sum() {
    cout << "\n=== partial_sum ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    vector<int> result(5);
    partial_sum(v.begin(), v.end(), result.begin());
    cout << "Partial sums: ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

void demo_adjacent_difference() {
    cout << "\n=== adjacent_difference ===" << endl;
    vector<int> v = {1, 3, 6, 10, 15};
    vector<int> result(5);
    adjacent_difference(v.begin(), v.end(), result.begin());
    cout << "Adjacent differences: ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

// ============== SET ALGORITHMS ==============

void demo_set_union() {
    cout << "\n=== set_union ===" << endl;
    vector<int> v1 = {1, 3, 5};
    vector<int> v2 = {2, 3, 4};
    vector<int> result;
    set_union(v1.begin(), v1.end(), v2.begin(), v2.end(), back_inserter(result));
    cout << "Union: ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

void demo_set_intersection() {
    cout << "\n=== set_intersection ===" << endl;
    vector<int> v1 = {1, 2, 3, 4, 5};
    vector<int> v2 = {3, 4, 5, 6, 7};
    vector<int> result;
    set_intersection(v1.begin(), v1.end(), v2.begin(), v2.end(), back_inserter(result));
    cout << "Intersection: ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

void demo_set_difference() {
    cout << "\n=== set_difference ===" << endl;
    vector<int> v1 = {1, 2, 3, 4, 5};
    vector<int> v2 = {3, 4, 5, 6, 7};
    vector<int> result;
    set_difference(v1.begin(), v1.end(), v2.begin(), v2.end(), back_inserter(result));
    cout << "Difference (v1-v2): ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

// ============== OTHER USEFUL ALGORITHMS ==============

void demo_for_each() {
    cout << "\n=== for_each ===" << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    cout << "Elements: ";
    for_each(v.begin(), v.end(), [](int x) { cout << x << " "; });
    cout << endl;
}

void demo_generate() {
    cout << "\n=== generate ===" << endl;
    vector<int> v(5);
    int n = 10;
    generate(v.begin(), v.end(), [&n]() { return n++; });
    cout << "Generated: ";
    for (int x : v) cout << x << " ";
    cout << endl;
}

void demo_merge() {
    cout << "\n=== merge ===" << endl;
    vector<int> v1 = {1, 3, 5};
    vector<int> v2 = {2, 4, 6};
    vector<int> result;
    merge(v1.begin(), v1.end(), v2.begin(), v2.end(), back_inserter(result));
    cout << "Merged: ";
    for (int x : result) cout << x << " ";
    cout << endl;
}

int main() {
    // Non-modifying algorithms
    demo_find();
    demo_find_if();
    demo_count();
    demo_count_if();
    demo_all_of();
    demo_any_of();
    demo_none_of();
    demo_search();
    demo_min_element();
    demo_max_element();

    // Modifying algorithms
    demo_copy();
    demo_copy_if();
    demo_transform();
    demo_fill();
    demo_replace();
    demo_replace_if();
    demo_reverse();
    demo_rotate();
    demo_remove();
    demo_remove_if();
    demo_unique();
    demo_shuffle();

    // Sorting algorithms
    demo_sort();
    demo_sort_descending();
    demo_stable_sort();
    demo_partial_sort();
    demo_nth_element();

    // Binary search algorithms
    demo_binary_search();
    demo_lower_bound();
    demo_upper_bound();
    demo_equal_range();

    // Numeric algorithms
    demo_accumulate();
    demo_inner_product();
    demo_partial_sum();
    demo_adjacent_difference();

    // Set algorithms
    demo_set_union();
    demo_set_intersection();
    demo_set_difference();

    // Other algorithms
    demo_for_each();
    demo_generate();
    demo_merge();

    return 0;
}
