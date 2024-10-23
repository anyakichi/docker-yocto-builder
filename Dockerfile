ARG ubuntu_version="latest"
FROM ubuntu:${ubuntu_version}

# https://www.yoctoproject.org/docs/2.7/ref-manual/ref-manual.html
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
        gcc-multilib \
        git \
        iputils-ping \
        libacl1 \
        liblz4-tool \
        libsdl1.2-dev \
        locales \
        mesa-common-dev \
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
        xterm \
        xz-utils \
        zstd \
        gosu \
        language-pack-en \
        sudo \
        tmux \
    && for i in libegl1-mesa pylint pylint3; do \
        if apt-cache show "$i" >/dev/null 2>&1; then \
            DEBIAN_FRONTEND=noninteractive apt-get install -y $i; \
        fi \
       done \
    ; if ! command -v pylint3 >/dev/null 2>&1; then \
        ln -s /usr/bin/pylint /usr/bin/pylint3; \
      fi \
    ; rm -rf /var/lib/apt/lists/*

RUN update-locale LANG=en_US.UTF-8

ADD http://git.yoctoproject.org/cgit/cgit.cgi/poky/plain/scripts/oe-git-proxy /usr/local/bin/
RUN chmod 755 /usr/local/bin/oe-git-proxy

RUN \
    useradd -ms /bin/bash builder \
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

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/buildenv-entrypoint.sh"]
CMD ["/bin/bash"]

ARG yocto_branch
ENV \
    LANG=en_US.UTF-8 \
    YOCTO_BITBAKE_TARGET=core-image-minimal \
    YOCTO_BRANCH=${yocto_branch} \
    YOCTO_CCACHE_DIR="" \
    YOCTO_DL_DIR="" \
    YOCTO_MACHINE="" \
    YOCTO_SSTATE_DIR=""
