---
title: "Should dependencies always be kept up to date?"
date: 2026-05-19T17:21:43-07:00
description: "This is kind of a hot take, following up from yesterday's post."
draft: false
toc: false
images:
keywords:
  - Updating dependencies
  - Software engineering
  - Developer experience
  - dependency graph concerns
tags:
  - Dependencies
  - Software Engineering
---
Something came up at work today related to the topic [I discussed yesterday]({{< ref "/posts/could_should/index.md" >}}).

**Should dependencies always be kept up to date?**

I work in the Developer Experience (DevX) realm right now, and the current perspective on handling the potential security concerns that [Mythos](https://red.anthropic.com/2026/mythos-preview/) is highlighting is that we should immediately update all code (third party) dependencies to their respective, latest versions.

While that perspective is valid for my company right now (there's so much more to the story there), this isn't always a valid perspective to take.

**And this isn't a new concept, either.**

If you go deep underground into the most secure places like government cold storage or nuclear facilities, you'll often find _ancient_ technology. Think [8 inch floppy disks](https://en.wikipedia.org/wiki/Floppy_disk) still running core infrastructure from post-WW2 days.

Why would you let something languish like this?

Well, updating a nuclear reactor to be fully online suddenly potentially exposes its edges to the world. And getting security protocols to work effectively is _hard_. And scary when you consider the real life damage that nuclear material can cause if handled incorrectly when a bug is triggered.

The Unix / Linux ecosystem has pockets of this as well - a lot of core utils like `ls` and `cat` are generally full featured for what they were intended and don't exactly need to be updated. Because, well, it _does what it does_, and people have built other critical infra on top of this expected behavior.

I digress a bit, but my bigger point in today's society is a bit more like this:

**If you are concerned about your old dependencies leaving you exposed to zero-day bugs and exploits, you should also be equally as concerned about new ones introducing you to _new_ ones.**

Sure, it's _highly_ likely that newer versions of code are far more secure than the old ones, but the chance that the newer versions introduced (or reintroduced) past bugs is certainly _not zero_.

I've worked with a lot of engineers over the years who immediately shut down attempts to update their project dependencies. It's introducing unknowns into code that "works just fine" in most cases, at least when it comes to competent and often old-school engineers.

On one hand, I really don't like that mentality. But on the other, I kind of revere it. We are constantly asking ourselves in software questions like "but when is it _done_?" and rarely have an answer.

So make sure your dependency graph is as up to date as is reasonable. It's a good practice to have!

But also don't do it and expect yourself to be immune to future late-night bug-bashes once Mythos is released to the world.