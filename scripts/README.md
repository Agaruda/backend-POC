# Local CI Scripts

這個目錄包含了本地端 CI 檢查腳本，讓開發者可以在發送 PR 前先進行程式碼品質檢查。

## 檔案說明

### `local-ci.sh` - 主要 CI 腳本
完整的本地端 CI 檢查腳本，包含：
- 環境檢查
- 程式碼品質檢查 (Black, Flake8, Ruff, Mypy)
- 建置檢查 (Dockerfile, Docker build, App startup)
- 安全性檢查 (Semgrep, Trivy, License)

### `install-tools.sh` - 工具安裝腳本
自動安裝所有必要的開發工具：
- Python 3.11+
- uv 套件管理器
- Docker
- hadolint (Dockerfile 檢查)
- semgrep (安全掃描)
- trivy (漏洞掃描)

### `format.sh` - 快速格式化腳本
快速格式化程式碼的簡化腳本。

## 使用方式

### 1. 首次設定

```bash
# 安裝所有必要工具
./scripts/install-tools.sh

# 或手動安裝 uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"
```

### 2. 執行完整檢查

```bash
# 執行所有檢查
./scripts/local-ci.sh

# 或使用 uv 腳本
uv run check
```

### 3. 執行特定檢查

```bash
# 只執行格式化檢查
./scripts/local-ci.sh --format-only

# 只執行 linting 檢查
./scripts/local-ci.sh --lint-only

# 只執行安全性檢查
./scripts/local-ci.sh --security-only

# 只執行建置檢查
./scripts/local-ci.sh --build-only
```

### 4. 自動修復

```bash
# 自動修復格式化問題
./scripts/local-ci.sh --auto-fix

# 或使用快速格式化腳本
./scripts/format.sh
```

### 5. 查看幫助

```bash
./scripts/local-ci.sh --help
```

## 整合到開發流程

### 在 pyproject.toml 中設定腳本

```toml
[tool.uv.scripts]
check = "bash scripts/local-ci.sh"
format = "bash scripts/format.sh"
install-tools = "bash scripts/install-tools.sh"
```

### 使用 uv 執行

```bash
uv run check      # 執行完整檢查
uv run format     # 格式化程式碼
uv run install-tools  # 安裝工具
```

### Git Hooks 整合

可以設定 pre-commit hook 自動執行檢查：

```bash
# 在 .git/hooks/pre-commit 中
#!/bin/bash
./scripts/local-ci.sh --format-only
```

## 檢查項目

### 程式碼品質檢查
- **Black**: 程式碼格式化檢查
- **Flake8**: 程式碼風格和潛在問題檢查
- **Ruff**: 快速程式碼檢查
- **Mypy**: 型別安全性檢查 (非阻塞)

### 建置檢查
- **Dockerfile**: 使用 hadolint 檢查 Dockerfile
- **Docker Build**: 測試 Docker 映像建置
- **App Startup**: 測試 FastAPI 應用程式啟動

### 安全性檢查
- **Semgrep**: 靜態應用程式安全測試
- **Trivy**: 依賴套件漏洞掃描
- **License**: 授權檔案檢查

## 輸出範例

```
🔍 Running Local CI Checks...
Project: /path/to/project
Log file: /path/to/project/.local-ci.log

🔍 Environment Setup
  ├── Python 3.11.5: PASSED
  ├── uv package manager: PASSED
  ├── Docker: PASSED
  └── Dependencies installed: PASSED

🔍 Code Quality Checks
  ├── Black formatting: PASSED
  ├── Flake8 linting: PASSED
  ├── Ruff checking: PASSED
  └── Mypy type checking: PASSED

🔍 Build Checks
  ├── Dockerfile linting: PASSED
  ├── Docker build test: PASSED
  └── App startup test: PASSED

🔍 Security Checks
  ├── Semgrep security scan: PASSED
  ├── Trivy vulnerability scan: PASSED
  └── License check: PASSED

🔍 Check Summary
Total checks: 12
Passed: 12
Failed: 0
Warnings: 0

✅ All critical checks passed! 🎉
```

## 故障排除

### 常見問題

1. **uv 未找到**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   export PATH="$HOME/.cargo/bin:$PATH"
   ```

2. **Docker 未運行**
   - macOS: 啟動 Docker Desktop
   - Linux: `sudo systemctl start docker`

3. **權限問題**
   ```bash
   chmod +x scripts/*.sh
   ```

4. **工具未安裝**
   ```bash
   ./scripts/install-tools.sh
   ```

### 日誌檔案

檢查結果會記錄在 `.local-ci.log` 檔案中，可以查看詳細的執行日誌。

## 自訂設定

可以建立 `.local-ci-config.yaml` 檔案來自訂檢查設定：

```yaml
# 範例配置檔案
checks:
  quality:
    black:
      enabled: true
      auto_fix: true
    flake8:
      enabled: true
      max_line_length: 88
    ruff:
      enabled: true
    mypy:
      enabled: true
      strict: false
  
  build:
    dockerfile:
      enabled: true
    docker_build:
      enabled: true
    app_startup:
      enabled: true
      timeout: 10
  
  security:
    semgrep:
      enabled: true
      config: auto
    trivy:
      enabled: true
      severity: CRITICAL,HIGH
    license:
      enabled: true

ignore_files:
  - "*.pyc"
  - "__pycache__"
  - ".venv"
  - "node_modules"
``` 