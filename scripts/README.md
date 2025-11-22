# 貢獻者更新腳本

`scripts/update-contributors.py` 會從 GitHub 取得貢獻者資料、更新提交次數與權重,並在需要時自動建立新頁面(提交 >= 10 次)。

## 常用指令

```bash
# 例行更新: 只刷新提交次數與權重,保留現有標籤/連結
python3 scripts/update-contributors.py --commits-only

# 完整同步: 下載頭像、抓取個人資料並重建頁面
python3 scripts/update-contributors.py

# 先看結果再決定是否執行
python3 scripts/update-contributors.py --dry-run
```

更多選項:
- `--min-commits N`  只處理提交 >= N 的貢獻者(預設 10)
- `--skip-avatars`   跳過頭像下載(已有圖時較快)
- `--skip-info`      跳過個人資料更新(只動頭像)

## 需求

- Python 3.7+
- GitHub CLI(`gh`) 並已 `gh auth login`
- `curl`、`cwebp`

## 工作方式

- 例行模式(`--commits-only`) 會
  - 更新所有已存在頁面的提交次數與權重(`weight = 10000 - commits`)
  - 若找到新達標的貢獻者會自動建立 `content/contributors/<login>/index.zh-{cn,tw}.md` 以及 200/240px WebP 頭像
- 完整模式會重新產生頁面並覆蓋標籤,特殊角色需手動調整
- 頁面內容只保留「XX 次提交」描述,不寫 email 或個人簡介

## 建議流程

1. 每週或每月執行 `--commits-only`
2. 發現 GitHub 有新達 10 次提交的成員時,跑一次完整模式並手動調整標籤
3. 若只需要更新頭像或連結,搭配 `--skip-avatars` / `--skip-info`

## 注意事項

- 特殊分類(社群創始人、網站維護者、主要維護者)需手動維護
- 亞太區 API 速率足夠,但仍建議 dry-run 先檢查輸出
- `__pycache__/` 等 Python 產物已在 `.gitignore` 中,不需要提交
