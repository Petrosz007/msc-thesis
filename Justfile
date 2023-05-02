watch:
  typst watch thesis.typ

watch-graphs:
  find 'graphs/' -name '*.dot' | entr -s 'just compile-graphs'

compile-graphs:
  dot -Tpng -O ./graphs/dot/*.dot
  circo -Tpng -O ./graphs/circo/*.dot
