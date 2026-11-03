<p align="center">
  <img src="Resources/Branding/AppIcon.png" width="160" alt="MH Desk Pets — 泡狐龍圖示">
</p>

# MH Desk Pets

[English](README.md) · [繁體中文](README.zh-TW.md) · [日本語](README.ja.md)

以 Swift 與 AppKit 打造的 macOS《魔物獵人》桌寵，陪伴你的 Claude Code 與 Codex 工作階段
每隻魔物對應一個 CLI 工作階段，隨著工作中、等待輸入或閒置狀態播放動畫

![依狀態分組的魔物：火龍、雷狼龍、泡狐龍與天彗龍工作中；轟龍與冰呪龍等待輸入；迅龍與滅盡龍閒置](docs/assets/preview.gif)

精選魔物依狀態分組，各組按 EM 編號排序，以 1.2 秒循環播放；每隻魔物都有三種狀態的動畫
可在[完整魔物名冊](docs/monsters.md)查看預覽與英文、繁體中文、日文名稱
名冊與程式內的角色清單預設依 EM 編號的數值排序

- 介面與魔物名稱支援英文、繁體中文、日文
- 可調整動畫速度與大小（64–256 px），設定自動儲存
- 魔物可自由拖曳，按兩下即可切換到對應終端，支援 tmux pane 與 cmux 分頁
- 選用的半透明宿舍支援房間自動擴縮、拖曳交換位置與整組移動把手
- 可匯入自訂 GIF 角色，也能用 PNG 影格新增魔物

## 建置與安裝

需要 Apple Silicon Mac、macOS 14+、Swift 6（Command Line Tools）與 FFmpeg

```sh
git clone --recurse-submodules https://github.com/chesterXalan/mh-desk-pets.git
cd mh-desk-pets
brew install ffmpeg
make app
```

將 `build/DeskPets.app` 複製到 `/Applications` 後開啟
`make run` 會建置並開啟應用程式；`make test` 執行應用程式測試
工作階段偵測與 hooks 由鎖定版本的 [Agent Session Bridge](https://github.com/chesterXalan/agent-session-bridge) submodule 提供，
可用 `make -C vendor/agent-session-bridge test` 執行其測試；建置時會自動初始化尚未取得的 submodule

## 使用

1. 從選單列開啟**管理… → Hooks**，安裝 hooks 後重開 CLI 工作階段
2. 啟動 Claude Code 或 Codex，魔物就會自動出現；可在**工作階段**中選擇角色
3. 拖曳魔物安排位置，按兩下切換到對應終端；語言、大小與速度可在**設定**調整
4. 可選擇啟用**宿舍**，將魔物安排進房間，拖曳上方把手即可整組移動

角色選擇與位置會自動記住
宿舍操作與終端相容性請見[使用細節（英文）](docs/usage.md)

## 新增角色

在 **角色 → 新增角色…** 選擇閒置 GIF，也可加入工作中與等待輸入的動畫
來源檔名不受限制，程式會自動複製並命名角色資料夾內的檔案
新增內建魔物的方式請見[角色素材（英文）](docs/characters.md)
PNG 影格與角色資訊納入版本控制，GIF 則在建置時產生
應用程式圖示原圖與 GitHub 預覽圖也有版控，詳見[品牌素材（英文）](docs/branding.md)

## 開發

程式註解與技術文件使用英文；介面文字維持英文、繁體中文、日文三語
新的 commit 訊息使用英文與 Gitmoji + Conventional Commits，例如 `✨ feat: Add a monster companion`
變更設定方式或行為時，請同步更新英文、繁體中文與日文 README

修改程式碼後執行 `make test` 與 `make app`；修改角色資訊後執行 `make catalog`

## 本機資料

設定、綁定與匯入角色儲存在 `~/Library/Application Support/DeskPets/`
共用 hooks 執行檔與工作階段紀錄位於 `~/Library/Application Support/AgentSessionBridge/`，獨立於應用程式本體
Agent Town 可使用相同 bridge，兩個應用程式不需要依賴彼此
安裝 hooks 會更新 `~/.claude/settings.json` 與 `~/.codex/hooks.json`，取代舊版 DeskPets 項目，
保留其他 hooks，並在修改前備份各檔案；安裝後請重開 CLI 工作階段
移除共用 hooks 會影響所有使用它的應用程式；刪除此應用程式則會保留 bridge
遷移期間仍可讀取原本 `DeskPets/sessions/` 的紀錄，應用程式不發送網路請求

## 致謝

基於 [youngOman/desk-pets](https://github.com/youngOman/desk-pets)，靈感來自同事 Evan 的 agent-pets
程式碼採用 [MIT](LICENSE) 授權，保留上游著作權聲明
《魔物獵人》角色屬於 CAPCOM，隨附圖像為 AI 生成的同人創作
