FROM ghcr.io/gobletqa/goblet-action:latest as action-installer

WORKDIR /github/app
COPY . /goblet-action
COPY goblet-core/. /github/app/.

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
