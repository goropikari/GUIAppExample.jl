FROM ubuntu:18.04

RUN apt-get update -y && \
    apt-get install -y sudo wget build-essential git vim ubuntu-mono libxrender1 libxtst6 libxi6

RUN useradd -g users -G sudo -m -s /bin/bash ubuntu && \
    echo 'ubuntu:foobar' | chpasswd
RUN echo 'Defaults visiblepw'            >> /etc/sudoers
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV JULIA_MINOR_VERSION=1.4
ENV JULIA_PATCH_VERSION=0
RUN cd /usr/local && \
    wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    tar xvf julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    rm julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    ln -s $(pwd)/julia-$JULIA_MINOR_VERSION.$JULIA_PATCH_VERSION/bin/julia /usr/bin/julia


# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER ubuntu
WORKDIR /home/ubuntu
