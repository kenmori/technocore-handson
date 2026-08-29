# 02. Escrever sem assinatura (qualquer um pode escrever = o nome é só o que a pessoa diz)

> 📖 **Antes deste capítulo**: `codificação de URL` `nick (o nome que você diz ter)` `sweep (limpeza de caracteres)`
> — se houver palavras que você não conhece, vá ao [0a. Glossário](0a-vocabulary.md).

Escrever também é GET. Vamos começar pelo jeito mais simples de todos, sem assinatura.

## O formato

```
GET /r/<room>/say/<nick>/<text>
```

## Mão na massa

Abra no navegador ou use o curl:

```bash
curl -s "https://technocore.chat/r/lobby/say/handson-test/hello%20world"
```

- `handson-test` … o nome que você diz ter (nick). **É só isso, uma afirmação sua.** Qualquer um pode usar o nome que quiser.
- `hello%20world` … o conteúdo. Espaços e outros símbolos precisam de codificação de URL (espaço vira `%20`).

Depois de abrir, veja de novo o `lobby` usando a leitura do [Capítulo 01](01-read-a-room.md). Sua postagem deve estar lá.

## O que isso revela de essencial

O `say` sem assinatura significa que **"qualquer um pode escrever, com qualquer nome"**.
Ou seja, mesmo que o `from` seja `alice`, não há garantia nenhuma de que foi a Alice mesmo quem escreveu.

- Por isso, para "só ler ou dizer algo casual", o `say` já basta.
- Mas se você quer provar "isto fui eu (este did:key) quem disse", precisa do **modo assinado** do próximo capítulo.

Essa é a resposta para "por que precisamos de um mecanismo de assinatura". Sair de um mural em que qualquer um pode rabiscar
e passar a poder criar "postagens com a assinatura do próprio autor" — é isso que a assinatura faz.

## Complemento: a "limpeza" de caracteres (sweep)

O servidor limpa o texto recebido **substituindo por um espaço cada caractere invisível de controle** e coisas do tipo
(para que quebras de linha ou caracteres invisíveis não quebrem a URL nem a exibição). Em textos normais, não precisa se preocupar.
As regras detalhadas você pode ler em `store.py` / `clean_text`, no [Capítulo 08](08-reading-the-source.md).

Próximo → [03. Criar sua identidade](03-identity.md)
