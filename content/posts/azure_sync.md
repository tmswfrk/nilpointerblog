---
title: "Azure and rsync"
date: 2026-02-23T17:05:10-08:00
draft: false
toc: false
images:
keywords:
  - Azure rsync
  - azcopy
  - SAS tokens
  - Serving website from blob storage
tags:
  - Azure
  - SAS Token
---
I'm not actually referring to _the_ `rsync` command that a lot of us know and love.

I'm referring to `azcopy sync`.

I sometimes use this to copy over files from the generated `public/` folder that `Hugo` creates for me to my Azure blob store. That's where this site is stored.

In [another post]({{< ref "/posts/azure_runs_this_site.md" >}}), I wrote about a handy VSCode plugin that I use when uploading changes to this site. Unfortunately, this one deletes everything and re-uploads everything.

A bit much, right?

Well, the alternative here is to use `azcopy sync`. It involves a few things...

**Download the azcopy binary**

The best place to do this is to locate the right binary for your OS + Architecture from the main Azure page: https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10.

**Generate a SAS key for a certain amount of time**

Do this within the Azure portal. In the `$web` container within your storage account, you can generate a SAS token using the `...` button to its right.

From there, define whatever time interval you want for this token (shorter is better, as is the case with cryptography) and optionally set it against your IP address that you want run the `sync` operation from.

Make sure to give it the right permissions, usually `read`, `write`, `delete`, and `list`, especially if you plan to use the `--delete-destination` flag.

**It's important to keep track of this key!**

Once you navigate away from this page, you won't be able to see the key again. You'll instead have to create another one - luckily, there's no limit to these apparently!

**Run the right command**

Make sure you follow this pattern:
```
azcopy sync "<local-directory-path>" "https://<storage-account-name>.blob.core.windows.net/<container-name>"
```
If you're using this at all like I am, you'll need to escape the `$` character from the `$web` container that prepends all of this. Or just use single quotes as opposed to double ones.

And you'll also need to make sure the full SAS key is added to the URL, too.

So in total, something like this.
```
azcopy sync '/Users/<$USER>/code/some-hugo-project/public/' 'https://mystorageacct.blob.core.windows.net/$web\?sp=racwdli&st=2024-11-21T06:24:19Z&se=2025-11-21T14:24:19Z&sip=123.456.789.987&spr=https&sv=2022-11-02&sr=c&sig=<someOtherGobbletyGook>'
```

Fun!

The irony in this is that I'm 100% going to just use the VSCode plugin for pushing this change. But once the site gets bigger, I'll definitely need to set up a new SAS key and run the `sync` command instead.

**You don't technically need a SAS key to do this, btw.**

I just find it easier. Using `azcopy login` will create an "Azure AD" or "Entra ID" and that can be used more directly rather than creating a whole separate SAS token. With the way my subscription is configured in Azure, I've found logging in like this to be a bit cumbersome, so I just use the SAS token instead.