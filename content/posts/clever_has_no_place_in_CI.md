---
title: "\"Clever\" Has No Place in CI"
date: 2026-02-19T20:18:15-08:00
draft: false
toc: false
images:
  - ""
tags:
  - CI
  - Github Actions
---
I wanted to share this separately on my site because, well, it made quite the impression over on [LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7406476989181628416), where I initially posted it.

> Hot take: the code used in infrastructure engineering shouldn't be complicated, nor should it be clever. It actually should be rather dumb.
>
> If something goes wrong, you want it to be with the code you're trying to build or ship, not an unexpected effect of an overly complex CI system.
>
> Delegate to native tooling everywhere you can. Don't be clever. Be clever elsewhere and save yourself the maintenance effort.

I got a bunch of comments on the topic, so I guess labeling it a "hot take" was apropos.

**Why is this Controversial?**

In my experience, CI is quite an abstract topic, even for software engineers. But without proper guardrails, good intentions can go awry and get out of control _quickly_. Especially when you have distributed actions across multiple Github Actions configuration files and/or CLIs.

Some good takeaways that I liked:

> "Most things can be solved in a simple way."

[Occam's Razor](https://en.wikipedia.org/wiki/Occam's_razor) approves this message, as do I.

> Kernighan's Law "Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it."

Absolutely love [Kernighan's Law](https://www.laws-of-software.com/laws/kernighan/). Debugging in inherently _hard_. Doing it in a highly customized and "environment-assuming" environment that _intentionally_ isn't set up like your dev box is even _harder_.

> What I keep seeing with teams is that every time infra code gets “smart”, it’s usually compensating for missing decisions upstream. Then six months later no one knows why the pipeline behaves the way it does.

Couple this with "the road to hell is paved with good intentions" and you have a recipe for all the custom infrastructure that keeps DevX engineers in business.

**Doing the Digital Janitor Work**

I recently had to sort out some GHA actions (is that redundant?) to fix some compatibility tests across some Go modules. It was initially configured in one way that never quite worked - until another engineer implemented a command-line `find | xargs` command to locate N other `go.mod` files.

Super abstract. But it DID work. One-liners are fun!

Diving into the issue, I found that in a previous setup step, we were zipping up some source files in a way that included their full, absolute paths. This meant that when extracting them in the other job, we suddenly had a bunch of duplicative paths that looked _an awful lot_ like the previous path it was all starting from. Gross.

No one had bad intentions here, mind you, and I could have just continued dealing with it on my end. But I decided to fix the issue upstream, sorting out the zip action to better handle a shared Github runner.

I didn't need to, but leaving it in that state and then continuing to do my job would have made it far more difficult to reason about later.

**These kinds of things happen in software engineering.**

They just do. And I imagine that AI may make this worse.

But can we all agree that simpler, "dumb" CI is better when it comes to building and deploying code?