#import "../utils.typ": *

= Graph Reduction
== What is Graph Reduction?

When GPT generates test cases, it generates an interval (or boolean value) for variables. This means, that the discrete test points should come from those intervals. But there could be a case when multiple test cases would have intersecting intervals. For example:

- T1: `{x: [0, 10]}`
- T2: `{x: (-10, 5)}`
- T3: `{x: [0, 200]}`

For example in this case if we select $x = 2$ as out test point, it would cover all the three test cases.

This way, we can reduce the number of our total test cases, by trying to find test cases (NTuples) which intersect and calculating their intersection.

In this example, the intersection of T1 and T2 is `{x: [0, 5)}` and the intersection of that and T3 is `{x: [0, 5)}`.

=== NTuple intersection

First, I'll have to clarify, that booleans only intersect when their values are the same. So `true` intersects with `true`, and `false` with `false`. This can be derived from intervals, for example if `true` is $[0,0]$ and `false` is $[1,1]$. This method can also be applied to Enums (which is a future improvement idea, as detailed in #todo[link future improvement chapter about enums]).

Two NTuples intersect, when all of their variables intersect. If a varible is not present in an NTuple, we treat it as if it could take all the possible values. In practise this means, that we just use the value of that variable from the other NTuple.

*Example*: The intersection of `{x: [0, 100], y: false, z: [5,5]}` and `{z: [10, 20], y: false}` is `{x: [0, 100], y: false, z: [5,5]}`.

because NTuples have intersections, in the following sections I'll give examples only with simple intervals, to keep them concise. But those examples can be used for NTuples as well.

#pagebreak()

=== Graph representation

So our goal is to intersect NTuples in a way, that in the end we have the least number of NTuples possible. We can imagine this problem as a Graph, where the nodes are the NTuples, and we have an edge between two verities, if those NTuples have an intersection.

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
  ), caption: [One intersection in Graph Reduction]) <simple-reduction>
]) 

In @simple-reduction we can see, that we select $[0, 20]$ and $[-2, 2]$ for intersection. The detailed process for intersection:

1. We identify the edge connecting them. _(red)_
2. We identify the edges and nodes they are connected to _(gray dashed)_
3. We remove the edges connecting them to other edges _(gray dashed)_ and remove the edge connecting them _(red)_.
4. We intresect the nodes, and replace the two original nodes with the new intersected node. _(blue)_
5. We look at the nodes they were originally connected to _(gray dashed)_ and see if the new intersected node intersects them. If yes, we restore those edges.

In step 5 it is enough to look at the edges which were originally connected to the nodes instead of the whole graph. This is, because with intersections our intervals can only get smaller, so we'd never add new edges to the graph that weren't there before.

=== Strategies for optimising Graph Reduction

This Graph Reduction is an NP-complete problem @thebook[p. 116]. Because of this, we can only create algorithms that approximate the most optimally reduced graph.

As you can see, every step of our Graph Reduction basically creates a new graph. We remove and replace nodes, we remove edges. This poses a problem, because the order of reduction matters. Consider the following example:

#align(center)[
  #figure([
    #image("../graphs/circo/lossy_o.dot.png")
    #image("../graphs/circo/lossy_oa1.dot.png")
    #image("../graphs/circo/lossy_oa2.dot.png")
  ], caption: [Optimal join]) <optimal_join>
]

#align(center)[
  #figure([
    #image("../graphs/circo/lossy_o.dot.png")
    #image("../graphs/circo/lossy_ob1.dot.png")
    #image("../graphs/circo/lossy_ob2.dot.png", width: 70%)
  ], caption: [Not optimal join]) <not_optimal_join>
]

If this problem would be one dimentional, as in, we only had simple intervals, we could use the $O(n log n)$ solution proposed in @stackexchangeMinimumPointCover. But, that algorithm assumes that the intervals can be sorted in increasing order by their hi endpoints. Because we are dealing with NTuples and we could have $n$ intervals for each interval, we can't use this algorithm, because we can't define a partial ordering on it that'd work in this case.

=== Abstracting Graph Reduction

Graph reduction can be posed in a more abstract and generic way. This allows us to concentrate more on the reduction part, without getting lost in the details.

After we construct our graph (with the intersection of NTuples), we don't actually need to know the contents of the nodes. In the previous section the definition for joining edges doesn't actually need to know whether the nodes intersect or not, they only need to know how the edges are connected. (That was derived from intersections, but we can focus on generic edges and nodes from now on.)

We can rephrase the problem the following way: Given a graph, join nodes on edges until no edges remain in the graph. When joining two nodes, the joint node will have edges to nodes to which both the original nodes had edges to. If there were nodes only one of the original nodes had edges to, the joint node won't have that edge.

Terminology:
- Losing an edge: When joining nodes, the joint node won't have an edge to a node to which the original nodes had edges to.
- Retaining nodes: When joining nodes, the joint node will have an edge to a node to which the original nodes had edges to.

With this, we can define some properties.

1. When joining nodes, the joint node will retain edges to nodes to which both the joint nodes have edges to.
2. When joining nodes, edges will be lost to nodes to which only one joining node had edges to.
3. If we have N nodes which all have edges between them, so it is a complete graph, they can be reduced down to one node. This comes from 1. and 2., because we only lose edges where not all nodes have edges to that node, but because we have a complete graph we don't lose edges.
4. We can freely reduce nodes where after joining we retain all the edges.

*Hypothesis:* There is an optimal way to reduce an asyclic component of nodes. The optimal way is to start joining nodes "from the edges", meaning, from nodes which only have one edge. We can trace back all acyclic components to the example with 4 nodes joined in a line in @optimal_join and @not_optimal_join.

In the @optimal_join we're first joining edges from the ends. This means, that we only lose one edge when joining. In @not_optimal_join, when we are joining in the middle, we lose two edges. This is why my hypothesis is, that joining from the edges is a good strategy.

As we can see, we can reduce the same starting point to either 2 or 3 three nodes in the end. This means, that there will always be an optimal solution to this problem, and suboptimal ones.

Components with more than 4 nodes exhibit the same behavior. There are also cases, where a component can split into two 4 node chains (like in the example) and then the difference between the optimal and not optimal solutions is 2 (one for each 4 node segment). This can be achieved with a 10 node chain and joining the two nodes in the middle.


== MONKE

MONKE stands for Minimal Overhead Node Kollision Elliminator. This means, that this algorithm has little to no heuristics (no overhead) and it elliminates kolliding (intersecting) nodes, A.K.A. joining them.

MONKE works in a very simple way: We take the list of edges in the graph, always take one and join the nodes on the edge. Repeat, until there are no edges in the graph.

Suprisingly, this algorithm works quite well, as we'll see in @gr-compare.

*Hypothesis:* If there was a seriously wrong way to join nodes, as in, lose a lot of nodes that other joins could retain, MONKE wouldn't work that well. Because MONKE is essentially a random algorithm, it wouldn't give optimal results. Therefore, my hypothesis is, that there are no completely wrong joins that can be made. Yes, as we've seen in the previous section, there are ways to have an optimal reduction, but suboptimal reductions are rare.

== Least Losing Nodes Reachable

The heuristic of the Least Losing Nodes Reachble (LLNR) algorithm is that it tries to lose the least amount of nodes that could be reached with a Breadth First Search (BFS).

The idea behind this algorithm is, that if we lose the least number of nodes reachable, is that this way we can join the nodes which can be 'freely joined' (as described in the previous chapter).

The algorithm assigns a weight to each edge, with the following steps:

1. Start a BFS from one of the edges of the node. Count how many nodes are reachable. This will be the before count.
2. Copy the graph and join the nodes on that edge.
3. Do a BFS in the cloned graph from the joint node. The node count will be the after count.
4. before - after will be the number of nodes that we wouldn't be able to reach after the join. This will be weight of the edge.

We calculate the weights of all edges. We join the edge with the smallest weight (least losing nodes reachable). After a join, all the edge weigths have to be recalculated, because we potentially lost edges, so graph traversal is effected.

A further optimisation could be, that we only recalculate the edges inside a component, because other components' graph traversal won't be affected.

This algorithm is much more computationally expensive than MONKE. Before each join we have to recalculate all edge weights, so for each edge we have to do a BFS. This scales exponentially with the number of edges in the graph.

Another downside of the algorithm is that it only considers one join. It can't see that that join might be disadvantageous X steps from now.

== Least Losing Edges

The heuristic for Least Losing Edges (LLE) is that after each join we want to lose the least number of edges in total in the graph.

The idea behind this algorithm is similar to Least Losing Nodes Reachable, we want to make optimal joins first.

The algorithm works similarly as Least Losing Nodes Reachable. It assigns a weight to each edge with the following steps:

1. Count the number of edges in the graph.
2. Copy the graph and join the nodes on the edge. Count how many edges are in the copied graph.
3. See how many edges were removed (lost) from the graph due to the join.

We calculate the weights of all the edges. We join the edge with the smallest weight (least losing edges). After a join, all the edge weigths have to be recalculated, because subsequent joins could affect the edges differently, than the number we calculated.

This algorithm is also much more computationally expensive than MONKE, but a bit faster than Least Losing Nodes Reachable. For each join we have to simulate all the joins (Same as LLNR), but we only have to count the number of edges, which is a less expensive operation than doing a BFS twice. The number of nodes can be stored in a variable and modified after each join, so it could be a constant operation. This algorithm scales exponentially with the number of edges.

It has the same downside as LLNR, it only considers the one join, not the subsequent steps.

== Comparing the Graph Reduction Algorithms <gr-compare>

#todo[write this]
