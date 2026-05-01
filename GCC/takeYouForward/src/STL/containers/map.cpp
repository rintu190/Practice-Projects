#include <map>
#include <iostream>
#include <string>
#include <unordered_map>

using namespace std;

int main(){
    map<string,int> m = {
        {"apple", 5},
        {"orange",7},
        {"banana", 12}
    };
    m["grape"] = 4;
    m.insert({"kiwi", 7});

    cout << m["apple"] << endl;
    m.erase("banana");

    auto it = m.find("orange");
    if (it != m.end()){
        cout << it->first << ":" << it->second << endl;
    }
    for(auto& p : m){
        cout << p.first << " " << p.second << endl;
    }

    //multimap
    multimap<int, string> mm;
    mm.insert({1, "one"});
    mm.insert({1,"uno"});
    mm.insert({2,"two"});

    auto range = mm.equal_range(1);
    for(auto it = range.first; it != range.second;++it){
        cout << it-> first <<" : " << it->second << endl;
    }

    //unordered map
    unordered_map<string, int> um = {
        {"apple", 5},
        {"banana", 3}
    };
    
    um["orange"] = 7;
    cout << um["apple"] << endl;
    
    if (um.find("banana") != um.end()) {
        cout << "Found banana" << endl;
    }
    
    for (auto& p : um) {
        cout << p.first << " -> " << p.second << endl;
    }

    //unordered multimap
    unordered_multimap<int, string> umm;
    umm.insert({1, "one"});
    umm.insert({1, "uno"});
    umm.insert({2, "two"});
    
    auto range = umm.equal_range(1);
    for (auto it = range.first; it != range.second; ++it) {
        cout << it->second << " ";
    }




}