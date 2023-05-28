#import "../utils.typ": *

= Coding in Rust

I used the latest Rust version for this project, which is 1.69 #footnote[https://blog.rust-lang.org/2023/04/20/Rust-1.69.0.html] at the time of writing.

Rust is a performant high-level programming language @rust-lang.org. It borrows functional techniques from other languages, like monadic error handling and a rich type system. Instead of garbage collectors, it uses borrow checking to solve memory management. 

The Rust compiler can catch a lot of errors during compilation. Its rich typesystem, and lint tools like clippy #footnote[https://github.com/rust-lang/rust-clippy], helps writing correct code. For GPT, this was crucial, as there must not be any errors in test case generation.

Another advantage of Rust is that it uses LLVM #footnote[https://rustc-dev-guide.rust-lang.org/overview.html] to compile to native code. Combined with no garbage collection, this allows Rust code to be faster than other languages @bugden2022rust.

Rust can also compile to WebAssembly #footnote[https://developer.mozilla.org/en-US/docs/WebAssembly/Rust_to_wasm], which makes the code available in browsers on websites. This means, that GPT can be run on the web, making the test generation tool more easily available for test designers, they don't even have to install the program on their computer.

The source code of my GPT implementation is open-source and available on GitHub at #link("https://github.com/test-design-org/general-predicate-testing"). The code consist of three main modules:

- `gpt-common`: This hosts the main logic of GPT: parsing, AST, IR, test case generation with GPT, graph reduction.
- `gpt-cli`: This is the command line tool that can generate test cases from `.gpt` source files. It has configurable options, like what graph reduction Algorithm to use, or in what format to display the generated test cases.
- `gpt-frontend`: This contains the frontend application, that compiles the Rust code to HTML and Javascript, so that it can be opened in a web browser.

I'd like to highlight some of the core libraries I used:

- *nom* #footnote[https://github.com/rust-bakery/nom]: Parser combinator library for writing the GPT Lang parser.
- *petgraph* #footnote[https://github.com/petgraph/petgraph]: Graph library with some common graph algorithms included.
- *clap* #footnote[https://github.com/clap-rs/clap]: Command Line Argument Parser for `gpt-cli`.
- *yew* #footnote[https://github.com/yewstack/yew]: Front end framework for creating web applications in Rust.
