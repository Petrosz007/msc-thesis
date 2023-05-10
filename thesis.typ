#import "template.typ": project
#import "utils.typ" : *

#show: project.with(
  title: "General Predicate Testing",
  author: (
    name: "Andi Péter",
    degree: "Computer Science MSc"
  ),
  supervisor: (
    name: "Kovács Attila",
    affiliation: "Professor, Ph.D."
  ),
  university: (
    name: "Eötvös Loránd University",
    faculty: "Faculty of Informatics",
    department: "Dept. of Computer Algebra",
    city: "Budapest",
    logo: "images/elte_cimer.jpg"
  ),
  date: "2023",
  biblography_file: "works.bib"
)

#include "chapters/introduction.typ"

#include "chapters/intervals.typ"

#include "chapters/gpt_algo.typ"

#include "chapters/gpt_lang.typ"

#include "chapters/graph_reduction.typ"

#include "chapters/examples.typ"

= Code architecture
== Rust
== Frontend app, webassembly

#include "chapters/future.typ"

#include "chapters/todos.typ"

#include "chapters/appendix.typ"

