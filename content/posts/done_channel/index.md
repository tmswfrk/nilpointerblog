---
title: "Using the \"done\" channel in Go"
date: 2026-02-27T14:29:51-08:00
description: "I see this pattern a lot, and I often confuse it with how WaitGroups work."
draft: false
toc: false
images:
keywords:
  - Golang channels
  - Golang done channel
tags:
  - Golang
  - Concurrency
  - Done channel
---
I wanted to document how a `done` channel is most commonly used. 

Mainly because I've personally found it to be more confusing than it should be.

It usually looks a bit like this, when following a worker pattern:
```
func main() {
  var doneCh = make(chan struct{})

  // Perform some concurrent work
  // ...

  // Wait on that work
  for i := 0; i < 10; i++ {
    <-doneCh
  }
  
  // complete
}
```
I intentially left out a bit here to highlight what a "done" channel actually looks like. 

Following up on the [worker pattern]({{< ref "/posts/worker_pattern.md" >}}) post yesterday, I also connected a few dots that previously I had never connected.

**A `done` channel does effectively the same thing as a `WaitGroup`.**

In the example above, the `<-doneCh` command is a blocking operation. The command waits for something to be sent to the channel before it can read an empty struct from it. In this case, a send operation is performed at the end of a function being called from within a go routine.

Note that the _content_ of the channel doesn't matter - only that something is sent to it. It's only there to block further operations while longer tasks finish their work.

**The `struct{}` type is a little bit special in Golang.**

Bare `struct{}` types in Golang allocate no memory. This is super helpful if you want to build a `Set` or something where you only care about the presence of a key, or in this case, the presence of anything in the channel to gate behavior.

From [Dave Cheney's blog](https://dave.cheney.net/2014/03/25/the-empty-struct) and using `unsafe.Sizeof()` to show memory usage of items, we can see that a `struct{}` takes no bytes.
```
var s struct{}
fmt.Println(unsafe.Sizeof(s))
// prints 0
```
So rather than using up more memory than you need to storing throwaway data, it's a great idea to use `chan struct{}` for a `done` channel.

**Going back to the example above...**

Using the previously discussed [worker pattern]({{< ref "/posts/worker_pattern.md" >}}):
```
func main() {
  var (
    workCh = make(chan int)
    doneCh = make(chan struct{})
    numWorkers = 10
  )

  // set up a worker pool
  for i := 0; i < numWorkers; i++ {
    go doWork(i, workCh, doneCh)
  }

  // add task items to our work channel
  for i := 0; i < 100; i++ {
    workCh <- i
  }

  // close after adding all tasks
  close(workCh)

  // block using the doneCh
  for i := 0; i < numWorkers; i++ {
    <-doneCh
  }
  // complete!
}
```
One more important thing to add here is how the `doWork()` function operates!

Similar to how, prior to Golang `v1.25.0`, we had to pass in the `WaitGroup` to the go routine's function to decrement it, we have to do the same here with the `doneCh`.

```
func doWork(wid int, workCh chan int, doneCh chan struct{}) {
  for work := range workCh {
    // ... do something that takes a while
  }
  
  // send an empty struct to the channel
  doneCh <- struct{}{}
}
```
(See the [Go Playground link](https://go.dev/play/p/HPvyDZLHInU) for the complete example)

**Note the similarities to a `WorkGroup`!**

Previously, we would:
- `wg.Add(1)` prior to calling the `go doWork()` operation.
- Pass in the `wg` to the function.
- `defer wg.Done()` to signal "done" when `doWork()` was completed.

Whereas in this pattern, the exact same process occurs:
- Set up a blocking call on the done channel with `<-doneCh`.
- Pass in the `doneCh` to the function.
- Send an empty struct to the channel when `doWork()` was completed.

Just like you have to `wg.Add(1)` _for each worker's invocation of its go routine_, you have to set up a blocking "wait" on the `doneCh`.

**Using a done channel without the worker pattern**

Without using the worker pattern, you need to model this function using a single worker in-line function:
```
func main() {
	var (
		workCh = make(chan int)
		doneCh = make(chan struct{})
	)

  // set up a single worker
  go func() {
    for work := range workCh {
      // do some work until channel is closed
      // ...
    }
    // signal the end of the work tasks
    doneCh <- struct{}{}
  }()

  // send all tasks to work channel
  for i := 0; i < 100; i++ {
    workCh <- i
  }

  // close when all tasks are sent
  close(workCh)

  // wait for the signal
  <-doneCh

  // complete!
}
```
(See the [Go Playground link](https://go.dev/play/p/M3hXPcAqmDk))

This is a good pattern to use if each task is simple and fast to perform, but adding each task is expensive.

All this being said, I'd still recommend using the `sync.WaitGroup` method if possible, while also utilizing the newer constructs available in Golang >= `v1.25.0`, since it's just far easier to reason about! 

But this is still great to know, and I know I'm glad I went back to review this one again.