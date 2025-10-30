# Numeric - int, float, complex
# Sequence Type - string, list, tuple
# Mapping Type - dict
# Boolean - bool
# Set Type - set, frozenset
# Binary Types - bytes, bytearray, memoryview

a = 5       #int
b = 5.0     #float
c = 2 + 4j  #complex

#string
s = "welcome to python"
print(s[1],s[2],s[-1])

#list
str1 = []
str2 = [1,2,3]
str3 = ["welcome","to","python",100,237.45]
print(str3[1],str3[2],str3[-1],str3[-3])

#Tuple
tup1 = ()
tup2 = ("welcome","to","python")
print(tup2[1],tup2[-1])

#set
S1 = set()
s2 = set("welcome to python")
s3 = set(["python","to","python"])
print(s2)
print(s3)

for i in s3:
    print(i,end = " ")

#dictionary
d1 = {}
d2 = {1: 'welcome', 2: 'to', 3: 'python'}
d3 = dict({1:'dictionary', 'name': 'by', 3: 'constructor'})

print(d3['name'])
print(d3.get(3))

