# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

danger-claude is a Docker image that packages the Claude CLI in a containerized Debian environment with pre-configured system dependencies (build tools, database client libs, mise version manager). It runs Claude CLI as a non-root `claude` user with `--dangerously-skip-permissions` by default.

## Build & Run

```bash
# Build the image
danger-claude --build

# Run in current directory (mounts pwd, creates docker volume for claude config)
danger-claude
```

Or directly with Docker:

```bash
docker build -t danger-claude .
docker run --rm -v "$PWD:/myproject" -v "$PWD/.git:/myproject/.git:ro" -v danger-claude:/home/claude/.claude -w /myproject -ti danger-claude
```

## Architecture

- **`bin/danger-claude`**: Ruby CLI script (Homebrew-distributable). Handles `--build` (image build) and default mode (docker run with volume mounts). Uses the current directory name as the container workdir, mounts `.git` as read-only, persists Claude config in a named Docker volume.
- **`Dockerfile`**:

- **Base**: Debian Bookworm slim
- **System packages**: build-essential, git, curl, tmux, database client libs (libpq-dev, libmariadb-dev), mise (polyglot version manager)
- **User**: Non-root `claude` (UID/GID 1000)
- **Entrypoint**: Bash script that handles `.claude.json` config file migration (legacy `~/.claude.json` → `~/.claude/.claude.json` with symlink) before executing the command
- **Workdir**: `/work`
