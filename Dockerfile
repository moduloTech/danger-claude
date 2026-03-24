FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates procps tmux git openssh-client build-essential zlib1g-dev libffi-dev libreadline-dev libyaml-dev libpq-dev libmariadb-dev

RUN install -dm 755 /etc/apt/keyrings \
    && curl -fSs https://mise.jdx.dev/gpg-key.pub | tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list \
    && apt update -y && apt install -y mise gh

RUN rm -rf /var/lib/apt/lists/*

# Non-root user to run claude with the flag `--dangerously-skip-permissions`
# Also added to root group (gid 0) so it can access Docker Desktop's SSH agent
# socket which is bind-mounted as root:root with rw-rw---- permissions.
RUN groupadd --gid 1000 claude \
    && useradd --uid 1000 --gid claude --groups root --create-home --shell /bin/bash claude

# Entrypoint must be written as root before switching user
RUN printf '#!/usr/bin/env bash\n\
set -e\n\
if [ -f "$HOME/.claude/.claude.json" ]; then\n\
  ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"\n\
elif [ -f "$HOME/.claude.json" ]; then\n\
  cp "$HOME/.claude.json" "$HOME/.claude/.claude.json"\n\
  ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"\n\
fi\n\
if [ -n "$MISE_TRUSTED_PATHS" ]; then\n\
  IFS=: read -ra _paths <<< "$MISE_TRUSTED_PATHS"\n\
  for _p in "${_paths[@]}"; do\n\
    for _f in "$_p/mise.toml" "$_p/.mise.toml" "$_p/.tool-versions"; do\n\
      [ -f "$_f" ] && mise trust "$_f" 2>/dev/null\n\
    done\n\
  done\n\
fi\n\
eval "$(mise activate bash)"\n\
exec "${@:-bash}"\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Pre-create mount points for named volumes so they inherit claude ownership
# instead of being created as root by Docker on first mount.
RUN mkdir -p /home/claude/.config/gh /home/claude/.local/share/mise \
    && chown -R claude:claude /home/claude/.config /home/claude/.local

USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:${PATH}"

WORKDIR /home/claude
ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude", "--dangerously-skip-permissions"]
