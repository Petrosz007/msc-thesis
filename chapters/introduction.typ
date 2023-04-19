#import "../utils.typ" : *

= Introduction

#todo[Review this before finalizing everything, all of this should be present in the thesis]

In this thesis I'll introduce my automatic test case generation algorithm, the implementation of General Predicate Testing proposed by Kovacs Attila and Forgacs Istvan @thebook. I'll outline the current state-of-the-art black box testing strategies, what their advantages and disadvantages are. I'll explain what GPT is, how it works in theory, and how I put it into practice. I'll show my proposed Domain Specific Language for formalizing the predicates of requirements. I'll show how this automatic test generation scales much better than the current state-of-the-art manual test generation techniques.

== Common testing practices

Software testing is an essential part of the software development life cycle. Testing software allows us to be confident, that the program adheres to the requirements and works as expected. There can be functional and non-functional requirements, in this thesis I'll focus on functional requirements.

There are multiple approaches to testing software, one is Black Box testing @Mathur2008-am, where we don't create tests from the already written source code, but we treat it as a black box and create the tests from the requirements. This approach allows us to be unbiased and focus on the requirement set.



== Test case generation

