#import "../utils.typ" : *

= Introduction

#todo[Review this before finalizing everything, all of this should be present in the thesis]

In this thesis I'll introduce my automatic test case generation algorithm, the implementation of General Predicate Testing proposed by Kovacs Attila and Forgacs Istvan @thebook. #todo[This feels like they proposed the implementation.] I'll outline the current state-of-the-art black box testing strategies, what their advantages and disadvantages are. I'll explain what GPT is, how it works in theory, and how I put it into practice. I'll show my proposed Domain Specific Language for formalizing the predicates of requirements. I'll show how this automatic test generation scales much better than the current state-of-the-art manual test generation techniques.

== Common testing practices

Software testing is an essential part of the software development life cycle. Testing software allows us to be confident, that the program adheres to the requirements and works as expected. There can be functional and non-functional requirements, in this thesis I'll focus on functional requirements.

There are multiple approaches to testing software, one is Black Box testing, where we create tests sets from the requirement specifications. In practice, this means that we're not looking at how to code is written when writing tests. This way we can systematically test the correctness of outputs for given inputs @murnane2001effectiveness.

The state-of-the-art black box testing methods are: @nidhra2012black @khan2012comparative @thebook

1. _Equivalence Partitioning_: The input and output domains can be partitioned in a way, that values in each partition belong to the same Equivalence Class. This way, test cases are only required to have one value from each partition.
2. _Boundary Value Analysis_: Test cases are created from the boundaries of Equivalence Classes. These can be the values just below, on, or just above the boundaries. This can catch usual off-by-one errors.
3. _Fuzzing_: #todo[Fuzz testing is used for finding implementation bugs, using malformed/semi-malformed data injection in an automated or semi-automated session.] 
4. _Cause-Effect Graph_: #todo[It is a testing technique, in which testing begins by creating a graph and establishing the relation between the effect and its causes. Identity, negation, logic OR and logic AND are the four basic symbols which expresses the interdependency between cause and effect.]
5. _Orthogonal Array Testing_: #todo[OAT can be applied to problems in which the input domain is relatively small, but too large to accommodate exhaustive testing.]
6. _All Pair Testing_: #todo[In all pair testing technique, test cases are designs to execute all possible discrete combinations of each pair of input parameters. Its main objective is to have a set of test cases that covers all the pairs.]
7. _State Transition Testing_: #todo[This type of testing is useful
for testing state machine and also for navigation of graphical
user interface.]


Next I'll explain Equivalence Class Partitioning and Boundary Value Analysis in more detail, as GPT is based on those.

=== Equivalence Class Partitioning

=== Boundary Value Analysis

== Test case generation

