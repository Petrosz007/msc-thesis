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

#include "chapters/abstract.typ"

#include "chapters/terminology.typ"

#include "chapters/introduction.typ"

// #include "chapters/black_box.typ"

#include "chapters/intervals.typ"

#include "chapters/gpt_algo.typ"

#include "chapters/gpt_lang.typ"

#include "chapters/graph_reduction.typ"

#include "chapters/examples.typ"

#include "chapters/code_architecture.typ"

#include "chapters/summary.typ"

#include "chapters/future.typ"

#include "chapters/todos.typ"

#include "chapters/appendix.typ"

