---
title: "A thought on debugging"
date: 2026-02-24T13:48:08-08:00
description: "Who doesn't love a good quote?"
draft: false
toc: false
images:
keywords:
  - Debugging
  - Computer Science Quotes
  - AI thoughts
tags:
  - Debugging
  - Quotes
  - AI
---
> Everyone knows that debugging is twice as hard as writing a program in the first place. So if you’re as clever as you can be when you write it, how will you ever debug it?

[Brian W. Kernighan](https://en.wikipedia.org/wiki/Brian_Kernighan) is attributed to that quote, and it (regularly) reasonates a lot with me.

I think sometimes as engineers, we actually _like_ complexity. It feels fun to build something really interesting and technical in scope, and we often confuse simple topics like "simple", "technical", or even "beautiful", "clean", "elegant"...the list goes on.

I actually also like this variation on the same quote:

> “Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live.”

Supposedly by Martin Goldin (although I can't find a definitive account of which Martin Goldin this is).

**It's only gonna get worse with AI.**

I don't know if you've heard, but there's this thing called "AI" and it's supposed to make life better for all of us and automate us all out of existence.

I've seen it being used a _lot_ lately, with engineers priding themselves on how they don't actually need to write code anymore, relying on AI agents like Claude, ChatGPT, Gemini, etc to do it for them. 

**Nevermind the actual "engineering" part of all this.**

Regardless, the more coding you offload to an agent to do on your behalf, the less _you_ know about how it actually works. 

And the _more_ complicated it's going to be to figure things out when they (inevitably) go wrong.

Unless you _very_ proactively review it and fix these PRs as they come, of course. But given how often we all see `"LGTM"` on our Github PR's, I have a feeling that this may very quickly spiral out of control if we don't manage it.

**So let's take a step back.**

If AI works for you and it simplifies your life, great. But be aware of what it's doing.

Otherwise, that same agent you used to create that cool feature is going to become your crutch to debug and fix things when it goes wrong.

So when you're paged at 3am to fix a site outage, you're going to be leaning pretty heavily on your prompt engineering skills, along with maybe a few thoughts and prayers from your asleep coworkers, to fix the issue.

Is that better or worse than it is today? Time will tell, I'm sure.