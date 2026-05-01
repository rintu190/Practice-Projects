#include <set>
#include <unordered_set>
#include <map>
#include <iostream>

using namespace std;

int main() {
    //set - ordered and unique
    set<int> st = {3,1,4,1,5,9,2,6};
    st.insert(7);
    st.erase(1);

    auto it = st.find(4);
    if(it != st.end()){
        cout << "found in set: " << *it << endl;
    }
    for( int x : st){
        cout << x << " ";
    }

    //multiset - ordered  but not unique
    multiset<int> ms = {1,2,2,3,3,3};
    ms.insert(4);
    auto countMS = ms.count(3);
    cout << endl << "count of 3 in multiset:" << countMS << endl;

    //unordered set - unique but not ordered
    unordered_set<int> us = {5,2,8,1,9};
    us.insert(3);
    us.erase(2);
    auto countUS = us.count(5);
    cout << "count of 5 in unordered set: " << countUS << endl ;

    //unordered multiset - not unique and not ordered
    unordered_multiset<int> ums = {1, 2, 2, 3, 3, 3};
    
    ums.insert(4);
    auto countUMS = ums.count(3);
    
    cout << "Count of 3 in unordered multiset: " << countUMS << endl;
    

}