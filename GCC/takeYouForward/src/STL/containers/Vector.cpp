#include <vector>
#include <iostream>

using namespace std;

int main(){
    vector<int> v = {1,2,3,4,5};

    v.push_back(6);
    v.pop_back();
    v[0] = 10;
    v.at(1) = 20;

    for(int x : v){
        cout << x << " ";
    }
    cout << endl;
    cout << "Size: " << v.size() << endl;
    cout << "Capacity: " << v.capacity() << endl;
 }
