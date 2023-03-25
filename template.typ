    #let title_page(title, author, supervisor, university, date) = {
  // Title row
  grid(columns: (20%, 80%),
    image(university.logo),
    align(center + horizon)[
      #text(size: 16pt)[*#university.name*] \
      #text(size: 14pt)[#university.faculty] \
      #text(size: 12pt)[#university.department]
    ]
  )

  v(18em)

  // Title
  align(center, text(size: 20pt)[*#title*])
  
  v(14em)

  // Authors
  grid(
    // columns: (1fr,) * calc.min(2, authors.len()),
    columns: (70%, 30%),
    [#supervisor.name \ #supervisor.affiliation],
    [#author.name \ #author.degree]
  )

  // Date
  align(center + bottom)[#university.city, #date]
}

#let project(
  title: "", 
  author: (name: "", degree: ""), 
  supervisor: (), 
  university: (), 
  date: "1970", 
  biblography_file: "",
  body
) = {
  // Set the document's basic properties.
  set document(author: author.name, title: title)

  set page(
    paper: "a4",
    margin: (left: 35mm, right: 25mm, top: 25mm, bottom: 25mm),
    // Page numbers will start from one less, because the title page doesn't count
    numbering: (num, body) => if num == 1 { "" } else { str(num - 1) },
    number-align: center,
  )

  set text(
    font: "Source Sans Pro", 
    lang: "en",
    size: 12pt,
    spacing: 150%
  )

  set heading(numbering: "1.1")

  
  // Start every chapter on a new page
  show heading.where(
    level: 1
  ): it => {
    pagebreak(weak: true)
    pad(top: 2em, bottom: 0.5em, it)
  }

  // Title page
  title_page(title, author, supervisor, university, date)
  pagebreak()


  // Table of contents.
  outline(depth: 3, indent: true)
  pagebreak()


  // Main body.
  set par(justify: true)
  set page(header: align(center, smallcaps(title)))

  body

  bibliography(biblography_file)
}
