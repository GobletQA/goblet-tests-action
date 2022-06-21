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
WORKDIR /goblet-action
COPY --from=action-builder /goblet-action/dist ./dist
COPY --from=action-builder /goblet-action/node_modules ./node_modules
COPY --from=action-builder /goblet-action/package.json ./package.json
COPY --from=action-builder /goblet-action/tsconfig.json ./tsconfig.json
COPY --from=action-builder /goblet-action/entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["/goblet-action/entrypoint.sh"]
