FROM ghcr.io/keg-hub/keg-herkin:develop as action-installer
WORKDIR /goblet-action
COPY package.json package.json
COPY yarn.lock yarn.lock
RUN yarn install --non-interactive --ignore-optional

FROM ghcr.io/keg-hub/keg-herkin:develop as action-builder
WORKDIR /goblet-action
COPY --from=action-installer /goblet-action/node_modules ./node_modules
COPY . .
RUN yarn build

FROM ghcr.io/keg-hub/keg-herkin:develop as action-runner

# TODO: remove this when finished with development of action
RUN yarn global add ts-node esbuild-runner esbuild

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
    ln -s /home/runner/tap/node_modules $HOME/.node_modules

RUN cd /keg/tap && \
    npx playwright install --with-deps

COPY --from=action-builder /goblet-action/dist /goblet-action
COPY --from=action-builder /goblet-action/node_modules /goblet-action/node_modules
COPY --from=action-builder /goblet-action/package.json /goblet-action/package.json
COPY --from=action-builder /goblet-action/tsconfig.json /goblet-action/tsconfig.json
COPY --from=action-builder /goblet-action/entrypoint.sh /goblet-action/entrypoint.sh

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
