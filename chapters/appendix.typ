#import "../utils.typ": *

#set heading(level: 1, numbering: none)

#set heading(
  level: 2,
  supplement: "Appendix",
  numbering: (..nums) => 
    "A." +
    nums
      .pos()
      .enumerate()
      .filter(xs => xs.at(0) > 0)
      .map(xs => str(xs.at(1)))
      .join(".")
)

= Appendix
== Planned Vacation Days <paid-vacation-days-code>
#todo[This might need to be updated]
```cpp
/*
Paid vacation days

R1 The number of paid vacation days depends on age and years of service. Every employee receives at least 22 days per year.

Additional days are provided according to the following criteria:
R2-1 Employees younger than 18 or at least 60 years, or employees with at least 30 years of service will receive 5 extra days.
R2-2 Employees of age 60 or more with at least 30 years of service receive 3 extra days, on top of possible additional days already given based on R2-1. 
R2-3 If an employee has at least 15 years of service, 2 extra days are given. These two days are also provided for employees of age 45 or more. These extra days cannot be combined with the other extra days.

Display the vacation days. The ages are integers and calculated with respect to the last day of December of the current year.
*/

var age: int
var service: int

// R1
if(age < 18 && service < 30)
if(age >= 60 && service < 30)
if(service >= 30 && age < 60 && age >= 18)

// R1-2
if(service >= 30 && age >= 60)

// R1-3
if(service >= 15 && age < 45 && age >= 18 && service < 30)
if(age >= 45 && service < 30 && age < 60)

```
