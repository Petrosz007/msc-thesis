#import "../utils.typ" : *

= Introduction

#todo[Review this before finalizing everything, all of this should be present in the thesis]

In this thesis I'll introduce my automatic test case generation algorithm, which uses General Predicate Testing proposed by Kovacs Attila and Forgacs Istvan @thebook. I'll outline the current state-of-the-art black box testing strategies, what their advantages and disadvantages are. I'll explain what GPT is, how it works in theory, and how I put it into practice. I'll show my proposed Domain Specific Language for formalizing the predicates of requirements. I'll show how this automatic test generation scales much better than the current state-of-the-art manual test generation techniques.

== Common testing practices

Software testing is an essential part of the software development life cycle. Testing software allows us to be confident, that the program adheres to the requirements and works as expected. There can be functional and non-functional requirements, in this thesis I'll focus on functional requirements.

There are multiple approaches to testing software, one is Black Box testing, where we create tests sets from the requirement specifications. In practice, this means that we're not looking at how to code is written when writing tests. This way we can systematically test the correctness of outputs for given inputs @murnane2001effectiveness.

The state-of-the-art black box testing methods are: @nidhra2012black @khan2012comparative @thebook

1. _Equivalence Partitioning_: The input and output domains can be partitioned in a way, that values in each partition belong to the same Equivalence Class. This way, test cases are only required to have one value from each partition.
2. _Boundary Value Analysis_: Test cases are created from the boundaries of Equivalence Classes. These can be the values just below, on, or just above the boundaries. This can catch usual off-by-one errors.
3. _Fuzzing_: Black-box fuzz testing is about taking valid inputs and randomly mutating them to try to find implementation bugs. This approach has low code-coverage and requires lot of test cases. @godefroid2007random There is also white-box fuzzing, which is much more effective, due to having access to the source code. @godefroid2008automated
4. _Cause-Effect Graph_: We create a graph and creating links between the effect and its causes. There are four types of these links: indentity, negation, logic OR, and logical AND. There are some proposed automatic test generation tools from Cause-Effect Graphs @son2014test.
5. _Orthogonal Array Testing_: OAT is a pairwise testing technique used when the input domain is small, but testing all the possible combinations of inputs whould result in a too large test set. @Rao2009Jul
6. _All Pair Testing_: All the unique pairs of inputs are in the test case set. This way all the possible pairs are tested, but the test set is quite large.
7. _State Transition Testing_: Used for state machines or User Interfaces, the transitions between states are tested.

In this thesis we'll assume, that the input variables are independent. Otherwise domain analysis has to be used #todo[cite Beizer 1983, Binder 1999, Forgács and Kovács 2019].

Next I'll explain Equivalence Partitioning and Boundary Value Analysis in more detail, as GPT is based on those.

=== Equivalence Partitioning

In Equivalence Partitioning the inputs are divided into equivalence classes in a way, that if two inputs belong to the same class they behave in the same way during testing. If both inputs test the same behavior, then if there is a bug, they can both detect it @thebook.

The equivalence classes are not-empty, disjoint, and the union of the equivalence classes cover the entire input domain. Equivalence classes are also referred to as partitions.

The partitions can be either valid or invalid partitions. Valid partitions contain the acceptable values, invalid partitions contain the not acceptable values. A value is acceptable if the predicate returns a logical true value. 

The steps of Equivalence Partitioning @thebook:
1. Identify the input domain
2. Partition the domain into valid and invalid
3. Refine and merge the partitions until they can't be merged any more
4. Validate the partitioning

Once we have the partitions, we can create test sets, by creating a test case for each partition.

It is possible to obtain the partitioning data without actually doing the partitioning @thebook. We can select the domain boundaries and use the boundaries to approximate the partitions. As the borers are easier to compute than the entire partitions, and we can generate test cases from these borders, this is a good approximate solution for equivalence partitioning.

=== Boundary Value Analysis

In most cases, potential bugs occur near the border of equivalence partitions, because of programmer error @thebook. As such, we should select test cases from the partitions to test these boundaries.

Boundary Value Analaysis builds on Equivalence Partitioning and proposes ways to select test points from the partitions.

We can select the following points when analyzing boundary values:

#todo[re-create this image]
#figure(image("../images/2023-05-10-18-58-54.png"), caption: "EP with closed or open boundaries")

*Predicate errors:* While programming, predicates can be written in many wrong ways. The numbers could be off-by-one #todo[Cite some off-by-one error paper], we could mistype the operator and have `>` instead of `<` or `<=`, write `!=` instead of `==`.

BVA helps detect predicate errors, because these most often occur at borders of partitions. If we have correctly selected test cases to cover all the borders of partition, we will correctly detect these predicate errors.

As Forgács and Kovács detailed, BVA is easy when we have one parameter, but once we have multiple parameters it becomes significantly harder @thebook.

== Automatic test case generation

Generating test cases automatically is advantageous, because creating test cases manually takes up a significant amount of time and is prone to human error. 

White box testing solutions have had many automatic test generation algorithms, because they have access to the source code and can base the tests upon something. #todo[cite something here]. 

Black box testing solutions have a harder time generating test automatically, beause they are derived from the specifications and requirements. Human language is hard to parse and even harder to extract test cases from #todo[cite something]. With the recent advances of Generative Pre-trained Transformer models, maybe this will change, but current solutions are prone to hallucinations #todo[cite something], and thus we can't rely on them to generate correct test cases.

#todo[link some other black box automatic test case generation tools]

To generate test cases automatically, black box solutions have to use some kind of intermediary format to generate the tests from. Test designers have to convert the requirements to one of these formats. For example cause-effect graphs.

There are currently no ways to automatically generate test cases with BVA #todo[cite something]. As it is a manual process, it takes up a lot of time and is prone to error.

My GPT solution is novel in that sense, as automatic BVA solutions haven't been created yet. Because GPT builds on BVA.

