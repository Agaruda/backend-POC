# Local CI Scripts

This directory contains local CI check scripts that allow developers to perform code quality checks before submitting PRs.

## File Descriptions

### `local-ci.sh` - Main CI Script
Complete local CI check script that includes:
- Environment setup
- Code quality checks (Black, Flake8, Ruff, Mypy)
- Build checks (Dockerfile, Docker build, App startup)
- Security checks (Semgrep, Trivy, License)

### `install-tools.sh` - Tool Installation Script
Automatically installs all necessary development tools:
- Python 3.11+
- uv package manager
- Docker
- hadolint (Dockerfile linting)
- semgrep (security scanning)
- trivy (vulnerability scanning)

### `format.sh` - Quick Formatting Script
Simplified script for quick code formatting.

## Usage

### 1. Initial Setup

```bash
# Install all necessary tools
./scripts/install-tools.sh

# Or install uv manually
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"
```

### 2. Run Complete Checks

```bash
# Run all checks
./scripts/local-ci.sh

# Or use uv script
uv run check
```

### 3. Run Specific Checks

```bash
# Run formatting checks only
./scripts/local-ci.sh --format-only

# Run linting checks only
./scripts/local-ci.sh --lint-only

# Run security checks only
./scripts/local-ci.sh --security-only

# Run build checks only
./scripts/local-ci.sh --build-only
```

### 4. Auto-fix Issues

```bash
# Auto-fix formatting issues
./scripts/local-ci.sh --auto-fix

# Or use quick formatting script
./scripts/format.sh
```

### 5. View Help

```bash
./scripts/local-ci.sh --help
```

## Integration with Development Workflow

### Setting up scripts in pyproject.toml

```toml
[tool.uv.scripts]
check = "bash scripts/local-ci.sh"
format = "bash scripts/format.sh"
install-tools = "bash scripts/install-tools.sh"
```

### Using uv to run scripts

```bash
uv run check      # Run complete checks
uv run format     # Format code
uv run install-tools  # Install tools
```

### Git Hooks Integration

You can set up pre-commit hooks to automatically run checks:

```bash
# In .git/hooks/pre-commit
#!/bin/bash
./scripts/local-ci.sh --format-only
```

## Check Items

### Code Quality Checks
- **Black**: Code formatting check
- **Flake8**: Code style and potential issues check
- **Ruff**: Fast code checking
- **Mypy**: Type safety checking (non-blocking)

### Build Checks
- **Dockerfile**: Use hadolint to check Dockerfile
- **Docker Build**: Test Docker image build
- **App Startup**: Test FastAPI application startup

### Security Checks
- **Semgrep**: Static application security testing
- **Trivy**: Dependency vulnerability scanning
- **License**: License file check

## Output Example

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

## Troubleshooting

### Common Issues

1. **uv not found**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   export PATH="$HOME/.cargo/bin:$PATH"
   ```

2. **Docker not running**
   - macOS: Start Docker Desktop
   - Linux: `sudo systemctl start docker`

3. **Permission issues**
   ```bash
   chmod +x scripts/*.sh
   ```

4. **Tools not installed**
   ```bash
   ./scripts/install-tools.sh
   ```

### Log Files

Check results are logged in the `.local-ci.log` file, where you can view detailed execution logs.

## Custom Configuration

You can create a `.local-ci-config.yaml` file to customize check settings:

```yaml
# Example configuration file
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