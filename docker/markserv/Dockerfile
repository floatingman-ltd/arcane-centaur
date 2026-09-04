# Pinned to 20.20 rather than the floating 20-alpine tag on purpose.
#
# markdown-it-github-alerts is published as an ES module only ("type": "module",
# no CommonJS build) while server.js is CommonJS. requiring it works solely
# because require(esm) was backported to Node 20.19. The 20-alpine tag happens
# to resolve past that floor today, but it is not a guarantee -- a rebuild on a
# host with an older 20-alpine cached would produce a container that dies at
# startup rather than one that merely renders alerts unstyled.
#
# Do not relax this to 20-alpine without checking `node --version` >= 20.19 in
# the resulting image.
FROM node:20.20-alpine

# Install application dependencies into a dedicated directory so they are
# isolated from the served docs volume mounted at /docs.
WORKDIR /app
COPY package.json .
RUN npm install --omit=dev && npm cache clean --force
COPY server.js .

WORKDIR /docs

# 8080 — HTTP preview server (also serves SSE live-reload on /__livereload)
EXPOSE 8080

CMD ["node", "/app/server.js"]
