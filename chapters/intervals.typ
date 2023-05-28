#import "../utils.typ" : *

= Intervals <intervals>

Intervals are the backbone of GPT. Instead of assigning single points to Equivalence Partitions, we use intervals. This way, we can represent every possible value that we want to test our predicates with.

There weren't any off-the-shelf libraries that implemented interval handling exactly in the way I needed, so I had to create my own interval library. It consists of two main parts: Simple intervals and what I call Multiintervals. Multiintervals are made up of multiple simple intervals, but behave as an interval. The `intervals-general` library @rust-intervals-general had good simple interval support, but no multiinterval support.

I will use the word interval both for simple intervals, or multiintervals. If a distinction needs to be made, I'll clarify. But in later chapters, all that will matter is that we are working with an interval.

In my interval implementation there are three important functions: intersection, union, and complement. With these I could implement all of GPT's functionality.

== Simple Intervals

Simple intervals are intervals in a mathematical sense. It has two endpoints, a _lo_ (low) and a _hi_ (high). It has two boundaries: a _lo_ boundary and a _hi_ boundary. A boundary is either closed $[$ $]$ or open $($ $)$.

A special case is when an interval is unbounded. I'll use the notation of $infinity$ with an open boundary to indicate when an interval is unbounded from one side. For example: $[10, infinity)$.

An interval can contain only a single point: $[10, 10]$.

Empty intervals can exist when no points can be in an interval, like $(10, 10)$ or $(10, 10]$.

An interval can only be constructed if _lo_ $<=$ _hi_.

For the implementation, I'm only storing the _lo_boundary_, _lo_, _hi_, _hi_boundary_ variables. All the calculations are made with these values.

Interval could be in different states (unbounded, bounded, single point, empty). A design alternative could to use Algebraic Data Types to represent intervals in different states, so we cannot create inconsistent an state, like $[-infinity, infinity]$ or $(10, 10]$.

#pagebreak()

=== Intersection

*Detecting if there is an intersection*

Pseudocode for detecting whether the intersection of two intervals is possible:

```py
case1 = self.lo > other.hi || other.lo > self.hi
case2 = self.lo == other.hi && (self.lo_boundary == Open || other.hi_boundary == Open)
case3 = other.lo == self.hi && (other.lo_boundary == Open || self.hi_boundary == Open)

return !(case1 || case2 || case3)
```

Here, we are looking at the case when the intervals don't intersect, because that is an easier case to handle. We can negate this result to get whether intervals intersect.

- `case1` is when the intervals are above or below each other, like $[0, 10]$ and $[20, 30]$ or $[20, 30]$ and $[0, 10]$. Because _lo_ $<=$ _hi_, we only have to check the _lo_ and _hi_ of the two intervals.

- `case2` is when the intervals would have the same endpoint, but either one of the boundaries is Open. Since an open boundary doesn't contain that point, intersection can't be made either. For example $[0, 10]$ and $(10, 20)$.

- `case3` is the same as `case2`, but checking the intervals from the other way.

In all other cases the intervals would intersect.

*Calculating the intersection*

Pseudocode for calculating the intersection of intervals `self` and `other`:

```py
if not self.intersects_with(other):
  return "No Intersection"

interval_with_lower_hi = if self.hi_cmp(other) == Greater then self else other
interval_with_higher_lo = if self.lo_cmp(other) == Less then self else other

return Interval {
  lo_boundary: interval_with_higher_lo.lo_boundary
  lo: interval_with_higher_lo.lo
  hi: interval_with_lower_hi.hi
  hi_boundary: interval_with_lower_hi.hi_boundary
}
```

First, we check if the intervals can even be intersected. If they can't, we return that there is no intersection. In Rust, this could be an `Option::None` type, in other languages it could be a `null`.

Then, if the intervals can be intersected, we take the lower _hi_ endpoint and use that as the new _hi_ point and _hi_ boundary. We do the same and look for higher _lo_ point and use that as the new _lo_ point. The `hi_cmp` and `lo_cmp` functions are comparison functions, which take the boundaries into account when comparing _hi_ or _lo_. These functions are needed, because there could be a case where we the points are the same, but the boundaries are different. For example $5)$ and $5]$, in this case the closed boundary is higher.

=== Union

The union of two simple intervals can either be a simple interval (if they intersect) or a multiinterval (if they don't). Due to this, we always assume that the union of two simple intervals will be a multiinterval. There is no need for the code to produce a union of simple intervals that is a simple interval, but it could be implemented.

Pseudocode:

```py
return Multiinterval::from_intervals([self, other])
```

We can just create a multiinterval from the two intervals. With this constructor, Multiinterval will call a `clean()` on itself, which I'll explain later. In short, in this case `clean()` would merge the two intervals if they intersect.

=== Complement

The complement of an interval contains all the elements which are not in the interval.

For simple intervals, this could result in a multiinterval. For example, the complement of $[0, 10)$ is $(-infinity, 0)" "(10, infinity)$. 

Simple intervals basically have two sides: a side left and a side right of the interval. If our interval is unbounded, we won't have that side in the complement. The complement of $(-infinity, infinity)$ is an empty multiinterval.

```py
if self.is_empty():
  return (-infinity, infinity)


new_intervals = []

if self.lo != -infinity:
  new_intervals += Interval(Open, -infinity, self.lo, self.lo_boundary.inverse())


if self.hi != infinity:
    new_intervals += Interval(self.hi_boundary.inverse(), self.hi, infinity, Open)

MultiInterval {
    intervals: new_intervals
}
```

#pagebreak()

== Multiintervals 

Multiintervals are intervals composed of multiple simple intervals. They are required for GPT. For example if we have a predicate that states $x > 0 and x <= 10 and x in.not {5,7}$ we could represent the interval of values $x$ could take as the multiinterval $(0,5)" "(5,7)" "(7,10]$.

An empty multiinterval is one which has no intervals. We don't store empty intervals in mutliintervals.

An invariant of multiintervals is that its intervals are sorted in increasing order.

=== Cleaning

There could be multiintervals, which are not 'clean', i.e. not in a semantically correct form. Take for example $(10, infinity)" "(-5,5)" "[0, 20]$.

Here are the steps to clean a multiinterval:

1. *Removing empty intervals.* Empty intervals hold no values, so they are unnecessary to have in a multiinterval. From the example we'd remove $(-5,-5)$.
2. *Sorting the intervals.* Intervals should be in an increasing order inside a multiinterval. When comparing intervals, we compare their _lo_ values. The example would change from $(10, infinity)" "[0, 20]$ to $[0, 20]" "(10, infinity)$.
3. *Merging overlapping intervals.* If intervals would intersect, we can merge them together. The example would change from $[0, 20]" "(10, infinity)$ to $[0, infinity)$.

We can define a constructor `Multiinterval::from_intervals` that will always create a clean multiinterval from a list of intervals:

```py
def Multiinterval::from_intervals(intervals):
  multiinterval = new Multiinterval(intervals)

  multiinterval.clean()

  return multiinterval
```

=== Intersection

*Detecting if there is an intersection*

To check that two mutliintervals intersect, we can check if any of their intervals intersect. Pseudocode:

```py
for x in self.intervals:
  for y in other.intervals:
    if x.intersects_with(y):
      return True

return false
```

As a future optimisation idea, we could do an $O(2n)$ algorithm instead of an $O(n^2)$, because the intervals are in increasing order. We could traverse them like in a two pointers technique @TwoPointers.

#pagebreak()

*Calculating the intersection*

Pseudocode:

```py
intersected_intervals = []

for x in self.intervals:
  for y in other.intervals:
    if x.intersects_with(y):
      intersected_intervals += x.intersect(y)

return Multiinterval::from_intervals(intersected_intervals)
```

We try to intersect all the intervals. The `Multiinterval::from_intervals` constructor will call a `clean()`, so the resulting intersected Multiinterval will be in the correct form.

=== Union

We take both multiintervals' intervals, concatenate them and create a multiintevral from them. This constructor calls `clean()`, so it'll take care of sorting and overlapping intervals.

```py
return Multiinterval::from_intervals(self.intervals ++ other.intervals)
```

=== Complement

The complement of an interval contains all the elements which are not in the interval. In simple terms, we just return all the 'space' between the intervals of a multiinterval.

For example:

- Multiinterval: $[-42, 3)" "(3, 67)" "(100, 101)" "[205, 607]" "(700, infinity)$
- Complement: $(-infinity, -42)" "[3, 3]" "[67, 100]" "[101, 205)" "(607, 700]$

Pseudocode:

```py
if self.is_empty()
  return (-infinity, infinity)

complement_intervals = []

if intervals.lowest_lo() != -infinity:
  complement_intervals += Interval(Open, -infinity, lowest_lo, lowest_boundary)

for [a, b] in self.intervals.window(2):
  complement_intervals += Interval(a.hi_boundary.complement(), a.hi, b.lo, b.lo_boundary.complement())

if intervals.highest_hi() != -infinity:
  complement_intervals += Interval(highest_boundary, highest_hi, infinity, Open)

return new Multiinterval(complement_intervals)
```

We go through the intervals in pairs. The `.window(2)` function call returns all the neighboring pairs in a list. It is a sliding window. We always create an interval between the _hi_ of the first and the _lo_ of the second interval, as this is the space not covered by our multiinterval.

As in the sliding window we only look at the _hi_ of the left side and the _lo_ of the right side, we have to handle the case at the edges of the multiinterval. If our multiinterval is not unbounded, the complement has to be unbounded.

We don't have to clean the multiinterval, because of its invariant. Due to the invariant, it won't have empty intervals, it will be sorted, and it won't have overlapping intervals.

