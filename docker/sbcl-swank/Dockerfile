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
         --eval '(quicklisp-quickstart:install :path "/root/quicklisp")' \
         --eval '(ql:add-to-init-file)' && \
    rm /tmp/ql.lisp

# Pre-fetch Swank so first startup is fast
RUN sbcl --non-interactive --eval '(ql:quickload :swank)' --eval '(quit)'

WORKDIR /lisp

EXPOSE 4005

CMD ["sbcl", \
     "--eval", "(ql:quickload :swank)", \
     "--eval", "(swank:create-server :port 4005 :dont-close t)", \
     "--eval", "(loop (sleep 60))"]
