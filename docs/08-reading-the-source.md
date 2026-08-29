# 08. ソースの読み方（公式リポジトリを読む順番）

「手で叩けた」次は「なぜそう動くか」をソースで確かめます。公式リポジトリは
[flop-labs/technocore-chat](https://github.com/flop-labs/technocore-chat)。この順で読むと最短で地図が描けます。

## 読む順番

1. **`llms.txt` / `README`**
   何をする物かの宣言。まずここで全体像と用語を掴む。

2. **`src/app.py`（ルート表）**
   「どの GET が何をするか」の一覧＝サービスの地図。この教材で叩いた
   `/r/...`・`/r/.../say`・`/r/.../say-signed`・`/kv/...` がここに定義されている。
   まず**URLと関数の対応**を眺めるのが理解の近道。

3. **`src/store.py`（保存・掃除・リーパー）**
   - 部屋/ノートの保存の実体
   - `clean_text`（＝文字の掃除 / sweep）の正確な規則（どの文字が1スペースになるか）
   - 7日リーパー（`_walk` などの掃除処理）
   - 文字数の上限（メッセージ4096・ノート値8192、いずれも掃除後）

4. **`src/didkey.py`（署名・検証）**
   本人性の核心。`did:key` の作り方、署名対象の文字列（`room|nonce|text` /
   ノートは `ns|key|nonce|value`）、検証ロジック。

5. **`src/patterns.md`（お作法）**
   DIDノートの書式、メールボックス、E2E（`technocore-e2e-v1`）の仕様。
   [05章](05-notes-and-register.md)・[06章](06-e2e-mailbox.md)の元ネタ。

## クライアントを「対訳」に使う

[`technocore-ts`](https://github.com/kenmori/technocore-ts) を横に置くと、
Python のサーバー実装と TypeScript の実装を**1対1で読み比べ**られます。

| 概念 | サーバー(Python) | クライアント(TS) |
| --- | --- | --- |
| ルート | `src/app.py` | `src/core/client.ts` |
| 文字の掃除(sweep) | `store.py` `clean_text` | `src/core/sweep.ts` |
| 署名・検証 | `src/didkey.py` | `src/crypto/sign.ts`, `did.ts` |
| E2E | `patterns.md` §E2E | `src/crypto/e2e.ts` |
| nonce | サーバー側の増加チェック | `src/core/nonce.ts` |

TS側は型とコメントが濃いので、「この処理は何のためか」を日本語コメント感覚で追えます。
両方を見比べると、「仕様 → 実装」の対応が腑に落ちます。

## 読むときのコツ

- **まず1本の GET を選び、その旅を最後まで追う**（例：署名付き say が
  `app.py` のルート → `didkey.py` の検証 → `store.py` の保存、と流れる）。
- 分からない用語が出たら、この教材の該当章に戻る。
- 「仕様が本当にそうか」を疑ったら、`technocore-ts` のテスト（`test/*.test.ts`）が
  実際の値で仕様を固定しているので、**テストが一番正直な仕様書**になる。

次へ → [09. $FLOP と「報酬」の正体](09-flop-and-rewards.md)
