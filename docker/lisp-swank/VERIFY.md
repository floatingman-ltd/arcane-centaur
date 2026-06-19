# Verification: lisp-swank containers

Manual verification steps for the `add-lisp-repl-containers` change.
Run these after building on a fresh environment to confirm every profile
reaches healthy and Conjure can connect on 4005.

## Prerequisites

- Docker Engine and Docker Compose v2 installed
- Neovim with this config loaded (Conjure configured for 4005)
- Working directory: `docker/lisp-swank/`

```sh
cd ~/.config/nvim/docker/lisp-swank
```

---

## Step 0 — Build all images

Build everything before running any profile. First build fetches
tarballs and compiles Quicklisp/Swank per implementation — allow
10–15 minutes. Subsequent builds are cached.

```sh
docker compose build
```

Expected: all four images (`sbcl`, `ccl`, `ecl`, `abcl`) build without
error. Check each section of output ends with `FINISHED` or `CACHED`.

---

## Step 1 — SBCL (default, no profile)

```sh
LISP_DIR=$PWD docker compose up -d --wait
```

**Verify container health:**

```sh
docker compose ps
# sbcl should show: Status=healthy
```

**Verify port 4005 is open on the host:**

```sh
grep -q :0FA5 /proc/net/tcp && echo "PASS: port 4005 open" || echo "FAIL"
```

**Verify port 8080 is reachable from the host:**

```sh
# Start a trivial listener inside the container
docker compose exec sbcl bash -c 'echo "ok" | nc -lp 8080 -q1 &'
sleep 1
curl -s --max-time 3 http://127.0.0.1:8080 && echo "PASS: 8080 reachable" || echo "FAIL"
```

**Verify Conjure connects (in Neovim):**

```
1. Open any .lisp file
2. HUD should show: ; connected to localhost:4005
   (if not: ,cc to connect manually)
3. Evaluate: (lisp-implementation-type)
   Expected result: "SBCL"
4. Evaluate: (lisp-implementation-version)
   Expected: a version string, e.g. "2.3.x"
```

---

## Step 2 — Switch to CCL

```sh
LISP_DIR=$PWD docker compose down

LISP_DIR=$PWD docker compose --profile ccl up -d --wait
```

**Verify:**

```sh
docker compose ps
# ccl should show: Status=healthy
# sbcl should not be listed
```

**In Neovim:**

```
,cc   (reconnect — same 4005 socket, new container)
Evaluate: (lisp-implementation-type)
Expected: "Clozure Common Lisp"
```

---

## Step 3 — Switch to ECL

```sh
LISP_DIR=$PWD docker compose --profile ccl down

LISP_DIR=$PWD docker compose --profile ecl up -d --wait
```

**Verify:**

```sh
docker compose ps
# ecl should show: Status=healthy
```

**In Neovim:**

```
,cc
Evaluate: (lisp-implementation-type)
Expected: "Embeddable Common-Lisp"
```

---

## Step 4 — Switch to ABCL

```sh
LISP_DIR=$PWD docker compose --profile ecl down

LISP_DIR=$PWD docker compose --profile abcl up -d --wait
```

ABCL starts the JVM; the healthcheck allows 60 s before counting
retries — `--wait` blocks until healthy so no manual polling needed.

**Verify:**

```sh
docker compose ps
# abcl should show: Status=healthy
```

**In Neovim:**

```
,cc
Evaluate: (lisp-implementation-type)
Expected: "Armed Bear Common Lisp"
```

---

## Step 5 — Confirm :4005 contract (only one implementation at a time)

With any profile currently running, attempt to start a second:

```sh
# Example: abcl is up; try to also start ecl
LISP_DIR=$PWD docker compose --profile ecl up -d
```

**Expected:** Docker fails with a port-binding conflict on
`127.0.0.1:4005`. This confirms the contract: the host port enforces
mutual exclusion without any editor-side logic.

---

## Step 6 — Clean up

```sh
LISP_DIR=$PWD docker compose --profile abcl down
# (substitute whichever profile is currently running)
```

---

## Pass criteria

| Check | Expected result |
|---|---|
| `docker compose up -d --wait` (no profile) | sbcl `healthy`, port 4005 open |
| `--profile ccl up -d --wait` | ccl `healthy`, port 4005 open |
| `--profile ecl up -d --wait` | ecl `healthy`, port 4005 open |
| `--profile abcl up -d --wait` | abcl `healthy`, port 4005 open |
| `,cc` after each switch | Conjure connects; `(lisp-implementation-type)` returns correct impl |
| `127.0.0.1:8080` with in-container listener | `curl` succeeds |
| Two profiles simultaneously | Docker port conflict error (expected — this is correct behavior) |

---

## Troubleshooting

**Container never reaches healthy:**

```sh
docker compose logs <service>
# Look for errors before the "Swank started at port: 4005." line.
```

Common causes:
- CCL: tarball URL changed — check the GitHub release tag in `ccl/Dockerfile`
- ECL: missing C toolchain (should be installed by the Dockerfile; check apt errors)
- ABCL: JVM OOM — ABCL needs ~256 MB heap; ensure Docker has enough memory

**Conjure HUD stays empty after `,cc`:**

See the troubleshooting section in
`docs/modules/ROOT/pages/languages/lisp.adoc` — the three failure modes
(port never opened, connection refused, `close-connection: end of file`)
are documented there with fixes.
