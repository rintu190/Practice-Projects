#include <set>
#include <unordered_set>
#include <map>
#include <iostream>

using namespace std;

int main() {
    set<int> st = {3,1,4,1,5,9,2,6};
    st.insert(7);
    st.erase(1);

    auto it = st.find(4);
    if(it != st.end()){
        cout << "found: " << *it << endl;
    }
    for( int x : st){
        cout << x << " ";
    }

}