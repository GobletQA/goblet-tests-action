FROM ghcr.io/gobletqa/goblet-app:latest as action-installer
WORKDIR /goblet/app
# Clean up Goblet so it only includes the stuff we need to run tests
# This will be better handled when the repo is cleaned up
RUN <<EOF
  set -eux;
  rm -rf .*ignore
  rm -rf firebase.json
  rm -rf .firebaserc
  rm -rf .gitignore
  rm -rf bundle
  rm -rf configs/app.pm2.config.js
  rm -rf configs/commit-types.json
  rm -rf commitlint.config.js
  rm -rf configs/eslintrc.config.js
  rm -rf configs/firebase.config.js
  rm -rf configs/lint-staged.config.js
  rm -rf configs/pm2.config.js
  rm -rf configs/prettier.config.js
  rm -rf container
  rm -rf docs
  rm -rf index.js
  rm -rf tap.js
  rm -rf *.md
  rm -rf release-please-config.json
  rm -rf turbo.json
  rm -rf scripts
  rm -rf repos/backend
  rm -rf repos/conductor
  rm -rf repos/dind
  rm -rf repos/frontend
  rm -rf repos/kind
  rm -rf repos/monaco
  rm -rf repos/sockr
  rm -rf repos/traceViewer
  rm -rf repos/vite
  mkdir -p temp
  mkdir -p /github
  mv /goblet/app/ /github/app/
EOF

WORKDIR /github/app
COPY goblet-core/. /github/app/.
RUN yarn install

FROM mcr.microsoft.com/playwright:v1.27.0-focal as action-runner
COPY --from=action-installer /github/app /github/app
# Symlink the parent folder of the github workspace to the repos folder
# This ensures the correct folder locations exist for goblet
# We must run Jest from a parent folder of both goblet and the github workspace
RUN <<EOF
  apt-get install jq -y --no-install-recommends
  apt-get clean
  apt-get autoclean
  apt-get autoremove
  rm -rf /var/lib/apt/lists/*
  rm -rf /var/lib/apt/lists.d/*
  rm -rf /goblet
  ln -s /github /goblet
  rm -rf $HOME/.node_modules
  ln -s /github/app/node_modules $HOME/.node_modules
  ln -s /github/app/node_modules /github/node_modules
  cd /github/app
  npx playwright install --with-deps
EOF
COPY . /goblet-action

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
