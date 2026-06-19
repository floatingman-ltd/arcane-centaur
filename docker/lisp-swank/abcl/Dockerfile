FROM debian:bookworm-slim

# abcl from Debian repos (pulls in default-jre-headless as a dependency).
# ABCL runs on the JVM, so the JRE is needed at runtime too.
RUN apt-get update && apt-get install -y --no-install-recommends \
    abcl \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Quicklisp
RUN curl -fsSL -o /tmp/ql.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    abcl --no-userinit --batch \
         --load /tmp/ql.lisp \
         --eval '(quicklisp-quickstart:install :path "/root/quicklisp")' \
         --eval '(quit)' && \
    rm /tmp/ql.lisp

# Pre-fetch Swank so first startup is fast
RUN abcl --no-userinit --batch \
         --load /root/quicklisp/setup.lisp \
         --eval '(ql:quickload :swank)' \
         --eval '(quit)'

COPY swank-start.lisp /app/swank-start.lisp

WORKDIR /lisp

EXPOSE 4005

# --no-userinit: skip ~/.abclrc so the container is deterministic.
# No --batch: we need the process to stay alive while Swank serves.
CMD ["abcl", "--no-userinit", \
     "--load", "/root/quicklisp/setup.lisp", \
     "--load", "/app/swank-start.lisp"]
