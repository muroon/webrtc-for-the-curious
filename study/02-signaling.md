# シグナリング

この文書は、WebRTCにおけるシグナリングの仕組みについてまとめたものです。

---

## 1. シグナリングとは

### 定義

- WebRTCエージェント同士が通信を開始するための**最初のブートストラップ**
- 2つのエージェントが接続を確立するために必要な情報を交換するプロセス
- シグナリングメッセージは単なるテキスト

### 特徴

| 項目 | 説明 |
|------|------|
| 転送方法 | WebRTCは転送方法を規定しない（WebSocket等が一般的） |
| プロトコル | SDP（Session Description Protocol）を使用 |
| タイミング | 通話開始前に行われる |

---

## 2. SDP（Session Description Protocol）

### 概要

- [RFC 8866](https://tools.ietf.org/html/rfc8866)で定義
- キー＝値形式のプロトコル（INIファイルに類似）
- Session Descriptionは0個以上のメディア記述を含む

### SDPの構文

```
キー=値
```

- 各行は1文字のキーで始まる
- 等号の後が値
- 値の後に改行

### WebRTCで使用する主要キー

| キー | 名前 | 説明 |
|------|------|------|
| `v` | Version | バージョン（常に`0`） |
| `o` | Origin | 再交渉用のユニークID |
| `s` | Session Name | セッション名（常に`-`） |
| `t` | Timing | タイミング（常に`0 0`） |
| `m` | Media Description | メディア記述 |
| `a` | Attribute | 属性（最も一般的） |
| `c` | Connection Data | 接続データ（`IN IP4 0.0.0.0`） |

---

## 3. メディア記述

### 構造

- Session Descriptionには複数のメディア記述を含められる
- 各メディア記述は通常1つのメディアストリームに対応
- フォーマット（RTPペイロードタイプ）と属性を含む

### 例

```
m=audio 4000 RTP/AVP 111
a=rtpmap:111 OPUS/48000/2
m=video 4000 RTP/AVP 96
a=rtpmap:96 VP8/90000
```

| メディア | フォーマット | コーデック |
|----------|--------------|------------|
| audio | 111 | Opus |
| video | 96 | VP8 |

---

## 4. オファー/アンサーモデル

### 仕組み

```
┌─────────────┐          ┌─────────────┐
│   Agent A   │          │   Agent B   │
│ (Offerer)   │          │ (Answerer)  │
└──────┬──────┘          └──────┬──────┘
       │                        │
       │  ─────Offer (SDP)───▶  │
       │                        │
       │  ◀────Answer (SDP)───  │
       │                        │
```

- 一方のエージェントが**オファー**を出して通話を開始
- 他方のエージェントが**アンサー**で受け入れるか拒否
- コーデックやメディア記述を拒否する機会を与える

---

## 5. トランシーバー

### 概念

- WebRTC特有の概念
- メディア記述をJavaScript APIに公開する
- トランシーバー作成ごとにローカルSession Descriptionにメディア記述が追加

### 方向属性（direction）

| 値 | 説明 |
|----|------|
| `send` | 送信のみ |
| `recv` | 受信のみ |
| `sendrecv` | 送受信 |
| `inactive` | 非アクティブ |

---

## 6. WebRTCで使用されるSDP属性

### 接続・セキュリティ関連

| 属性 | 説明 |
|------|------|
| `group:BUNDLE` | 複数トラフィックを1つの接続で処理 |
| `fingerprint:sha-256` | DTLS証明書のハッシュ値 |
| `setup:` | DTLSのクライアント/サーバー設定 |
| `ice-ufrag` | ICEエージェントのユーザーフラグメント |
| `ice-pwd` | ICEエージェントのパスワード |
| `candidate` | ICE候補アドレス |

### setup属性の値

| 値 | 動作 |
|----|------|
| `setup:active` | DTLSクライアントとして動作 |
| `setup:passive` | DTLSサーバーとして動作 |
| `setup:actpass` | 相手に選択を依頼 |

### メディア関連

| 属性 | 説明 |
|------|------|
| `mid:` | メディアストリームの識別子 |
| `rtpmap` | コーデックとRTPペイロードタイプのマッピング |
| `fmtp` | ペイロードタイプへの追加パラメータ |
| `ssrc` | 同期ソース（メディアストリームトラックの識別） |

---

## 7. Session Descriptionの完全な例

```
v=0
o=- 3546004397921447048 1596742744 IN IP4 0.0.0.0
s=-
t=0 0
a=fingerprint:sha-256 0F:74:31:25:CB:A2:13:EC:...
a=group:BUNDLE 0 1
m=audio 9 UDP/TLS/RTP/SAVPF 111
c=IN IP4 0.0.0.0
a=setup:active
a=mid:0
a=ice-ufrag:CsxzEWmoKpJyscFj
a=ice-pwd:mktpbhgREmjEwUFSIJyPINPUhgDqJlSd
a=rtpmap:111 opus/48000/2
a=ssrc:350842737 cname:yvKPspsHcYcwGFTw
a=sendrecv
m=video 9 UDP/TLS/RTP/SAVPF 96
c=IN IP4 0.0.0.0
a=setup:active
a=mid:1
a=ice-ufrag:CsxzEWmoKpJyscFj
a=ice-pwd:mktpbhgREmjEwUFSIJyPINPUhgDqJlSd
a=rtpmap:96 VP8/90000
a=ssrc:2180035812 cname:XHbOTNRFnLtesHwJ
a=sendrecv
```

### この例からわかること

- オーディオとビデオの2つのメディアセクション
- 両方とも`sendrecv`（双方向通信）
- ICE候補と認証情報により接続が可能
- 証明書フィンガープリントにより安全な通話が可能

---

## 8. まとめ

- シグナリングはWebRTC通信の最初のステップ
- SDPを使用して接続に必要な情報を交換
- オファー/アンサーモデルで双方が合意
- トランシーバーでメディアの方向を制御
- ICE、DTLS、コーデック情報などがSDP属性として含まれる
