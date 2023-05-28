#import "../utils.typ": *
#import "../libs/notes.typ": note, display

= Graph Reduction <graph-reduction>
== What is Graph Reduction?

When GPT generates test cases, it generates an interval (or boolean value) for variables. This means, that the discrete test points should come from those intervals. But there could be a case when multiple test cases would have intersecting intervals. For example:

- T1: `{x: [0, 10]}`
- T2: `{x: (-10, 5)}`
- T3: `{x: [0, 200]}`

For example, in this case, if we select $x = 2$ as out test point, it would cover all the three test cases.

This way, we can reduce the number of our total test cases by trying to find test cases (NTuples) that intersect, then calculate their intersection.

In this example, the intersection of T1 and T2 is `{x: [0, 5)}` and the intersection of that and T3 is `{x: [0, 5)}`.

As we can see, these intersections are still correct and valid test cases, we are still covering all the original test cases generated by GPT. Graph reduction won't violate the correctness of the test cases.

=== NTuple intersection

First, I'll have to clarify that booleans only intersect when their values are the same. So, `true` intersects with `true`, and `false` with `false`. This can be derived from intervals, for example, if `true` is $[0,0]$ and `false` is $[1,1]$. This method can also be applied to Enums (which is a future improvement idea, as detailed in @future-enums).

Two NTuples intersect, when all of their variables intersect. If a variable is not present in an NTuple, we treat it as if it could take all the possible values. In practice this means, that we just use the value of that variable from the other NTuple.

*Example*: The intersection of `{x: [0, 100], y: false, z: [5,5]}` and `{z: [10, 20], y: false}` is `{x: [0, 100], y: false, z: [5,5]}`.

Because NTuples have intersections, in the following sections I'll give examples only with simple intervals, to keep them concise. But those examples can be used for NTuples as well.

#pagebreak()

=== Graph representation

Our goal is to intersect NTuples in a way, that in the end we have the least number of NTuples in the end. We can imagine this problem as a Graph, where the nodes are the NTuples, and we have an edge between two nodes, if those NTuples have an intersection.

Example: 

#align(center, figure(image("../graphs/dot/simple.dot.png", width: 25%), caption: []))

What happens when we intersect two nodes?

#align(center, [
  #figure(
    grid(
      columns: (1fr, 1fr, 1fr),
    image("../graphs/dot/simple0.dot.png", width: 80%),
    image("../graphs/dot/simple1.dot.png", width: 80%),
    image("../graphs/dot/simple2.dot.png", width: 80%),
  ), caption: [One intersection in graph reduction]) <simple-reduction>
]) 

In @simple-reduction we can see, that we select $[0, 20]$ and $[-2, 2]$ for intersection. The detailed process for intersection is the following:

1. We identify the edge connecting them. _(red)_
2. We identify the edges and nodes they are connected to. _(gray dashed)_
3. We remove the edges connecting them to other edges _(gray dashed)_ and remove the edge connecting them. _(red)_
4. We intersect the nodes, and replace the two original nodes with the new intersected node. _(blue)_
5. We look at the nodes they were originally connected to _(gray dashed)_ and see if the new intersected node intersects them. If yes, we restore those edges.

In step 5, it is enough to look at the edges, which were originally connected to the nodes, instead of the whole graph. This is, because with intersections our intervals can only get smaller, so we'd never add new edges to the graph that weren't there before.

=== Strategies for optimizing Graph Reduction

This graph reduction is an NP-complete problem @thebook[p. 116]. Because of this, we can only create algorithms that approximate the most optimally reduced graph.

As you can see, every step of our graph reduction basically creates a new graph. We remove and replace nodes, and also we remove edges. This poses a problem, because the order of reduction matters. Consider the following example:

#align(center)[
  #figure([
    #image("../graphs/circo/lossy_o.dot.png", width: 70%)
    #image("../graphs/circo/lossy_oa1.dot.png", width: 70%)
    #image("../graphs/circo/lossy_oa2.dot.png", width: 70%)
  ], caption: [Optimal join]) <optimal_join>
]

#align(center)[
  #figure([
    #image("../graphs/circo/lossy_o.dot.png", width: 70%)
    #image("../graphs/circo/lossy_ob1.dot.png", width: 70%)
    #image("../graphs/circo/lossy_ob2.dot.png", width: 50%)
  ], caption: [Not optimal join]) <not_optimal_join>
]

If this problem was one dimensional, as in, we only had simple intervals, we could use the $O(n log n)$ solution proposed in @stackexchangeMinimumPointCover. However, this algorithm assumes that the intervals can be sorted in increasing order by their hi endpoints. Because we are dealing with NTuples, and we could have $n$ intervals for each interval, we can't use this algorithm, because we can't define a partial ordering on it that'd work in this case.

=== Abstracting Graph Reduction

Graph reduction can be posed in a more abstract and generic way. This allows us to concentrate more on the reduction part, without getting lost in the details.

After we construct our graph (with the intersection of NTuples), we don't actually need to know the contents of the nodes. In the previous section, the definition for joining edges doesn't actually need to know whether the nodes intersect or not, they only need to know how the edges are connected. (That was derived from intersections, but we can focus on generic edges and nodes from now on.)

We can rephrase the problem the following way: Given a graph, join nodes on edges until no edges remain in the graph. When joining two nodes, the joint node will have edges to nodes to which both the original nodes had edges to. If there were nodes that only one of the original nodes had edges to, then the joint node won't have that edge.

Terminology:
- Losing an edge: When joining nodes, the joint node won't have an edge to a node to which the original nodes had edges to.
- Retaining nodes: When joining nodes, the joint node will have an edge to a node to which the original nodes had edges to.

With this, we can define some properties.

1. When joining nodes, the joint node will retain edges to nodes, to which both the joint nodes have edges to.
2. When joining nodes, edges will be lost to nodes, to which only one joining node had edges to.
3. If we have N nodes which all have edges between them, so it is a complete graph, they can be reduced down to one node. This comes from point 1. and 2., because we only lose edges where not all nodes have edges to that one node, but because we have a complete graph we don't lose edges.
4. We can freely reduce nodes where we retain all the edges after the join.

*Hypothesis:* There is an optimal way to reduce an acyclic component of nodes. The optimal way is, to start joining nodes "from the edges", meaning, from nodes which only have one edge. We can trace back all acyclic components to the example with 4 nodes joined in a line in @optimal_join and @not_optimal_join.

In @optimal_join, we're first joining edges from the ends. This means, that we only lose one edge when joining. In @not_optimal_join, when we are joining in the middle, we lose two edges. Due to this, my hypothesis is that joining from the edges is a good strategy.

As we can see, we can reduce the same starting point to either 2 or 3 three nodes in the end. This means, that there will always be an optimal solution to this problem, and suboptimal ones.

Components with more than 4 nodes exhibit the same behavior. There are also cases, where a component can split into two 4 node chains (like in the example) and then the difference between the optimal and not optimal solutions is 2 (one for each 4 node segment). This can be achieved with a 10 node chain and joining the two nodes in the middle.

#pagebreak()

== MONKE

MONKE stands for Minimal Overhead Node Kollision (Collision) Eliminator. This means, that this algorithm has little to no heuristics (no overhead) and it eliminates colliding (intersecting) nodes, i.e. joining them.

MONKE works in a very simple way: We take the list of edges in the graph, always take one and join the nodes on the edge. Repeat, until there are no edges in the graph.

Surprisingly, this algorithm works quite well, as we'll see in @gr-compare.

*Hypothesis:* If there was a seriously wrong way to join nodes, as in, lose a lot of nodes that other joins could retain, then MONKE wouldn't work that well. Because MONKE is essentially a random algorithm, it wouldn't give optimal results. Therefore, my hypothesis is, that there are no completely wrong joins that can be made. Yes, as we've seen in the previous section, there are ways to have an optimal reduction, but suboptimal reductions are rare.

== Least Losing Nodes Reachable

The heuristic of the Least Losing Nodes Reachable (LLNR) algorithm is that it tries to lose the least amount of nodes that could be reached with a Breadth First Search (BFS).

The idea behind this algorithm is, that if we lose the least number of nodes reachable, then we can join the nodes which can be 'freely joined' (as described in the previous chapter).

The algorithm assigns a weight to each edge, with the following steps:

1. Start a BFS from one of the edges of the node. Count how many nodes are reachable. This will be the before count.
2. Copy the graph and join the nodes on that edge.
3. Do a BFS in the cloned graph from the joint node. The node count will be the after count.
4. `before - after` will be the number of nodes that we wouldn't be able to reach after the join. This will be weight of the edge.

We calculate the weights of all edges. We join the edge with the smallest weight (the one that loses the least nodes reachable). After a join, all the edge weights have to be recalculated, because we potentially lost edges, so graph traversal is effected.

A further optimization could be, that we only recalculate the edges inside a component, because other components' graph traversal won't be affected.

This algorithm is much more computationally expensive than MONKE. Before each join, we have to recalculate all edge weights, so for each edge we have to do a BFS. This scales exponentially with the number of edges in the graph.

Another downside of the algorithm is that it only considers one join. It can't see that a join might be disadvantageous a number of steps from now.

== Least Losing Edges

The heuristic for Least Losing Edges (LLE) is that after each join, we want to lose the least number of edges in total in the graph.

The idea behind this algorithm is similar to Least Losing Nodes Reachable: we want to make optimal joins first.

The algorithm works similarly as Least Losing Nodes Reachable. It assigns a weight to each edge with the following steps:

1. Count the number of edges in the graph.
2. Copy the graph and join the nodes on the edge. Count how many edges are in the copied graph.
3. Count how many edges were removed (lost) from the graph due to the join.

We calculate the weights of all the edges. We join the edge with the smallest weight (the one that loses the least edges). After a join, all the edge weights have to be recalculated, because subsequent joins could affect the edges differently, than the number we calculated.

This algorithm is also much more computationally expensive than MONKE, but a bit faster than Least Losing Nodes Reachable. For each join, we have to simulate all the joins (Same as LLNR), but we only have to count the number of edges, which is a less expensive operation than doing a BFS twice. The number of nodes can be stored in a variable and modified after each join, so it could be a constant operation. This algorithm scales exponentially with the number of edges.

It has the same downside as LLNR, because it only considers the one join, not the subsequent steps.

=== Most Losing Edges

A variation of the LLE algorithm is the Most Losing Edges (MLE) algorithm. It works the exact same way as LLE, but when selecting the edge to join, it'll select the one with the highest weight.

This algorithm is absolutely not practical, but is a good frame of reference for the other algorithms. We can approximate how good a reduction is by looking at a "worst case" reduction.

*Hypothesis:* MLE approximates the worst case of graph reduction. It'll always try to join edges which'll lose the most edges, which are probably bad joins.

#pagebreak(weak: true)

== Least Losing Components

The heuristic for Least Losing Components (LLC) is that after each join we don't want the graph to split into a lot of components. If our graph splits into components, then we can't join nodes in different components. If the graph stays in the fewest number of components, the potential for joins could be there.

The idea behind this algorithm is similar to Least Losing Nodes Reachable, we want to make optimal joins first.

The algorithm works similarly as Least Losing Nodes Reachable. It assigns a weight to each edge with the following steps:

1. Count the number of components in the graph.
2. Copy the graph and join the nodes on the edge. Count how many components are in the copied graph.
3. Count how many new components would be in the graph due to the join.

We calculate the weights of all the edges, then we join the edge with the smallest weight (the one which loses the components). After a join, all the edge weights have to be recalculated, because subsequent joins could affect the edges differently, than the number we calculated.

This algorithm is very computationally expensive. For each join, we have to simulate all the joins (Same as LLNR), but we only have to count the number of components in the graph, which is a costly operation.

It has the same downside as LLNR, because it only considers the one join, not the subsequent steps.

#pagebreak(weak: true)

== Comparing the Graph Reduction Algorithms <gr-compare>

For the benchmark, I've used a 2020 Apple M1 MacBook Pro with 16Gb or RAM. I've used cargo-instrument @cargoInstruments that uses XCode Instruments @xcodeInstruments for profiling.

The baseline runs represent the baseline, when no graph reduction is done. It is needed, because I measured the whole runtime of the program, which includes parsing the GPT Lang source file, creating the NTuples, and creating the initial graph. To get the runtime of only the algorithms, you can subtract the baseline runtime from the runtime.

How to read the results:
- The *Runtime* show the total runtime of the program in seconds (s) or milliseconds (ms). Lower is better.
- The *Num. of Test Cases* columns shows the reduced number of test cases. Lower is better.
- The *%* columns show the reduction percentage. Higher is better.
- The table is ordered by runtime in ascending order.
- When comparing percentages I use percentage points (pp for short).

#let benchmark_table(xs, label_str: none) = [
  #if label_str != none [
    #heading([Benchmarks for #xs.file], level: 3) #label(label_str)
  ] else [
    === Benchmarks for #xs.file
  ]
  GPT Lang code can be found in #ref(label(xs.file + "-code"))

  Number of non-reduced test cases: #xs.og_test_cases \
  Number of edges in the initial graph: #xs.edges
  
  #align(center,
    figure(
      table(
        columns: (15%, 15%, 20%, 10%),
        [*Algorithm*], [*Runtime*], [*Num. of\ Test Cases*], [*%*],
        ..xs.table_data.map(x => {
          let (algo, time, count) = x
          ([#algo], [#time], [#count], 
           [#calc.round((1 - (count / xs.og_test_cases)) * 100.0, digits: 2)%])
        }).flatten()
      ),
      caption: [#xs.file benchmark results]
    )
  )
]

#let price_calculation = (
  file: "price_calculation.gpt",
  og_test_cases: 14,
  edges: 39,
  table_data: (
    ("baseline", "1ms", 14),
    ("MONKE", "3ms", 8),
    ("MLE", "3ms", 9),
    ("LLE", "3ms", 8),
    ("LLNR", "3ms", 8),
    ("LLC", "4ms", 8),
  )
)

#benchmark_table(price_calculation)

Price Calculation is a really simple example, with a tiny graph of 39 edges. All the algorithms reduce to the same number of test cases, except for MLE, as expected.

The runtime is also similar, because of the small graph.


#pagebreak(weak: true)

#let paid_vacation_days = (
  file: "paid_vacation_days.gpt",
  og_test_cases: 55,
  edges: 183,
  table_data: (
    ("baseline", "3ms", 55),
    ("MONKE", "3ms", 22),
    ("MLE", "5ms", 29),
    ("LLE", "9ms", 22),
    ("LLC", "49ms", 24),
    ("LLNR", "57ms", 22),
  )
)

#benchmark_table(paid_vacation_days)

This graph is almost 4.7 times the Price Calculation graph. Now, we can start to see a difference between the number of test cases. MONKE, LLE, and LLNR produce the best reduction. LLC can't reduce that well with 3.64 pp behind the best ones. MLE performs the worst, as expected. However, it is worth noting, that MLE could still reduce the graph almost by half and is 12.73 pp behind the best.

We can see the exponential factor coming in for LLC and LLNR. Their runtimes are an order of magnitude worse than the other algorithms.


#let complex_small = (
  file: "complex_small.gpt",
  og_test_cases: 328,
  edges: 11684,
  table_data: (
    ("baseline", "0.028s", 328),
    ("MONKE", "0.031s", 51),
    ("MLE", "3.11s", 71),
    ("LLE", "26.84s", 45),
    ("LLC", "130.80s", 54),
    ("LLNR", "216.60s", 53),
  )
)

#benchmark_table(complex_small)

Here we make the jump from 189 edges to 11 684 edges and the difference is striking. The runtime of MONKE is still around the baseline with 31ms. We can see that the other algorithms are slower: MLE is 100 times, LLE is 865 times, LLC is 4219 times and LLNR is 6967 slower than the baseline. The exponential scaling difference can be clearly seen in these results.

The difference between the reductions may seem significant at first. LLE has the best reduction, and while MONKE may seem to have 10% more test cases than LLE, the overall reduction from the starting 328 test cases is just 1.83 pp. With MONKE being almost 3 orders of magnitude faster, this 1.83 pp difference is not that much in comparison.

It is also interesting, that MLE has 1.5 times as many test cases as LLE, but the overall difference between reduction is 7.93 pp.


#let complex_medium = (
  file: "complex_medium.gpt",
  og_test_cases: 452,
  edges: 23664,
  table_data: (
    ("baseline", "0.066s", 452),
    ("MONKE", "0.084s", 69),
    ("MLE", "11.19s", 99),
    ("LLE", "111.00s", 58),
  )
)

#benchmark_table(complex_medium)

Because of the exponential scaling of LLC and LLNR, I wasn't able to run them, because they'd take too much time.

In this benchmark, the number of edges in the graph is doubled. The relative difference between the results is similar to the previous example. LLE is 1321 times slower than MONKE. MONKE also starts to drift from the baseline, which means that scaling starts to kick in as well.

There is a 2.44 pp difference between MONKE and LLE.


#let complex_hard = (
  file: "complex_hard.gpt",
  og_test_cases: 3657,
  edges: 1229629,
  table_data: (
    ("baseline", "47.37s", 3657),
    ("MONKE", "153.00s", 354),
  )
)

#benchmark_table(complex_hard, label_str: "complex-hard-chapter")

Because of the exponential scaling of the other algorithms, I could only run MONKE in a reasonable amount of time.

In this example the 1.2 million edges in the graph is quite a big jump from the 22 thousand previously. It shows on MONKE's runtime as well.

From the profiling information, I saw that 108 seconds were spent removing the nodes from the graph. If we subtract the baseline's from MONKE's, that means that most of the runtime is spent removing nodes from the graph. A future improvement idea would be to find a Graph structure that has low costed node removal, while also keeping the node joining performance, so neighbor lookup and edge addition is fast. 

=== Summary

From these benchmarks we could see, that MONKE is the most performant and the second best performing reduction algorithm. In reduction per seconds of runtime it is the best algorithm.

MLE achieving 78% reduction also supports my hypothesis, that there is likely no absolutely wrong way to join nodes that would affect the end result of the reduction significantly. There are certainly better ways and heuristics to use when reducing, as we can see with LLE. The test designers should decide how much time they are willing to spend waiting for test case generation, with the benefit of having a more reduced test set.

In the last example the number of test cases have been reduced to a tenth of the baseline. This shows the power and usefulness of graph reduction. There is quite a difference between having to run 3657 versus 354 test cases, when they cover the exact same equivalence partitions.
