---
title: "Building strings in Golang"
date: 2026-03-10T15:00:17-07:00
description: "Diving into a contrived example is a great way to get more familiar with Golang."
draft: false
toc: false
images:
keywords:
  - stringbuilder
  - Golang string concatenation
  - Golang performance comparison
tags:
  - strings
  - Golang
---
**How do I build a string in Golang?**

Building a string seems trivial, and it generally is, but it's a great way to dive into further to understand some of the basics around what makes Golang so interesting.

First of all, let's note that a _string_ in Golang is _immutable_. That means whenever you want to append to a string, the existing string _plus what you're appending_ needs to be copied to a new string in memory. This means that when optimizing code, we need to be mindful when we write code that performs these actions many times.

This is more of a common thing to think about in rust, but I digress.

In general, there are largely 4 primary ways to append to a string in Golang:
- Using string concatenation via the `+` or `+=` function.
- Using the `fmt` module to use formatting directives.
- Using a `bytes.Buffer` to collect bytes that represent strings.
- Using the `strings.Builder` type from the `strings` library.

The last two are quite different from the first two. I find that they're less often done because, well, people are either not as familiar with them or are more concerned about other, slower portions of their code.

Paying attention to _why_ this is, though, is certainly helpful when writing other code that "[smells](https://en.wikipedia.org/wiki/Code_smell)" similar.

So by way of example, in the same order:
```
var str string

// string concatenation
str = "This " + "is " + "an " + "example"

// using formatting directives
str = fmt.Sprintf("I have %d examples", 4)

// using a byte buffer
var buf = new(bytes.Buffer)
buf.WriteString("This")
buf.WriteString("is")
buf.WriteString("an")
buf.WriteString("example")
str = buf.String()

// using strings.Builder
var bStr strings.Builder
bStr.Grow(4) // to pre-allocate memory
bStr.WriteString("This")
bStr.WriteString("is")
bStr.WriteString("an")
bStr.WriteString("example")
str = bStr.String()
```
In short, the _fastest_ way of the above is the simple string concatenation use case. This is because during compilation, the Golang compiler actually performs a shortcut and makes this variable into a single constant, which is then referenced directly as a completed string from a special section of read-only memory.

**There's a caveat to this, however.**

If you're appending to a string within a `for` loop, the compiler often is _unable to infer_ the combined constant size of the final string. This usually results in a bunch of extra copy actions and leftover memory that the garbage collector needs to come along later to clear out. Not great!

**The slowest?**

The slowest is the `fmt.Sprintf()` method, since it requires multiple calls to handle parsing `4` into a `string` type, then joins it together into a final string. It makes it incredibly easy for you as the developer, but it isn't fast.

**So how do each perform?**

When running some benchmarks on all four options, the `bytes.Buffer` and `strings.Builder` methods are quite similar - still much faster than the `fmt.Sprintf()` method, but slower than the compiler-optimized concatenation.

Without including too much code here, using `go test -bench=.` on my local computer:
```
❯ go test -bench=.
goos: darwin
goarch: arm64
pkg: github.com/tmswfrk/stringbuilder
cpu: Apple M3
BenchmarkSB/WithPlus-8         	31813908	        37.52 ns/op
BenchmarkSB/WithSprintf-8      	 5284426	       228.4 ns/op
BenchmarkSB/WithBuffer-8       	15300552	        81.16 ns/op
BenchmarkSB/WithStringBuilder-8     16196134	        79.69 ns/op
PASS
ok  	github.com/tmswfrk/stringbuilder	6.369s
```
In the above, the columns are, from left to right:
- the name of the test
- the number of times that test was run
- how many nanoseconds occurred, on average, per allocation (to heap memory)

This means that the string concatentation method used the fewer number of allocations and ran the most times (due to its efficiency), while the formatting directive used the most allocations and ran the fewest number of times.

**When should I use the `strings.Builder` or `bytes.Buffer` methods?**

The `strings.Builder` and `bytes.Buffer` methods are really quite good when appending to a string and you don't know many times you need to do so. 

If we try to append using a `for` loop as mentioned earlier, you're likely going to have a bad time. Let's check out some example code:
```
func withPlus(x string) string {
	return x + x + x + x + x + x + x + x + x + x
}

func withPlusForLoop(x string) string {
	for i := 0; i < 10; i++ {
		x += x
	}
	return x
}

func withStringBuilder(x string) string {
	bb := &strings.Builder{}
	for i := 0; i < 10; i++ {
		bb.WriteString(x)
	}
	return bb.String()
}
```
When we test these using `go test -bench=.` you see some very interesting results:
```
❯ go test -bench=.
goos: darwin
goarch: arm64
pkg: github.com/tmswfrk/stringbuilder
cpu: Apple M3
BenchmarkSB/WithPlus-8         	31047177	        38.21 ns/op
BenchmarkSB/WithPlusForLoop-8  	  909802	         1234 ns/op
BenchmarkSB/WithStringBuilder-8     14542545	        74.36 ns/op
PASS
ok  	github.com/tmswfrk/stringbuilder	4.573s
```
Note _just how much slower_ the string concatenation is with the for loop is!

True story, when attempting to run this from `0 < i < 1000`, my computer basically froze. Crazy.

**Where can I learn more?**

I did most of this when attending GopherCon in 2025, but there's a blog I'd suggest you read for more in-depth information: https://alexanderobregon.substack.com/p/go-string-concatenation-costs 