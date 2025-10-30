# import os
# print(os.getcwd())
f = open("geek.txt","r")
print(f)
content = f.read()
print(content)
print("file name: ",f.name)
print("mode: ",f.mode)
print("isClosed? ",f.closed)
f.close()

#with keyword
with open("geek.txt","r") as file:
    content = file.read()
    print(content)

#try catch
try:
    file = open("geek.txt","r")
    content = file.read()
    print(content)
finally:
    file.close()