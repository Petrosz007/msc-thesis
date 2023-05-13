#import "../utils.typ" : *

= GPT Lang <gpt-lang>
So far, we've looked at GPT as a test generation technique. The other power of my GPT implementation is that I've developed a Domain Specific Lanuage (DSL) for defining requirements for GPT. From this DSL GPT can generate test cases. This makes the test generation process much faster. It is called GPT Lang.

GPT Lang has a C inspired syntax, to make it easier for developers to learn. Because for GPT we are only concerned with predicates, we can only write conditions in this DSL.

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

As you can see, GPT Lang looks similar to how we will actually implement our programs. This can be useful in more things. First, after we implement the requirements in GPT Lang and generate our test cases for Test Driven Development (TDD) we have a starting point for coding in other languages, as we have basically defined the control flow in GPT Lang. Also, if we have an existing codebase, we can easily test it with GPT, because we can convert the existing control flow to GPT Lang easily.

You can currently do the following things in GPT Lang:
- Declare variables with boolean or number types (optionally with precision)
- Declare `if`, `else if`, and `else` statements, with an optional body that can have other `if` statements. They can have any number of predicates.
- Declare predicates, which can be
  - Boolean `true` or `false`
  - Number $>, >=, <, <=, ==, !=$ constant
  - Number `in` or `not in` interval
- Predicates can be negated with `!`, grouped with parenthasies `(` `)`, conjuncted with `&&` or disjuncted with `||`.

== Syntax

*Numbers*

Numbers can be either integers, floating point numbers, or `Inf` (for infinity). They can be negative.

Example.: `146`, `3.14`, `-6390`, `-Inf`, `0.01`

*Type*

Types can be:
- `bool`: Boolean.
- `int`: Integer.
- `num`: Number with default precision of 0.01.
- `num(<precision>)`: Number with the given precision. `<precision>` must be a positive number and not `Inf`.

Example: `bool`, `num`, `num(0.001)`, `num(1)`

*Variable declaration*

`var <var_name>: <type>`

Examples:
- `var price: num(0.01)`
- `var isVIP: bool`
- `var year: int`

*Interval*

`<lo_boundary> <lo>, <hi> <hi_boundary>`

Where
- `<lo_boundary>` is `(` or `[`
- `<lo>` and `<hi>` are numbers
- `<hi_boundary>` is `)` or `]`

Example: `(-Inf, 0]`, `[2.3, 6.75)`, `[1,1]`

*Predicate*

Predicates repesent a comparison between variables and constants, they can either get evaluated to true or false.

Boolean predicate: \
`<var_name> <op> <true|false>` or `<true|false> <op> <var_name>` \
Where `<op>` is `==` or `!=`

Binary number predicate: \
`<var_name> <op> <constant>` or `<constant> <op> <var_name>` \
Where `<op>` is `<`, `>`, `<=`, `>=`, `==`, or `!=`

Interval predicate: \
`<var_name> <in|not in> <interval>`

#todo[Give examples here for conditions]

#todo[Give example about && || () and !()]

== Parsing to the AST


== Converting the AST to IR

== Flattening the IR

== Converting disjunctions to conjunctions <or-to-ands>
