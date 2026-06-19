FROM debian:bookworm-slim

# ecl from Debian repos. gcc + libc6-dev are needed at runtime because
# ECL compiles Lisp through C — every ql:quickload triggers a C build step.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ecl \
    gcc \
    libc6-dev \
    make \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Quicklisp
RUN curl -fsSL -o /tmp/ql.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    ecl --norc \
        --load /tmp/ql.lisp \
        --eval '(quicklisp-quickstart:install :path "/root/quicklisp")' \
        --eval '(quit)' && \
    rm /tmp/ql.lisp

# Pre-fetch Swank so first startup is fast
RUN ecl --norc \
        --load /root/quicklisp/setup.lisp \
        --eval '(ql:quickload :swank)' \
        --eval '(quit)'

COPY swank-start.lisp /app/swank-start.lisp

WORKDIR /lisp

EXPOSE 4005

CMD ["ecl", "--norc", \
     "--load", "/root/quicklisp/setup.lisp", \
     "--load", "/app/swank-start.lisp"]
