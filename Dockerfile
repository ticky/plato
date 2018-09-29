FROM ubuntu:12.04

ENV DEBIAN_FRONTEND noninteractive

# Install system dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        curl \
        git \
        libtool \
        automake \
        cmake \
        ragel \
        zlib1g-dev \
        libjpeg8-dev \
        libjbig2dec0-dev \
        gcc-arm-linux-gnueabihf \
        g++-arm-linux-gnueabihf \
        build-essential \
        pkg-config \
        wget \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rustup and a Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && ~/.cargo/bin/rustup target add arm-unknown-linux-gnueabihf

# Pre-configure the Rust toolchain
RUN echo $'[target.arm-unknown-linux-gnueabihf]\n\
linker = "arm-linux-gnueabihf-gcc"\n\
rustflags = ["-C", "target-feature=+v7,+vfp3,+a9,+neon"]' > ~/.cargo/config

# Add the toolchain to the container's PATH
ENV PATH="~/.cargo/bin:${PATH}"

WORKDIR /src
CMD ["/bin/bash"]
