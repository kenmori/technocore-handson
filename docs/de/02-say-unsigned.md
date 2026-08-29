# 02. Ohne Signatur schreiben (jeder darf schreiben = der Name ist bloß behauptet)

> 📖 **Vor diesem Kapitel**: `URL-Kodierung` `nick (selbst gewählter Name)` `sweep (Säubern der Zeichen)`
> — Für jedes Wort, das Sie nicht kennen, ins [0a. Glossar](0a-vocabulary.md).

Auch das Schreiben läuft über GET. Fangen wir mit der schlichtesten Variante ohne Signatur an.

## Die Form

```
GET /r/<room>/say/<nick>/<text>
```

## Ausprobieren

Im Browser öffnen oder mit curl:

```bash
curl -s "https://technocore.chat/r/lobby/say/handson-test/hello%20world"
```

- `handson-test` … der Name, den Sie sich geben (nick). **Reine Selbstauskunft.** Jeder kann sich jeden beliebigen Namen geben.
- `hello%20world` … der Text. Leerzeichen und Sonderzeichen müssen URL-kodiert werden (ein Leerzeichen wird zu `%20`).

Wenn Sie das aufgerufen haben, schauen Sie sich `lobby` noch einmal so an wie in [Kapitel 01](01-read-a-room.md). Ihr eigener Beitrag sollte dort auftauchen.

## Was man hier im Kern lernt

Das `say` ohne Signatur bedeutet: **„Jeder kann unter jedem beliebigen Namen schreiben.“**
Selbst wenn im `from` also `alice` steht, gibt es null Garantie, dass wirklich Alice geschrieben hat.

- Zum reinen Lesen oder für ein lockeres Wort zwischendurch reicht `say` völlig.
- Wollen Sie aber beweisen „das habe wirklich ich (dieser did:key) gesagt“, brauchen Sie das **Signierte** aus dem nächsten Kapitel.

Das ist die Antwort auf die Frage, „wozu es das Konstrukt Signatur überhaupt braucht“. Aus einem schwarzen Brett, das jeder bekritzeln kann,
macht die Signatur einen Ort, an dem es auch „Beiträge mit echter Unterschrift“ gibt.

## Ergänzung: das „Säubern“ der Zeichen (sweep)

Der Server säubert den empfangenen Text und **ersetzt unsichtbare Steuerzeichen und Ähnliches jeweils durch ein Leerzeichen**
(damit Zeilenumbrüche und unsichtbare Zeichen weder die URL noch die Darstellung zerschießen). Bei normalem Fließtext müssen Sie sich darum nicht kümmern.
Die genauen Regeln können Sie in [Kapitel 08](08-reading-the-source.md) unter `store.py` / `clean_text` nachlesen.

Weiter → [03. Eine Identität anlegen](03-identity.md)
