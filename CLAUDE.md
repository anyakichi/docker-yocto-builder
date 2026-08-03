# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The Yocto image of [docker-buildenv](https://github.com/anyakichi/docker-buildenv).
There is no code to build here: the repository is two Dockerfiles, a set of
*documents* in `buildenv.d/`, and one shell script in `bin/`.

The `buildenv` submodule is the machinery. It carries `buildenv.sh` (installed
as `buildenv`, the interpreter of the documents), `din.sh` (the host-side
`din` that runs a container with `$PWD` bind-mounted at `/build`),
`entrypoint.sh` (aligns the builder user's uid/gid with the owner of the
mounted directory) and `buildenv.conf`. Read `buildenv/CLAUDE.md` before
changing anything that depends on how documents are parsed — the pipeline,
the escaping and the continuation-line rules are described there.

This repository supplies only what is Yocto-specific: which packages a build
host needs, and what `extract`, `setup` and `build` do.

## Commands

```console
# Render a document as a manual, without building an image.  CONFDIR points
# buildenv at the working tree, and bin/ has to be on PATH for yocto-flavor.
$ CONFDIR=buildenv.d PATH="$PWD/bin:$PATH" YOCTO_BRANCH=wrynose \
    ./buildenv/buildenv.sh extract -m
$ CONFDIR=buildenv.d PATH="$PWD/bin:$PATH" YOCTO_BRANCH=kirkstone \
    ./buildenv/buildenv.sh setup -p     # -p prints the commands alone
$ CONFDIR=buildenv.d PATH="$PWD/bin:$PATH" \
    ./buildenv/buildenv.sh setup -d     # -d stops after expansion

# Build an image.  yocto_branch defaults to master when it is not given.
$ docker build --build-arg base=ubuntu:noble --build-arg yocto_branch=wrynose \
    -t yocto-builder:test .
$ docker build -f Dockerfile.fedora --build-arg base=almalinux:9 \
    --build-arg yocto_branch=scarthgap -t yocto-builder:test .

# Smoke test it.  A real build takes hours; extract and setup are what this
# repository can break, so run them and stop before bitbake.
$ mkdir /tmp/y && cd /tmp/y && din yocto-builder:test
builder@y:/build$ extract -m        # what it would do
builder@y:/build$ extract && setup
```

Render both flavors after touching a document — a branch from before
whinlatter and one after it — since the two take different halves of the
dispatch. There is no test suite in this repository; the tests of the
interpreter live in the submodule (`buildenv/tests/run.sh`).

## Documents

`buildenv.d/<subcommand>.<NN>.md` is markdown prose in which the `$ ` lines
are the commands. `buildenv <name>` collects `<name>.*` in filename order,
expands it and runs the commands; `-m` prints the whole thing as a manual
instead, which is why the prose is written to be read by a user.

Subcommand names come from the filenames, so every `foo-bar.NN.md` is a
subcommand of `buildenv` whether or not it is meant to be run by hand. The
Dockerfiles therefore set `ALIASES="extract setup build"` in
`/etc/buildenv.conf`, which keeps the included fragments out of the shell as
commands. `DOTCMDS=setup` marks `setup` as sourced (`. <(buildenv setup)`)
rather than run.

Two levels of expansion share one file, and getting them backwards is the
usual mistake:

- `${YOCTO_BRANCH:-master}` is expanded when the document is rendered, so the
  manual shows the value the image would use. It runs under `bash -u`, hence
  the `:-` default; a bare unset variable is a hard error.
- `\${YOCTO_BUILDTOOLS}` survives rendering and reaches the shell that runs
  the command. Use it for anything the command itself must evaluate — a
  condition, a variable written into `auto.conf`.

## The flavor dispatch

whinlatter (5.3) replaced `oe-init-build-env` of poky with `bitbake-setup`,
so `extract` and `setup` each exist twice:

```
extract.40.md  ->  {% include extract-$(yocto-flavor) %}  ->  extract-poky.40.md
                                                          |   extract-bitbake-setup.40.md
setup.40.md    ->  {% include setup-$(yocto-flavor) %}    ->  setup-poky.40.md
                                                          |   setup-bitbake-setup.40.md
                                                              both include setup-auto-conf.40.md
```

`bin/yocto-flavor` prints `poky` or `bitbake-setup`. It decides by matching
`YOCTO_BRANCH` against a hardcoded list of the releases that predate
bitbake-setup — a list that never grows, so a new release needs no change
there. `YOCTO_LEGACY_BRANCHES` overrides it.

The two flavors differ in layout, and the prose in `README.md` describes it
for users: poky clones into `./poky` and builds in `./build`, while
bitbake-setup collects layers into `./yocto/layers`, builds in `./yocto/build`
and shares `site.conf`, the downloads and the sstate cache in `.`. Keep
`README.md` in step when either changes; the variable table there is the only
documentation of `YOCTO_*`.

## The two Dockerfiles

`Dockerfile` (apt) and `Dockerfile.fedora` (dnf) differ only in the package
installation. Everything from `ADD oe-git-proxy` down — the builder user, the
`COPY` lines, the `sed` on `buildenv.conf`, the `ENV` block — is duplicated,
and a change to one of them belongs in both. A new `YOCTO_*` variable has to
be declared in both `ENV` blocks, or it is unset and `bash -u` in the document
fails.

The images span xenial to resolute and fedora to almalinux 8, so the
unconditional package list is the intersection that every base has. Anything
that is missing from some base, or that only the recent releases want, goes in
the loop guarded by `apt-cache show` / `dnf info` instead. The ubuntu images
since noble ship a default user on uid 1000, which the entrypoint wants for
builder; `Dockerfile` deletes it.

## CI and tags

`.github/workflows/docker.yml` builds in two stages, and pushes only from
`main`:

1. `build_and_push_base` / `build_and_push_fedora` build the real images, one
   per base, tagged `<base>-main` (`noble-main`, `almalinux9-main`).
2. `build_and_push` builds `Dockerfile.env`, which is `FROM <base>-main` plus
   `ENV YOCTO_BRANCH`, for every base × branch pair, tagged `<base>-<branch>`.
   A pair listed in `DEFAULT_PAIRS` also gets the bare `<branch>` tag, which
   is what `anyakichi/yocto-builder:wrynose` means.

So the branch-specific images are ENV overlays; adding a Yocto release is a
line in the `branch` matrix, and a line in `DEFAULT_PAIRS` naming the base
that suits it. Adding a base image means the `base` matrix of the build job
*and* the `base` matrix of `build_and_push`, where the tag form has no colon.

## Conventions

Commit subjects are `<area>: <Imperative sentence>` — `docker:`, `ci:`,
`README:` — with the body explaining why, and a submodule bump is
`Update buildenv` on its own. A change in behaviour is followed by the
`README:` commit that describes it. Comments in the Dockerfiles and prose in
the documents are full sentences that say why; match that register.
