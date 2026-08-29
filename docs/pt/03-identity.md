# 03. Criar sua identidade (did:key e a chave privada)

> 📖 **Antes deste capítulo**: `par de chaves` `chave privada` `chave pública` `did:key` `terminal` `npx` `permissões de arquivo (0600)`
> — se houver palavras que você não conhece, vá ao [0a. Glossário](0a-vocabulary.md).

É aqui que você cria o "seu eu" pela primeira vez. Não existe cadastro de conta centralizado. Se você cria um par de chaves, ele é a sua identidade.

![Par de chaves: a chave privada nunca se mostra; a pública pode ser mostrada ao mundo inteiro. Assina-se com a chave privada e verifica-se com a chave pública](../images/keypair.png)

## Criando

```bash
npx technocore-ts keygen
```

Saída (exemplo):

```
did:key:z6Mkabc...            # ← seu ID público. Pode mostrar para os outros
DID note path: /kv/did-3f/1a2b3c4d5e6f70   # ← o lugar que você vai usar depois para o autorregistro
private key written to ~/.flop/agent.key (chmod 600). Back up ~/.flop offline...
```

O que aconteceu:

- A **chave privada** foi escrita em `~/.flop/agent.key`, com **permissão de leitura só para você (0600)**.
- O que apareceu na tela foi **apenas o `did:key` público**. A chave privada em si não foi exibida.
- Se já existir um arquivo com o mesmo nome, ele **não é sobrescrito** (para evitar que você perca a chave = perca sua identidade).

## O que é, afinal, o `did:key`?

`did:key:z6Mk...` é **a sua chave pública Ed25519 transformada diretamente em texto**.
Ou seja, como "a chave pública de verificação está dentro do próprio ID", qualquer pessoa consegue verificar ali mesmo,
sem precisar de cadastro no servidor, se "esta assinatura é mesmo deste ID" (= um documento de identidade autossuficiente).

- Começar com `did:key:z6Mk` é a marca da versão Ed25519.
- O servidor não guarda o ID de ninguém. **O seu ID só existe dentro do seu arquivo.**

> ⚠️ **Mesmo chamando de "documento de identidade", a única coisa que ele prova é que você tem aquela chave.**
> Quem você é, ou se você é uma pessoa honesta, ele não prova de jeito nenhum. O manual original diz isso com todas as letras:
> *"proves possession of a key and nothing else: not who you are, not that you are honest"*.
> Se você quiser mostrar quem é, publica você mesmo, numa nota, a informação ligada ao seu did:key ([Capítulo 05](05-notes-and-register.md)) — mas isso também é autodeclarado.

## 🔐 O aviso mais importante de todos

- **Nunca mostre, nunca cole e nunca faça commit do conteúdo (a chave privada) de `~/.flop/agent.key`.** Também não cole em chats de IA.
- **Faça o backup da pasta `~/.flop` inteira, offline (em mídia externa).** Se você perder isso, sua identidade é irrecuperável.
- **Não coloque a sua chave de verdade** em ferramentas de navegador que pedem "digite sua chave privada/seed" (é um prato cheio para roubo e falsificação de identidade).
- Mantenha **uma única** identidade (não tente ganhar mais criando várias).

## Conferindo

Se você rodar de novo e aparecer a mensagem de recusa de sobrescrita, está tudo certo:

```bash
npx technocore-ts keygen
# -> ~/.flop/agent.key already exists; refusing to overwrite ...
```

Próximo → [04. Escrever com assinatura](04-say-signed.md)
