---
title: "Social Acceptance of Large Scale Changes"
date: 2026-09-04T14:46:37-07:00
description: "Trust and social acceptance are far more important to the software development process than you think. Especially so when it comes to building your core platform and infrastructure."
draft: false
toc: false
images:
keywords:
  - Software Engineering at Google book
  - Trusting your infrastructure
  - Engineering trust
tags:
  - Software Engineering
  - Management
  - Communication
---
I started reading through a book posted online called [Software Engineering at Google](https://abseil.io/resources/swe-book), written in March of 2020 (truly a fateful time in all of our lives).

It's an O'Reilly book, too, which you can purchase here if you're interested ([affiliate link](https://www.amazon.com/gp/product/1492082791?tag=bicyclewate08-20)).

In particular, I've started with chapter 22, which discusses "Large Scale Changes" or LSC's for short. The intention behind it is to discuss how Google's monorepo works when it comes to making changes that span across multiple projects.

This is definitely a difficult problem, and one that Google addresses very differently than other companies, mostly due to their sheer size and volume of code as well as their heavy investment in managing it.

**"Social Acceptance" of LSC's**

This is the part that stuck out to me most, and I'd like to quote the entirety of what stuck out (emphasis is mine):

> Related to these policies was a shift in cultural norms surrounding LSCs.  Although it is important for code owners to have a sense of responsibility for their software, they also needed to learn that LSCs were an important part of Google’s effort to scale our software engineering practices. Just as product teams are the most familiar with their own software, library infrastructure teams know the nuances of the infrastructure, and **getting product teams to trust that domain expertise is an important step toward social acceptance of LSCs**. As a result of this culture shift, local product teams have grown to trust LSC authors to make changes relevant to those authors’ domains.
>
> Occasionally, local owners question the purpose of a specific commit being made as part of a broader LSC, and change authors respond to these comments just as they would other review comments. **Socially, it’s important that code owners understand the changes happening to their software, but they also have come to realize that they don’t hold a veto over the broader LSC**. Over time, we’ve found that a good FAQ and a solid historic track record of improvements have generated widespread endorsement of LSCs throughout Google.

I got to reflecting on my time at LinkedIn, and when I really thought about it, this was a far bigger issue than I realized at the time.

A lot of what I was most recently doing at LinkedIn was in this very domain - large scale changes across a _bunch_ of repositories. LinkedIn unfortunately has something like 20,000 internal repositories as of 2026.

Without going into too much detail, I was responsible for navigating the company away from an old way of building Golang applications into a new one, one that I was constructing and building. Most of that work was attaining parity with the existing system, but it was still a vastly new system by comparison.

Further, I was a founding member of a new team making these changes, a team labeled as a _systems infrastructure_ team. And initially, there was a lot of excitement around its mission.

**Entropy**

Unfortunately, over time, the cracks in the pavement began to show and certain silos began to form within the team. The shared vision began to get fragmented and the company started to change underneath our charter.

A unified idea to focus language support to better align with open source standards suddenly shifted backwards towards what had traditionally been used.

Combined with company attrition, the quality of work began to suffer and to put it simply, it was clear that our users and product partners _simply did not trust us or our work_.

**PR skepticism**

I found myself having to explain the proposed changes over and over to our partners, while also having to convince them that what I was doing was going to make their lives better.

Over time, I gained some ground and had some footing to stand on, but the overall trend persisted - our product partners really just wanted to deliver what they were being asked by their management and didn't really care about what we were doing. They also didn't want to spend any additional cycles reviewing my submitted code or work on implementing the new standards.

And management was too busy doing too many things elsewhere, reductively pretending that AI could simply do all of this for us while also complaining about how our non standard code prevented us from using AI properly.

**...but I digress**

While I was still able to deliver most of what I set out to do, the unified vision of what the team was founded on was generally abandoned.

I would have much rather seen management focus on developing this trust sooner and earlier. Do the road shows, showcase the before and after of the old and new systems, praise the team outside of the team, show that the priorities are there and driven by our developer community, show incremental progress, listen to your engineers, the list goes on.

**It's all about the trust**

In reflecting on the above, the original points of this book's chapter really reasonated with me. Without this trust, you really can't get done what you need to get done as an infrastructure team.

If your customers or product partners don't know what you're up to, or if your code is actually going to make their lives better, you're going to be the tail wagging the dog, effectively doing things backwards.

You'll be so focused on constantly proving your work is vital that you'll have less time to actually do the work.

And when the time comes, you won't have the good will built up to do the really heavy hitting stuff. You'll stay contained as a supporting organization who only makes changes when their product partner teams have the time, the bandwidth, and the right OKRs.

That's it for now. Much more to be said on this topic though!