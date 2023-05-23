#import "../utils.typ" : *

#align(center)[
  #heading(level: 1, numbering: none, [Abstract])

  Software testing is a critical part of the Software Development Life Cycle. Test designers often have to create test cases manually from the requirements, which is costly and prone to human error. Boundary Value Analysis is a powerful method for testing programs, General Predicate Testing by Kovacs Attila and Forgacs Istvan is a systemic extension of BVA. There have been some automatic test generation tools based on BVA, but none on GPT. I'll show how I implemented the GPT algorithm to create an automatic test case generation tool. Natural language requirements have to be specified to be systematic and usable by programs, for which I've created Domain Specific Language. I explored how disjunctions can be used in GPT. I analyzed how the algorithmic test case reduction can reduce the number of test cases by up to 90.32% while covering all original test cases. With this tool, the amount of time spent by test designers on Boundary Value Analysis can be significantly reduced.
]

// #write_this[There should be an abstract, which is not a numbered chapter. It should summarise all the things and the results]

// #todo[Review this before finalizing everything, all of this should be present in the thesis]
// #todo[

// In this thesis I'll introduce my automatic test case generation algorithm, which uses General Predicate Testing proposed by Kovacs Attila and Forgacs Istvan @thebook. I'll outline the current state-of-the-art black box testing strategies, what their advantages and disadvantages are. I'll explain what GPT is, how it works in theory, and how I put it into practice. I'll show my proposed Domain Specific Language for formalizing the predicates of requirements. I'll show how this automatic test generation scales much better than the current state-of-the-art manual test generation techniques.

// ]
