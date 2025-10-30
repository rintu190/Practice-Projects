name = input("Enter name ")
print("Hello",name)

# multiple inputs
x, y, z = input("Enter three value: ").split()
print("No of Students: ",x)
print("No of Boys: ",y)
print("No of Girls: ",z)

#typecasting
n = int(input("how many roses: "))
price = float(input("Price of each rose?: "))
print(n)
print(price)

#find datatypes
a = "Hello World"
b = 10
c = 11.22
d = ("Geeks", "for", "Geeks")
e = ["Geeks", "for", "Geeks"]
f = {"Geeks": 1, "for":2, "Geeks":3}

print(a,type(a))
print(b, type(b))
print(c, type(c))
print(d, type(d))
print(e, type(e))
print(f, type(f))

#output formatting
amount = 250.50
print("amount : ${:.2f}".format(amount))
print('09', '12', '2016', sep='-')

name = 'Tushar'
age = 25
print(f"my name {name} and age is {age}")

num = int(input("Enter a value: "))
sum = num + 5
print("The sum is %d" %sum)