# [2024-05-18] 🌎 Uploading blog programmatically

I am a lazy person spending most of their time in a terminal 💻...

This is one of the reasons why [lmno.lol](https://lmno.lol) really suites me.. I update my 
markdown locally, drag it on the edit page, click save, boom, done 👈!

Since I don't want to move out of my terminal, I hacked a little script
using [curl](https://curl.se/) to upload my blog programmatically.

[lmno.lol](https://lmno.lol) is protected by a cookie based authentication
system. The first thing to do is to login with the username and password.
Luckily the login screen is a form I can submit with curl with roughly this
command:

[![login curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/login-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/login-curl.png)

After storing the cookie session key, we can now move to the next step, which
is uploading a new version of [lmno.lol/crisidev](https://lmno.lol/crisidev)! 

## Today I learned something wild!
I was inspecting the Firefox console during the blog upload phase, after clicking `save` on
`https://lmno.lol/crisidev/edit` and I found the API POST call to `https://lmno.lol/api`
that is responsible to update my blog.

I click on the request and 🔥

[![copy as curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/copy-as-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/copy-as-curl.png)

I am crying of joy.

## Update my blog

Mozilla produces a working `curl` command that I had to tweak a little to basically this:

[![api curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/api-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/api-curl.png)

Easy! 
## The result

[![script result](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script-result.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script-result.png)

## Auto publish anyone? 🤩

The blog is a self-contained [Github repo](https://github.com/crisidev/blog) and is published
to [lmno.lol/crisidev](https://lmno.lol/crisidev) using a 
[Github action](https://github.com/crisidev/blog/blob/main/.github/workflows/publish.yml)
based on the learnings above so that every time I update it the repository and push on `main`, 
the CI kicks in and a new version is published automatically 🚀

## The code
Here is the full script, which is shared also as a [gist](https://gist.github.com/crisidev/658906ccd133ddb0083258771ffe17e9).

[![lmno blog upload script](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script.png)](https://gist.github.com/crisidev/658906ccd133ddb0083258771ffe17e9)

