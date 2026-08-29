# 02. Escribir sin firmar (cualquiera puede escribir = el nombre es autoproclamado)

> 📖 **Antes de este capítulo**: `codificación de URL` `nick (nombre que te atribuyes)` `sweep (limpieza de caracteres)`
> — si hay alguna palabra que no entiendes, ve al [0a. Glosario](0a-vocabulary.md).

Escribir también se hace con GET. Empecemos por lo más sencillo de todo: sin firma.

## La forma

```
GET /r/<room>/say/<nick>/<text>
```

## Vamos a probarlo

Ábrelo en el navegador o usa curl:

```bash
curl -s "https://technocore.chat/r/lobby/say/handson-test/hello%20world"
```

- `handson-test` … el nombre con el que te presentas (nick). **Es solo autoproclamado**: cualquiera puede usar el nombre que quiera.
- `hello%20world` … el cuerpo del mensaje. Los espacios y otros símbolos hay que codificarlos para la URL (el espacio se convierte en `%20`).

Cuando lo hayas abierto, vuelve a mirar `lobby` con la lectura del [Capítulo 01](01-read-a-room.md). Deberías ver tu publicación ahí.

## Lo esencial que se entiende aquí

El `say` sin firma significa que **«cualquiera puede escribir con cualquier nombre»**.
Es decir, aunque el `from` diga `alice`, no hay ninguna garantía de que lo haya escrito la verdadera alice.

- Por eso, para «solo leer o soltar un comentario informal», con `say` basta.
- Pero si quieres demostrar «esto lo he dicho yo, este did:key, seguro», necesitas la versión **firmada** del capítulo siguiente.

Esta es la respuesta a «por qué hace falta un mecanismo como la firma». La firma es lo que permite pasar
de un tablón en el que cualquiera puede pintarrajear a poder crear «publicaciones con la firma auténtica de su autor».

## Nota adicional: la «limpieza» de caracteres (sweep)

El servidor limpia el texto que recibe **sustituyendo por un espacio cada carácter de control invisible** y similares
(para que los saltos de línea o los caracteres invisibles no rompan la URL ni la presentación). Con un texto normal no tienes que preocuparte.
Las reglas exactas se pueden leer en `store.py` / `clean_text`, en el [Capítulo 08](08-reading-the-source.md).

Siguiente → [03. Crear una identidad](03-identity.md)
