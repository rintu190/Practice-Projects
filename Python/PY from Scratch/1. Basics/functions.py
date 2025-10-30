def fun():
    print("welcome to function")
fun()

def evenodd(x:int) -> str :
    if(x % 2 == 0):
        return 'even'
    else:
        return 'odd'
print(evenodd(16))
print(evenodd(7))

#default Parameter
def myFun(x,y=50):
    print(x)
    print(y)
myFun(10)

#keyword arguments
def student(fname,lname):
    print(fname,lname)
student(fname="gajendra",lname="bagha")

#position arguments
def nameAge(name,age):
    print("name is ",name)
    print("age is ",age)
nameAge("rintu","35")
nameAge("40","Gajendra")

#arbitrary arguments
def arbFun(*args):
    for arg in args:
        print(arg)
arbFun("hello","welcome","to","python")

#docstring
def docstringFun(x):
    """docstring test line in a function"""
    print(x)
print(docstringFun.__doc__)

#nested/inner function
def f1():
    s="f1 method"
    def f2():
        print(s)
    f2()
f1()

#anonymous function using lambda k/w
def cube(x): return x*x*x
cube1 = lambda x : x*x*x
print(cube1(5))

#python parameters always pass by reference
def myfun(x):
    x =20
x =10
myfun(x)
print(x)

#recursive function
def factorial(n):
    if n == 0:
        return 1
    else:
        return n * factorial(n - 1)
print("factorial recursive :-",factorial(5))