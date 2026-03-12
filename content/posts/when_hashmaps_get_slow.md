---
title: "When HashMaps get \"slow\""
date: 2026-03-12T14:46:15-07:00
description: "They're not always the O(1) answer that you generally assume them to be when solving LeetCode problems online."
draft: false
toc: false
images:
keywords:
  - How do HashMaps work
  - What is big-oh runtime for hash maps
tags:
  - HashMaps
  - LeetCode
---
Many years ago, I took a Data Structures class. I wasn't even in the major that I would later graduate in, but there were a few topics that I actually remembered from back then.

At least to some extent. I remember the _content_, but the _context_ was a bit, dare I say _unknown_.

What we were discussing one day were HashMaps. We had previously discussed Linked Lists and a few other types, and I knew of the _name_ "HashMap", but what exactly were they?

In short, we were discussing:
- how to allocate an array of data somewhere in memory
- using a "hash function" to take an input parameter (a key) and "hash" it using a simplistic function (using the modulus function)
- locate that hashed location in our backing array
- either retrieving the value stored there or inserting one to it

The question inevitably came up - _what if that location already has something in it?_

Well, we'll just move on to the next slot that's free. Simple enough, right?

It all makes far more sense now, but I remember we finally came across the idea of using a Linked List to "chain" values in the slot instead of placing a singular value in the hashed location. 

The idea was to help combat problems that arise when the hash table gets full enough. Suddenly looking for an empty spot is hardly any better than just starting at the first spot of the array and iterating over it one spot at a time.

**So does this mean HashMaps aren't O(1)?**

I find that a lot of LeetCode problems generally just assume that all hashmaps are simply `O(1)` access / insert time.

How does that compare with any of the above, then? Shouldn't it be `O(n)` big-Oh time for both reads and writes? Even reads have to search for the same hashed location, which may not immediately have the item you're looking for.

Turns out this is a very well-known issue, and was actually a legitimate problem for languages like PHP and Java up until 2011 or so.

**When hash maps get slow.**

If an overly simplistic hashing function, like the one we did in in my Data Structures class, were used, we'd likely find ourselves colliding with other values rather quickly. And performing a secondary hash then can become a heavier operation on the CPU just to locate some data location.

What if you were unfortunate to the point where all items were hashed to the same spot in your hash map, requiring a linked list to store all of your values? Finding an item there would certainly be slow, as it would have to both hash the key, then go look linearly through the linked list.

Similarly, what if someone were actively trying to crash your system? Say they sent a bunch of similar requests to a `POST` endpoint, which caused a lot of collisions to happen, or possibly filled up your hash quickly, requiring the backing array to be resized over and over? This is a slow operation usually that requires _all the data in the hashmap_ to be copied to the newly resized array.

Java, as it turns out, implemented a [red-black tree](https://en.wikipedia.org/wiki/Red–black_tree) data structure instead of using the linked list implementation to handle these cases. It also created a far more random hashing function than before, using [SIPHash](https://en.wikipedia.org/wiki/SipHash), implemented first in 2012. This, combined with the red-black tree instead of a linked list, made the max time when "chaining" occurs go from `O(n)` to `O(log n)`.

**This is significant for larger sized maps.**

As seems to always be the case when it comes to computer science concepts, everything has trade-offs. A little bit of extra overhead will technically slow down small maps, but will significantly reduce the problems you can run into later. This is particularly the case when:
- the map fills beyond a 0.75 "occupied" ratio and data needs to be expanded
- keys get significantly larger
- the whole map gets large enough so it has to be allocated to the heap

Golang recently implemented Swiss Tables in `v1.24+` ([see the blog post](https://go.dev/blog/swisstable)) which is an additional extension to all of this, which is how I came across writing this post about it all. In it, they discuss breaking down a hash map into smaller tables, each of which contain bits that trade some bit space for information that avoids unnecessary chaining and similar look up operations. 

It's a fascinating read if you're curious, especially since it has reduced map operation times for larger maps by [as much as 60%](https://github.com/golang/go/issues/54766#issuecomment-2542444404)!

There's far more to consider there, but suffice it to say, a little bit of extra "record keeping" can significantly improve performance when things get large or get complicated.