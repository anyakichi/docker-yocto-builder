Clone bitbake repository, which provides bitbake-setup.

```
$ git clone https://git.openembedded.org/bitbake
```

Collect the layers of the release with bitbake-setup and prepare the
build directory.  They are placed under ./yocto, while site.conf, the
downloads and the sstate cache are placed in the current directory and
shared between the setups.

```
$ ./bitbake/bin/bitbake-setup \
>     --setting default top-dir-name . \
>     init --non-interactive --setup-dir-name yocto \
>     ${YOCTO_CONFIG:-poky-${YOCTO_BRANCH:-master}} \
>     ${YOCTO_CONFIG_NAME:-poky} \
>     distro/${YOCTO_DISTRO:-poky} \
>     machine/${YOCTO_MACHINE:-qemux86-64}
```

Install buildtools into yocto/buildtools when YOCTO_BUILDTOOLS is set.
It provides the host tools of the versions the release needs, for a
build host that has them too old or does not have them at all.  The
installer comes with the layers collected above.

```
$ if [[ "\${YOCTO_BUILDTOOLS}" ]]; then
>     ./bitbake/bin/bitbake-setup \
>         install-buildtools --setup-dir "\${PWD}/yocto" \${YOCTO_BUILDTOOLS_OPTS}
> fi
```
