FROM gact:test as action-installer

WORKDIR /github/app
COPY . /goblet-action
COPY goblet-core/. /github/app/.

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"
RUN pnpm install


ENTRYPOINT ["/goblet-action/entrypoint.sh"]
