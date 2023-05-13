#import "../utils.typ" : *

= Introduction

#write_this[write this. write about testing, automatic test generation, GPT and predicate errors]

== Motivation

#write_this[write this]

== Methodology

In this thesis, my main task was to create an implementation of the GPT algorithm. As the book only outlined how to do GPT manually, I had to come up with ways to make an automatic and algorithmic solution.

First, I had to implement proper interval handling, as there weren't any available libraries that handled intervals this way. In @intervals I'll show how I implemented my own simple- and multiintervals.

Next, when I had working intervals, I had to implement the GPT algorithm. This went through a few iterations. In the first version I could create NTuples by hand and run the GPT test case generation algorithm on it, which generated a non-reduced set of test cases.

But creating NTuples by hand is quite some manual work, so I implemented a CSV like structure for formalising requirements. It was a bit easier and a more user friendly way to use GPT. I also created a web page for it that others could use.

#align(center)[
  #figure(image("../images/2023-05-13-18-52-39.png"), caption: [CSV like GPT Lang])
]

This was a pretty bare-bones solution, it was a bit hard to write and reason about requirements in this format. This is why I created GPT Lang, which I'll detail in @gpt-lang. I had to experiment with and design a DSL, that was easy to write and reason about, was familiar to programmers, but still adhered to black box testing principles. I wrote a parser, designed an AST and an IR, and then transformed the IR to NTuples that GPT could use.

 Because GPT Lang could resemble source code, one could think that we could extend it to analyse source code and generate test cases in a white box way. But as detailed in the next chapters, I explicitly wanted to avoid that and GPT Lang is by-design only for black box testing.

Now I had a user-friendly DSL for writing specifications in, but one pain point was, that the original GPT algorithm was only detailed for conjunctive forms. Disjunctions are an essential part of requirements and programming, so I wanted to research how I could make disjunctions work with GPT. In @or-to-ands I detail this procedure. This is a great lift for GPT, as now the test designers don't have to think about how to bring conjunctive forms to disjunctive forms, my program would handle that automatically. It not only saves time, but reduces the risk of human error.

After that, I've researched how the number of test cases can be reduced in an algorithmic way. In @graph-reduction I detail how I abstracted this problem to be about graph reduction, and what different graph reduction algorithms I came up with. Graph Reduction is as essential part of GPT, it reduces the number of test cases needed by orders of magnitude. This was also a pretty hard procedure to do manually for GPT, so automation can save even more time for the test designers.

In @validation I'll validate that my implementation is correct and generates the test cases outlined in the book. This section also provides examples about how GPT works and what errors it can catch.

After the summary in @summary, I'll talk about some future research and implementation ideas in @future.

