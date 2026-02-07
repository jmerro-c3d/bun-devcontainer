FROM buildpack-deps:bookworm-curl

RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev -s /bin/zsh dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
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



# Install lazygit (latest release)
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install -D lazygit /usr/local/bin/lazygit && \
    rm lazygit.tar.gz lazygit

USER dev

RUN curl -fsSL https://bun.sh/install | bash

RUN sudo ln -s /home/dev/.bun/bin/bun /usr/local/bin/bun
RUN sudo ln -s /home/dev/.bun/bin/bunx /usr/local/bin/bunx

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && sed -i 's/plugins=(git)/plugins=(git fzf sudo extract zoxide docker bun)/' ~/.zshrc \
    && curl -fsSL https://starship.rs/install.sh | sh -s -- -y \
    && echo 'eval "$(starship init zsh)"' >> ~/.zshrc \
    && echo 'source ~/.aliases' >> ~/.zshrc

COPY --chown=dev:dev starship.toml /home/dev/.config/starship.toml
COPY --chown=dev:dev aliases /home/dev/.aliases

SHELL ["/bin/zsh", "-c"]
CMD ["/bin/zsh"]
