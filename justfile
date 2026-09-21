dotfiles := env_var('HOME') / "dotfiles"
scripts  := dotfiles / "scripts"

alias u := update
alias i := install

os   := `uname -s`
distro := if os == "Darwin" { "macos" } else { `grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 || echo "unknown"` }

# Add, commit, and push all changes
[private]
default: (git)

# Show detected OS/distro
check-distro:
    @echo "OS:     {{os}}"
    @echo "Distro: {{distro}}"

# Fetch git submodules (nvim config, pi config)
submodules:
    #!/usr/bin/env bash
    set -e
    cd "{{dotfiles}}"
    git submodule sync --recursive
    git submodule status | awk '/^-/ {print $2}' | while read -r path; do
      echo "==> Fetching submodule $path..."
      git submodule update --init --recursive -- "$path"
    done

# Create config directories and symlinks
symlink:
    #!/usr/bin/env bash
    MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
    echo "==> Creating config directories and symlinks..."
    if ! "$MISE" bootstrap --only files,dotfiles --yes; then
      echo ""
      echo "==> A target above is a real file or directory, not a link."
      echo "    Inspect it, then replace it with: just symlink-force"
      exit 1
    fi

# Replace conflicting real files with symlinks
symlink-force:
    #!/usr/bin/env bash
    MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
    "$MISE" bootstrap --only files --yes
    "$MISE" dot apply --force --yes

# Install packages (distro-aware)
install:
    #!/usr/bin/env bash
    if [ ! -x "$HOME/.local/bin/mise" ]; then
      echo "==> Installing mise..."
      curl https://mise.run | sh
    fi
    MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
    echo "==> Installing system packages and git repos..."
    if ! "$MISE" bootstrap --only packages,repos --yes; then
      echo "==> WARNING: some packages did not install; run 'mise bootstrap packages status'"
    fi
    if [ -x "$MISE" ]; then
      echo "==> Installing mise tools..."
      if ! "$MISE" install; then
        echo "==> WARNING: some mise tools did not install; run 'mise install' again"
      fi
    fi

# Apply macOS user defaults
macos-defaults:
    #!/usr/bin/env bash
    if [ "{{distro}}" != "macos" ]; then
      echo "==> Not macOS, skipping"
      exit 0
    fi
    MISE="$(command -v mise || echo "$HOME/.local/bin/mise")"
    "$MISE" bootstrap --only macos-defaults --yes

# Enable user services
services:
    #!/usr/bin/env bash
    case "{{distro}}" in
      macos)
        echo "==> No services to enable for macOS"
        ;;
      arch|cachyos|endeavouros|manjaro)
        echo "==> Enabling Arch services..."
        bash "{{scripts}}/cachyos/services.sh"
        ;;
      debian|ubuntu|linuxmint|pop)
        echo "==> Enabling services (generic)..."
        ;;
      *)
        echo "==> Unknown distro: {{distro}}"
        exit 1
        ;;
    esac

# Install herdr plugins listed in configs/herdr/plugins.txt
herdr-plugins:
    #!/usr/bin/env bash
    export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:$PATH"
    bash "{{dotfiles}}/configs/herdr/install-plugins.sh"

# Install nvim plugins at the versions in lazy-lock.json
nvim-plugins:
    #!/usr/bin/env bash
    export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:$PATH"
    NVIM="$(command -v nvim || "$HOME/.local/bin/mise" which nvim 2>/dev/null || true)"
    if [ -z "$NVIM" ]; then
      echo "  SKIP: nvim not installed"
      exit 0
    fi
    echo "==> Restoring nvim plugins from lazy-lock.json..."
    "$NVIM" --headless "+Lazy! restore" +qa
    echo "==> Installing treesitter parsers..."
    "$NVIM" --headless "+lua local p = require('lazy.core.config').plugins['nvim-treesitter']; local o = require('lazy.core.plugin').values(p, 'opts', false); require('nvim-treesitter').install(o.ensure_installed or {}):wait(600000)" +qa

# Run full bootstrap (submodules + symlink + install + defaults + services + plugins)
bootstrap: submodules symlink install macos-defaults services nvim-plugins herdr-plugins

# Update submodules, mise tools and system packages
update:
    #!/usr/bin/env bash
    echo "==> Updating git submodules..."
    cd "{{dotfiles}}"
    git submodule sync --recursive
    git submodule update --init --recursive --remote --merge
    echo "==> Updating mise tools..."
    mise upgrade
    echo "==> Updating git repos..."
    mise bootstrap repos update --yes
    case "{{distro}}" in
      macos)
        echo "==> Requesting sudo access (kept alive for this recipe)..."
        sudo -v
        ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
        SUDO_KEEPALIVE_PID=$!
        trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

        echo "==> Updating Homebrew..."
        brew update
        failed=()
        NONINTERACTIVE=1 brew upgrade --formula --yes || failed+=("formulae")
        for cask in $(brew outdated --cask --quiet); do
          NONINTERACTIVE=1 brew upgrade --cask --yes "$cask" || failed+=("$cask")
        done
        if [ ${#failed[@]} -gt 0 ]; then
          echo "==> Skipped (upgrade failed): ${failed[*]}"
        fi
        echo "==> Cleaning up Homebrew..."
        brew cleanup --prune=all
        ;;
      arch|cachyos|endeavouros|manjaro)
        echo "==> Updating Arch packages..."
        yay -Syu
        ;;
      debian|ubuntu|linuxmint|pop)
        echo "==> Updating apt packages..."
        if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo -E"; fi
        export DEBIAN_FRONTEND=noninteractive
        $SUDO apt-get update -qq
        $SUDO apt-get upgrade -y --with-new-pkgs \
          -o Dpkg::Options::=--force-confold \
          -o Dpkg::Options::=--force-confdef
        $SUDO apt-get autoremove -y
        ;;
      *)
        echo "==> Unknown distro: {{distro}}, skipping system packages"
        ;;
    esac
    if command -v herdr >/dev/null 2>&1; then
      echo "==> Updating herdr plugins..."
      bash "{{dotfiles}}/configs/herdr/install-plugins.sh" --update
    fi
    if command -v pi >/dev/null 2>&1; then
      echo "==> Updating pi extensions..."
      pi update --extensions
    fi

# Add, commit, and push all changes (nvim and pi submodules first)
git msg="update":
    #!/usr/bin/env bash
    set -e
    cd "{{dotfiles}}"
    for sub in nvim pi; do
      [ -d "$sub/.git" ] || [ -f "$sub/.git" ] || continue
      if [ -n "$(git -C "$sub" status --porcelain)" ]; then
        echo "==> Committing $sub..."
        git -C "$sub" add -A
        git -C "$sub" commit -m "{{msg}}"
      fi
      branch="$(git -C "$sub" symbolic-ref -q --short HEAD || true)"
      if [ -z "$branch" ]; then
        echo "==> $sub is on a detached HEAD, not pushing"
        continue
      fi
      if [ -n "$(git -C "$sub" log --oneline "origin/$branch..$branch" 2>/dev/null)" ]; then
        echo "==> Pushing $sub..."
        git -C "$sub" push origin "$branch"
      fi
    done
    git add .
    if git diff --cached --quiet; then
      echo "==> Nothing to commit in dotfiles"
    else
      git commit -m "{{msg}}"
    fi
    git push
