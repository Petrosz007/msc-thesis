#import "../utils.typ" : *

#heading(level: 1, numbering: none, [Terminology])

#let my_terms = (
  ("BVA", "Boundary Value Analysis"),
  ("GPT", "General Predicate Testing"),
  ("AST", "Abstract Syntax Tree"),
  ("IR", "Intermediary Representation"),
  ("EP", "Equivalence Partitioning"),
  ("SUT", "System Under Test"),
  ("DSL", "Domain Specific Language"),
  // ("", ""),
).sorted(key: x => x.at(0))

// #grid(
//   columns: (1.5cm, 10cm),
//   row-gutter: 11pt,
//   ..my_terms.map(x => {
//     let (short, long) = x
//     return ([*#short*:], [#long])
//   }).flatten()
// )

#set terms(separator: [: ], indent: 0.5cm)
#for (short, long) in my_terms [/ #short: #long]
