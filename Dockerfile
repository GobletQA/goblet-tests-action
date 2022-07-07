FROM ghcr.io/keg-hub/keg-herkin:develop as action-runner

# Symlink the parent folder of the github workspace to the repos folder
# This ensures the correct folder locations exist for goblet
# We must run Jest from a parent folder of both goblet and the github workspace
RUN mkdir -p /home/runner && \
    mv /keg/tap /home/runner/tap && \
    rm -rf /keg && \
    ln -s /home/runner /keg && \
    mkdir -p /keg/work && \
    ln -s /home/runner/work /keg/repos

RUN rm -rf /keg/tap && \
    rm -rf $HOME/.node_modules && \
    ln -s /home/runner/tap/node_modules $HOME/.node_modules && \
    ln -s /home/runner/tap/node_modules /home/runner/node_modules

RUN cd /keg/tap && \
    npx playwright install --with-deps

COPY . /goblet-action

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
