The settings below are optional.  Each of them is written only when the
variable it comes from is set, so nothing is added when none of them is
and the build runs with the defaults of the release.  They are what
lets a build share the ccache, the downloads and the sstate cache with
the host, which is what makes the builds after the first one fast.

```
$ if [[ "\${YOCTO_CCACHE_DIR}" ]]; then
>     echo "CCACHE_TOP_DIR = \"\${YOCTO_CCACHE_DIR}\"" >> conf/auto.conf
>     echo 'INHERIT += "ccache"' >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_DL_DIR}" ]]; then
>     echo "DL_DIR = \"\${YOCTO_DL_DIR}\"" >> conf/auto.conf
> fi
$ if [[ "\${YOCTO_SSTATE_DIR}" ]]; then
>     echo "SSTATE_DIR = \"\${YOCTO_SSTATE_DIR}\"" >> conf/auto.conf
> fi
```
