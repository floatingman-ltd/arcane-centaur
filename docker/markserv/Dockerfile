FROM node:20-alpine

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
