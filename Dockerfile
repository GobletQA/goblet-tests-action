FROM ghcr.io/gobletqa/goblet-action:latest as action-installer

WORKDIR /github/app
COPY scripts /goblet-action/scripts
COPY entrypoint.sh /goblet-action/entrypoint.sh
COPY goblet-core/. /github/app/.

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
