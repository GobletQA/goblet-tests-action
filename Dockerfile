FROM ghcr.io/gobletqa/goblet-app:latest as action-installer
WORKDIR /goblet/app
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
    rm -rf repos/frontend && \
    rm -rf repos/traceViewer && \
    rm -rf repos/workflows && \
    mkdir -p temp
COPY goblet-core/. /goblet/app/.

FROM ghcr.io/gobletqa/goblet:develop as action-runner

# Copy over the cleaned up Goblet repo from the previous step
COPY --from=action-installer /goblet/app /github/app
RUN apt-get install jq -y --no-install-recommends && \
    apt-get clean && \
    cd /github/app && \
    npx playwright install --with-deps

# Symlink the parent folder of the github workspace to the repos folder
# This ensures the correct folder locations exist for goblet
# We must run Jest from a parent folder of both goblet and the github workspace
RUN rm -rf /goblet && \
    ln -s /github /goblet && \
    rm -rf $HOME/.node_modules && \
    ln -s /github/app/node_modules $HOME/.node_modules && \
    ln -s /github/app/node_modules /github/node_modules

COPY . /goblet-action

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
