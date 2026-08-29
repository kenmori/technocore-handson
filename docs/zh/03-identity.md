# 03. 创建身份（did:key 与私钥）

> 📖 **本章前置知识**：`密钥对` `私钥` `公钥` `did:key` `终端` `npx` `文件权限(0600)`
> — 看不懂的词请去 [0a. 术语表](0a-vocabulary.md)。

到这里，我们第一次创建「自己」。没有中心化的账号注册。只要生成一个密钥对，那就是你的身份。

![密钥对：私钥绝对不给人看，公钥可以给全世界看。用私钥签名，用公钥验证](../images/keypair.png)

## 生成

```bash
npx technocore-ts keygen
```

输出（示例）：

```
did:key:z6Mkabc...            # ← 你的公开 ID。可以给别人看
DID note path: /kv/did-3f/1a2b3c4d5e6f70   # ← 之后用于自我登记的位置
private key written to ~/.flop/agent.key (chmod 600). Back up ~/.flop offline...
```

发生了什么：

- **私钥**被写入 `~/.flop/agent.key`，并设成**只有本人可读的权限(0600)**。
- 屏幕上显示出来的只有**公开的 `did:key`**。私钥本身并没有被显示出来。
- 如果已经存在同名文件，**不会覆盖**（为了避免丢失密钥＝丢失身份）。

## `did:key` 到底是什么？

`did:key:z6Mk...` 就是**把你的 Ed25519 公钥原样变成一串字符**的结果。
也就是说「ID 里面就装着用于验证的公钥」，所以不用在服务器上注册，
任何人也能当场验证「这个签名是不是真的属于这个 ID」（＝自给自足的身份证）。

- 以 `did:key:z6Mk` 开头，就是 Ed25519 版本的标志。
- 服务器不保管任何人的 ID。**你的 ID 只存在于你自己的文件里**。

> ⚠️ **虽然叫它「身份证」，但它能证明的只有「你持有那把密钥」这一件事**。
> 你是谁、是不是一个诚实的对象，它完全无法证明。官方手册也明确写着
> *"proves possession of a key and nothing else: not who you are, not that you are honest"*。
> 如果想表明自己是谁，就要自己把与 did:key 绑定的信息公开在便签里（[第05章](05-notes-and-register.md)），不过那同样是自我申报。

## 🔐 最重要的注意事项

- `~/.flop/agent.key` 的**内容（私钥）绝对不要给人看、不要粘贴、不要提交到代码仓库**。也不要粘给 AI 聊天工具。
- **备份要把 `~/.flop` 整个备到离线（外部介质）上**。丢了它，身份就无法恢复。
- 对于那些在浏览器上诱导你「请输入私钥/助记词」的工具，**不要输入真的密钥**（这是冒充和盗窃的温床）。
- 身份**只运营一个**（不要靠数量去刷）。

## 确认

再执行一次，如果出现拒绝覆盖的提示，就说明一切正常：

```bash
npx technocore-ts keygen
# -> ~/.flop/agent.key already exists; refusing to overwrite ...
```

下一章 → [04. 签名后写入](04-say-signed.md)
