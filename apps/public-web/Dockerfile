FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY scripts/build.mjs scripts/build.mjs
COPY public public
COPY src src
RUN node scripts/build.mjs

FROM node:22-alpine AS runtime
WORKDIR /app
COPY --from=build /app/package.json ./
COPY --from=build /app/dist dist
COPY --from=build /app/src src
COPY scripts/healthcheck.mjs scripts/healthcheck.mjs
USER node
ENV NODE_ENV=production HOST=0.0.0.0 PORT=5173
EXPOSE 5173
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["node", "scripts/healthcheck.mjs"]
CMD ["node", "src/app/main.mjs"]
