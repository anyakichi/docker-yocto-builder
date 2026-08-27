ARG base="ubuntu"
FROM ${base}

# https://docs.yoctoproject.org/ref-manual/system-requirements.html#ubuntu-and-debian
RUN \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        chrpath \
        cpio \
        debianutils \
        diffstat \
        file \
        gawk \
        gcc \
        git \
        iputils-ping \
        libacl1 \
        locales \
        python3 \
        python3-git \
        python3-jinja2 \
        python3-pexpect \
        python3-pip \
        python3-subunit \
        socat \
        texinfo \
        unzip \
        wget \
        xz-utils \
        zstd \
        gosu \
        language-pack-en \
        sudo \
        tmux \
    && for i in \
        gcc-multilib \
        libcrypt-dev \
        libegl1-mesa \
        liblz4-tool \
        libsdl1.2-dev \
        mesa-common-dev \
        pylint \
        pylint3 \
        python3-websockets \
        xterm \
       ; do \
        if apt-cache show "$i" >/dev/null 2>&1; then \
            DEBIAN_FRONTEND=noninteractive apt-get install -y $i; \
        fi \
       done \
    ; if ! command -v pylint3 >/dev/null 2>&1; then \
        ln -s /usr/bin/pylint /usr/bin/pylint3; \
      fi \
    ; rm -rf /var/lib/apt/lists/*

RUN update-locale LANG=en_US.UTF-8

ADD https://git.openembedded.org/openembedded-core/plain/scripts/oe-git-proxy /usr/local/bin/
RUN chmod 755 /usr/local/bin/oe-git-proxy

# Recent ubuntu images ship a default user that occupies uid 1000, which
# the entrypoint would otherwise fail to give to builder.
RUN \
    if getent passwd ubuntu >/dev/null; then userdel -r ubuntu; fi \
    && useradd -ms /bin/bash builder \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder
RUN \
    echo '. <(buildenv init)' >> ~/.bashrc \
    && echo '[[ ${NO_PROXY} ]] || export NO_PROXY=$no_proxy' >> ~/.bashrc \
    && echo '[[ ${http_proxy} ]] && export GIT_PROXY_COMMAND=oe-git-proxy' >> ~/.bashrc \
    && git config --global user.email "builder@yocto" \
    && git config --global user.name "Yocto Builder" \
    && git config --global url."https://github.com/".insteadOf git://github.com/

USER root
WORKDIR /home/builder

COPY buildenv/entrypoint.sh /buildenv-entrypoint.sh
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

# The documents of extract and setup are chosen by this command.
COPY bin/yocto-flavor /usr/local/bin/

# The documents that extract and setup include are commands of buildenv
# as well, but they are not meant to be run by hand.
RUN \
    sed -i \
        -e 's/^#ALIASES=.*/ALIASES="extract setup build"/' \
        -e 's/^#DOTCMDS=.*/DOTCMDS=setup/' \
      /etc/buildenv.conf

ENTRYPOINT ["/buildenv-entrypoint.sh"]
CMD ["/bin/bash"]

ARG yocto_branch
ENV \
    LANG=en_US.UTF-8 \
    YOCTO_BB_GENERATE_MIRROR_TARBALLS="" \
    YOCTO_BITBAKE_TARGET=core-image-minimal \
    YOCTO_BRANCH=${yocto_branch} \
    YOCTO_BUILDTOOLS="" \
    YOCTO_BUILDTOOLS_OPTS="" \
    YOCTO_CCACHE_DIR="" \
    YOCTO_CONFIG="" \
    YOCTO_CONFIG_NAME="" \
    YOCTO_DISTRO="" \
    YOCTO_DL_DIR="" \
    YOCTO_MACHINE="" \
    YOCTO_REV="" \
    YOCTO_SOURCE_MIRROR_URL="" \
    YOCTO_SSTATE_DIR="" \
    YOCTO_SSTATE_MIRRORS=""
