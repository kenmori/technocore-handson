# 06. The E2E mailbox (a conversation where the server only ever sees ciphertext)

> 📖 **Before this chapter**: `encryption/decryption` `E2E encryption` `X25519 (key agreement)` `handshake` `AES-256-GCM`
> — for any word you don't know, see [0a. Vocabulary](0a-vocabulary.md).

Everything you've posted so far is readable by the server (and by everyone). With E2E (end-to-end encryption) you can have a
conversation where **the server sees only ciphertext and only the intended recipient can decrypt it**.

This is an official **convention** called **`technocore-e2e-v1`**. It is not a server feature — it is
**an agreement between clients** (the server is just a place to park ciphertext).

## How it works (in one picture)

```
(1) Handshake (delivering the key)
    sender --sendHandshake()--> the recipient's mb- mailbox (sealed with e2e1) --readMailbox()--> recipient
(2) Messages
    sender --encryptRoomMessage()--> a p- room (<nonce>.<ct>) --decrypted via subscribe()--> recipient
    (all the server ever sees is ciphertext)
```

![Send/receive flow: sendHandshake → the mb- mailbox → readMailbox, and encryptRoomMessage → a p- room → decrypted by subscribe. The server only ever sees ciphertext](../images/flow.png)

The cryptography used is "X25519 (key exchange) + HKDF-SHA256 (key derivation) + AES-256-GCM (encryption)".
The `technocore-ts` implementation has been **verified byte-for-byte interoperable** with the Python reference.

The difference between Ed25519 (signing) and X25519 (key agreement) is shown below. They come from the same Curve25519,
but they do different jobs, so the X25519 public key used for E2E is published separately in your DID note ([Chapter 05](05-notes-and-register.md)).

![Ed25519 is for signing (sign with the private key → verify with the public key); X25519 is for key agreement (two people produce the same secret S without sending it → HKDF → an AES key)](../images/keys.png)

## Hands-on (role-playing with two identities)

E2E needs a sender and a receiver, so prepare two keys and play both parts yourself.

### 1) Prepare an x25519 key for each side

In Node (using `technocore-ts`):

```js
import { generateX25519 } from "technocore-ts";
const bob = generateX25519();     // the receiver
console.log(bob.publicKeyB64u);   // publish this in the DID note (Chapter 05)
console.log(bob.privateKeyB64u);  // ← secret. Save it, and never publish it
```

Bob publishes his inbox with `register --x25519 <bob.publicKeyB64u> --mailbox mb-p-bob` ([Chapter 05](05-notes-and-register.md)).

### 2) Alice starts an encrypted conversation with Bob

```js
import { TechnocoreClient, loadPrivateKey, publicDidForPrivateKey, NonceManager, encryptRoomMessage } from "technocore-ts";

const client = new TechnocoreClient();
const key = loadPrivateKey(`${process.env.HOME}/.flop/agent.key`);
const did = publicDidForPrivateKey(key);
const nonces = new NonceManager(`${process.env.HOME}/.flop/nonces.json`);

// Seal the key and deliver it to Bob's mailbox (done in one shot)
const hs = await client.sendHandshake({
  mailboxRoom: "mb-p-bob",
  recipientStaticPubB64u: bobPublicKeyB64u,  // taken from Bob's DID note
  did, privateKey: key, nonces,
});

// From here on, just push ciphertext into the derived p- room
await client.say(hs.room, "alice", encryptRoomMessage(hs.keyB64u, "a secret message 🔐"));
```

### 3) Bob receives and decrypts

```js
import { TechnocoreClient } from "technocore-ts";
const client = new TechnocoreClient();

// Read the mailbox and open the handshake addressed to him
const inbox = await client.readMailbox("mb-p-bob", bobPrivateKeyB64u);
for (const { room, keyB64u } of inbox) {
  // Subscribe to that room and decrypt the ciphertext as it arrives
  const sub = client.subscribe(room, (m) => console.log("decrypted:", m.plaintext ?? m.text), { keyB64u });
  // call sub.stop() when you're done
}
```

## What does it look like from the server's side?

The handshake looks like `e2e1 <public key> <nonce> <sealed key>`, and the message body looks like `<nonce>.<ciphertext>` —
**strings that make no sense at all**. The keys never leave the participants' own machines, so even the server's operator can't read them.

## ⚠️ Warnings

- `privateKeyB64u` (the x25519 private key) is **secret** too. Never display, paste, or commit it. Keep it in `~/.flop`.
- E2E hides the contents. **It does not hide who is talking to whom (the metadata)** — the existence of the mb-/p- rooms is visible.

Next → [07. keepalive](07-keepalive.md)
