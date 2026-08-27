Clone poky repository.

```
$ git clone -b ${YOCTO_BRANCH:-master} https://git.yoctoproject.org/poky
{% if "${YOCTO_REV:-}" %}
$ git -C poky checkout ${YOCTO_REV}
{% endif %}
```

Install buildtools into poky/buildtools when YOCTO_BUILDTOOLS is set.
It provides the host tools of the versions the release needs, for a
build host that has them too old or does not have them at all.

```
$ if [[ "\${YOCTO_BUILDTOOLS}" ]]; then
>     poky/scripts/install-buildtools \${YOCTO_BUILDTOOLS_OPTS}
> fi
```
