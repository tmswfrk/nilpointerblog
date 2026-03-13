---
title: "On Regular Expressions"
date: 2026-03-13T10:48:58-07:00
description: "Turns out there more to them than simply \"they come from perl\"."
draft: false
toc: false
images:
keywords:
  - How are regular expressions evaluated
  - Evaluating regular expressions
  - Backtracking and regular expressions
tags:
  - Regex
  - Golang
---
Way back when, I was primarily a Perl developer. I actually did my first interview for LinkedIn in Perl. I always liked that the language was created by a linguist (I legitimately miss using `unless`).

Today, though, besides the occasional one-liner, I think Perl is most known for its contributions to how we all (now) use regular expressions (this post isn't going into what they are or how to use them).

However, there's a bit more detail here that I've only recently filled in.

**First, there was POSIX.**

In the traditional Unix world, both "basic" (BRE) and "extended" (ERE) POSIX-based regular expressions were / are used. 

There's a bit more here than I'd like to go into, but in basic POSIX regular expressions, you have to escape parentheses with `\(` and use character classes like `[[:space:]]`. 

The most typical case for when you'd need to use these patterns are when using the unix shell command `grep`. You can also use the extended regular expression set by adding the `-E` flag or simply using the similarly-named `egrep` CLI.

**Then, there was Perl.**

Perl introduced another way to handle regular expressions, effectively adding some syntactic sugar that we're all quite familiar with these days.
- `\s` for any whitespace character (or `\S` for a non-whitespace character)
- `\d` for a digit character (or a `\D` for a non-digit character)
- etc.

These are basically now the de facto "regular expressions" set that we use across all the major languages these days. Making this distinction I think is important, if only for historical purposes, especially since I always remember being confused why someone would use `[[:space:]]` instead of simply `\s`.

**Enter the concept of "Backtracking".**

One of the most handy aspects to regular expressions are the usage of special references such as `$1` or `$2`. These are called "backreferences" and refer to a previously matched set of characters within a defined set of parentheses. It can make things quite dynamic when looking through text.

I remember when first discovering them how much they felt like magic to me.

How we use them conveniently also helps us understand how the language's runtime actually evaluates text against a given regular expression.

**Backtracking is great. Until it's not.**

This is what I wanted to mention here - turns out there are two primary ways in which these regular expressions _are actually evaluated_.

- `PCRE` or Perl Compatible Regular Expressions
- `RE2`, originally a C++ evaluation algorithm created by Google

There is also a third option, the [rust regex crate](https://docs.rs/regex/1.1.9/regex/), which largely follows the same patterns and rules as `RE2` does, as far as I understand it.

In `PCRE`, when the respective language runtime iterates over the bytes in a string to evaluate it against a supplied regular expression, it effectively runs through it as if it were a tree. This means traversing its branches, depth first, looking for what can be matched. When a "branch" doesn't match the condition, the algorithm backtracks up a step and continues to a different branch.

However, in `RE2`, a state machine is created and each state can be evaluated, one at a time.

**What does this mean?**

Well in short, this means that `RE2` does NOT support these backreferences and is slower than `PCRE` is. _At least for smaller, simpler use cases._

This is where things get interesting.

If considering this as a "big oh" runtime algorithm, `PCRE`, while very flexible and awesome for most use cases, _can suddenly be horrifically slow_. It's usually not, but it gets slow very fast as things get complex. And it can also exhaust memory and all of your cpu threads.

`RE2`, by comparison, is consistently linear in its big oh runtime. This means it's "slower" for the simpler use cases by comparison, but is consistent and significantly faster and uses less memory.

**`RE2` is used in Golang, and it was a deliberate decision to do so.**

I love to read the [r/Golang](https://www.reddit.com/r/golang/) subreddit and someone was asking why Golang's regex pattern matching was ["so slow"](https://www.reddit.com/r/golang/comments/1rr2evh/why_is_gos_regex_so_slow/) (they provided benchmarks). I was confused as to why my favorite language would be slandered in such a way.

But it got me deep diving into the topic and I learned some things!

**What really helped me understand this better was a post-mortem write up.**

I think the Appendix portion of Cloudflare's write up / post-mortem from an incident they had in 2019 is the best way to understand more of all this. In short, they had a huge outage which was traced down ultimately to a complex regex pattern that, using `PCRE` for its evaluation, exhausted threads and memory. 

I really liked what they wrote up on the topic, and they included some gifs showing just how many backtracking iterations can occur on even simplistic looking regular expressions.

The link to the appendix section: https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/#appendix-about-regular-expression-backtracking 

It's a bit dense, but it's worth a read!