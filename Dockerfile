FROM gcc:13.2.0-bookworm AS verilator
WORKDIR /verilator_src
RUN apt update && \
    apt install -y \
    bison \
    flex \
    g++ \
    gcc  \
    help2man \
    make \
    perl \
    texi2html && \
    curl -OL https://github.com/verilator/verilator/archive/refs/tags/v5.024.tar.gz && \
    tar xf v5.024.tar.gz && \
    cd verilator-5.024 && \
    autoconf && \
    ./configure --prefix=/verilator && \
    make -j`nproc` && make install && \
    rm -rf /var/lib/apt/lists/*

# Install both scala-cli and mill
FROM alpine AS scala_cli
RUN apk add --no-cache curl && \
    curl -fL https://github.com/Virtuslab/scala-cli/releases/latest/download/scala-cli-x86_64-pc-linux.gz | gzip -d > /scala-cli && \
    chmod +x /scala-cli && \
    curl -L https://github.com/com-lihaoyi/mill/releases/download/0.11.7/0.11.7 > /mill && \
    chmod +x /mill


# Place executables into runtime.
# TODO: enable to use those executables from `scratch` image.
# several shared library would be required.
# root@807bf31d643e:/usr/bin# ldd scala-cli
#         linux-vdso.so.1 (0x00007fffffb97000)
#         libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f388a6f6000)
#         libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f388a6f1000)
#         libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f388a6d2000)
#         librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f388a6cd000)
#         libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f3883e1f000)
#         /lib64/ld-linux-x86-64.so.2 (0x00007f388a6ff000)
# and ones linked to verilator.
FROM debian:bookworm
COPY --from=verilator --chmod=0x755 /verilator/bin /usr/bin
COPY --from=verilator /verilator/share /usr/share
COPY --from=scala_cli --chmod=0x755 /scala-cli /usr/bin
COPY --from=scala_cli --chmod=0x755 /mill /usr/bin

# Install requirements to run verilator
# https://verilator.org/guide/latest/install.html#install-prerequisites
RUN apt update && apt install -y \
    ccache \
    g++ \
    help2man \
    libfl-dev \
    libfl2 \
    libgoogle-perftools-dev \
    make \
    mold \
    numactl \
    perl \
    python3 \
    zlib1g \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
