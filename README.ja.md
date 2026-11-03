<p align="center">
  <img src="Resources/Branding/AppIcon.png" width="160" alt="MH Desk Pets — タマミツネのアイコン">
</p>

# MH Desk Pets

[English](README.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md)

Swift と AppKit で作られた、macOS 上の Claude Code・Codex セッションに寄り添う『モンスターハンター』のデスクトップペットです。
各モンスターが 1 つの CLI セッションに対応し、作業中・入力待ち・待機中の状態に合わせて動きます。

![状態別のモンスター：作業中のリオレウス・ジンオウガ・タマミツネ・バルファルク、入力待ちのティガレックス・イヴェルカーナ、待機中のナルガクルガ・ネルギガンテ](docs/assets/preview.gif)

一部のモンスターを状態別にまとめ、各グループ内で EM ID 順に並べた 1.2 秒ループのプレビューです。
すべてのモンスターに 3 種類のアニメーションがあります。
[モンスター一覧](docs/monsters.md)で、プレビューと英語・繁体字中国語・日本語の名前を確認できます。
一覧とアプリ内のキャラクターリストは、初期設定では EM ID の数値順に並びます。

- UI とモンスター名は英語・繁体字中国語・日本語に対応
- アニメーションの速度とサイズ（64–256 px）を調整でき、設定は自動保存
- 自由にドラッグして配置し、ダブルクリックで対応するターミナルに切り替え。tmux ペインと cmux タブにも対応
- 任意で使える半透明のすみか。部屋の自動拡張・縮小、ドラッグでの入れ替え、ハンドルによる全体移動に対応
- カスタム GIF キャラクターの読み込みや、PNG フレームによるモンスター追加が可能

## ビルドとインストール

Apple Silicon Mac、macOS 14 以降、Swift 6（Command Line Tools）、FFmpeg が必要です。

```sh
git clone --recurse-submodules https://github.com/chesterXalan/mh-desk-pets.git
cd mh-desk-pets
brew install ffmpeg
make app
```

`build/DeskPets.app` を `/Applications` にコピーして開いてください。
`make run` はビルド後にアプリを開き、`make test` はアプリのテストを実行します。
セッション検出とフックには、バージョンを固定した [Agent Session Bridge](https://github.com/chesterXalan/agent-session-bridge) submodule を使います。
そのテストは `make -C vendor/agent-session-bridge test` で実行できます。未取得の submodule はビルド時に自動で初期化されます。

## 使い方

1. メニューバーから**管理… → Hooks**を開き、フックを設定して CLI セッションを再起動します。
2. Claude Code または Codex を起動するとモンスターが自動で現れます。**セッション**でキャラクターを選べます。
3. ドラッグで配置し、ダブルクリックで対応するターミナルへ切り替えます。言語・サイズ・速度は**設定**で変更できます。
4. 必要に応じて**すみか**を有効にして部屋に配置できます。上部のハンドルをドラッグすると、全体をまとめて移動できます。

キャラクターの選択と位置は自動的に記憶されます。
すみかの操作やターミナルとの互換性は、[詳しい使い方（英語）](docs/usage.md)を参照してください。

## キャラクターの追加

**キャラクター → キャラクターを追加…** で待機中の GIF を選び、必要に応じて作業中・入力待ちのアニメーションも追加できます。
元のファイル名に制限はありません。アプリがキャラクターのフォルダーにコピーし、自動で名前を付けます。
組み込みモンスターの追加方法は[キャラクター素材（英語）](docs/characters.md)を参照してください。
PNG フレームとキャラクター情報をバージョン管理し、GIF はビルド時に生成します。
アプリアイコンの元画像と GitHub のプレビュー画像も管理対象です。[ブランド素材（英語）](docs/branding.md)に詳細があります。

## 開発

コードコメントと技術文書は英語で記述し、UI テキストは英語・繁体字中国語・日本語に対応させてください。
新しい commit メッセージは英語の Gitmoji + Conventional Commits 形式にします。例：`✨ feat: Add a monster companion`。
設定手順や動作を変更するときは、英語・繁体字中国語・日本語の README を同時に更新してください。

コードを変更したら `make test` と `make app` を実行し、キャラクター情報を変更した場合は `make catalog` も実行してください。

## ローカルデータ

設定、セッションとの割り当て、読み込んだキャラクターは `~/Library/Application Support/DeskPets/` に保存されます。
共有フックの実行ファイルとセッション記録は `~/Library/Application Support/AgentSessionBridge/` にあり、アプリ本体から独立しています。
Agent Town も同じ bridge を利用でき、どちらのアプリも他方を必要としません。
フック設定は `~/.claude/settings.json` と `~/.codex/hooks.json` を更新し、旧 DeskPets の項目を置き換えます。
他のフックは保持し、各ファイルを変更前にバックアップします。設定後は CLI セッションを再起動してください。
共有フックの削除はすべての利用アプリに影響しますが、このアプリを削除しても bridge は残ります。
移行中は既存の `DeskPets/sessions/` の記録も読み取れます。アプリはネットワーク通信を行いません。

## クレジット

[youngOman/desk-pets](https://github.com/youngOman/desk-pets) を基に、同僚 Evan の agent-pets に着想を得ています。
コードは上流の著作権表示を保持した [MIT](LICENSE) ライセンスです。
『モンスターハンター』のキャラクターは CAPCOM に帰属します。同梱画像は AI 生成のファンアートです。
