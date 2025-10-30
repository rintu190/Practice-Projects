n =10
try:
    res =n / 0
except ZeroDivisionError:
    print("cant be divided")
except (ValueError, TypeError) as e:
    print("Error", e)
else:
    print(res)
finally:
    print("exec completed")

#raise an exception
def set(age):
    if age < 0:
        raise ValueError("Age cannot be negative.")
    print(f"Age set to {age}")

try:
    set(-5)
except ValueError as e:
    print(e)