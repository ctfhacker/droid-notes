FROM ubuntu:zesty

ARG NDK_VERSION=r15c
ARG BRANCH=android-msm-marlin-3.18-oreo-r6
ARG DEVICE=marlin

ENV ARCH=arm64
ENV CROSS_COMPILE=/gcc-7.1.1/bin/aarch64-linux-gnu-

RUN apt-get update
RUN apt-get install -yq wget curl unzip git build-essential bc

RUN git clone https://github.com/ctfhacker/droid-notes
RUN wget https://buildroot.uclibc.org/downloads/buildroot-2017.02.6.tar.gz && \
    tar zxvf buildroot* && \
    cp droid-notes/buildroot-config buildroot-2017.02.6 && \
    cd buildroot-2017.02.6 && \
    make && \
    cd ..

RUN wget https://releases.linaro.org/components/toolchain/binaries/7.1-2017.08/aarch64-linux-gnu/gcc-linaro-7.1.1-2017.08-i686_aarch64-linux-gnu.tar.xz && \
    xz -d gcc* && \
    tar xvf gcc*tar && \
    rm *tar && \
    mv gcc* gcc-7.1.1

RUN git clone --depth=1 --single-branch -b ${BRANCH} https://android.googlesource.com/kernel/msm

ENV CONFIG=arch/arm64/configs/${DEVICE}_defconfig

WORKDIR /msm
RUN >>${CONFIG} echo "CONFIG_KASAN=y"
RUN >>${CONFIG} echo "CONFIG_KASAN_INLINE=y"
RUN >>${CONFIG} echo "CONFIG_KCOV=y"
RUN >>${CONFIG} echo "CONFIG_SLUB=y"
RUN >>${CONFIG} echo "CONFIG_SLUB_DEBUG=y"
RUN >>${CONFIG} echo "CONFIG_KERNEL_LZ4=n"
RUN make ${DEVICE}_defconfig

RUN make -j$(nproc) CFLAGS="-Wno-error=-misleading-indentation -Wno-error=return-local-addr"
