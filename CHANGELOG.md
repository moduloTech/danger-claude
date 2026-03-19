# Changelog

## [Unreleased]

## [0.0.3] - 2026-03-19

### Added

- New `-v`/`--volume` CLI option to mount additional Docker volumes into the container. Accepts a bare host path (mounted at the same path) or a `host_path:container_path` pair. Can be specified multiple times.

## [0.0.2.4] - 2026-03-18

### Fixed

- Use `File.realpath` to resolve Homebrew symlinks when locating the Dockerfile, so `--build` finds the Cellar prefix instead of `/opt/homebrew`.

## [0.0.2.3] - 2026-03-18

### Fixed

- Fix `--build` to work when installed via Homebrew by resolving the Dockerfile relative to the script's prefix directory and passing it explicitly to `docker build -f`. Add error message when Dockerfile is missing.

## [0.0.2.2] - 2026-03-18

### Added

- Forward host `user.name` and `user.email` git config into the container via environment variables, so commits made inside the container use the correct author identity.

## [0.0.2.1] - 2026-03-18

### Fixed

- Fix volume mount paths to use `/home/claude/<workdir>` for both the project directory and `.git` mount, matching the container's working directory.

## [0.0.2] - 2026-03-18

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
