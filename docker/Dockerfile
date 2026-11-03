FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi \
    bc bison flex libssl-dev libelf-dev python3 cpio lz4 kmod git ca-certificates \
    xz-utils zstd perl rsync file && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends clang lld llvm && rm -rf /var/lib/apt/lists/*
