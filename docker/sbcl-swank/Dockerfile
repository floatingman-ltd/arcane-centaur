FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    sbcl \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Quicklisp
RUN curl -fsSL -o /tmp/ql.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --non-interactive \
         --load /tmp/ql.lisp \
         --eval '(quicklisp-quickstart:install :path "/root/quicklisp")' && \
    rm /tmp/ql.lisp

# Pre-fetch Swank so first startup is fast
RUN sbcl --non-interactive \
         --load /root/quicklisp/setup.lisp \
         --eval '(ql:quickload :swank)' \
         --eval '(quit)'

# Copy the Swank startup script
COPY swank-start.lisp /app/swank-start.lisp

WORKDIR /lisp

EXPOSE 4005

# --non-interactive: exit cleanly on unhandled errors instead of hanging
# in the Lisp debugger (which has no TTY inside a container).
CMD ["sbcl", \
     "--non-interactive", \
     "--load", "/root/quicklisp/setup.lisp", \
     "--load", "/app/swank-start.lisp"]
