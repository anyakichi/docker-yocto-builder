Skip setup if setup is already done.

```
$ [[ "\${BBPATH}" ]] && return 0
```

Setup yocto build environment.

```
$ source poky/oe-init-build-env build || return 1
```

Create auto.conf for our build environment.

```
$ rm -rf conf/auto.conf
$ [[ "${YOCTO_MACHINE}" ]] && echo "MACHINE = \"${YOCTO_MACHINE}\"" >> conf/auto.conf
$ [[ "${YOCTO_DL_DIR}" ]] && echo 'DL_DIR = "${YOCTO_DL_DIR}"' >> conf/auto.conf
$ [[ "${YOCTO_SSTATE_DIR}" ]] && echo 'SSTATE_DIR = "${YOCTO_SSTATE_DIR}"' >> conf/auto.conf
```
