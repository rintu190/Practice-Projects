#include <deque>
#include <iostream>

using namespace std;

int main(){
    deque<int> dq = {1,2,3};
    dq.push_back(4);
    dq.push_front(6);

    for(int x : dq){
        cout << x << " ";
    }
    cout << endl;

    dq.pop_back();
    dq.pop_front();

    for(int x : dq){
        cout << x << " ";
    }
    cout << endl;
    
}