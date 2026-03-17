# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

danger-claude is a Docker image that packages the Claude CLI in a containerized Debian environment with pre-configured system dependencies (build tools, database client libs, mise version manager). It runs Claude CLI as a non-root `claude` user with `--dangerously-skip-permissions` by default.

## Build & Run

```bash
# Build the image
docker build -t danger-claude .

# Run interactively
docker run -it danger-claude

# Run with a mounted workspace and Claude config
docker run -it -v $(pwd):/work -v ~/.claude:/home/claude/.claude danger-claude
```

## Architecture

The entire project is a single `Dockerfile`:

- **Base**: Debian Bookworm slim
- **System packages**: build-essential, git, curl, tmux, database client libs (libpq-dev, libmariadb-dev), mise (polyglot version manager)
- **User**: Non-root `claude` (UID/GID 1000)
- **Entrypoint**: Bash script that handles `.claude.json` config file migration (legacy `~/.claude.json` → `~/.claude/.claude.json` with symlink) before executing the command
- **Workdir**: `/work`
