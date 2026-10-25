# gobeyondcreativity.com for Dokploy (compose.yaml): the site as it ran on kimsufi, under
# `next start -p 3010` on Node 20.14 with pnpm 9.2. No database or env, so it builds in the image.

FROM node:20.14.0-alpine@sha256:804aa6a6476a7e2a5df8db28804aa6c1c97904eefb01deed5d6af24bb51d0c81

# A shared corepack home, so the node user below finds the pnpm that root prepared.
ENV COREPACK_HOME=/usr/local/share/corepack
RUN apk add --no-cache libc6-compat \
    && corepack enable \
    && corepack prepare pnpm@9.2.0 --activate

WORKDIR /app
RUN chown node:node /app
USER node

# HUSKY=0: the postinstall script sets up git hooks, and there's no .git in the image.
ENV HUSKY=0 \
    NEXT_TELEMETRY_DISABLED=1
COPY --chown=node:node package.json pnpm-lock.yaml .npmrc ./
RUN pnpm install --frozen-lockfile

COPY --chown=node:node . .
RUN pnpm build

ENV NODE_ENV=production
# `pnpm start` is `next start -p 3010`.
EXPOSE 3010
CMD ["pnpm", "start"]
