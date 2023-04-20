#import "../utils.typ" : *

= GPT Algorithm

Kovacs Attila and Forgacs Istvan proposed General Predicate Testing @thebook[p. 69]. It is a method of black box test case generation, based on and extending BVA.

#todo[Explain precision]
#todo[In this doc when we refer to intervals, we could mean multiintervals, for the sake of simplicity.]

== BVA in GPT (in, inin, on, off out)
=== Converting conditions to intervals
In GPT we create intervals from conditions, similar to Equivalence Partitioning. 

_Example:_ For the condition $x < 10$, we create the interval $(-infinity, 10)$

#todo[Explain the condition -> to interval process]

An interesting case happens, when we take the not equal to condition. For $x != 10$ we have to generate a multiinterval, because the values $x$ could take is $(-infinity,10)" "(10,infinity)$.

=== Extending BVA
Now that we have intervals to work with, we should generate the possible test values. In normal BVA we would pick single points from the intervals. GPT extends this in two ways: 

1. We don't pick single values, but the the largest possible intervals. This will be helpful, when in the end we try to reduce the number of test cases, we can see the overlap between different test cases.
2. We not only look at the minimum and maximum possible acceptable value, but more. We look at not acceptable values and test that our implementation properly fails for those. #todo[This might be covered in BVA, further investigation needed.]

#todo[Actually, GPT is an implementation of BVA with some extra functionalities, right?]

=== Equivalence Partitioning in GPT
In BVA the equivalence partitions for $[1, 10)$ would be $(-infinity, 1)" "[1, 10)" "[10, infinity)$

In GPT we have more equivalence partitions. #todo[Explain why]

- *In:* The interval of the acceptable values. In case of Open ends we step one with the precision to make it closed. Unbounded parts remain unbounded.
_Example:_ $[1,10)$ will have the In of $[1,9.99]$ \
_Example:_ $(-infinity, 10]$ will have the In of $(-infinity, 10]$

- *InIn:* One step of precision inside In.
_Example:_ $[1,10)$ will have the InIn of $[1.01,9.98]$ \
_Example:_ $(-infinity, 10]$ will have the InIn of $(-infinity, 9.99]$

- *On:* First possible acceptable values from the edges. These are single points, the endpoints of In. Unbounded edges have no On points. If the interval is a single point there will only be one On point.
_Example:_ $[1,10)$ will have the On points of $[1,1]" "[9.99,9.99]$ \
_Example:_ $(-infinity, 10]$ will have the On point of $[9.99,9.99]$

- *Off:* First not acceptable values from the edges. One step outside the edges of In. Unbounded edges have no Off points. 
_Example:_ $[1,10)$ will have the Off points of $[0.99,0.99]" "[10,10]$ \
_Example:_ $(-infinity, 10]$ will have the Off point of $[10.01,10.01]$

- *Out:* Not acceptable values, except for the Off points. The complement of the In interval, stepped one, to exclude the Off points.
_Example:_ $[1,10)$ will have the Out interval of $(-infinity,0.98]" "[10.01,infinity)$ \
_Example:_ $(-infinity, 10]$ will have the Off interval of $[10.01,infinity)$

#todo[Here the In interval and On points are overlapping, why the "duplication"? Because in GPT when we create the Off and Out intervals we only do it for one variable in a test case. That way we only test that that variable is handled correctly in the logic. All the other variables will have the In intervals, so they are accepted.]

For multiintervals we use the same equivalence partitioning technique. We calculate the partition for all the intervals inside the multiinterval and create a multiinterval out of the partitions.

== Test case generation in GPT

We can generate multiple intervals with GPT that we can select test values from. But this is just for one predicate. To test all the predicates in a condition, we use the following technique:

- Creating an NTuple from the condition.
- Generating the IN, ININ, and ON values for each variable in the NTuple.
- Generating the OFF and OUT values for each variable in the NTuple.

Let's look at each of those steps in detail:

=== Creating an NTuple from the condition

An NTuple is a tuple with N elements. In GPT I use the term NTuple for a map of the variable names to the EPs. This is because of historical reasons, originally these were literal tuples, but working with an explicit variable to EP mapping is easier to handle during graph reduction.

In GPT we can inly create NTuples from a condition that only contains conjunctions. I'll explain how to convert a condition with disjunctions to conjunctive forms in a later chapter. #todo[ref that chapter.]

Example: The condition $x < 10$ && $y$ in $[0, 20]$ && $z ==$ true would become the following NTuple:
```
{
  x: (-Inf, 10)
  y: [0, 20]
  z: true
}
```

=== Generating the IN, ININ, and ON values for each variable in the NTuple

Now we have an NTuple with variables that have EPs associated with them. We take the NTuple and for each variable we generate the In, InIn, and On values for each. Because the values are acceptable values, we can group them together and check all of the variables' values in one NTuple. This won't be the case for Off and Out.

One complication is, that On (and later Off) can generate multiple values. When we have could have multiple values for variables, we take the Cartesian product of the possibilities. This is further complicated by the fact that we could have N variables with M possible values and we'd have to take the Cartesian product of all of those.

Example from the previous NTuple:
```
In:  { x: (-Inf, 9.99], y: [0, 20], z: true }
InIn: { x: (-Inf, 9.98], y: [0.01, 19.99], z: true }
On:  { x: 9.99, y: 0 and 20, z: true } 
The Cartesian product of this is { x: 9.99, y: 0, z: true } and { x: 9.99, y: 20, z: true }
```

Example 2: Let's look at the On and Cartesian product for the following NTuple: \
`{ a: [0, 10], b: [20, 30] }` \
The On values would be: `{ a: 0 and 10, b: 20 and 30 }`
The Cartesian products of this is:
```
{ a: 0, b: 20 }
{ a: 0, b: 30 }
{ a: 10, b: 20 }
{ a: 10, b: 30 }
```



== Hierarchical GPT
