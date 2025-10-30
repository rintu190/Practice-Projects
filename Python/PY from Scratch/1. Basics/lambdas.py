from functools import reduce

s1 = "lambda test"
s2 = lambda fun:fun.upper()
print(s2(s1))

n = lambda x: "Positive" if x>0 else "Negative" if x < 0 else "zero"
print(n(-3))

#lambda with list
li = [lambda arg = x: arg *10 for x in range(1,5)]
for i in li:
    print(i())

#lambda if else
check = lambda x:"even" if x*2 ==0 else "odd"
print(check(7))

#lambda multiple statement
calc = lambda x,y:(x+y,x*y)
print(calc(4,5))


n = [1,2,3,4,5,6]

#lambda filter
even = filter(lambda x: x%2 == 0,n)
print(list(even))

#lambda map
b = map(lambda x: x*2,n)
print(list(b))

#lambda reduce
c = reduce(lambda x,y : x * y, n)
print(c)