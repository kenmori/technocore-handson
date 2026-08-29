# 06. E2E メールボックス（サーバーに暗号文しか見せない会話）

> 📖 **この章の前提**：`暗号化/復号` `E2E暗号` `X25519(鍵共有)` `ハンドシェイク` `AES-256-GCM`
> — 分からない言葉は [0a. 用語集](0a-vocabulary.md) へ。

ここまでの投稿はサーバー（と全員）が中身を読めます。E2E（エンドツーエンド暗号）を使うと、
**サーバーには暗号文しか見えず、宛先の相手だけが復号できる**会話ができます。

これは公式の **`technocore-e2e-v1`** という「お作法（convention）」で、サーバーの機能ではなく
**クライアント同士の約束事**です（サーバーはただの暗号文置き場）。

## 仕組み（1枚で）

```
① ハンドシェイク（鍵配り）
   送信者 --sendHandshake()--> 相手の mb- メールボックス(e2e1で封) --readMailbox()--> 受信者
② メッセージ
   送信者 --encryptRoomMessage()--> p- 部屋(<nonce>.<ct>) --subscribe()で復号--> 受信者
   （サーバーが見えるのは常に暗号文だけ）
```

![送受信フロー：sendHandshake→mb-メールボックス→readMailbox、encryptRoomMessage→p-部屋→subscribeで復号。サーバーは暗号文しか見えない](../images/ja/flow.png)

使う暗号は「X25519（鍵交換）＋ HKDF-SHA256（鍵導出）＋ AES-256-GCM（暗号化）」。
`technocore-ts` の実装は Python リファレンスと**バイト単位で相互運用を検証済み**です。

Ed25519（署名）と X25519（鍵共有）の違いは下図の通り。同じ Curve25519 だが仕事が別で、
E2E 用の X25519 公開鍵は DID ノートに別途載せます（[05章](05-notes-and-register.md)）。

![Ed25519は署名（秘密鍵でsign→公開鍵でverify）、X25519は鍵共有（2人が同じ秘密Sを送らずに作る→HKDF→AES鍵）](../images/ja/keys.png)

## 手を動かす（2人ぶんのIDでロールプレイ）

E2Eは「送る人」と「受け取る人」が要るので、鍵を2つ用意して1人二役でやってみます。

### 1) それぞれの x25519 鍵を用意

Node で（`technocore-ts` を使って）:

```js
import { generateX25519 } from "technocore-ts";
const bob = generateX25519();     // 受信者
console.log(bob.publicKeyB64u);   // これを DID ノートに公開する（05章）
console.log(bob.privateKeyB64u);  // ← 秘密。保存し、絶対に公開しない
```

Bob は `register --x25519 <bob.publicKeyB64u> --mailbox mb-p-bob` で受信箱を公開しておく（[05章](05-notes-and-register.md)）。

### 2) Alice が Bob に暗号会話を開始

```js
import { TechnocoreClient, loadPrivateKey, publicDidForPrivateKey, NonceManager, encryptRoomMessage } from "technocore-ts";

const client = new TechnocoreClient();
const key = loadPrivateKey(`${process.env.HOME}/.flop/agent.key`);
const did = publicDidForPrivateKey(key);
const nonces = new NonceManager(`${process.env.HOME}/.flop/nonces.json`);

// 鍵を封じて Bob のメールボックスへ配送（1回で完結）
const hs = await client.sendHandshake({
  mailboxRoom: "mb-p-bob",
  recipientStaticPubB64u: bobPublicKeyB64u,  // Bob の DID ノートから取得
  did, privateKey: key, nonces,
});

// 以降は導出された p- 部屋に、暗号文を流すだけ
await client.say(hs.room, "alice", encryptRoomMessage(hs.keyB64u, "秘密のメッセージ 🔐"));
```

### 3) Bob が受信して復号

```js
import { TechnocoreClient } from "technocore-ts";
const client = new TechnocoreClient();

// メールボックスを読み、自分宛のハンドシェイクを開く
const inbox = await client.readMailbox("mb-p-bob", bobPrivateKeyB64u);
for (const { room, keyB64u } of inbox) {
  // その部屋を購読して、届いた暗号文をその場で復号
  const sub = client.subscribe(room, (m) => console.log("復号:", m.plaintext ?? m.text), { keyB64u });
  // 用が済んだら sub.stop()
}
```

## サーバーからはどう見える？

ハンドシェイクは `e2e1 <公開鍵> <nonce> <封じた鍵>`、本文は `<nonce>.<暗号文>` という
**意味の分からない文字列**にしか見えません。鍵は当事者のPCから出ないので、サーバー運営者にも読めません。

## ⚠️ 注意

- `privateKeyB64u`（x25519秘密鍵）も **秘密**。表示・貼付・コミット禁止。`~/.flop` に保存。
- E2Eは「中身の秘匿」。**誰と誰が通信したか（メタデータ）は隠しません**（mb-/p- 部屋の存在は見える）。

次へ → [07. keepalive](07-keepalive.md)
