The settings below are optional.  Each of them is written only when the
variable it comes from is set, so nothing is added when none of them is
and the build runs with the defaults of the release.  They are what
lets a build share the ccache, the downloads and the sstate cache with
the host, which is what makes the builds after the first one fast, or
fetch the sources and the sstate objects from mirrors that already hold
them.

```
$ if [[ "\${YOCTO_BB_GENERATE_MIRROR_TARBALLS}" ]]; then
>     echo "BB_GENERATE_MIRROR_TARBALLS = \"\${YOCTO_BB_GENERATE_MIRROR_TARBALLS}\"" >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_CCACHE_DIR}" ]]; then
>     echo "CCACHE_TOP_DIR = \"\${YOCTO_CCACHE_DIR}\"" >> conf/auto.conf
>     echo 'INHERIT += "ccache"' >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_DL_DIR}" ]]; then
>     echo "DL_DIR = \"\${YOCTO_DL_DIR}\"" >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_SOURCE_MIRROR_URL}" ]]; then
>     echo "SOURCE_MIRROR_URL = \"\${YOCTO_SOURCE_MIRROR_URL}\"" >> conf/auto.conf
>     echo 'INHERIT += "own-mirrors"' >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_SSTATE_DIR}" ]]; then
>     echo "SSTATE_DIR = \"\${YOCTO_SSTATE_DIR}\"" >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_SSTATE_MIRRORS}" ]]; then
>     echo "SSTATE_MIRRORS = \"\${YOCTO_SSTATE_MIRRORS}\"" >> conf/auto.conf
> fi
```
