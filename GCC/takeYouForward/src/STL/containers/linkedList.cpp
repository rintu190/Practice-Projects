#include <list>
#include <forward_list>
#include <iostream>

using namespace std;

int main(){
    //Doubly Linked List
    list<int> doubleList = {1,2,3,4,5};
    doubleList.push_back(7);
    doubleList.push_front(0);

    for (int x : doubleList){
        cout << x <<" ";
    }
    cout << endl;

    doubleList.pop_back();
    doubleList.pop_front();

    for (int x : doubleList) {
        cout << x <<" ";
    }
    cout << endl;

    //Singly Linked List
    forward_list<int> list = {1,2,3,4,5};
    list.push_front(0);
    list.pop_front();

    auto it = list.begin();

    cout << *it << endl;
    
    list.erase_after(it);

    for(int x : list){
        cout << x << " ";
    }
    cout << endl;
}



