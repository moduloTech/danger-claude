FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates procps tmux git build-essential zlib1g-dev libffi-dev libreadline-dev libyaml-dev libpq-dev libmariadb-dev

RUN install -dm 755 /etc/apt/keyrings \
    && curl -fSs https://mise.jdx.dev/gpg-key.pub | tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list \
    && apt update -y && apt install -y mise

RUN rm -rf /var/lib/apt/lists/*

# Non-root user to run claude with the flag `--dangerously-skip-permissions`
RUN groupadd --gid 1000 claude \
    && useradd --uid 1000 --gid claude --create-home --shell /bin/bash claude

# Entrypoint must be written as root before switching user
RUN printf '#!/usr/bin/env bash\n\
set -e\n\
if [ -f "$HOME/.claude/.claude.json" ]; then\n\
  ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"\n\
elif [ -f "$HOME/.claude.json" ]; then\n\
  cp "$HOME/.claude.json" "$HOME/.claude/.claude.json"\n\
  ln -sf "$HOME/.claude/.claude.json" "$HOME/.claude.json"\n\
fi\n\
exec "${@:-bash}"\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:${PATH}"

WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude", "--dangerously-skip-permissions"]
