---
title: "The Worker Pattern"
date: 2026-02-26T16:09:17-08:00
description: "A follow up from my post yesterday, this is something I regularly reach for when writing concurrent code."
draft: false
toc: false
images:
keywords:
  - Golang worker pattern
  - Golang channels
tags:
  - Golang
  - Concurrency
  - Worker Pattern
---
I really like using a worker pattern with [unbuffered channels]({{< ref "/posts/unbuffered_vs_buffered.md" >}}).

API calls, especially when each can be handled separately and independently, are easily implemented with this pattern, and I've seen it help tremendously when downloading artifacts for building in CI, for example.

Instead of setting up a buffered channel with a capacity of 10 in an attempt to concurrently handle 10 requests, you can create an unbuffered channel and read from it using 10 workers.

To do this in a coordinated fashion, however, it does require the usage of a `WaitGroup`, which is part of the `sync` package of the standard library.

Let's take a look:
```
func main() {
	var (
		wg         = new(sync.WaitGroup)
		ch         = make(chan int)
		numWorkers = 10
	)

	// set up a worker pool
	for w := 0; w < numWorkers; w++ {
		wg.Go(func() {
			doSomething(ch)
		})
	}

	// add work items to our channel
	for i := 0; i < 100; i++ {
		ch <- i
	}

	// close the channel after adding everything
	close(ch)

	// wait for our workers to finish
	wg.Wait()
}

func doSomething(ch chan int) {
	// read from the channel
	for item := range ch {
		fmt.Printf("Doing some work for item %d\n", item)
		time.Sleep(time.Millisecond * 500)
	}
}
```
([Go Playground link](https://go.dev/play/p/P-YYQ0VCR8c))

Pretty sweet, isn't it?

**WorkGroup usage prior to Golang `v1.25.0` is different.**

Note that in versions of Golang prior to `v1.25.0`, the usage of a `WaitGroup` was slightly different. Instead of using:
```
for w := 0; w < numWorkers; w++ {
	wg.Go(func() {
		doSomething()
	})
}
```
It would look more like this:
```
for w := 0; w < numWorkers; w++ {
	// add an item of work
	wg.Add(1)
	
	// also pass in the wg to the func
	// and call as a go routine
	go doSomething(wg, ch)
}
```
Which also required you to pass in the `WaitGroup` to the function like so:
```
func doSomething(wg *sync.WaitGroup, ch chan in) {
	// signal done to the wg
	defer wg.Done()

	for item := range ch {
		//...
	}
}
```
I really like the new `wg.Go()` function, since it abstracts away the slightly awkward `wg.Add(1)` and `wg.Done()` function calls.

**Worker IDs in output can help with debugging.**

You can also pass in the worker id to the function being called for additional traceability. Then you can show which worker is doing which item of work.
```
func doSomething(wid int, ch chan int) {
	// read from the channel
	for item := range ch {
		fmt.Printf("Worker %d did work on item %d\n", 
			wid, item)
		time.Sleep(time.Millisecond * 500)
	}
}
```
Check out the [Go Playground link](https://go.dev/play/p/GUiOc6S6qHf) if you want to see it in action.

You can actually _see_ concurrency in action by noticing the numbers scolling by "out of order". Each request is going to take a different amount of time, and you can rely on the Golang runtime to handle all the context switching for you.

```
...
Worker 1 did work on item 67
Worker 9 did work on item 65
Worker 5 did work on item 68
Worker 4 did work on item 66
Worker 0 did work on item 69
Worker 2 did work on item 70
...
```

**It helps to have a "unit of work" defined as its own function.**

For readability and maintainability, I recommend having the actual "work" relegated to its own function. 

And importantly, have that function be simply defined as a single unit of work, rather than comingling it with concurrent parameters (unless you need mutexes, for example, to gate certain non-thread-safe actions).

This makes the calling function essentially a wrapper that handles the concurrency. It's kind of a "separation of concerns".

It also makes for easier unit testing - another topic for another day!