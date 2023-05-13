#import "../utils.typ" : *

= GPT Algorithm

Kovacs Attila and Forgacs Istvan proposed General Predicate Testing @thebook[p. 69]. It is a method of black box test case generation, based on and extending BVA.

On a high level, GPT works like BVA, we identify the boundaries and equivalence partitions of predicates. The difference is, that the partitions are named (IN, ININ, ON, OFF, OUT) and we handle them as partitions, not just immediately select a test point from them. 

Because we continue to handle them as intervals, after generating all partitions, we can reduce their number by identifying overlapping partitions and intersecting them.

Some terminology before we dive into GPT in detail:
- When we refer to intervals and intersections and equivalence partitions, they don't only mean numbers. Variables can have boolean or enum or any other custom types, but we can think about the values assignable to those as intervals. We can assign numbers to each value they represent and treat their values as single points. 
- GPT only works with closed intervals (except for unbounded intervals, which are handled as unbounded). Because computers work with finite precision, we can convert an open interval to a closed interval. For example if we use the precision of `0.01` the interval $[0, 1)$ can be converted to the closed interval $[0, 0.99]$.
- For simplicity when we refer to intervals, we can either mean simple intervals or multiintervals. What matters is that they refer to value ranges, and they can be intersected.

== Boundary Value Analysis in GPT (IN, ININ, ON, OFF, OUT)
=== Converting conditions to intervals
In GPT we create intervals from predicates, similar to Equivalence Partitioning. We create an interval, where all of the elements inside the interval satisfy the predicate.

_Example:_ For the predicate $x < 10$, we create the interval $(-infinity, 10)$.

For booleans, we have a constant representation. If something is equal to some boolean we take that boolean. If something is not equal to some boolean, we take that boolean and negate it.
_Example:_ For the predicate `x != true`, we will have `false`.


An interesting case happens, when we take the not equal to predicate. For $x != 10$ we have to generate a multiinterval, because the values $x$ could take is $(-infinity,10)" "(10,infinity)$.

=== Extending BVA
Now that we have intervals to work with, we should generate the equivalence partitions and select the possible test values. In normal BVA we do the partitioning and select single points from the intervals. 

GPT extends this: We don't pick single values, but the the largest possible intervals for the partitions. This will be helpful, when in the end we try to reduce the number of test cases, because we can see the overlap between different test cases. This ultimately helps us reduce the number or test cases required to test the same equivalence partitions.

=== Equivalence Partitioning in GPT <ep-in-gpt>
In BVA the equivalence partitions for $[1, 10)$ would be $(-infinity, 1)" "[1, 10)" "[10, infinity)$

In GPT we have more equivalence partitions:

- *IN:* The interval of the acceptable values. In case of Open ends we step one with the precision to make it closed. Unbounded parts remain unbounded.

  _Example:_ $[1,10)$ will have the IN of $[1,9.99]$ \
  _Example:_ $(-infinity, 10]$ will have the IN of $(-infinity, 10]$

- *ININ:* One step of precision inside IN.

  _Example:_ $[1,10)$ will have the ININ of $[1.01,9.98]$ \
  _Example:_ $(-infinity, 10]$ will have the ININ of $(-infinity, 9.99]$

- *ON:* First possible acceptable values from the edges. These are single points, the endpoints of IN. Unbounded edges have no ON points. If the interval is a single point there will only be one ON point.

  _Example:_ $[1,10)$ will have the ON points of $[1,1]" "[9.99,9.99]$ \
  _Example:_ $(-infinity, 10]$ will have the ON point of $[9.99,9.99]$

- *OFF:* First not acceptable values from the edges. One step outside the edges of IN. Unbounded edges have no OF points. 

  _Example:_ $[1,10)$ will have the OFF points of $[0.99,0.99]" "[10,10]$ \
  _Example:_ $(-infinity, 10]$ will have the OFF point of $[10.01,10.01]$

- *OUT:* Not acceptable values, except for the OFF points. The complement of the IN interval, stepped one, to exclude the OFF points.

  _Example:_ $[1,10)$ will have the OUT interval of $(-infinity,0.98]" "[10.01,infinity)$ \
  _Example:_ $(-infinity, 10]$ will have the OUT interval of $[10.02,infinity)$

Each of these can detect a different kind of predicate error. Compared to BVA (which is just an (IN+ON+ININ) and (OFF+OUT) #todo[dunno, think about this this]) we have to have these different intervals, because we'll be reducing the test cases and intersecting intervals. If we were to just reduce BVA intervals we could "lose" some important test cases.

_Example:_ In BVA the equivalence partitions of $[1, 10)$ would be $(-infinity, 1)" "[1, 10)" "[10, infinity)$. If we'd reduce for example the $[10, infinity)$ with $[20, infinity)$ we'd lose the 10 point, which would check the ON points. If we explicitly have the on points, they can't be reduced further (because they are a single point) and we'll have them in the final test cases.

Here the IN interval and ON points are overlapping, why the "duplication"? Because in GPT when we create the OFF and OUT intervals we only do it for one variable at a time in a test case. That way we only test that that variable is handled correctly in the logic. All the other variables will have the IN intervals, so they are accepted.

For multiintervals we use the same equivalence partitioning technique. We calculate the partition for all the intervals inside the multiinterval and create a multiinterval out of the partitions.

== Test case generation in GPT

We can generate multiple intervals with GPT that we can select test values from. But this is just for one predicate. To test all the predicates in a condition, we use the following technique:

- Creating an NTuple from the condition.
- Generating the IN, ININ, and ON values for each variable in the NTuple.
- Generating the OFF and OUT values for each variable in the NTuple.

Let's look at each of those steps in detail:

=== Creating an NTuple from the condition

An NTuple is a tuple with N elements. In GPT I use the term NTuple for a map of the variable names to the EPs. This is because of historical reasons, originally these were literal tuples, but working with an explicit variable to EP mapping is easier to handle during graph reduction.

In GPT we can inly create NTuples from a condition that only contains conjunctions. I'll explain how to convert a condition with disjunctions to conjunctive forms in @or-to-ands.

Example: The condition $x < 10$ && $y$ in $[0, 20]$ && $z ==$ true would become the following NTuple:
```
{
  x: (-Inf, 10)
  y: [0, 20]
  z: true
}
```

=== Generating the IN, ININ, and ON values for each variable in the NTuple

Now we have an NTuple with variables that have EPs associated with them. We take the NTuple and for each variable we generate the IN, ININ, and ON values for each. Because the values are acceptable values, we can group them together and check all of the variables' values in one NTuple. This won't be the case for OFF and OUT.

One complication is, that ON (and later OFF) can generate multiple values. When we have could have multiple values for variables, we take the Cartesian product of the possibilities. This is further complicated by the fact that we could have N variables with M possible values, and we'd have to take the Cartesian product of all of those.

Example from the previous NTuple:
```
IN:  { x: (-Inf, 9.99], y: [0, 20], z: true }
ININ: { x: (-Inf, 9.98], y: [0.01, 19.99], z: true }
ON:  { x: 9.99, y: 0 and 20, z: true } 
The Cartesian product of this is { x: 9.99, y: 0, z: true } and { x: 9.99, y: 20, z: true }
```

Example 2: Let's look at the ON and Cartesian product for the following NTuple: \
`{ a: [0, 10], b: [20, 30] }` \
The On values would be: `{ a: 0 and 10, b: 20 and 30 }`
The Cartesian products of this is:
```
{ a: 0, b: 20 }
{ a: 0, b: 30 }
{ a: 10, b: 20 }
{ a: 10, b: 30 }
```

=== Generating the OFF and OUT values for each variable in the NTuple

OFF and OUT values should not be acceptable by the system under test (SUT). To test that they are indeed not accepted, we'll generate OFF and OUT values one variable at a time. All the other variables will have IN values.

Example for the previous NTuple:

```
OFF: 
  x:  { x: 10, y: [0, 20], z: true }
  y1: { x: (-Inf, 9.99], y: -0.01, z: true }
  y2: { x: (-Inf, 9.99], y: 20.01, z: true }
  z:  { x: (-Inf, 9.99], y: [0, 20], z: false }

OUT:
  x:  { x: [10.01, Inf), y: [0, 20], z: true }
  y1: { x: (-Inf, 9.99], y: (-Inf, -0.02], z: true }
  y2: { x: (-Inf, 9.99], y: [20.02, Inf), z: true }
  z:  { x: (-Inf, 9.99], y: [0, 20], z: false }
```

As you can see, OFF and OUT values can have multiple. As previously, we're taking the carthesian product of these products. In reality that means that we'll have two versions, because all the other IN values will be one value.

Note: in the algorithm the resulting OFF and OUT NTuples aren't labelled with which variable they were generated for, I put it there in this example to make it easier to see.

== Test value concretization in GPT

Test cases in GPT hold intervals of values for the variables. Programs need concrete values for variables to run test cases. To do this, we can just select either endpoint of the interval and that'll be a good test point. Test cases from GPT will always be closed intervals so we can safely use those numbers. An exception is unbounded intervals, where we have to use the bounded part of that interval. If the interval is $(-infinity, infinity)$ we can choose $0$.

== Hierarchical GPT

#write_this[write about HGPT]
