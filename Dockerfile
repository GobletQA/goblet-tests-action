FROM ghcr.io/gobletqa/goblet:develop as action-installer
WORKDIR /keg/tap
# Clean up Goblet so it only includes the stuff we need to run tests
# This will be better handled when the repo is cleaned up
RUN rm -rf .*ignore && \
    rm -rf firebase.json && \
    rm -rf bundle && \
    rm -rf configs/eslintrc.config.js && \
    rm -rf configs/firebase.config.js && \
    rm -rf configs/lint-staged.config.js && \
    rm -rf configs/pm2.config.js && \
    rm -rf configs/prettier.config.js && \
    rm -rf container && \
    rm -rf docs && \
    rm -rf index.js && \
    rm -rf tap.js && \
    rm -rf *.md && \
    rm -rf scripts && \
    rm -rf repos/admin && \
    rm -rf repos/backend && \
    rm -rf repos/conductor && \
    rm -rf repos/tap && \
    rm -rf repos/workflows && \
    mkdir -p temp
COPY goblet-core/. /keg/tap/.

FROM ghcr.io/gobletqa/goblet:develop as action-runner

# Copy over the cleaned up Goblet repo from the previous step
COPY --from=action-installer /keg/tap /home/runner/tap
RUN apt-get install jq -y --no-install-recommends && \
    apt-get clean && \
    cd /home/runner/tap && \
    npx playwright install --with-deps

# Symlink the parent folder of the github workspace to the repos folder
# This ensures the correct folder locations exist for goblet
# We must run Jest from a parent folder of both goblet and the github workspace
RUN rm -rf /keg && \
    ln -s /home/runner /keg && \
    mkdir -p /keg/work && \
    ln -s /home/runner/work /keg/repos && \
    rm -rf $HOME/.node_modules && \
    ln -s /home/runner/tap/node_modules $HOME/.node_modules && \
    ln -s /home/runner/tap/node_modules /home/runner/node_modules

COPY . /goblet-action

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
