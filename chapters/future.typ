#import "../utils.typ" : *

= Future improvement ideas <future>

== Coincidental Correctness

Hierons, R. M. has shown in @coincidentalCorrecttness, that because BVA only generates single points on boundaries, geometric shifts in boundaries can lead to accidental correctness. In other words, there are some incorrect implementations, which cannot be caught with BVA.

Consider the following example: Write a program that accepts a point as an $(x,y)$ coordinate, $x$ and $y$ are integers. Return true, if the point is above the $f(x) = 0$ function's slope, otherwise return false.

From this, we'd write it in GPT Lang as:
```cpp
var x: int
var y: int
if(y > 0) else
```

You can notice, that we don't reference x here, so the generated test cases won't care for x either. If we default x to 0 in all test cases, we'd have the following reduced generated test cases: `A = { x: 0, y: 1 }, B = { x: 0, y: (-Inf, -1] }, C = { x: 0, y : [2, Inf) }, D = { x: 0, y: 0 }`

The problem with this, is that if the implementation checked against the $f(x) = x$ function's slope, all of our test cases would still pass. This is, because in the $x = 0$ point both $f(x) = 0$ and $f(x) = x$ behave in the same way. But we know that checking against $f(x) = x$ would be an incorrect implementation.

The following figure shows the two functions, $f(x) = 0$ in green and $f(x) = x$ in orange. In this scenario the test points A, B, C, and D see that both functions behave in the same way. But point E and F could show the bug, because they are both under the slope of $f(x) = x$.

#align(center, image("../images/2023-04-17-22-40-15.png", height: 20%))

== Linear Predicates

GPT can currently only handle predicates with one variable. Linear predicates are not supported. 
