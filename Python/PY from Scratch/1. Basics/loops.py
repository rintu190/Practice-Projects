count = 0
while (count < 3):
    count = count + 1
    print("hello")

cnt = 0
while (cnt < 3):
    cnt = cnt + 1
    print("Hello Geek")
else:
    print("In Else Block")

for i in range(1,5):
    for j in range(i):
        print(i, end = ' ')
    print()

#contiue
for letter in 'geeksforgeeks':
    if letter == 'e' or letter == 's':
        continue
    print('Current Letter :', letter)

#break
for letter in 'geeksforgeeks':
    if letter == 'e' or letter == 's':
        break
print('Current Letter :', letter)

#pass - to write empty loop
for letter in 'geeksforgeeks':
    pass
print('Last Letter :', letter)

#for loop
fruits = ["apple", "orange", "kiwi"]
for fruit in fruits:
    print(fruit)

fruits = ["apple", "orange", "kiwi"]
iter_obj = iter(fruits)
while True:
    try:
        fruit = next(iter_obj)
        print(fruit)
    except StopIteration:
        break