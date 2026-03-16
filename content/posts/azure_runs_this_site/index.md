---
title: "Azure (currently) runs this site"
date: 2026-02-20T17:36:02-08:00
description: "This post documents how this website is hosted in Azure as a static website, deployed via Front Door."
draft: false
toc: false
keywords:
  - Azure static website
  - Front Door configuration
  - Running a website
tags:
  - Azure
  - Cloud
  - Website
---
In the world of cloud providers, there are generally three big ones - Google Cloud Platform (GCP), Microsoft Azure, and, of course, Amazon Web Services (AWS). AWS has by far the lion's share of the market, but mainly because they were the first to said market.

Each have enabled all kinds of development from small to medium companies so that they don't have to set up a bunch of servers, letting them sit idle most of the time.

Much better than having Bob accidentally knock the power button on your production box under his desk, then lock the door and head home for the weekend.

That being said...

**This site is hosted on Azure.**

There has been a long standing program through LinkedIn where employees get a credit each month if they set up and use Azure. So that's what I've been using to host this site and my other one, [bicyclewatercooler.com](https://www.bicyclewatercooler.com).

The short of it is this:
- I write blog content in the form of markdown (.md) files.
- I compile them locally with Hugo.
  - I do this via `hugo --baseURL https://www.nilpointer.blog/` as it's easier to keep `localhost` in my `hugo.toml` during development.
- I upload the generated `public/` directory to my configured Azure blob store.
- Sometimes I need to purge the CDN / FrontDoor configuration so that the new assets I upload are reflected to the public.

**VSCode + Extensions works well for this.**

With a few plugins, I can easily upload the generated content directly to my static website storage. There are two extensions that are needed for this (at least I _think_ both are needed):
- [Azure Resources](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureresourcegroups)
- [Azure Storage](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurestorage)

The only "gotcha" here is that the plugin operation that uploads your files to your storage has to _delete everything and reupload everything_. Not a big deal for a site that can manage plenty of downtime (_"it's just a website!"_), but it gets annoying after a while. There's a way to do this via an `rsync` like operation, but I'll save that for another post.

**Overall, this all works quite well.**

Mainly because you don't have to set up any kind of web server to serve your content. You can just serve static contents via Microsoft's extensive CDN.

With small, non-dynamic content, it's quite efficient and basically costs pennies to serve each month.

If I ever have to move to a new provider, I'm sure it won't be too difficult to start up something similar in one of the other providers!