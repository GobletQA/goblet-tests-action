FROM ghcr.io/gobletqa/goblet-action:latest as action-installer

WORKDIR /github/app
COPY . /goblet-action
COPY goblet-core/. /github/app/.

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"
RUN npm install --global pnpm@8.3.1 && \
    npm uninstall -g yarn && \
    pnpm install --force
    

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
