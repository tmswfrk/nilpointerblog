---
title: "A Golang Slice gotcha that...got me"
date: 2026-02-21T12:33:28-08:00
draft: false
toc: false
images:
tags:
  - Golang
  - Slices
  - Arrays
---
I was doing some self study the other day, feeling relatively confident building out a [Trie](https://en.wikipedia.org/wiki/Trie) for an autocomplete function. When checking my work with Gemini, I was recommended something like this as a possible function signature:
```
func (t *Trie) collect(n *TrieNode, pfx string, results *[]string) {
  // ...
}
```
Where I started to spiral was the **`*[]string`** type in the final input parameter. 

**That's weird looking, isn't it?**

In Golang, slices and arrays are often confused. You may say: _"But aren't slices copied by reference?"_ 

And you would be wrong. Like I was. Everything is copied by value in Golang! Even when it appears like they aren't.

**Lets look at some source code...**

A quick look at the [runtime/slice.go](https://go.dev/src/runtime/slice.go) file shows this as the slice data structure:
```
type slice struct {
	array unsafe.Pointer
	len   int
	cap   int
}
```
What does this mean, exactly?
- An "array" is the underlying type / struct that stores your data.
- A "slice" is a wrapper struct that includes both the data you're storing and some metadata about that data.
- A "slice" is technically a "slice header".

This is why when you instantiate an "array", you need to provide it an explicit size, which basically is a type on its own:
```
var arr1 [4]string // creates 4 empty strings
var arr2 [3]string // different type!
```
Compare this to the far more familiar form(s):
```
var s1 []string
var s2 = make([]string, 3) // requires an initial size
var s3 = []string{"something", "goes", "here"}
```
**Getting back to my "gotcha"...**

When you pass a slice to another function, you most typically pass it as a `[]string`. It's easy and it looks nice if I don't say so myself.

And since most functions are written to return another `[]string` or possibly something else entirely, it's pretty rare that you have to think about what's really going on here.

Let's look at a contrived example:
```
var s = []string{"something", "goes", "here"}
fmt.Printf("original: %s\n", s)
modSlice(s) // function call, passes s by value
fmt.Printf("after return: %s\n", s)
```
Where `modSlice()` is defined as:
```
func modSlice(s []string) {
	fmt.Printf("inside func orig: %s\n", s)
	s = append(s, "another")
	fmt.Printf("inside func modified: %s\n", s)
}
```
Should be fine, right? You expect the new entry, "another", to be included in the final "after return" print statement.

Perhaps not:
```
original: [something goes here]
inside func orig: [something goes here]
inside func modified: [something goes here another]
after return: [something goes here]
```
(see [Go Playground link](https://go.dev/play/p/mm2ZuRRrQVu))

It _looks_ like the new entry isn't actually writing to the backing array.

**So why did this happen / not happen?**

If you list out the `s` variable from both the caller's perspective and from the function's perspective, you should effectively see the same item:
```
Caller: mySlice{array: 0x123, len: 3, cap: 10}
Function: mySlice{array: 0x123, len: 3, cap: 10}
```
After all, the function just received _a copy_ of the slice (header). The `array` attribute includes _the same_ array reference.

When we add a new entry to the slice via the `append` function, `mySlice` becomes larger in `len` while modifying the same memory behind the `array` parameter:
```
mySlice{array: 0x123, len: 4, cap: 10}
```
However, when we return back to the caller's stack and context, our `mySlice` variable still has:
```
mySlice{array: 0x123, len: 3, cap: 10}
```

**Note the `3` in the `len` parameter!**

When `fmt.Printf` receives the `s` slice in our original example, it only knows to print up to 3 items, effectively ignoring what _does indeed exist in memory_ at the additional position we just added!

**Gemini's response**

Earlier I noted that Gemini told me to pass the slice by ref as `*[]string`.

This was to guarantee that when the `append` function was called inside the function, that it would modify _the same slice_. It would do the same memory manipulation as before, but would _also_ update the `len` and `cap` struct attributes of the same slice, too.

More can be said about why this isn't the best idea (more allocations to the heap, confusing function signatures), so I rewrote my code to avoid this whole situation to begin with. But for completeness, if you were to make this change to the above contrived code:
```
func main() {
	var s = []string{"something", "goes", "here"}
	fmt.Printf("original: %s\n", s)
	modSlice(&s) // note the reference
	fmt.Printf("after return: %s\n", s)
}

func modSlice(s *[]string) {
	fmt.Printf("inside func orig: %s\n", s)
	*s = append(*s, "another") // both refs
	fmt.Printf("inside func modified: %s\n", s)
}
```
And then run it, you would see:
```
original: [something goes here]
inside func orig: &[something goes here]
inside func modified: &[something goes here another]
after return: [something goes here another]
```
(see [Go Playground link](https://go.dev/play/p/-Q_4G2dGhuo))