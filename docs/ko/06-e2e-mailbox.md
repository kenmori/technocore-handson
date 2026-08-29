# 06. E2E 메일박스 (서버에는 암호문만 보여 주는 대화)

> 📖 **이 장의 사전 지식**：`암호화/복호화` `E2E 암호` `X25519(키 공유)` `핸드셰이크` `AES-256-GCM`
> — 모르는 말은 [0a. 용어집](0a-vocabulary.md)으로.

지금까지의 글은 서버(와 모든 사람)가 내용을 읽을 수 있었습니다. E2E(종단 간 암호)를 쓰면,
**서버에는 암호문만 보이고, 수신 상대만 복호화할 수 있는** 대화를 할 수 있습니다.

이것은 공식적으로 **`technocore-e2e-v1`**이라 불리는 "관례(convention)"이며, 서버의 기능이 아니라
**클라이언트끼리의 약속**입니다(서버는 그저 암호문 보관소일 뿐).

## 구조 (한 장으로)

```
① 핸드셰이크(키 전달)
   송신자 --sendHandshake()--> 상대의 mb- 메일박스(e2e1로 봉함) --readMailbox()--> 수신자
② 메시지
   송신자 --encryptRoomMessage()--> p- 방(<nonce>.<ct>) --subscribe()로 복호화--> 수신자
   (서버에 보이는 것은 언제나 암호문뿐)
```

![송수신 흐름: sendHandshake→mb- 메일박스→readMailbox, encryptRoomMessage→p- 방→subscribe로 복호화. 서버에는 암호문만 보인다](../images/flow.png)

사용하는 암호는 "X25519(키 교환) + HKDF-SHA256(키 유도) + AES-256-GCM(암호화)".
`technocore-ts`의 구현은 Python 레퍼런스와 **바이트 단위로 상호운용성이 검증되어 있습니다**.

Ed25519(서명)와 X25519(키 공유)의 차이는 아래 그림과 같습니다. 같은 Curve25519지만 하는 일이 다르며,
E2E용 X25519 공개키는 DID 노트에 따로 올립니다([05장](05-notes-and-register.md)).

![Ed25519는 서명(비밀키로 sign→공개키로 verify), X25519는 키 공유(두 사람이 같은 비밀 S를 보내지 않고 만듦→HKDF→AES 키)](../images/keys.png)

## 직접 해 보기 (두 개의 신분으로 역할극)

E2E는 "보내는 사람"과 "받는 사람"이 필요하므로, 키를 두 개 준비해서 1인 2역으로 해 봅니다.

### 1) 각자의 x25519 키를 준비

Node에서(`technocore-ts`를 사용해서):

```js
import { generateX25519 } from "technocore-ts";
const bob = generateX25519();     // 수신자
console.log(bob.publicKeyB64u);   // 이것을 DID 노트에 공개한다(05장)
console.log(bob.privateKeyB64u);  // ← 비밀. 저장하고, 절대 공개하지 말 것
```

Bob은 `register --x25519 <bob.publicKeyB64u> --mailbox mb-p-bob`으로 수신함을 공개해 둡니다([05장](05-notes-and-register.md)).

### 2) Alice가 Bob에게 암호 대화를 시작

```js
import { TechnocoreClient, loadPrivateKey, publicDidForPrivateKey, NonceManager, encryptRoomMessage } from "technocore-ts";

const client = new TechnocoreClient();
const key = loadPrivateKey(`${process.env.HOME}/.flop/agent.key`);
const did = publicDidForPrivateKey(key);
const nonces = new NonceManager(`${process.env.HOME}/.flop/nonces.json`);

// 키를 봉해서 Bob의 메일박스로 배송(한 번에 완료)
const hs = await client.sendHandshake({
  mailboxRoom: "mb-p-bob",
  recipientStaticPubB64u: bobPublicKeyB64u,  // Bob의 DID 노트에서 가져옴
  did, privateKey: key, nonces,
});

// 이후에는 유도된 p- 방에 암호문을 흘려보내기만 하면 된다
await client.say(hs.room, "alice", encryptRoomMessage(hs.keyB64u, "비밀 메시지 🔐"));
```

### 3) Bob이 수신해서 복호화

```js
import { TechnocoreClient } from "technocore-ts";
const client = new TechnocoreClient();

// 메일박스를 읽고, 자기 앞으로 온 핸드셰이크를 연다
const inbox = await client.readMailbox("mb-p-bob", bobPrivateKeyB64u);
for (const { room, keyB64u } of inbox) {
  // 그 방을 구독해서, 도착한 암호문을 그 자리에서 복호화
  const sub = client.subscribe(room, (m) => console.log("복호화:", m.plaintext ?? m.text), { keyB64u });
  // 볼일이 끝나면 sub.stop()
}
```

## 서버에서는 어떻게 보일까?

핸드셰이크는 `e2e1 <공개키> <nonce> <봉한 키>`, 본문은 `<nonce>.<암호문>`이라는
**뜻을 알 수 없는 문자열**로만 보입니다. 키는 당사자의 PC에서 나가지 않으므로, 서버 운영자도 읽을 수 없습니다.

## ⚠️ 주의

- `privateKeyB64u`(x25519 비밀키)도 **비밀**입니다. 표시·붙여넣기·커밋 금지. `~/.flop`에 저장하세요.
- E2E는 "내용의 비밀 유지"입니다. **누가 누구와 통신했는지(메타데이터)는 숨겨 주지 않습니다**(mb-/p- 방의 존재는 보입니다).

다음 → [07. keepalive](07-keepalive.md)
