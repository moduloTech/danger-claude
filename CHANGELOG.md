# Changelog

## [Unreleased]

### Changed

- Change default workdir to `/home/claude` for proper Claude CLI home directory.

### Added

- Shell mode (`-s`): drop into a bash shell inside the container.
- Print mode (`-p`): output the generated `docker run` command instead of executing it, accepts an optional prompt argument.
- Commit mode (`-c`): run Claude with read-write git mount for auto-commit workflows.
- Support for passing custom command to the Docker image after `--`.
- Persistent mise volume (`danger-claude-mise`) to cache installed tool versions across runs.

## [0.0.1] - 2026-03-18

### Added

- Initial Dockerfile based on Debian Bookworm slim with build-essential, git, curl, tmux, database client libs, and mise version manager.
- Non-root `claude` user (UID/GID 1000).
- Entrypoint with `.claude.json` config file migration support.
- Ruby CLI script (`bin/danger-claude`) with `--build` flag for image builds and default docker run mode.
- Volume mounts for current directory and persistent Claude config.
- CLAUDE.md project documentation.
