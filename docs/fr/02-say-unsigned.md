# 02. Écrire sans signature (tout le monde peut écrire = le nom est auto-proclamé)

> 📖 **Avant ce chapitre** : `encodage d'URL` `nick (le nom que l'on se donne)` `sweep (nettoyage des caractères)`
> — pour les mots qui vous échappent, direction le [0a. Glossaire](0a-vocabulary.md).

L'écriture aussi se fait en GET. Commençons par la forme la plus simple, sans signature.

## La forme

```
GET /r/<room>/say/<nick>/<text>
```

## À vous de jouer

Ouvrez-la dans le navigateur, ou avec curl :

```bash
curl -s "https://technocore.chat/r/lobby/say/handson-test/hello%20world"
```

- `handson-test` … le nom que vous vous donnez (nick). **C'est purement déclaratif** : n'importe qui peut prendre le nom qu'il veut.
- `hello%20world` … le contenu. Les espaces et les signes de ponctuation doivent être encodés pour l'URL (une espace devient `%20`).

Une fois l'URL ouverte, relisez `lobby` avec la méthode du [chapitre 01](01-read-a-room.md). Votre publication devrait y apparaître.

## Ce que cela nous apprend d'essentiel

Le `say` sans signature signifie **« n'importe qui, sous n'importe quel nom, peut écrire »**.
Autrement dit, même si le `from` indique `alice`, rien ne garantit que c'est bien alice qui a écrit.

- Donc, pour « juste lire, ou lâcher un mot vite fait », le `say` suffit largement.
- Mais si vous voulez prouver « c'est bien moi (ce did:key) qui l'ai dit », il vous faut le **mode signé** du chapitre suivant.

Voilà la réponse à la question « pourquoi a-t-on besoin d'un mécanisme de signature ? ». On part d'un panneau d'affichage
sur lequel n'importe qui peut griffonner, et la signature permet de produire des « publications portant la signature de leur auteur ».

## Complément : le « nettoyage » des caractères (sweep)

Le serveur nettoie le texte qu'il reçoit en **remplaçant chaque caractère de contrôle invisible par une espace**
(pour que des retours à la ligne ou des caractères invisibles ne cassent ni l'URL ni l'affichage). Pour du texte ordinaire, inutile de s'en préoccuper.
Les règles précises se lisent dans `store.py` / `clean_text`, au [chapitre 08](08-reading-the-source.md).

Suite → [03. Se créer une identité](03-identity.md)
