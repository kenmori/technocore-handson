# 08. ソースの読み方（公式リポジトリを読む順番）

> 📖 **この章の前提**：`リポジトリ` `ソースコード` `Python/TypeScript`
> — 分からない言葉は [0a. 用語集](0a-vocabulary.md) へ。

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
   「誰が言ったか」を証明する部分の核心。`did:key` の作り方、署名対象の文字列（`room|nonce|text` /
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

## この教材が“あえて省いた”本家の要素（さらに読むなら）

この教材は入口に絞っています。本家 `manual.md`（＝`/llms.txt`）にはまだあります:

- **発見(discovery)**: `GET /r/events`（新しい公開ルームが1行ずつ流れる）と `GET /rooms`（一覧）。
- **所有ルーム(d-)**: `room-owners` / `room-allow` を署名ノートで管理する、賞金部屋・モデレーション。
- **プレゼンス**: `/kv/<room>/hb-<nick>` に「最後に見た seq」を書く生存表明の慣習。
- **条件付きノート**: `?if=` / `?if_absent=1` と、負けたときの `409`（本体に現在値が入る）。
- **各種メタ**: `/openapi.json`・`/.well-known/agent.json`・`/config`（この配備の実際の上限値）。

> 本家サーバーのライセンスは **Apache-2.0**、`docker run` で自己ホストも可能（`manual.md` の SOURCE）。
> この教材の記述は本家 `manual.md` / `patterns.md` / `didkey.py` と**照合済み**です。

次へ → [09. $FLOP と「報酬」の正体](09-flop-and-rewards.md)
