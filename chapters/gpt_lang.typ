#import "../utils.typ" : *

= GPT Lang <gpt-lang>
So far, we've looked at GPT as a test generation technique. The other feature of my GPT implementation is that I've developed a Domain Specific Language (DSL) for defining requirements for GP, I call it GPT Lang. From this DSL, GPT can generate test cases. This makes the test generation process much faster.

GPT Lang has a C inspired syntax, because this makes the language more intuitive for the developers. We can only write conditions in this DSL, since in GPT we are only concerned with predicates.

Let's look at an example:

```cpp
var vip: bool
var price: num(0.01)
var second_hand_price: int

if(vip == true && price < 50) {
  if(second_hand_price == 2)
  if(second_hand_price in [6,8])
}

if(vip == false && price >= 50)
else if(vip == true || !(price >= 50 && second_hand_price >= 20)) {
  if(30 < price && 60 < second_hand_price)
}
else
```

As you can see, GPT Lang looks similar to how we will actually implement our programs. This can be useful in many more aspects. First, after we implement the requirements in GPT Lang and generate our test cases for Test Driven Development (TDD), we have a starting point for coding in other languages, as we have basically defined the control flow in GPT Lang. Also, if we have an existing codebase, we can easily test it with GPT, because we can convert the existing control flow to GPT Lang easily.

Currently, GPT Lang has the following functionality:
- Declare variables with boolean or number types (optionally with precision).
- Declare `if`, `else if`, and `else` statements, with optional bodies that can have other `if` statements. They can have any number of predicates.
- Declare predicates, which can be
  - Boolean `true` or `false`
  - Number $>, >=, <, <=, ==, !=$ constant
  - Number `in` or `not in` interval
- Predicates can be negated with the prefix operator `!`, grouped with parentheses `(` `)`, conjoined with `&&` or disjointed with `||`.

#pagebreak(weak: true)

== Syntax

*Numbers*

Numbers can be either integers, floating point numbers, or `Inf` (for infinity). They can also be negative.

_Example:_ `146`, `3.14`, `-6390`, `-Inf`, `0.01`

*Type*

Types can be:
- `bool`: Boolean.
- `int`: Integer.
- `num`: Number with default precision of 0.01.
- `num(<precision>)`: Number with the given precision. `<precision>` must be a positive number and not `Inf`.

_Example:_ `bool`, `num`, `num(0.001)`, `num(1)`

*Variable declaration*

`var <var_name>: <type>`

_Examples:_
- `var price: num(0.01)`
- `var isVIP: bool`
- `var year: int`

*Interval*

`<lo_boundary> <lo>, <hi> <hi_boundary>`

Where
- `<lo_boundary>` is `(` or `[`
- `<lo>` and `<hi>` are numbers
- `<hi_boundary>` is `)` or `]`

_Example:_ `(-Inf, 0]`, `[2.3, 6.75)`, `[1,1]`

*Predicate*

Predicates represent a comparison between variables and constants. They can either get evaluated to true or false.

Boolean predicate: \
`<var_name> <op> <true|false>` or `<true|false> <op> <var_name>` \
Where `<op>` is `==` or `!=`

_Example:_ `isVIP == true`, `false != has_elements`

Binary number predicate: \
`<var_name> <op> <constant>` or `<constant> <op> <var_name>` \
Where `<op>` is `<`, `>`, `<=`, `>=`, `==`, or `!=`

_Example:_ `price <= 10`, `0 < age`, `students != 0`

Interval predicate: \
`<var_name> <in|not in> <interval>`

_Example:_ `age not in [0, 18)`, `n in (-Inf, 200]`

*Conditions*

Conditions are predicates, joined together with `&&` or `||`, grouped with `( )` or a grouping is negated with `!( )`. \
```
condition ::= <predicate>
        | (<predicate>)
        | !(<predicate>)
        | <condition> <&& | ||> <condition>
```

_Examples:_
- `price < 10 && age <= 18`
- `height > 170 || (age > 16 && parent_present == true)`
- `!(x == false && !(y == true || z == true))`

*Ifs*

If statements contain conditions they want to test, they work like most modern programming languages. They can have an optional body, which can have any number of if statements. They can have any number of `else if` branches, with their own conditions and body. Furthermore, they can have an optional `else` statements, which can also have a similar body.

```
if ::= if(<condition>) ({ <if>* })? 
      (else if(<condition>) ({ <if>* })?)* 
      (else ({ <if>* }))?
```

_Examples_:
- ```cpp
if(x < 0) else
  ```
- ```cpp
if(x > 0) {
  if(y == 0)
  else if(y == 1)
  else
} else {
  if(y == -1)

  if(z == -1)
}
```

#pagebreak()

== Parsing and creating the AST

The AST of GPT Lang is the simple representation of the syntax. As it is a syntax tree, it has a tree structure with different nodes.

There are two main nodes: `VarNode` and `IfNode`.

`VarNode` holds a variable declaration. It has the variable name and it's type.

`IfNode` has it's own conditions as a `ConditionNode`, the body which contains a list of `IfNode`, a list of `ElseIfNodes` and an `ElseNode`.

`ConditionNode` is an ADT with three variants:
- A negated `ConditionNode`.
- An expression, which holds a single predicate.
- A group of expressions, with a left and right-hand side and an operand which is `||` or `&&`.

The parser is implemented using parser combinators. The output of the parser is this AST.

== Converting the AST to IR

The AST is only a representation of the GPT Lang code. That structure can be brought to a simpler form, the Intermediary Representation (IR). We can also condense the condition structure, which will be the Reduced IR.

// The IR has a similar structure for conditions. When we convert from the AST to the IR we handle the `if` and `else if` nodes, the body of if statements and in the IR we will only handle list of conditions.
The IR has a similar structure for conditions. When we convert from the AST to the IR, it will only handle list of conditions. We have to flatten the `if` nodes, roll up the nested bodies, and handle the `else` and `else if` nodes.

These are the steps to convert an `IfNode`:
1. Convert the `if`'s conditions to IR conditions.
2. For the body, traverse recursively, take that result and conjunct the `if`'s conditions to it.
3. For the `else if` nodes, conjunct the top level conditions so far and conjunct the negated version to the `else if`s conditions.
4. For the body of `else if`s and the `else` statement, evaluate them recursively and conjoined the negated previous conditions onto them.

_Example:_

```cpp
if(x == 1) {
  if(y == 2)
  if(y == 3)
} else if(x < 10)
else {
  if(z == 0)
}
```

In this case, from the body of the first `if`s we'll have:
```cpp
x == 1
x == 1 && y == 2
x == 1 && y == 3
```

After that, we go to the `else if`. To get to that `else if`, the previous condition had to be false, so we conjoin that to the condition:
```cpp
!(x == 1) && x < 10 
```

To get to the `else` statement, both the `if` and the `else if` had to be false. We also append these to `if`'s body, so we'll have:
```cpp
!(x == 1) && !(x < 10)
!(x == 1) && !(x < 10) && z == 0
```

In total, we'll have:
```cpp
x == 1
x == 1 && y == 2
x == 1 && y == 3
!(x == 1) && x < 10
!(x == 1) && !(x < 10)
!(x == 1) && !(x < 10) && z == 0
```

Each of these lines is one Condition node inside the IR.

== Flattening the IR

As you can see from the previous example, they could be reduced by a bit. This is where the Reduced IR comes in.

The IR is traversed recursively as a tree. When we have a negation node, we'll return the negated version of the condition node inside.
- The negation of negation nodes is the node itself.
- For negated expressions, we negate the contained expression. This is defined for intervals with the complement function. For booleans we swap `true` to `false` and `false` to `true`.
- For grouped expressions, we swap the operator (`||` to `&&` and `&&` to `||`) and we negate both the left-hand and right-hand sides. We evaluate them recursively. We can do this because of De Morgan's laws.

After this reduction, there will be no negation nodes in the IR.

Next, we'll flatten the expressions. Currently, they are stored in a binary tree. But a conjunction chain or disjunction chain can exist, where we have $n$ elements, all of which are either all conjoined or disjointed. Our goal is to have a form, where if we have an `&&` node, it'll have any number of child nodes, but those child nodes are either single expressions or an `||` node. Same for the `||` node, it can only have simple expressions or `&&` nodes as children.

#pagebreak(weak: true)

*Example:*
Let's look at the following formula:
```cpp
x > 0 && (x < 10 && y < 10 || x > 20 && y > 10 || z == 0) && y == 2 && z > 20
```
#figure(image("../graphs/dot/reduced_ir_before.dot.png", width: 75%), caption: [Before reduction])
#figure(image("../graphs/dot/reduced_ir_after.dot.png", width: 75%), caption: [After reduction])

As you can see, after the reduction we have an n-ary tree, where `&&`s only have simple predicates or `||` as children, and `||`s only have simple predicates or `&&`s as children. For reference, I'll call this an AND-OR tree.


== Converting disjunctions to conjunctions <or-to-ands>

Converting disjunctions to conjunctions is in my opinion one of the most important features I've come up with for GPT. The GPT algorithm is only defined for conditions where the predicates are conjoined. But in the real world, we rarely use only conjunctions, we have to use disjunctions as well.

There is a way to create conjunctions from disjunctions. If we think about it, when programs evaluate `x || y`, they always have an order of operations. Most programming languages today first evaluate `x`, if it is true, they stop and evaluate that condition as true. If `x` is false, they evaluate `y`. We can use this order of operation to define two conjunctions: `x` and `!x && y`. If we write test cases for these two conjunctions, it is the same as if we tested `x || y`. Now we can use GPT on these converted predicates.

We need to make a slight adjustment for this. Because we are black box testing, we can't assume anything about the implementation. This includes the order in which the `||` is evaluated in or how the programmer implements it. Implementing `x || y` should have the same meaning as `y || x`, if we are testing idempotent pure functions that have no side effects.

*Example:* If we only generate test cases for `x` and `!x && y` and the programmer implements `y || x`, we don't test the case when only `y` is true or `!y && x`.

Based on this, we can say that we want to take the linear combination of the conditions inside a disjunction and generate all possible combinations.

*Example:* Let's look at the disjunctions generated for `x || y || z`:
```
x
!x && y
!x && !y && z
!x && z
!x && !z && y
y
!y && x
!y && z
!y && !z && x
z
!z && x
!z && y
```

As we can see, we didn't generate `!z && !x && y`, because we've already generated `!x && !z && y` and these would semantically be the same, since the order of elements can be switched around in conjunctions. This is also why z has fewer cases, because they've been generated previously.

This method is applied recursively, because we could have `&&` conditions inside `||`s. Also, when we have an `&&` condition with an `||` sub-condition, the linear combinations are generated 'in their place', the 'outer context' will remain the same.

#pagebreak(weak: true)

*Example:* `x && (y || z) && w`
```
x && y && w
x && !y && z && w
x && z && w
x && !z && y && w
```

In this case, the 'outer context' had one element, always `x && w`, it didn't have any variations. But what if it consisted of multiple variations, because they were `||`s too? We have to take the Cartesian product of those variations.

*Example:* `(a || b) && (c || d)`
```
a && c
a && !c && d
a && d
a && !d && c
!a && b && c
!a && b && !c && d
!a && b && d
!a && b && !d && c
b && c
b && !c && d
b && d
b && !d && c
!b && a && c
!b && a && !c && d
!b && a && d
!b && a && !d && c
```

We can see, that this is the Cartesian product is the same, as if we had generated `a || b` and `c || d` separately.

Because of the recursive nature of these methods, they can be applied to any deep and wide AND-OR tree.

The downside of this method is that it generates a huge amount of conditions and in turn a huge amount of test cases. But this is the price we pay for black box testing. This way we can guarantee that the implementation can have the predicates inside the `||`s in any order, we'll have a test case for it. Since our end goal is to make sure that we that the program adheres to the requirements, this is the correct approach.

This code could be modified, so that it doesn't generate all the variable orders for `||`s. The test designer and programmer could agree on the order of the variables and that'd reduce the number of test cases if needed. Later, it could cause regressions if the variable order is changed, so this is not recommended.

