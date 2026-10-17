FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --include=dev --ignore-scripts
COPY nuxt.config.ts tsconfig.json ./
COPY app app
COPY shared shared
COPY server server
COPY public public
RUN npm run build

FROM node:24-alpine AS runtime
WORKDIR /app
COPY --from=build /app/.output .output
COPY scripts/healthcheck.mjs scripts/healthcheck.mjs
USER node
ENV NODE_ENV=production HOST=0.0.0.0 PORT=5173
EXPOSE 5173
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["node", "scripts/healthcheck.mjs"]
CMD ["node", ".output/server/index.mjs"]
