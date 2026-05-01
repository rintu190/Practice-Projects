#include <stack>
#include <queue>
#include <iostream>

using namespace std;

int main(){
    stack<int> st;
    st.push(1);
    st.push(2);
    st.push(3);

    while(!st.empty()){
        cout <<st.top() << " ";
        st.pop();
    }
    cout <<endl;
    //Queue
    queue<int> q;
    q.push(1);
    q.push(2);
    q.push(3);
    while(!q.empty()){
        cout << q.front() << " ";
        q.pop();
    }
    cout <<endl;
}