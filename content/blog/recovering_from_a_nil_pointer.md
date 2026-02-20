+++
date = '2026-02-19T15:04:21-08:00'
draft = false
title = 'Recovering from a Nil Pointer'
+++
```
welcomeData := make([]byte, 100)
count, err := file.Read(welcomeData)
if err != nil {
	panic(err)
}
fmt.Printf("Welcome!")
```
In most coding languages, the concept of `null` is pretty ubiqitous. It's kind of like the number `0` in number theory - it's kind of..._nothing_. It's often a far more complex topic than most realize.

So when encountering a `null`, particularly a `null pointer exception` (or as I like to call it, "the joy of working in Java"), it's usually indicative that you've done something wrong and the compiler or runtime will immediately stop everything and bail completely. 

Instead of this being an ending of a thought or process, this blog represents more of a starting point.

# `nil` vs `null`
In Golang, my preferred language of choice, `nil` is NOT `null`, and _also_ represents something more. It's not the end of the road - it's actually a really nice, although pedantic, aspect to the language that you either love or hate.

I just so happen to love it these days. I appreciate the pedantic nature of it and the mindset it forces you to think about.

# Why nilpointer.blog?
I think it's fun to think about nothing. And then write about nothing. Or something. Whatever you want `null` (or `nil`) to mean.

# A little About Me
Previously an SRE for LinkedIn, I'm now more of a Golang nut who has found himself in the bowels of "big tech", however you choose to define it. I've championed the usage of Golang at my company for years, and have worked a TON to get it adopted in a place where, let's face it, Java wins most battles. 

CI/CD actions in an existing infrastructure is where you've usually find me, lurking in the shadows, telling you about the latest good word found on [https://go.dev/blog/](https://go.dev/blog/).

I love simple design and despise unnecessary complexity. I maintain that "clever" should NOT be the descriptive word of choice for your CI/CD system (here's looking at you, Github Actions).

# What to Expect
It seems that a lot of my ideas go to `/dev/null` so I thought this would be a better usage of documenting those ideas, good, bad, and everything in between. Without any of those dumb ads. Like, zero.

I like to tinker but also write content, and I'd like to focus those efforts on short-form technical content that's clear and simple to read or understand.

So whether you like Golang's usage of `nil` or (_shutter_) prefer Python or Java's exceptions, you'll hopefully have a home here. Or at the very least, something fun to read!