#import "../utils.typ" : *

= Summary <summary>

As I've shown, my GPT implementation works according the book @thebook. I've validated that the automatically generated and reduced test cases cover all kinds of predicate errors.

This tool can be used by test designers to automate the test generation process and validate critical systems. Because of it's automated nature, it can handle problems that were too complex for humans to do by hand. For example `complex_hard.gpt` in @complex-hard-chapter, which had over 1.2 million possible intersections between the NTuples before Graph Reduction.

I could also extend the original GPT algorithm with the handling of disjunctions. This is an important feature, as it allows test designers to describe the requirements close to specification. They don't have to come up with the correct equivalence partitions and conjunctive forms, which is also a lot of manual work and prone to error.

Graph Reduction had great results, with the most complex example having a 90.32% reduction of test cases. This means, that it is enough to use only a tenth of the number of test cases, but we still get the same test coverage. This can help test designers, who have to calculate the outputs for all of these test cases according to the specifications. It also reduces the amount of time it takes for the unit tests to run, improving the efficiency of Continuous Integration systems.

Murane argues that "One disadvantage with boundary value analysis is that it is not as systematic as other prescriptive testing techniques" @murnane2001effectiveness. As I've demonstrated, GPT is systematic and test cases can be generated automatically with my GPT implementation.

I think that this tool can be foundation for the GPT technique, and it can be used as an example of the effectiveness of automatic black-box BVA test generation.

== Acknowledgements

I'd like to thank Kovács Attila for his mentorship and guidance for almost two years during my studies. Without him and his work on General Predicate Testing, I couldn't have achieved these results.

I'd also like to thank the original group with whom I've started this GPT journey. We've brainstormed about the first implementations of GPT during our Requirement Analysis course, and we came up with MONKE. It's so wonderful to see that MONKE is still going strong after all these years.

Last, but not least, I'd like to thank Gyimesi Kristóf for his dedicated support during all four semesters, his great insights when designing complex algorithms, and the massive amount of time he put into proofreading this thesis.
