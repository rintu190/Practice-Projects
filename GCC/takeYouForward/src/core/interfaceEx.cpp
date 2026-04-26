#include <iostream>
using namespace std;

class Shape {
    protected:
      int width;
      int height;
    public:
    virtual int getArea() = 0;
    
    void setWidth(int w){
        width = w;
    }
    void setHeight(int h) {
        height = h;
    }
};
class Rectangle: public Shape{
    public:
    int getArea(){
        return width * height;
    }
};
class Triangle: public Shape{
    public:
    int getArea(){
        return (width * height) / 2;;
    }
};

int main(){
    Rectangle rectangle;
    Triangle triangle;

    rectangle.setHeight(5);
    rectangle.setWidth(7);
    cout << "rectangle area: " << rectangle.getArea() << endl;

    triangle.setHeight(5);
    triangle.setWidth(8);
    cout << "rectangle area: " << triangle.getArea() << endl;

    return 0;

}