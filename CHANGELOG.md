# Changelog

## [Unreleased]

## [0.5.1] - 2026-04-21

### Added

- Install `wkhtmltopdf` in the Docker image.

## [0.5.0] - 2026-04-21

### Added

- Automatically append a container-awareness system prompt to every `claude` invocation (interactive, `-p`, `-c`, `-r`). Informs Claude that it runs in a Docker container, that host services (databases, Redis, etc. from docker-compose) are reachable via `host.docker.internal`, and that non-interactive Ruby/Node commands should be prefixed with `mise x ruby --` / `mise x node --` since mise shims are not on PATH outside login shells.
- `--append-system-prompt TEXT` CLI option that overrides the default container-awareness prompt with a custom text, forwarded as-is to `claude --append-system-prompt`.

## [0.4.2] - 2026-04-20

### Added

- Install `jq` (JSON processor) and `poppler-utils` (PDF utilities, provides `pdftotext`) in the Docker image.

## [0.4.1] - 2026-04-17

### Fixed

- Piped stdin context was silently ignored in interactive mode without a prompt argument (e.g. `issue-md <URL> | danger-claude`). The context is now passed as the initial prompt to Claude.

## [0.4.0] - 2026-04-14

### Added

- Stdin piping support: pipe any content into `danger-claude` as context. In print mode (`-p`), the piped content is prepended to the prompt. In interactive mode, it is mounted as `/context/stdin` inside the container. Stdin is reopened from `/dev/tty` after consumption so interactive Docker sessions retain a working TTY. Example: `issue-md <URL> | danger-claude -p "fix this bug"`.
- Positional prompt argument: `danger-claude "explain this code"` starts an interactive Claude session with that initial prompt, like the `claude` CLI itself.
- `-s` / `--shell` now accepts an optional command: `danger-claude -s "ls -la"` runs the command in the container instead of opening a bash shell.
- `-P` / `--port MAPPING` flag to expose container ports to the host (passed as `-p` to `docker run`). Supports multiple `-P` flags for multi-port setups.

### Changed

- **Breaking:** bare arguments are now treated as a Claude prompt instead of a Docker command. Use `-s "command"` to run arbitrary commands in the container (replaces `-- command`).

## [0.3.1] - 2026-04-07

### Added

- `--add-host=host.docker.internal:host-gateway` on Linux so containers can reach host services (e.g. Chrome DevTools).

## [0.3.0] - 2026-04-03

### Added

- `-r` / `--resume SESSION_ID` flag to resume a previous Claude session. Works in both print mode (`-p -r`) and interactive mode (`-r` alone).

## [0.2.1] - 2026-04-02

### Added

- `--version` CLI flag to display the current version.

## [0.2.0] - 2026-03-31

### Added

- New `-m`/`--model MODEL` option to select the Claude model (forwarded as `--model` to the `claude` CLI).
- New `-e`/`--effort LEVEL` option to set effort level: low, medium, high (forwarded as `--effort` to the `claude` CLI).

### Changed

- `-c` (auto-commit) now instructs Claude to use Conventional Commits format (`<type>: <description>`) instead of free-form summary lines.

## [0.1.1] - 2026-03-27

### Added

- New `--max-turns N`, `--output-format FORMAT`, and `--json-schema SCHEMA` options forwarded to the `claude` CLI in print mode. Enables compatibility with tools like `mr-review` that rely on these Claude CLI flags.

## [0.1.0] - 2026-03-26

### Added

- New `-a`/`--agent NAME` option to run in print mode with a specific Claude Code subagent. Passes `--agent NAME` to the `claude` CLI, enabling subagent-specific system prompts, tool restrictions, models, and persistent memory.

## [0.0.6] - 2026-03-24

### Added

- Activate mise in the entrypoint and automatically trust all mounted volumes (workdir + extra `-v` paths) via `mise trust` so that project `.mise.toml` / `.tool-versions` are picked up automatically.

## [0.0.5] - 2026-03-23

### Added

- New `-g`/`--git-rw` option to mount `.git` as read-write. By default `.git` is mounted read-only; `-c` implies `--git-rw`. Works with all modes (`-s`, `-p`, default, `--`).
- Pre-create mount points for named volumes (`mise`, `gh`) in the Dockerfile so they inherit `claude` ownership instead of being created as root by Docker.

### Changed

- Rewrite CLI usage banner to document all modes and the read-only/read-write distinction.

### Fixed

- Use `-i` instead of `-ti` when stdin is not a TTY, allowing non-interactive use from scripts and subprocesses (e.g. `autodev`).

## [0.0.4] - 2026-03-20

### Added

- Install GitHub CLI (`gh`) and `openssh-client` in the Docker image.
- Persistent Docker volume for `gh` config directory across container runs.
- Forward host SSH agent socket (`SSH_AUTH_SOCK`) into the container when available, enabling git operations over SSH.
- Pass through `GH_TOKEN` or `GITHUB_TOKEN` env vars into the container for GitHub authentication.

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
