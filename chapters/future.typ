#import "../utils.typ" : *

= Future improvement ideas <future>

== Coincidental Correctness

Hierons, R. M. has shown @coincidentalCorrecttness, that because BVA only generates single points on boundaries, geometric shifts in boundaries can lead to accidental correctness. In other words, there are some incorrect implementations, which cannot be caught with BVA.

Consider the following example: Write a program that accepts a point as an $(x,y)$ coordinate, $x$ and $y$ are integers. Return true, if the point is above the $f(x) = 0$ function's slope, otherwise return false.

From this, we'd write it in GPT Lang as:
```cpp
var x: int
var y: int
if(y > 0) else
```

You can notice, that we don't reference x here, so the generated test cases won't care for x either. If we default x to 0 in all test cases, we'd have the following reduced generated test cases: `A = { x: 0, y: 1 }, B = { x: 0, y: (-Inf, -1] }, C = { x: 0, y : [2, Inf) }, D = { x: 0, y: 0 }`

The problem with this, is that if the implementation checked against the $f(x) = x$ function's slope, all of our test cases would still pass. This is, because in the $x = 0$ point both $f(x) = 0$ and $f(x) = x$ behave in the same way. But we know that checking against $f(x) = x$ would be an incorrect implementation.

@coincidental-correctness-example shows the two functions, $f(x) = 0$ in green and $f(x) = x$ in orange. In this scenario the test points A, B, C, and D see that both functions behave in the same way. But point E and F could show the bug, because they are both under the slope of $f(x) = x$.

#align(center)[
  #figure(image("../images/2023-04-17-22-40-15.png", height: 20%), caption: [Coincidental Correctness example]) <coincidental-correctness-example>
]

#pagebreak()

== Linear Predicates

GPT can currently only handle predicates with one variable. Linear predicates are not supported.

_Example:_ $i < j + 1$

== Different equivalence partitions for implementations

When implementing a program, if we differ by some, we might unknowingly create an implementation that has different equivalence partitions.

Example:

Paid Vacation Days reference implementation:

```js
function paidVacationDays(age, service) {
  let days = 22

  if (age < 18 || age >= 60 || service >= 30) {
    days += 5
  }
  if(age >= 45 && age < 60 && service < 30) {
    days += 2
  }
  if(age >= 18 && age < 45 && service >= 15 && service < 30) {
    days += 2
  }
  if(service >= 30 && age >= 60) {
    days += 3
  }

  return days
}
```

Paid vacation days different implementation:
```js
function paidVacationDays(age, service) {
  let days = 22

  if (age < 18 || age >= 60 || service >= 30) {
    days += 5

    if (age >= 60 && service >= 30) {
      days += 3
    }
  } else if (service >= 15 || age >= 45 /* <- This */) {
    days += 2
  }

  return days
}
```

In the second implementation, if we replace that `age >= 45` with any number in $[46,59]$ the original tests in @paid-vacation-days-final-reduced-test-cases still all pass. But we know for sure that we've made an error, because we've replaced that number.

An example test case for this error would be `{age: [46, 59], service: (-Inf, 14]}`.

This is, because this implementation has different equivalence partitions. In the original tests we only had to test M49 to test that service goes up to 28, not 14. Because of graph reduction and how we select test points, it's possible that we select a number from $[15,28]$. In this implementation with the `||` this test case will 'short circuit', because it sees a test case with `service >= 15` and it won't test the `age` part.

Because we've differed from the equivalence partitions that we've defined our GPT Lang definition with, the way we can solve this is to create another GPT Lang definition for this implementation. This way, we'll have a test case that covers the `service >= 15 || age >= 45` condition, which didn't exist in the original one.

This is related to the Competent Programmer Hypothesis defined in @CPH, because we don't want to test implementations that are vastly different or more overcomplicated than a simple solution. In this case, the else if, the nested if and additional `||` made this implementation more complex.

== Supporting enums in GPT Lang <future-enums>

Enums could be modelled like booleans for BVA. The only operators we need to support is `==` and `!=`. For `!=` we can create a list of all the other enum values. When intersecting NTuples we intersect the sets of these possible enum values.

Enums would let us model some behaviors. For example, when we have a function that does a database query, we could model it as `SUCCESS | TIMEOUT | CONNECTION_ERROR`. This is basically equivalence partitioning the results of any functions.

== Supporting Strings

There has been research about extending BVA to strings @jain2010boundary. This approach could be investigated further, as it would let us use GPT in even more situations. Handling strings is an indispensable part of programs, so having an automatic test generation solution for them could be very useful.

== Hierarchical GPT

#write_this[write about HGPT]
