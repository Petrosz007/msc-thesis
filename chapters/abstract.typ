#import "../utils.typ" : *

#align(center)[
  #heading(level: 1, numbering: none, [Abstract])
]

  Software testing is a critical part of the Software Development Life Cycle. Test designers often have to create test cases manually from the requirements, which is costly and prone to human error. This is partly because natural language requirements are hard to formalize, and there are currently no tools to do it automatically.
  
  Boundary Value Analysis (BVA) is a powerful black-box method for testing programs. In their book Kovács Attila and Forgács István proposed General Predicate Testing (GPT), which is a systemic test case generation method based on BVA. There have been some automatic test generation tools based on BVA, but none on GPT. The book describes the GPT method for test designers for manual application, but that can be prone to human error. The GPT method was only defined for conjunctive forms, so if the requirements had disjunctions, the test designers had to convert them to conjunctions by hand. Furthermore, there was no formal way of reducing the number of test cases by hand, it relied on intuition.
  
  In this thesis I'll present an algorithmic formalization of the GPT method, making it possible to be easily implemented and integrated into automatic test generation tools. Based on that, I've created an implementation and published it as an open-source tool.
  I've created a domain specific language (DSL) for specifying natural language requirements in a way that can be used for GPT. In addition, I added support to express disjunctions in the DSL. I've also defined an algorithm to reduce the number of initially generated test cases significantly. In some cases the reduction can reach 90.32%, while still covering all initial test cases. With this tool, the amount of time spent by test designers on General Predicate Testing can be significantly reduced.


// #write_this[There should be an abstract, which is not a numbered chapter. It should summarise all the things and the results]

// #todo[Review this before finalizing everything, all of this should be present in the thesis]
// #todo[

// In this thesis I'll introduce my automatic test case generation algorithm, which uses General Predicate Testing proposed by Kovacs Attila and Forgacs Istvan @thebook. I'll outline the current state-of-the-art black box testing strategies, what their advantages and disadvantages are. I'll explain what GPT is, how it works in theory, and how I put it into practice. I'll show my proposed Domain Specific Language for formalizing the predicates of requirements. I'll show how this automatic test generation scales much better than the current state-of-the-art manual test generation techniques.

// ]
