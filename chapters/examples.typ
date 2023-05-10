#import "../utils.typ": *

= Examples in GPT

== Paid Vacation Days

I'll show an example requirement set and test generation with the Paid Vacation Days example @thebook[p. 100]. With this we can see how my implementation differs from the algorithm proposed by Kovacs Attila and Forgacs Istvan. I'll refer to it as "the book" from now on.

#line(length: 100%, stroke: 2pt + gray)
*Paid vacation days*

- R1: The number of paid vacation days depends on age and years of service. Every employee receives at least 22 days per year.

Additional days are provided according to the following criteria:
- R2-1: Employees younger than 18 or at least 60 years, or employees with at least 30 years of service will receive 5 extra days.
- R2-2: Employees of age 60 or more with at least 30 years of service receive 3 extra days, on top of possible additional days already given based on R2-1. 
- R2-3: If an employee has at least 15 years of service, 2 extra days are given. These two days are also provided for employees of age 45 or more. These extra days cannot be combined with the other extra days.

Display the vacation days. The ages are integers and calculated with respect to the last day of December of the current year.
#line(length: 100%, stroke: 2pt + gray)

Let's look at the if statements one by one and compare the generated test cases. Note: this is without graph reduction. The test cases from the book will have an ID starting with B, my GPT implementation will have an M prefix.

The full GPT Lang definition can be found in @paid-vacation-days-code.

#pagebreak()

*R1-1: IF age < 18 AND service < 30 THEN...*

In the book, the test cases are:

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B1], [ON: age = 17, service = 29],
  [B2], [OFF1: age = 18, service < 30],
  [B3], [IN: age << 18, service << 30],
  [B4], [OUT1 age > 18, service < 30],
  [B5], [OFF2: age < 18, service = 30],
  [B6], [OUT2: age < 18, service > 30]
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M1], [age: $(-infinity, 17]$, service: $(-infinity, 29]$], [-],
  [M2], [age: $[17, 17]$, service: $[29, 29]$], [B1],
  [M3], [age: $(-infinity, 16]$, service: $(-infinity, 28]$], [B3],
  [M4], [age: $(-infinity, 17]$, service: $[30, 30]$], [B5],
  [M5], [age: $(-infinity, 17]$, service: $[31, infinity)$], [B6],
  [M6], [age: $[18, 18]$, service: $(-infinity, 29]$], [B2],
  [M7], [age: $[19, infinity)$, service: $(-infinity, 29]$], [B4]
)

As we can see, my GPT covers all the test cases in the book, but has an additional test case: M1. This is, because in the book B3 is said to be an IN, but it is actually an ININ. M1 in this case is the IN. This is, because in the book In and ININ are not differentiated this concretely. Because ININ is a subset of IN it is actually enough to generate the ININ for an interval.

I'm generating both the IN and the ININ, because there could be intervals which have an IN but not ININ (for example $[0,0.1]$ if the precision is $0.1$.). It is easier to generate both the IN and ININ and let Graph Reduction take care of joining the intervals.

#pagebreak()

*R1-1: IF age ≥ 60 AND service < 30 THEN...*

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B7], [ON: age = 60, service = 29],
  [B8], [OFF1: age = 59, service < 30],
  [B9], [OFF2: age ≥ 60, service = 30],
  [B10], [IN: age > 60, service << 30],
  [B11], [OUT1 age << 60, service < 30],
  [B12], [OUT2: age ≥ 60, service > 30]
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M8], [age: $[60, infinity)$, service: $(-infinity, 29]$], [-],
  [M9], [age: $[60, 60]$, service: $[29, 29]$], [B7],
  [M10], [age: $[61, infinity)$, service: $(-infinity, 28]$], [B10],
  [M11], [age: $[59, 59]$, service: $(-infinity, 29]$], [B8],
  [M12], [age: $(-infinity, 58]$, service: $(-infinity, 29]$], [B11],
  [M13], [age: $[60, infinity)$, service: $[30, 30]$], [B9],
  [M14], [age: $[60, infinity)$, service: $[31, infinity)$], [B12],
)

As we can see here as well, my GPT covered all the test cases from the book. The additional test case M8 is the IN, for the same reason as previously.

#pagebreak()

*R1-1: IF service ≥ 30 AND age < 60 AND age ≥ 18 THEN...*

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B13], [OUT1: age << 18, service ≥ 30],
  [B14], [OFF1: age = 17, service ≥ 30],
  [B15], [ON1/IN2: age = 18, service > 30],
  [B16], [ON2: age = 59, service = 30],
  [B17], [OFF2: age < 60 && age ≥ 18, service = 29],
  [B18], [OUT2: age < 60 && age ≥ 18, service << 30],
  [B19], [OFF3: age = 60, service ≥ 30],
  [B20], [OUT3: age > 60, service ≥ 30]
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M15], [age: $[18, 59]$, service: $[30, infinity)$], [-],
  [M16], [age: $[18, 18]$, service: $[30, 30]$], [-],
  [M17], [age: $[59, 59]$, service: $[30, 30]$], [B16],
  [M18], [age: $[19, 58]$, service: $[31, infinity)$], [-],
  [M19], [age: $[18, 59]$, service: $[29, 29]$], [B17],
  [M20], [age: $[18, 59]$, service: $(-infinity, 28]$], [B18],
  [M21], [age: $[17, 17]$, service: $[30, infinity)$], [B14],
  [M22], [age: $[60, 60]$, service: $[30, infinity)$], [B19],
  [M23], [age: $(-infinity, 16]$, service: $[30, infinity)$], [B13],
  [M24], [age: $[61, infinity)$, service: $[30, infinity)$], [B20]
)

Here we can see a difference between my GPT and the book. In my implementation, the two different predicates for age (age < 60 AND age ≥ 18) get merged to one Interval: $[18, 60)$.

For B15 I don't have an exact test case. This is because B15 combined the ON1 and the IN2. I have a separate test case for ON1 with M16 and a separate one for IN2 with M18.

M15 is the IN, as discussed previously.

All in all, with analyzing B15 we can say that my test cases cover the ones in the book.

#pagebreak()

*R1-2: IF service ≥ 30 AND age ≥ 60 THEN...*

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B21], [OUT1: age << 60, service ≥ 30],
  [B22], [OFF1: age = 59, service ≥ 30],
  [B23], [ON: age = 60, service = 30],
  [B24], [OFF2: age ≥ 60, service = 29],
  [B25], [IN: age > 60, service > 30],
  [B26], [OUT2: age ≥ 60, service << 30]
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M25], [age: $[60, infinity)$, service: $[30, infinity)$], [-],
  [M26], [age: $[60, 60]$, service: $[30, 30]$], [B23],
  [M27], [age: $[61, infinity)$, service: $[31, infinity)$], [B25],
  [M28], [age: $[60, infinity)$, service: $[29, 29]$], [B24],
  [M29], [age: $[60, infinity)$, service: $(-infinity, 28]$], [B26],
  [M30], [age: $[59, 59]$, service: $[30, infinity)$], [B22],
  [M31], [age: $(-infinity, 58]$, service: $[30, infinity)$], [B21],
)

All the test cases from the book are covered. M25 is the IN, as mentioned previously.

#pagebreak()

*R1-3: IF service ≥ 15 AND age < 45 AND age ≥ 18 AND service < 30 THEN...*

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B27], [OUT1: age << 18, service ≥ 15 && service < 30],
  [B28], [OFF1: age = 17, service ≥ 15 && service < 30],
  [B29], [OFF2: age < 45 && age ≥ 18, service = 14],
  [B30], [ON1: age = 18, service = 15],
  [B31], [OFF3: age < 45 && age ≥ 18, service = 30],
  [B32], [OUT2: age < 45 && age ≥ 18, service > 30],
  [B33], [OUT3: age < 45 && age >= 18, service << 15],
  [B34], [ON2: age = 44, service = 29],
  [B35], [OFF4: age = 45, service ≥ 15 && service < 30],
  [B36], [OUT4: age > 45, service ≥ 15 and service < 30],
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M32], [age: $[18, 44]$, service: $[15, 29]$], [-],
  [M33], [age: $[18, 18]$, service: $[15, 15]$], [B30],
  [M34], [age: $[44, 44]$, service: $[15, 15]$], [-],
  [M35], [age: $[18, 18]$, service: $[29, 29]$], [-],
  [M36], [age: $[44, 44]$, service: $[29, 29]$], [B34],
  [M37], [age: $[19, 43]$, service: $[16, 28]$], [-],
  [M38], [age: $[18, 44]$, service: $[14, 14]$], [B29],
  [M39], [age: $[18, 44]$, service: $[30, 30]$], [B31],
  [M40], [age: $[18, 44]$, service: $(-infinity, 13]$], [B33],
  [M41], [age: $[18, 44]$, service: $[31, infinity)$], [B32],
  [M42], [age: $[17, 17]$, service: $[15, 29]$], [B28],
  [M43], [age: $[45, 45]$, service: $[15, 29]$], [B35],
  [M44], [age: $(-infinity, 16]$, service: $[15, 29]$], [B27],
  [M45], [age: $[46, infinity)$, service: $[15, 29]$], [B36],
)

All the test cases from the book are covered by my GPT. 

M32 is the IN as explained previously. 

M33 and M35 are ON points. My GPT merges treats service as $[15, 30)$ and age as $[18, 45)$. When generating ON points age will have 18 and 44, service will have 15 and 29. My GPT takes the Cartesian product of these, that's why M34 and M35 appeared, in addition to M36 which is in the book as B34.

M37 is the ININ of the intervals. The books says, that the ON points are also IN points, that's why there are no explicit IN intervals. As discussed previously, my GPT generates both IN and ININ points, so this ININ appeared. Which is not a problem, as it is a valid test case.

// #pagebreak()
\


*R1-3: IF age ≥ 45 AND service < 30 AND age < 60 THEN...*

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [B37], [OUT1: age << 45, service < 30],
  [B38], [OFF2: age = 44, service < 30],
  [B39], [ON1: age = 45, service = 29],
  [B40], [OFF2: age ≥ 45 && age < 60, service = 30],
  [B41], [OUT2: age ≥ 45 && age < 60, service > 30],
  [B42], [ON2: age = 59, service << 30],
  [B43], [OFF3: age = 60, service < 30],
  [B44], [OUT: age > 60, service < 30]
)

With my GPT:
#table(
  columns: (auto, auto, auto),
  [No.], [Test Case], [Book No.],
  [M46], [age: $[45, 59]$, service: $(-infinity, 29]$], [-],
  [M47], [age: $[45, 45]$, service: $[29, 29]$], [B39],
  [M48], [age: $[59, 59]$, service: $[29, 29]$], [-],
  [M49], [age: $[46, 58]$, service: $(-infinity, 28]$], [-],
  [M50], [age: $[44, 44]$, service: $(-infinity, 29]$], [B38],
  [M51], [age: $[60, 60]$, service: $(-infinity, 29]$], [B43],
  [M52], [age: $(-infinity, 43]$, service: $(-infinity, 29]$], [B37],
  [M53], [age: $[61, infinity)$, service: $(-infinity, 29]$], [B44],
  [M54], [age: $[45, 59]$, service: $[30, 30]$], [B40],
  [M55], [age: $[45, 59]$, service: $[31, infinity)$], [B41],
)

All the test cases in the book are covered, except for B42. B42 is the combination of an ON and an ININ. The ININ for service (and age) is M49. The ON for age is M48.

M46 is the IN, same as previously.

#pagebreak()

*Summary*

In total, the book has 44 test cases, my GPT generated 55 test cases. 

The 11 test cases not in the book are:
- M1, M8, M15, M25, M32, M46 are INs (+6 test cases)
- M37 is an ININ (+1 test case)
- B42 -> M47 + M48 (+1 test case)
- B15 -> M16 + M18 (+1 test case)
- M34 and M35 are additional ONs (+2 test cases)

// #pagebreak()

*After graph reduction*

// With my GPT and MONKE:
// #table(
//   columns: (auto, auto),
//   [No.], [Test Case],
//   [#1], [age: $[17, 17]$, service: $[29, 29]$],
//   [#2], [age: $[59, 59]$, service: $[30, 30]$],
//   [#3], [age: $(-infinity, 16]$, service: $[15, 28]$],
//   [#4], [age: $[18, 18]$, service: $(-infinity, 13]$],
//   [#5], [age: $[45, 59]$, service: $[31, infinity)$],
//   [#6], [age: $(-infinity, 16]$, service: $[30, 30]$],
//   [#7], [age: $[17, 17]$, service: $[31, infinity)$],
//   [#8], [age: $[61, infinity)$, service: $[15, 28]$],
//   [#9], [age: $[60, 60]$, service: $[29, 29]$],
//   [#10], [age: $[18, 18]$, service: $[15, 15]$],
//   [#11], [age: $[60, 60]$, service: $[30, 30]$],
//   [#12], [age: $[60, 60]$, service: $[31, infinity)$],
//   [#13], [age: $[18, 18]$, service: $[29, 29]$],
//   [#14], [age: $[46, 58]$, service: $(-infinity, 28]$],
//   [#15], [age: $[19, 44]$, service: $[31, infinity)$],
//   [#16], [age: $[18, 18]$, service: $[30, 30]$],
//   [#17], [age: $[44, 44]$, service: $[15, 15]$],
//   [#18], [age: $[18, 44]$, service: $[14, 14]$],
//   [#19], [age: $[44, 44]$, service: $[29, 29]$],
//   [#20], [age: $[45, 45]$, service: $[29, 29]$],
//   [#21], [age: $[19, 43]$, service: $[16, 28]$],
//   [#22], [age: $[61, infinity)$, service: $[31, infinity)$],
//   [#23], [age: $[59, 59]$, service: $[29, 29]$],
// )

With my GPT and Least Losing Edges:

#table(
  columns: (auto, auto),
  [No.], [Test Case],
  [#1], [age: $[17, 17]$, service: $[29, 29]$],
  [#2], [age: $[45, 45]$, service: $[29, 29]$],
  [#3], [age: $(-infinity, 16]$, service: $[15, 28]$],
  [#4], [age: $[18, 18]$, service: $[29, 29]$],
  [#5], [age: $[46, 58]$, service: $[15, 28]$],
  [#6], [age: $[17, 17]$, service: $[30, 30]$],
  [#7], [age: $(-infinity, 16]$, service: $[31, infinity)$],
  [#8], [age: $[44, 44]$, service: $[15, 15]$],
  [#9], [age: $[44, 44]$, service: $[29, 29]$],
  [#10], [age: $[18, 18]$, service: $[15, 15]$],
  [#11], [age: $[59, 59]$, service: $[29, 29]$],
  [#12], [age: $[18, 44]$, service: $[31, infinity)$],
  [#13], [age: $[18, 44]$, service: $[14, 14]$],
  [#14], [age: $[61, infinity)$, service: $[31, infinity)$],
  [#15], [age: $[18, 44]$, service: $(-infinity, 13]$],
  [#16], [age: $[18, 18]$, service: $[30, 30]$],
  [#17], [age: $[59, 59]$, service: $[30, 30]$],
  [#18], [age: $[45, 58]$, service: $[31, infinity)$],
  [#19], [age: $[60, 60]$, service: $[29, 29]$],
  [#20], [age: $[60, 60]$, service: $[30, 30]$],
  [#21], [age: $[61, infinity)$, service: $(-infinity, 28]$],
  [#22], [age: $[19, 43]$, service: $[16, 28]$],
)

#pagebreak()

*Conclusion*

In the book, the number of reduced test cases is 18. This is 40.9% of the original 44 test set.

My GPT with MONKE reduced the number of test cases to 22. This is 40% of the original test set.

In conclusion, my GPT implementation generated all the test cases that were mentioned in the book. It also generated a few more test cases, but most of them can be reduced with Graph Reduction. The graph reduction reduced the number of test cases by a similar percentage than the reduction in the book.

*Hypothesis:* The 4 additional test cases in the reduced test set are because of M34, M35 (ONs), the breaking of B42 into M47 + M48, and breaking B15 into M16 + M18. These are additional test cases which weren't in the book and these NTuples (test cases) can't be intersected with other NTuples, so they remain in the reduced graph. We can see, that #8 is M34, #4 is M35. I couldn't really trace back the effect of B42 and B15.

#pagebreak()

*Let's make use of `||` in GPT Lang*

"R2-1 Employees younger than 18 or at least 60 years, or employees with at least 30 years of service will receive 5 extra days."

The wording or R2-1 uses 'or's. In the book this was written only with conjunctions. In GPT Lang it looked like this:
```cpp
if(age < 18 && service < 30)
if(age >= 60 && service < 30)
if(service >= 30 && age < 60 && age >= 18)
```

But we can write it in GPT Lang with `||`s: 
```cpp
if(age < 18 || age >= 60 || service >= 30)
```

As we can see, it is significantly easier to write, and we don't have to think about how to manually create conjunctions and cover all the cases, as GPT does that for us.

// Generating test cases from the `||` version:
// #table(
//   columns: (auto, auto, auto),
//   [No.], [Test Case], [R1-1 No.],
//   [M001], [age: $[17, 17]$, service: $[30, infinity)$], [M21],
//   [M002], [age: $[18, 18]$, service: $[30, 30]$], [M16],
//   [M003], [age: $(-infinity, 16]$, service: $[30, infinity)$], [M23],
//   [M004], [age: $[18, 18]$, service: $(-infinity, 28]$], [-],
//   [M005], [age: $[19, 58]$, service: $[31, infinity)$], [M18],
//   [M006], [age: $[60, 60]$, service: $[30, infinity)$], [M22],
//   [M007], [age: $[18, 59]$, service: $[29, 29]$], [M19],
//   [M008], [age: $[61, infinity)$, service: $[30, infinity)$], [M24],
//   [M009], [age: $[59, 59]$, service: $[30, 30]$], [M17],
// )

// M004 is almost like M6, but M6 contains 29 and M004 doesn't.

// As we can see, this only generated 9 test cases. This is significantly less than 24 generated previously. This is, because `||` is sensitive to the order of the predicates, as described in #todo[ref chapter that describes the execution order of `||`s]

// Generating test cases from the `||` version:
// #table(
//   columns: (auto, auto, auto),
//   [No.], [Test Case], [R1-1 No.],
//   [M001], [age: $[17, 17]$, service: $[29, 29]$], [M2],
//   [M002], [age: $[17, 17]$, service: $(-infinity, 28]$], [-],
//   [M003], [age: $(-infinity, 16]$, service: $[31, infinity)$], [M5 intersect M23],
//   [M004], [age: $[60, 60]$, service: $[29, 29]$], [M9],
//   [M005], [age: $(-infinity, 16]$, service: $(-infinity, 28]$], [M3],
//   [M006], [age: $[17, 17]$, service: $[30, 30]$], [M4 intersect M21],
//   [M007], [age: $[60, 60]$, service: $[30, 30]$], [M13 intersect M22],
//   [M008], [age: $[61, infinity)$, service: $[31, infinity)$], [M14 intersect M24],
//   [M009], [age: $[59, 59]$, service: $(-infinity, 28]$], [M11 inersect M20],
//   [M0010], [age: $[60, 60]$, service: $[31, infinity)$], [M14],
//   [M0011], [age: $[18, 18]$, service: $[30, 30]$], [M16],
//   [M0012], [age: $[18, 18]$, service: $[29, 29]$], [M6 intersect M19],
//   [M0013], [age: $[59, 59]$, service: $[30, 30]$], [M17],
//   [M0014], [age: $[19, 58]$, service: $[31, infinity)$], [M18],
//   [M0015], [age: $[61, infinity)$, service: $(-infinity, 28]$], [M10]
// )

// This only generated 15 test cases instead of the 24 generated previously. There are some test cases in this `||` solution which are the intersections of test cases from the previous solution. This is correct, because graph reduction could happen in the previous solution that would yield us these test cases.

// Test cases not covered explicitly covered:
// - _M1_: We have M005, which is stricter than M1.
// - _M7_:
// - M8
// - M12
// - M15

#todo[Explore the non variable order dependent version]
