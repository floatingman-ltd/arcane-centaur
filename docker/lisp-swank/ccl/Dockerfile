FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Clozure CL from the official GitHub release tarball.
# The archive extracts to ccl/ containing lx86cl64 (64-bit executable)
# and scripts/ccl64 (wrapper that sets CCL_DEFAULT_DIRECTORY).
RUN curl -fsSL -o /tmp/ccl.tar.gz \
    https://github.com/Clozure/ccl/releases/download/v1.12.2/ccl-1.12.2-linuxx86.tar.gz && \
    tar -xzf /tmp/ccl.tar.gz -C /opt/ && \
    rm /tmp/ccl.tar.gz && \
    ln -sf /opt/ccl/scripts/ccl64 /usr/local/bin/ccl

# Install Quicklisp
RUN curl -fsSL -o /tmp/ql.lisp https://beta.quicklisp.org/quicklisp.lisp && \
    ccl --no-init --batch \
        --load /tmp/ql.lisp \
        --eval '(quicklisp-quickstart:install :path "/root/quicklisp")' \
        --eval '(quit)' && \
    rm /tmp/ql.lisp

# Pre-fetch Swank so first startup is fast
RUN ccl --no-init --batch \
        --load /root/quicklisp/setup.lisp \
        --eval '(ql:quickload :swank)' \
        --eval '(quit)'

COPY swank-start.lisp /app/swank-start.lisp

WORKDIR /lisp

EXPOSE 4005

CMD ["ccl", "--no-init", \
     "--load", "/root/quicklisp/setup.lisp", \
     "--load", "/app/swank-start.lisp"]
