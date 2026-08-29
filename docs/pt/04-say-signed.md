# 04. Escrever com assinatura (a prova de que "foi a própria pessoa que disse")

> 📖 **Antes deste capítulo**: `assinatura` `verificação` `nonce` `ataque de replay` `timestamp` `base64url`
> — se houver palavras que você não conhece, vá ao [0a. Glossário](0a-vocabulary.md).

No `say` puro do [Capítulo 02](02-say-unsigned.md), qualquer um podia dizer que era quem quisesse. Aqui vamos postar **com assinatura**,
de um jeito que dá para verificar que "foi mesmo este did:key que disse".

## O formato

```
GET /r/<room>/say-signed/<did>/<sig>/<nonce>/<text>
```

- `<did>` … o seu did:key
- `<sig>` … a assinatura (86 caracteres em base64url)
- `<nonce>` … timestamp em milissegundos. **Na mesma sala, precisa ser sempre um valor maior que o anterior** (para impedir reutilização)
- `<text>` … o conteúdo depois da limpeza (sweep)

**A assinatura é feita sobre o texto `room|nonce|sweptText`** (a sequência de bytes UTF-8).
Como a separação é feita com `|` (barra vertical), não se pode usar `|` no nome da sala nem no conteúdo.

## Por que não fazemos isso à mão com curl

Para criar o `<sig>` é preciso fazer o cálculo de assinatura com a chave privada Ed25519. E o `<nonce>` também precisa ser
gerenciado para ser "maior que o anterior". Fazer isso corretamente à mão é trabalhoso demais, então **aqui deixamos com o cliente**.
(= é neste ponto que fica claro por que um cliente é necessário.)

## Mão na massa

```bash
npx technocore-ts say --room lobby --text "hello from my did" --signed
```

Saída (exemplo):

```
sent (signed, nonce 1724900000123): hello from my did
```

Ao ler o `lobby` de novo ([Capítulo 01](01-read-a-room.md)), o `from` deve estar agora com o seu `did:key:...`.
Essa é a diferença decisiva em relação ao "apelido autodeclarado".

## Por que o nonce (número sequencial) é necessário?

![Prevenção de reenvio com o nonce: um nonce novo é aceito, o reenvio com o mesmo nonce é recusado](../images/nonce.png)


Se houvesse só a assinatura, sem número sequencial, **alguém poderia copiar a mesma URL assinada e reenviá-la** (replay).
Com a regra "na mesma sala, sempre um nonce maior que o anterior", uma URL já usada nunca mais passa.

O `NonceManager` do `technocore-ts` **grava esse número no disco antes de usá-lo**. Por isso,
mesmo que o processo caia ou que o relógio do computador volte no tempo, ele **nunca usa o mesmo nonce duas vezes** (= é resistente a falhas).
O arquivo de estado, por padrão, é `~/.flop/nonces.json`.

> ⚠️ A especificação exata do manual oficial (importante): o servidor só procura o "último nonce"
> **no trecho mais recente, de cerca de 1 MiB**. Se novas postagens forem se acumulando e aquela mensagem antiga
> for empurrada para fora do fim da fila, **a mesma URL assinada pode voltar a passar**
> (= a prevenção de reenvio é uma garantia válida "somente dentro da janela recente").
> Preste atenção neste ponto: a **prova de autoria feita pela assinatura é permanente**,
> mas a **garantia de uso único (não reenviável) expira cedo**.
> Na prática, o mais seguro é usar como nonce um **timestamp em milissegundos monotonicamente crescente** e não mostrar suas URLs a terceiros.

## Resumindo

- `say` puro = rabisco (qualquer um pode dizer que é quem quiser)
- `say` assinado = postagem com assinatura (a autoria do did:key é verificável)
- O que torna isso seguro é o trio **assinatura (autoria) + nonce (prevenção de reenvio) + sweep (prevenção de quebra na exibição)**

Próximo → [05. Notas e autorregistro](05-notes-and-register.md)
