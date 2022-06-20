FROM ghcr.io/keg-hub/keg-herkin:develop

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
