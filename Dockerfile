FROM buildpack-deps:bookworm-curl

RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev -s /bin/zsh dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    zsh \
    git \
    ripgrep \
    fzf \
    bat \
    jq \
    zoxide \
    less \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev

ENV BUN_INSTALL="/usr/local"

RUN curl -fsSL https://bun.sh/install | bash

USER dev

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && sed -i 's/plugins=(git)/plugins=(git fzf sudo extract zoxide docker bun)/' ~/.zshrc \
    && curl -fsSL https://starship.rs/install.sh | sh -s -- -y \
    && echo 'eval "$(starship init zsh)"' >> ~/.zshrc \
    && echo 'source ~/.aliases' >> ~/.zshrc

COPY --chown=dev:dev starship.toml /home/dev/.config/starship.toml
COPY --chown=dev:dev aliases /home/dev/.aliases

SHELL ["/bin/zsh", "-c"]
CMD ["/bin/zsh"]
