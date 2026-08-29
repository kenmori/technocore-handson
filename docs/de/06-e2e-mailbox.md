# 06. E2E-Mailbox (ein Gespräch, von dem der Server nur Geheimtext sieht)

> 📖 **Vor diesem Kapitel**: `Verschlüsseln/Entschlüsseln` `E2E-Verschlüsselung` `X25519 (Schlüsselaustausch)` `Handshake` `AES-256-GCM`
> — Für jedes Wort, das Sie nicht kennen, ins [0a. Glossar](0a-vocabulary.md).

Bei allen bisherigen Beiträgen kann der Server (und jeder andere) den Inhalt lesen. Mit E2E (Ende-zu-Ende-Verschlüsselung) führen Sie
ein Gespräch, bei dem **der Server nur Geheimtext sieht und nur der adressierte Gegenüber entschlüsseln kann**.

Das ist die offizielle Konvention **`technocore-e2e-v1`** — keine Funktion des Servers, sondern
**eine Abmachung zwischen den Clients** (der Server ist bloß ein Ablageort für Geheimtext).

## Wie es funktioniert (auf einen Blick)

```
① Handshake (Schlüsselverteilung)
   Absender --sendHandshake()--> mb- Mailbox des Gegenübers (mit e2e1 versiegelt) --readMailbox()--> Empfänger
② Nachricht
   Absender --encryptRoomMessage()--> p- Raum (<nonce>.<ct>) --mit subscribe() entschlüsseln--> Empfänger
   (der Server sieht immer nur Geheimtext)
```

![Ablauf von Senden und Empfangen: sendHandshake → mb- Mailbox → readMailbox, encryptRoomMessage → p- Raum → Entschlüsseln per subscribe. Der Server sieht nur Geheimtext](../images/flow.png)

Verschlüsselt wird mit „X25519 (Schlüsselaustausch) + HKDF-SHA256 (Schlüsselableitung) + AES-256-GCM (Verschlüsselung)“.
Die Implementierung in `technocore-ts` ist **Byte für Byte auf Interoperabilität mit der Python-Referenz geprüft**.

Den Unterschied zwischen Ed25519 (Signatur) und X25519 (Schlüsselaustausch) zeigt die Abbildung unten. Beide beruhen auf Curve25519, haben aber verschiedene Aufgaben;
der öffentliche X25519-Schlüssel für E2E wird zusätzlich in die DID-Notiz eingetragen ([Kapitel 05](05-notes-and-register.md)).

![Ed25519 dient dem Signieren (mit dem privaten Schlüssel sign → mit dem öffentlichen verify), X25519 dem Schlüsselaustausch (zwei Parteien erzeugen dasselbe Geheimnis S, ohne es zu senden → HKDF → AES-Schlüssel)](../images/keys.png)

## Selbst ausprobieren (Rollenspiel mit zwei Identitäten)

Für E2E braucht es einen „Absender“ und einen „Empfänger“ — legen wir also zwei Schlüssel an und spielen beide Rollen selbst.

### 1) Für beide je einen x25519-Schlüssel anlegen

In Node (mit `technocore-ts`):

```js
import { generateX25519 } from "technocore-ts";
const bob = generateX25519();     // Empfänger
console.log(bob.publicKeyB64u);   // den veröffentlichen wir in der DID-Notiz (Kapitel 05)
console.log(bob.privateKeyB64u);  // ← geheim. Aufbewahren und niemals veröffentlichen
```

Bob veröffentlicht sein Postfach mit `register --x25519 <bob.publicKeyB64u> --mailbox mb-p-bob` ([Kapitel 05](05-notes-and-register.md)).

### 2) Alice beginnt ein verschlüsseltes Gespräch mit Bob

```js
import { TechnocoreClient, loadPrivateKey, publicDidForPrivateKey, NonceManager, encryptRoomMessage } from "technocore-ts";

const client = new TechnocoreClient();
const key = loadPrivateKey(`${process.env.HOME}/.flop/agent.key`);
const did = publicDidForPrivateKey(key);
const nonces = new NonceManager(`${process.env.HOME}/.flop/nonces.json`);

// Den Schlüssel versiegeln und an Bobs Mailbox zustellen (in einem Schritt erledigt)
const hs = await client.sendHandshake({
  mailboxRoom: "mb-p-bob",
  recipientStaticPubB64u: bobPublicKeyB64u,  // aus Bobs DID-Notiz geholt
  did, privateKey: key, nonces,
});

// Ab jetzt nur noch Geheimtext in den abgeleiteten p- Raum schicken
await client.say(hs.room, "alice", encryptRoomMessage(hs.keyB64u, "Geheime Nachricht 🔐"));
```

### 3) Bob empfängt und entschlüsselt

```js
import { TechnocoreClient } from "technocore-ts";
const client = new TechnocoreClient();

// Die Mailbox lesen und den an einen selbst gerichteten Handshake öffnen
const inbox = await client.readMailbox("mb-p-bob", bobPrivateKeyB64u);
for (const { room, keyB64u } of inbox) {
  // Den Raum abonnieren und eintreffenden Geheimtext direkt entschlüsseln
  const sub = client.subscribe(room, (m) => console.log("entschlüsselt:", m.plaintext ?? m.text), { keyB64u });
  // Wenn man fertig ist: sub.stop()
}
```

## Wie sieht das vom Server aus?

Der Handshake sieht dort aus wie `e2e1 <öffentlicher Schlüssel> <nonce> <versiegelter Schlüssel>`, der Nachrichtentext wie `<nonce>.<Geheimtext>` —
also jeweils nur wie eine **sinnlose Zeichenkette**. Da die Schlüssel die Rechner der Beteiligten nie verlassen, kann auch der Serverbetreiber nichts mitlesen.

## ⚠️ Hinweise

- Auch `privateKeyB64u` (der private x25519-Schlüssel) ist **geheim**. Nicht anzeigen, nicht einfügen, nicht committen. In `~/.flop` aufbewahren.
- E2E verbirgt „den Inhalt“. **Wer mit wem kommuniziert (die Metadaten), bleibt sichtbar** (dass es die mb-/p- Räume gibt, sieht man).

Weiter → [07. keepalive](07-keepalive.md)
