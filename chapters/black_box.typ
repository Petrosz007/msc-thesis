// #import "../utils.typ" : *

// = An overview of black-box testing

// == Common testing practices

// Software testing is an essential part of the software development life cycle. Testing software allows us to be confident that the program adheres to the requirements and works as expected. There can be functional and non-functional requirements, in this thesis I'll focus on functional requirements.

// There are multiple approaches to testing software, one is black-box testing, where we create tests sets from the requirement specifications. In practice, this means that we're not looking at how to code is written when writing tests. This way, we can systematically test the correctness of outputs for given inputs @murnane2001effectiveness.

// The state-of-the-art black-box testing methods are: @nidhra2012black @khan2012comparative @thebook

// 1. _Equivalence Partitioning_: The input and output domains can be partitioned in a way, that values in each partition belong to the same Equivalence Class. This way, test cases are only required to have one value from each partition.
// 2. _Boundary Value Analysis_: Test cases are created from the boundaries of Equivalence Classes. These can be the values just below, on, or just above the boundaries. This can catch usual off-by-one errors.
// 3. _Fuzzing_: Black-box fuzz testing is about taking valid inputs and randomly mutating them to try to find implementation bugs. This approach has low code-coverage and requires a lot of test cases. @godefroid2007random There is also white-box fuzzing, which is much more effective, due to having access to the source code @godefroid2008automated.
// 4. _Cause-Effect Graph_: We create a graph and creating links between the effect and its causes. There are four types of these links: indentity, negation, logical OR, and logical AND. There are some proposed automatic test generation tools from Cause-Effect Graphs @son2014test.
// 5. _Orthogonal Array Testing_: OAT is a pairwise testing technique used when the input domain is small, but testing all the possible combinations of inputs would result in a too large test set @Rao2009Jul.
// 6. _All Pair Testing_: All the unique pairs of inputs are in the test case set. This way all the possible pairs are tested, but the test set is quite large.
// 7. _State Transition Testing_: Used for state machines or User Interfaces, where the transitions between states are tested.

// In this thesis I'll assume, that the input variables are independent. Otherwise, domain analysis has to be used @Beizer1983-xr @Binder1999-kg @Forgacs2019-vr.

// Next, I'll explain Equivalence Partitioning and Boundary Value Analysis in more detail, as GPT is based on these methods.

// === Equivalence Partitioning

// In Equivalence Partitioning, the inputs are divided into equivalence classes in a way, that if two inputs belong to the same class, they behave in the same way during testing. If both inputs test the same behavior, then if there is a bug, they can both detect it @thebook.

// The equivalence classes are non-empty, disjoint, and the union of the equivalence classes cover the entire input domain. Equivalence classes are also referred to as partitions.

// The partitions can be either valid or invalid partitions. Valid partitions contain the acceptable values, invalid partitions contain the not acceptable values. A value is acceptable if the predicate returns a logical true value. 

// The steps of Equivalence Partitioning are @thebook:
// 1. Identify the input domain.
// 2. Partition the domain into valid and invalid.
// 3. Refine and merge the partitions until they can't be merged anymore.
// 4. Validate the partitioning.

// Once we have the partitions, we can create test sets by creating a test case for each partition.

// It is possible to obtain the partitioning data without actually doing the partitioning @thebook. We can select the domain boundaries and use the boundaries to approximate the partitions. As borers are easier to compute than the entire partitions and we can generate test cases from these borders, this is a good approximate solution for equivalence partitioning.

// === Boundary Value Analysis

// In most cases, potential bugs occur near the border of equivalence partitions, because of errors made by programmers @thebook. As such, we should select test cases from the partitions to test these boundaries.

// Boundary Value Analaysis builds on Equivalence Partitioning and proposes ways to select test points from the partitions.

// Forgács and Kovács state, that "many textbooks, blogs, software testing courses suggest inappropriate BVA solutions." @thebook[p. 74]. They propose the following method for selecting test values from equvivalence partitions:

// #figure(image("../images/ep_boundary.png"), caption: [EP with closed or open boundaries @thebook[p. 75]])

// These IN, ON, OFF, OUT points will be important, as equivalence partitioning in GPT builds on this (detailed in @ep-in-gpt) 

// *Predicate errors:* While programming, predicates can be written in many wrong ways. The numbers could be off-by-one @rigby2020miss, we could mistype the operator and have `>` instead of `<` or `<=`. Or we could write `!=` instead of `==`.

// BVA helps to detect predicate errors, because these most often occur at borders of partitions. If we have correctly selected test cases to cover all the borders of partitions, we will correctly detect these predicate errors.

// As Forgács and Kovács detailed, BVA is easy when we have one parameter, but once we have multiple parameters, it becomes significantly harder @thebook.

// == Competent Programmer Hypothesis <CPH>

// The Competent Programmer Hypothesis is: "Programmers create programs that are close to being correct, i.e., the specification and the appropriate code are close to each other." @thebook.

// Let's look at an example. We have to create a function that tests if $x < 0$, where $x$ is an integer. We can implement it as `x < 0` and have the test cases $-100, -1, 0, 1, 100$ to test it.

// Let's say, that somebody implements this as `x < 5 && x != 4 && x != 3 && x != 2 && x != 1 && x != 0`. For integers, this implementation is correct, but it is needlessly complicated, and it is far from the specification. In this case, if the programmer makes a predicate error in `x < 5` and writes `x < 6`, the function will return `true` for $5$, meaning `5 < 0`. Our original test cases didn't have this test point, so we wouldn't catch this bug. 

// It can be seen, that programs could be infinitely complicated this way, for example we could do $x < 100$ or $x < 99999999$ with the same principles. We can't test all potential predicate errors in every possible implementation. With CPH, we say that the implementation will be close to the specification, so it is enough to only test predicate errors, which would happen in an implementation close to the specification.

// == Automatic test case generation

// Generating test cases automatically is advantageous, because creating test cases manually takes up a significant amount of time and is prone to human error. 

// White-box testing solutions usually have automatic test generation algorithms, as they can parse the source code and generate test cases from it @fraser2013 @godefroid2008automated. But if we generate test cases from a faulty System Under Test (SUT), one that runs, but doesn't adhere to the requirements, we might not catch those bugs. The usefulness of automatic white-box test generation was called into question by Gordon Fraser and Matt Staats, in their analysis they found that "there was no measurable improvement in the number of bugs actually found by developers" @doesWbHelpTesters.

// White-box test generation algorithms exist that use BVA @bvaWhiteBox, but these are different from black-box solutions.

// Black-box testing solutions have a harder time generating test automatically, because they are derived from the specifications and requirements. Human language is hard to parse and even harder to extract test cases from @ambriola2006systematic. With the recent advances of Generative Pre-trained Transformer models, maybe this will change, but current solutions are prone to so-called 'hallucinations' @azamfirei2023large, and thus we can't rely on them to generate correct test cases.

// To generate test cases automatically, black-box solutions have to use some kind of intermediary format to generate the tests from. Test designers have to convert the requirements to one of these formats. Most of these are formal specifications are in UML diagrams @mustafa2021automated.

// There are some black-box test generation methods using BVA, but they require the use of UML diagrams @samuel2005boundary @mani2017test. These can't test simple functions, only classes with interfaces or state transitions. 

// BWDM @BWDM uses BVA to generate test cases automatically from the VDM++ specification language. In a followup paper they've used pair-wise testing to reduce the number of test cases generated by BVA @Katayama2019.

