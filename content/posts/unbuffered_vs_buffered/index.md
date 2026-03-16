---
title: "Golang's unbuffered and buffered channels"
date: 2026-02-25T16:40:18-08:00
description: "Perhaps one of my favorite parts of the language."
draft: false
toc: false
images:
keywords:
  - unbuffered vs buffered channels
  - Golang channels
tags:
  - Golang
  - Concurrency
  - Best Practices
---
From the [official Go Blog](https://go.dev/blog/codelab-share):

> Do not communicate by sharing memory; instead, share memory by communicating.

They're awesome because they enable concurrency support "out of the box". 

They're basically their own type that implements concurrent safe logic of sharing memory locations of data without the explicit usage of mutexes or locks. The example in the blog link above has some code blocks that show this quite well, actually.

**They can be buffered or unbuffered.**

This is implied in the way you define each type:
```
var unbuffered = make(chan int)
var buffered   = make(chan int, 3)
```
_A great way to describe the difference is that an unbuffered channel will block the go routine it's being called from until it's "filled" with something._

**You can also specify their "direction".**

This means you can make them "bidirectional", "send", or "receive". Note the locations of the `<-` identifier.
```
var bidirectional = make(chan int)
var sendOnly      = make(chan<- int)
var receiveOnly   = make(<-chan int)
```

**You can combine these attributes together.**

So you can have any combination of buffered, unbuffered, send, receive, or bidirectional.
```
var sendOnlyBuffered  = make(chan<- int, 10)
var receiveUnbuffered = make(<-chan int)
```

**You can change this in function headers.**

So this means you could have the following:
```
func main() {
  // create a bidirectional channel
  someChannel := make(chan int)

  myFunc(someChannel)
}

// specify channel in header as receive-only
func myFunc(ch <-chan) {
  // ...
}
```
Not only does this convey meaning, but it can make sure that your accidentally try to write to a channel that you're only expected to read from. Especially important if you have a bunch of different go routines doing different things!

**Reading from channels is done via the `range` function.**

A few additional points about this before an example:
- to read from a channel, you can use the same `range` function similar to how you read from a slice.
- due to this blocking behavior, reading from an unbuffered channel is often done within a separate goroutine.
- it's always a good idea to close the channel when you're done using it, usually via a `defer`.
```
func main() {
  // unbuffered
  var ch = make(chan int)
  defer close(ch)

  // see below
  go doSomething(ch)

  // populate the channel with items
  for i := 0; i < 10; i++ {
    ch <- i // "send to" the channel
  }
}

func doSomething(ch chan int) {
  for item := range ch {
    fmt.Printf("Item was read: %d\n", item)
  }
}
```
(see [Go Playground link](https://go.dev/play/p/yHpobaMikZ_J))

This just iterates over a set of numbers as if it were a slice, but it showcases that channels can work similarly. While also allowing for concurrency _and_ without needing to create and manage your own mutexes. Neat!

**How how would an unbuffered channel handle a longer task?**

Where things get interesting is when you simulate longer running operations in the above code.

Say you modify it a bit to include a `time.Sleep` statement to simulate a worker action (an api call, a db transaction, or something similar):
```
func doSomething(ch chan int) {
	for item := range ch {
		fmt.Printf("Item was read: %d\n", item)
		time.Sleep(time.Second) // simulate long process
	}
}
```
(another, separate [Go Playground link](https://go.dev/play/p/JzuweDGuFZI))

When running this, you'll notice that the "send to" action isn't gated by anything in particular. 

_Yet we only read one item from the channel per second!_

This means that the first `for` loop that populates the channel is being blocked because there's no "buffer" in the channel to queue later iterations up for later.

**Enter buffered channels, which have a capacity.**

This means that if you create one with a capacity of 2, but then try to send it 5 things, 3 of them will be blocked until the first two are read.

```
func main() {
  // make buffered channel with capacity 2
  var ch = make(chan int, 2)

  // same as before
  go writer(ch)

  // simulate slow process before reading
  time.Sleep(time.Second * 2)

  for item := range ch {
    fmt.Printf("Read %d from channel\n", item)
  }
}

func writer(ch chan int) {
  for i := 0; i < 5; i++ {
      ch <- i // this will block on 3, 4, 5
      fmt.Printf("wrote on iteration %d\n", i)

      // show delay between reads
      time.Sleep(time.Second)
  }
  close(ch)
}
```
(see [Go Playground link](https://go.dev/play/p/ByrDcG31Zr5))

So yeah, channels are pretty great. But they can be a bit tricky to grok at first, given that they look and act a bit differently than other parts of the Golang ecosystem.

Either way, expect to hear more from me about channels soon!