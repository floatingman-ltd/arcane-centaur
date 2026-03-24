FROM node:20-alpine

# Install markserv — a zero-config markdown HTTP server with live reload.
# Renders .md files as GitHub-flavoured HTML and serves the full directory
# tree, so relative links between markdown files resolve correctly.
RUN npm install -g markserv \
    && npm cache clean --force

WORKDIR /docs

# 8080  — markserv HTTP server
# 35729 — LiveReload WebSocket (automatic browser refresh on file save)
EXPOSE 8080 35729

CMD ["markserv", ".", "-p", "8080", "-a", "0.0.0.0"]
