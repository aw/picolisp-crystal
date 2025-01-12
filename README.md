# PicoLisp FFI with Crystal

This repo provides a simple example of how to use [PicoLisp](https://software-lab.de/down.html) with [Crystal](https://crystal-lang.org/install/) using PicoLisp's FFI `(native)` functionality.

This is similar to [picolisp-zig](https://github.com/aw/picolisp-zig) and [picolisp-rust](https://github.com/aw/picolisp-rust), except written for _Crystal_.

# Requirements

  * Crystal `v1.14+`
  * PicoLisp 64-bit `pil21`
  * Development libraries `apt-get install libevent-dev libpcre3-dev`

# Getting started

Once you've setup _PicoLisp_ and _Crystal_, simply type `make` to build and test the shared library.

# Output

Before I explain what's going on, here's what the output should look like:

```
Result code: 0
Extracted struct:
(de Extracted (42 43)
   ("A" "B")
   65535
   9223372036854775807
   "pilcrystal"
   (80 105 99 111 76 105 115 112) )
```

# Explain

The code can be found in [extract.l](extract.l) and [pil.cr](pil.cr). The _Crystal_ code is designed as a **shared library** and can be called by PicoLisp's **(native)** function to pass data to/from between both languages.

## PicoLisp code explanation

First, the code allocates 32 bytes of memory, which will be used to store data in a [struct](https://software-lab.de/doc/refS.html#struct).

It then creates a struct named `P` with the following specification:

  * 2 arbitrary bytes
  * 2-bytes containing valid UTF-8 characters
  * 1x 32-bit (4 bytes) signed integer
  * 1x 64-bit (8 bytes) signed long
  * 1x 8-byte null-terminated string
  * 1x 8-byte arbitrary bytes array

Then the following [native](https://software-lab.de/doc/refN.html#native) call is made and its result is stored in the `Res` variable:

```picolisp
(native "./libpil.so" "extract" 'I P)
```

This calls the `extract` function from the _Crystal_ library, with the `P` struct as its only parameter. It expects a 32-bit signed integer `I` as the return value (it will be either `0` or `-1`).

Next, the code will extract the `P` structure using the specification described above:

```
(struct P '((B . 2) (C . 2) I N S (B . 8)))
```

Finally, the code will free the previously allocated memory and print the result of the `P` structure.

Some tests run at the end to ensure the data received from _Crystal_ is what we expected.

### Note

  * The values sent to the _Crystal_ library will be printed by _Crystal_ and tested with the _spec_ equivalence tests.
  * The values received from the _Crystal_ library will be printed by _PicoLisp_ as `Extracted struct:`.

## Crystal code explanation

**WARNING:** I'm not certain if _Crystal_ accepts **null pointers**, so this code should be **considered dangerous** since it doesn't explicitly perform input validation or checks.

The _Crystal_ code defines the struct for the received data; it is named `PilStruct` in the `C` lib, and contains the exact same specification as the `P` struct in the _PicoLisp code explanation_.

The `extract()` function creates a new struct in the variable `newstruct` which contains some new values, different from what was received by _PicoLisp_.

The code then dereferences the pointer into a variable named `mystruct` and runs some tests on the entire struct received from _PicoLisp_. If any of the tests fail, an exception will be raised (in _Crystal_) and a stack trace will appear in the output 

Finally, it overwrites the `mystruct` values with the new ones from `newstruct`, and returns `0`. _PicoLisp_ can then read the return code and the new struct data.

# Thoughts

There isn't much to this code, but I thought it would be fun to create a working FFI library that's _not_ written in _C_ or _Rust_ or _Zig_ and which works perfectly with _PicoLisp_.

Enjoy!

# Contributing

  * For bugs, issues, or feature requests, please [create an issue](https://github.com/aw/picolisp-crystal/issues/new).

# License

[0BSD License](LICENSE)

Copyright (c) 2024 Alexander Williams, https://a1w.ca
