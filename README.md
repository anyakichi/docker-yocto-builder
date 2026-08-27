# docker-yocto-builder

[docker-buildenv](https://github.com/anyakichi/docker-buildenv) for
Yocto Firmware.

## How to use

```
$ mkdir yocto-1 && cd $_
$ din anyakichi/yocto-builder:wrynose
builder@yocto-1:/build$ extract
builder@yocto-1:/build$ setup
builder@yocto-1:/build/yocto/build$ build
```

`extract` and `setup` follow whichever way the release is built:

- whinlatter (5.3) and later are set up with
  [bitbake-setup](https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-environment-setup.html).
  `extract` clones bitbake and runs `bitbake-setup init`, which collects
  the layers of the selected configuration into `./yocto/layers` and
  prepares `./yocto/build`. `site.conf`, the downloads and the sstate
  cache are placed in the top directory (`.`) and shared between the
  setups. `setup` sources `yocto/build/init-build-env`.
- Older releases are set up the traditional way. `extract` clones poky,
  and `setup` sources `poky/oe-init-build-env build`.

Run `extract -m` or `setup -m` in the container to see what they are
about to do for the release of the image.

Layers and the configuration of a bitbake-setup build are managed after
the setup by bitbake-setup itself:

```
builder@yocto-1:/build/yocto/build$ bitbake-setup status
builder@yocto-1:/build/yocto/build$ bitbake-setup update
builder@yocto-1:/build/yocto/build$ bitbake-config-build enable-fragment machine/qemuarm64
```

## Environment variables

| Variable               | Default              | Description                                                                                             |
| ---------------------- | -------------------- | ------------------------------------------------------------------------------------------------------- |
| `YOCTO_BRANCH`         | `master`             | Release branch to build. It is baked into the branch specific images.                                    |
| `YOCTO_REV`            |                      | Exact revision of poky to check out, a commit hash or a tag. `YOCTO_BRANCH` still names the release it belongs to. |
| `YOCTO_BITBAKE_TARGET` | `core-image-minimal` | Target of bitbake.                                                                                       |
| `YOCTO_CONFIG`         | `poky-${YOCTO_BRANCH}` | bitbake-setup configuration template. `bitbake-setup list` shows what is available.                    |
| `YOCTO_CONFIG_NAME`    | `poky`               | bitbake configuration in the template, e.g. `poky-with-sstate`.                                          |
| `YOCTO_DISTRO`         | `poky`               | Distro fragment, e.g. `poky-tiny`.                                                                       |
| `YOCTO_MACHINE`        | `qemux86-64`         | Machine fragment. For the releases set up from poky it is `MACHINE` in `auto.conf` instead, and unset by default. |
| `YOCTO_BUILDTOOLS`     |                      | Install buildtools and use the host tools of it when it is set to anything.                              |
| `YOCTO_BUILDTOOLS_OPTS` |                     | Extra options for the command that installs buildtools.                                                  |
| `YOCTO_BB_GENERATE_MIRROR_TARBALLS` |         | `BB_GENERATE_MIRROR_TARBALLS`.                                                                           |
| `YOCTO_CCACHE_DIR`     |                      | `CCACHE_TOP_DIR`. ccache is inherited when it is set.                                                    |
| `YOCTO_DL_DIR`         |                      | `DL_DIR`.                                                                                                |
| `YOCTO_SOURCE_MIRROR_URL` |                   | `SOURCE_MIRROR_URL`. own-mirrors is inherited when it is set.                                            |
| `YOCTO_SSTATE_DIR`     |                      | `SSTATE_DIR`.                                                                                            |
| `YOCTO_SSTATE_MIRRORS` |                      | `SSTATE_MIRRORS`.                                                                                        |

`YOCTO_CONFIG`, `YOCTO_CONFIG_NAME` and `YOCTO_DISTRO` are only for the
releases set up with bitbake-setup, and they take effect in `extract`,
where the configuration is chosen, as does `YOCTO_MACHINE` for those
releases. Use `bitbake-config-build enable-fragment` to change the
machine or the distro of a setup that is already extracted.

`YOCTO_REV` is only for the releases set up from poky. A bitbake-setup
build takes its revisions from the configuration, so pin them with a
`YOCTO_CONFIG` of your own instead.

The way the release is set up is told by the `yocto-flavor` command,
which prints `poky` or `bitbake-setup`. `extract` and `setup` pick
their documents by it, so `YOCTO_LEGACY_BRANCHES`, which overrides the
releases it takes as predating bitbake-setup, decides which way is used.

## buildtools

Set `YOCTO_BUILDTOOLS` to build a release on a host that does not have
the host tools of the versions the release needs, such as AlmaLinux, or
an ubuntu older than the release wants:

```
$ din -e YOCTO_BUILDTOOLS=1 anyakichi/yocto-builder:wrynose
```

`extract` installs them, and `setup` sources the environment setup
script of them, so nothing has to be sourced by hand. Where they are
installed, and by which command, follows the way the release is set up.
`YOCTO_BUILDTOOLS_OPTS` is passed to that command.

| Release            | Installed in        | By                                                        |
| ------------------ | ------------------- | ---------------------------------------------------------- |
| whinlatter (5.3) - | `./yocto/buildtools` | `bitbake-setup install-buildtools`, e.g. `--force`         |
| walnascar (5.2) -  | `./poky/buildtools`  | `poky/scripts/install-buildtools`, e.g. `-r yocto-3.1.33`  |

## Build docker image

```
$ docker build \
    --build-arg base=ubuntu:noble \
    --build-arg yocto_branch=wrynose \
  -t yocto-builder:noble-wrynose .
```

`base` is an ubuntu or debian image for `Dockerfile`, and a fedora,
almalinux, centos or rockylinux image for `Dockerfile.fedora`.
`yocto_branch` is a yocto release branch name, and defaults to master
when it is not given. Pre-built docker images are available from:

- anyakichi/yocto-builder:\<base\>-\<yocto_branch\>
- ghcr.io/anyakichi/yocto-builder:\<base\>-\<yocto_branch\>

The image of the base and the release that suit each other is also
tagged with the release name alone, such as `noble-wrynose` being
`wrynose`.
