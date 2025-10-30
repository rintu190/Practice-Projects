#----------variables-------------
a = b = c = 100
print(a,b,c)

x, y, z = 1, 2.5, 'Python'
print(x,y,z)

s = "100"
n = int(s)
v = 35
m = str(v)
print (n,m)

#delete variable
x =10
print(x)
del x

#swap variables
a, b = 5, 10
a, b = b, a
print("swapped",a, b)

#count chars
word = "gajendra"
length = len(word)
print(length)

#---------Operators------------------
#arithmetic :- +, -, *, /, //, %,**
#comparison :- >, <, ==, !=, >=, <=
#logical :- and, or, not
#identity :- is not, is
#bitwise :-
a = 15
b = 9
#Bitwise AND
print(a & b)

#Bitwise OR
print(a | b)

#Bitwise NOT
print(~a)

#Bitwise XOR
print(a ^ b)

#Bitwise Shift Right
print(a >> 2)

#Bitwise Shift Left
print(a << 2)

#assignment  :-
a = 10
b = a
print(b)
b += a
print(b)
b -= a
print(b)
b *= a
print(b)
b <<= a
print(b)

#membership :-
x = 24
y = 10

list = [1,2,3,24,10,54]
if(x not in list):
    print("x absent")
if(y in list):
    print("y present")

#ternary :-
a,b = 10,20
min = a if a < b else b

#Precedene and Associativity





