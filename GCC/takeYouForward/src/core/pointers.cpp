#include <iostream>
#include <memory>
using namespace std;

int main(){
    int var = 20;
    int *ip;

    ip = &var;  //modify pointer

    cout << var << endl;
    cout << ip << endl;
    cout << *ip << endl;

    //pointer vs reference
    int number = 42;
    int *ptr = &number;
    int &ref = number;

    cout << *ptr <<" "<< ref << endl;
    *ptr = 100;
    cout << number <<" "<< ref << endl;
    ref = 200;
    cout << *ptr <<" "<< number << endl;
    cout << ptr <<" "<< &ref << endl;

    //meory leak and dangling pointer and delete pointer
    int *ptr1 = new int(10); //memory leak
    int *ptr2 = new int(100);
    delete ptr2; //dangling pointer

    delete ptr1;
    ptr1 = nullptr; //how to delete and clear a ptr

    //Smart Pointers
    unique_ptr<int> ptr1 = make_unique<int>(200);
    unique_ptr<int> ptr2 = move(ptr1);

    shared_ptr<int> ptr3 = make_shared<int>(300);
    shared_ptr<int> ptr4 = ptr3;

    shared_ptr<int> owner = make_shared<int>(400);
    weak_ptr<int> observer = owner;
    if (auto locked = observer.lock())
    {
        cout << "Object value: " << *locked << endl;
    }
    owner.reset();


    return 0;
}