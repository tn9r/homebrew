# tn9r/homebrew

Personal Homebrew Tap for macOS applications across personal and organization workspaces.

## Included Casks

| App | Description | Source Repository |
| :--- | :--- | :--- |
| **medify** | Personal media center & podcast library | `tn9r/medify` |
| **tacit** | A quiet layer underneath your typing on macOS (with CLI) | `freetis/Tacit` |
| **kinetic** | Pure Swift motion graphics studio for macOS (with CLI) | `narrino/kinetic` |

## Installation & Setup

### 1. Tap this repository
```bash
brew tap tn9r/homebrew
```

### 2. Authentication (for Private Releases)
Because the release packages live in private GitHub repositories, `brew` needs GitHub authentication to download them.
If you already use GitHub CLI, it works automatically:
```bash
gh auth login
```
Alternatively, set the environment variable in `~/.zshrc`:
```bash
export HOMEBREW_GITHUB_API_TOKEN="your_personal_access_token_with_repo_scope"
```

### 3. Install Applications
```bash
# Install Medify
brew install --cask medify

# Install Tacit (installs Tacit.app and links 'tacit' CLI to /opt/homebrew/bin)
brew install --cask tacit

# Install Kinetic (installs Kinetic.app and links 'kinetic' CLI to /opt/homebrew/bin)
brew install --cask kinetic
```

### 4. Upgrade
```bash
brew upgrade --cask medify tacit kinetic
```
