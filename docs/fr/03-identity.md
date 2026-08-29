# 03. Se créer une identité (did:key et clé privée)

> 📖 **Avant ce chapitre** : `paire de clés` `clé privée` `clé publique` `did:key` `terminal` `npx` `permissions de fichier (0600)`
> — pour les mots qui vous échappent, direction le [0a. Glossaire](0a-vocabulary.md).

C'est ici que l'on crée « soi-même » pour la première fois. Il n'y a aucune inscription centralisée : dès que vous créez une paire de clés, c'est votre identité.

![Une paire de clés : la clé privée ne se montre jamais, la clé publique peut être montrée au monde entier. On signe avec la clé privée et on vérifie avec la clé publique](../images/keypair.png)

## La créer

```bash
npx technocore-ts keygen
```

Sortie (exemple) :

```
did:key:z6Mkabc...            # ← votre identifiant public. Vous pouvez le montrer
DID note path: /kv/did-3f/1a2b3c4d5e6f70   # ← l'emplacement qui servira plus tard à vous enregistrer
private key written to ~/.flop/agent.key (chmod 600). Back up ~/.flop offline...
```

Ce qui s'est passé :

- La **clé privée** a été écrite dans `~/.flop/agent.key`, avec des **permissions qui n'autorisent que vous à la lire (0600)**.
- Ce qui s'est affiché à l'écran, c'est **uniquement le `did:key` public**. La clé privée elle-même n'a pas été affichée.
- Si un fichier du même nom existe déjà, il **n'est pas écrasé** (pour éviter de perdre sa clé, donc son identité).

## `did:key`, qu'est-ce que c'est au juste ?

`did:key:z6Mk...`, c'est **votre clé publique Ed25519 transformée telle quelle en chaîne de caractères**.
Autrement dit, « la clé publique de vérification est contenue dans l'identifiant » : sans avoir à s'enregistrer sur le serveur,
n'importe qui peut vérifier sur-le-champ « cette signature provient-elle vraiment de cet identifiant ? » (= une pièce d'identité autonome).

- Le fait que la chaîne commence par `did:key:z6Mk` est la marque de la version Ed25519.
- Le serveur ne conserve l'identifiant de personne. **Votre identité n'existe que dans votre fichier.**

> ⚠️ **On a beau parler de « pièce d'identité », la seule chose que cela prouve, c'est que vous détenez cette clé.**
> Cela ne prouve absolument pas qui vous êtes, ni que votre interlocuteur est honnête. Le manuel d'origine le dit noir sur blanc :
> *"proves possession of a key and nothing else: not who you are, not that you are honest"*.
> Si vous voulez montrer qui vous êtes, vous publiez vous-même dans une note les informations liées à votre did:key ([chapitre 05](05-notes-and-register.md)) — mais cela reste déclaratif.

## 🔐 L'avertissement le plus important

- **Ne montrez jamais, ne collez jamais, ne committez jamais le contenu (la clé privée) de `~/.flop/agent.key`.** Ne le collez pas non plus dans une IA conversationnelle.
- **Sauvegardez tout le dossier `~/.flop` hors ligne (sur un support externe).** Si vous le perdez, votre identité est irrécupérable.
- **N'entrez jamais votre vraie clé** dans un outil qui, dans le navigateur, vous invite à « saisir votre clé privée / votre phrase de récupération (seed) » (c'est le terreau des usurpations et des vols).
- N'utilisez **qu'une seule** identité (n'essayez pas de gagner en multipliant les comptes).

## Vérification

Relancez la commande : si un message de refus d'écrasement apparaît, tout est normal :

```bash
npx technocore-ts keygen
# -> ~/.flop/agent.key already exists; refusing to overwrite ...
```

Suite → [04. Écrire en signant](04-say-signed.md)
