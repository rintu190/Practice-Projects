age = 20

if age >= 18:
    print("eligible")

if age >= 18: print("eligible")

#if else
if age >= 18:
    print("eligible")
else:
    print("not eligible")

result = "eligible" if age >= 18 else "not eligible"

#else if
if age <= 12:
    print("Child.")
elif age <= 19:
    print("Teenager.")
elif age <= 35:
    print("Young adult.")
else:
    print("Adult.")

#nested if
age = 70
is_member = True

if age >= 60:
    if is_member:
        print("30% senior discount!")
    else:
        print("20% senior discount.")
else:
    print("Not eligible for a senior discount.")

#switch case
number = 2
match number:
    case 1:
        print("One")
    case 2 | 3:
        print("Two or Three")
    case _:
        print("Other number")