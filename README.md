# lmno.lol/crisidev
Blogging infrastructure to publish [https://lmno.lol/crisidev](https://lmno.lol/crisidev).

The [CI publish](./.github/workflows/publish.yml) runs the [publish script](./scripts/publish.sh),
which builds a file called `blog.md` from all the posts inside
the [posts directory](./posts/). Posts are directory named
`YYYY-MM-DD`, ordered by date, in reverse order, so that the newest 
article is the first

After generating the file, it uploads it to the bloggin platform
(explanation [here](https://lmno.lol/crisidev/uploading-blog-programmatically)).
