# initialize from the image

FROM debian:9

ARG TOOLCHAIN_FLAVOR=linux
ENV TOOLCHAIN_FLAVOR=$TOOLCHAIN_FLAVOR

# install build tools and dependencies

RUN apt-get update && apt-get install -y \
    build-essential wget git python3-pip gcc-multilib

# install dependencies from toolchain source build

RUN if [ "$TOOLCHAIN_FLAVOR" = "src" ]; then \
        apt-get install -y autoconf autogen bison dejagnu \
                           flex flip gawk git gperf gzip nsis \
                           openssh-client p7zip-full perl python-dev \
                           libisl-dev tcl tofrodos zip \
                           texinfo texlive texlive-extra-utils; \
    fi

# download toolchain

ENV TOOLCHAIN_SHORTVER=7-2018q2
ENV TOOLCHAIN_LONGVER=gcc-arm-none-eabi-7-2018-q2-update
ENV TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/$TOOLCHAIN_SHORTVER/$TOOLCHAIN_LONGVER-$TOOLCHAIN_FLAVOR.tar.bz2

# extract toolchain

RUN cd /opt && wget $TOOLCHAIN_URL && tar xfj $TOOLCHAIN_LONGVER-$TOOLCHAIN_FLAVOR.tar.bz2

# build toolchain (if required)

RUN if [ "$TOOLCHAIN_FLAVOR" = "src" ]; then \
        pushd /opt/$TOOLCHAIN_LONGVER ; \
        ./install-sources.sh --skip_steps=mingw32 ; \
        ./build-prerequisites.sh --skip_steps=mingw32 ; \
        ./build-toolchain.sh --skip_steps=mingw32,manual ; \
        popd ; \
    fi

# install additional tools

RUN apt-get install -y protobuf-compiler libprotobuf-dev

# setup toolchain

ENV PATH=/opt/$TOOLCHAIN_LONGVER/bin:$PATH

# install python dependencies

RUN pip3 install scons trezor

# workarounds for weird default install

RUN ln -s python3 /usr/bin/python
RUN ln -s dist-packages /usr/local/lib/python3.5/site-packages
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
