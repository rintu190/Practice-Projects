#include <bits/stdc++.h>

using namespace std;

void printPattern1(int n){
    for(int i = 0; i < n; i++){
        for( int j = 0; j < n; j++){
            cout << "* ";
        }
        cout << endl;
    }
}

int main(){
    cout << "Hello, World!" << endl;
    printPattern1(5);
}