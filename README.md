# docker-yocto-builder

[docker-buildenv](https://github.com/anyakichi/docker-buildenv) for
Yocto Firmware.

## How to use

```
$ mkdir yocto-1 && cd $_
$ din anyakichi/yocto-builder:dunfell
builder@yocto-1:/build$ extract
builder@yocto-1:/build$ setup
builder@yocto-1:/build/build$ build
```

## Build docker image

```
$ docker build \
    --build-arg ubuntu_version=focal \
    --build-arg yocto_branch=dunfell \
  -t yocto-builder:focal-dunfell .
```

You can replace `focal` with another ubuntu version and replace `dunfell`
with another yocto branch name. Pre-built docker images are available
from:

- anyakichi/yocto-builder:<ubuntu_version>-<yocto_branch>
- ghcr.io/anyakichi/yocto-builder:<ubuntu_versoin>-<yocto_branch>
