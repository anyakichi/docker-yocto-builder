Use the host tools of buildtools, which are installed in extract.

```
$ if [[ "\${YOCTO_BUILDTOOLS}" ]]; then
>     source yocto/buildtools/environment-setup-* || return 1
> fi
```

Setup yocto build environment.  The build directory is prepared by
bitbake-setup in extract.

```
$ source yocto/build/init-build-env || return 1
```

Create auto.conf, which holds the settings of this build environment.
It is written from scratch, since the build directory may be the one a
setup before has left.  MACHINE and DISTRO are not set here, since they
come from the fragments chosen in extract.

```
$ rm -f conf/auto.conf
```

{% include setup-auto-conf %}
