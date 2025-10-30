#classes and Objects
class Dog:
    species = "Canine"
    def __init__(self, name, age):
        self.name = name
        self.age = age

dogInstance1 = Dog("kutta 1",3)
dogInstance2 = Dog("kutta 2", 5)

print(dogInstance1.species)
print(dogInstance1.name)
print(dogInstance2.name)

    #instance var update
dogInstance1.name ="kuttiya 1"
    #class var update
Dog.species = "feline"

print(dogInstance1.species)
print(dogInstance2.species)

#Inheritance
class Dog:
    def __init__(self,name):
        self.name = name
    def display_name(self):
        print(f"dogs' name: {self.name}")
#Single
class Labrador(Dog):
    def sound(self):
        print("labrador woofs")

#Multi Level
class GuideDog(Labrador):
    def guide(self):
        print(f"{self.name} guides the way!")

#Multiple
class Friendly:
    def greet(self):
        print("Friendly!")
class GoldenRetriever(Dog, Friendly):
    def sound(self):
        print("golden retriever barks")

lab = Labrador("lab buddy")
lab.display_name()
lab.sound()

guide =  GuideDog("guide max")
guide.display_name()
guide.guide()

retriever = GoldenRetriever("gold charlie")
retriever.display_name()
retriever.greet()
retriever.sound()

#Polymorphism
class Vehicle:
    def sound(self):
        print("vehicle sounds")
#run time | overriding
class Car(Vehicle):
    def sound(self):
        print("voom")
class Train(Vehicle):
    print("ooo ooo")

#compile time | overloading
class Calculator:
    def add(self, a, b =0, c =0):
        return a + b + c

#Run time Polymorphism        
vehicles = [Vehicle(), Car(), Train()]
for vehicl in vehicles:
    vehicl.sound()

#Compile time Polymorphism
calc = Calculator()
print(calc.add(5,10))
print(calc.add(5,10,15))

#Encapsulation
class Dog:
    def __init__(self, name, breed, age):
        self.name = name        #public
        self._breed = breed     #protected
        self.__age = age        #private
    def get_info(self):
        return f"Name: {self.name}, Breed: {self._breed}, Age: {self.__age}"
    def get_age(self):
        return self.__age
    def set_age(self, age):
        if age > 0:
            self.__age = age
        else:
            print("invalid age")
dogInstance3 = Dog("Buddy", "Labrador", 3)
print(dogInstance3.name)
print(dogInstance3._breed)
print(dogInstance3.get_age())
dogInstance3.set_age(4)
print(dogInstance3.get_info())

#Abstraction
# Partial Abstraction: Abstract class contains both abstract and concrete methods.
# Full Abstraction: Abstract class contains only abstract methods (like interfaces).
from abc import ABC, abstractmethod

class Dog(ABC):
    def __init__(self, name):
        self.name = name
    @abstractmethod
    def sound(self):
        pass
    def display(self):
        print(f"dogs name: {self.name}")
class Labrador(Dog):
    def sound(self):
        print("labrador woofs")
class Beagle(Dog):
    def sound(self):
        print("beagle bark")
dogs = [Labrador("lab buddy"), Beagle("bgl charlie")]
for dog in dogs:
    dog.display()
    dog.sound()