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
== Planned Vacation Days <paid_vacation_days.gpt-code>
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

== Price Calculation <price_calculation.gpt-code>
```cpp
/*
Price calculation
R1 The customer gets 10% price reduction if the price of the goods reaches 200 euros.
R2 The delivery is free if the weight of the goods is under 5 kilograms. 
   Reaching 5 kg, the delivery price is the weight in euros, thus, when the products together are 6 kilograms then the delivery price is 6 euros. 
   However, the delivery remains free if the price of the goods exceeds 100 euros.
R3 If the customer prepays with a credit card, then s/he gets 3% price reduction from the (possibly reduced) price of the goods.
R4 The output is the price to be paid. The minimum price difference is 0.1 euro, the minimum weight difference is 0.1 kg.
*/

var prepaid_with_credit_card: bool
var price: num(0.1)
var weight: num(0.1)

// R1
if(price >= 200)

// R2
if(weight >= 5 && price <= 100)

// R3
if(prepaid_with_credit_card == true)
```

== complex_small.gpt <complex_small.gpt-code>
```cpp
var x: num
var y: num
var z: num

if(x != 1 || y != 1 || z != 1)
else if(x != 2 || y != 2 || z != 2)
else

if(x != 10 || y != 20)
else if(x != 2)
else
```

== complex_medium.gpt <complex_medium.gpt-code>
```cpp
var x: num
var y: num
var z: num

if(x != 1 || y != 1 || z != 1)
else if(x != 2 || y != 2 || z != 2)
else

if(x != 10 || y != 20)
else if(x != 2)
else if(z == 3)
else
```

== complex_hard.gpt <complex_hard.gpt-code>
```cpp
var x: num
var y: num
var z: num

if(x != 1 || y != 1 || z != 1)
else if(x != 2 || y != 2 || z != 2)
else if(x != 3 || y != 3 || z != 3)
else


if(x != 10 || y != 20)
else if(x != 2)
else if(x != 3 && y != 3 && z != 3)
else if(x != 4 && y != 4 && z != 4)
else
```
