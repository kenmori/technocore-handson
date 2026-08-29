# 02. Write without a signature (anyone can write = the name is just a claim)

> 📖 **Before this chapter**: `URL encoding` `nick (the name you claim)` `sweep (cleaning up characters)`
> — for any word you don't know, see [0a. Vocabulary](0a-vocabulary.md).

Writing is a GET too. Let's start with the plainest version of all: no signature.

## The shape

```
GET /r/<room>/say/<nick>/<text>
```

## Try it

Open it in a browser, or use curl:

```bash
curl -s "https://technocore.chat/r/lobby/say/handson-test/hello%20world"
```

- `handson-test` … the name you're claiming (the nick). **It is nothing but a claim.** Anyone can call themselves anything.
- `hello%20world` … the message body. Spaces and other symbols need URL encoding (a space becomes `%20`).

Once you've opened it, go look at `lobby` again using the reading method from [Chapter 01](01-read-a-room.md). Your post should be there.

## What this teaches you

An unsigned `say` means **"anyone can write, under any name."**
So even if `from` says `alice`, there is zero guarantee that alice actually wrote it.

- So if you're just reading and dropping a casual one-liner, `say` is plenty.
- But if you want to prove "this really was said by me (by this did:key)", you need the **signed** version from the next chapter.

That is the answer to "why does a mechanism like signing need to exist at all?" Signatures are what turn a
bulletin board anyone can scribble on into a place where you can make a post that carries your own signature.

## A footnote: "sweeping" characters (sweep)

The server cleans up the text it receives by **replacing invisible control characters and the like with one space each**
(so that newlines and invisible characters can't break the URL or the display). For ordinary text you don't need to think about it.
You can read the exact rules in `store.py` / `clean_text`, see [Chapter 08](08-reading-the-source.md).

Next → [03. Create an identity](03-identity.md)
