#include <iostream>
using namespace std;

class Shape {
    protected:
    int width, height;

    public:
    Shape(int a = 0, int b = 0){
        width = a;
        height = b;
    }
    virtual int area(){
        cout << "parent class area: " << width * height << endl;
        return width * height;
    }
};

class Rectangle : public Shape {
    public:
    Rectangle (int a = 0, int b = 0):Shape(a, b) {}
    int area(){
        cout << "Rectangle area: " << width * height << endl;
        return (width * height);
    }
};

class Trianlge : public Shape {
    public:
    Trianlge(int a = 0, int b = 0) : Shape(a,b) {}
    int area(){
        cout << "triangle area: " << (width * height)/2 << endl;
        return (width * height)/2;
    }
};

int main(){
    Shape *shape;
    Rectangle rec(10,7);
    Trianlge tri(10,5);

    shape = &rec;
    shape -> area();

    shape = &tri;
    shape -> area();

    return 0;
}
