Use the host tools of buildtools, which are installed in extract.

```
$ if [[ "\${YOCTO_BUILDTOOLS}" ]]; then
>     source poky/buildtools/environment-setup-* || return 1
> fi
```

Setup yocto build environment.

```
$ source poky/oe-init-build-env build || return 1
```

Create auto.conf, which holds the settings of this build environment.
It is written from scratch, since the build directory may be the one a
setup before has left.  MACHINE is written only when YOCTO_MACHINE is
set; the release builds for its own default machine otherwise.

```
$ rm -f conf/auto.conf
$ if [[ "\${YOCTO_MACHINE}" ]]; then
>     echo "MACHINE = \"\${YOCTO_MACHINE}\"" >> conf/auto.conf
> fi
```

{% include setup-auto-conf %}
