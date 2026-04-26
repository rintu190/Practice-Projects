#include <iostream>
using namespace std;

class Car {
    public:
    void drive(){
        cout << "driving on land" << endl;
    }
};
class Boat {
    public:
    void sail(){
        cout << "sailing in water" << endl;
    }
};

class DualMode : public Car, public Boat {
    public:
    void use(){
        drive();
        sail();
    }
};


class Derived1 : virtual public Car {};  // Virtual inheritance
class Derived2 : virtual public Car {};  // Virtual inheritance
class Final : public Derived1, public Derived2 {};

int main() {
    DualMode vehicle;
    vehicle.use();


    Final object;
    object.drive();
    return 0;
}