#
#docker build . -t rust_musl -f rust_musl.dockerfile 
FROM alpine:3.12.1 AS rust_musl

#  arg
ARG RUST_VERSION=1.47.0
ARG RUSTUP_VERSION=1.22.1
ARG CRATES_SOURCE_NAME=rustcc
ARG CRATES_SOURCE_URL=git://crates.rustcc.com/crates.io-index

#switch apk sources
RUN sed -i 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache \
    ca-certificates \
    gcc \
    git

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH 

RUN set -eux; \
    RUSTUP_DIST_SERVER="http://mirrors.rustcc.cn"; \
    RUSTUP_UPDATE_ROOT="http://mirrors.rustcc.cn/rustup"; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-musl/rustup-init"; \
    wget -c "$url"; \
    sha256_url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-musl/rustup-init.sha256"; \
    wget -c "${sha256_url}"; \
    echo "$(cat rustup-init.sha256 |cut -d ' ' -f 1) *rustup-init" | sha256sum -c -; \
    rm rustup-init.sha256; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host x86_64-unknown-linux-musl; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

#switch crates index
RUN echo '[source.crates-io]' > ${CARGO_HOME}/config; \
    echo 'registry = "https://github.com/rust-lang/crates.io-index"' >> ${CARGO_HOME}/config; \
    echo 'replace-with = "'"${CRATES_SOURCE_NAME}"'"' >> ${CARGO_HOME}/config; \
    echo '' >> ${CARGO_HOME}/config; \
    echo '[source.'"${CRATES_SOURCE_NAME}"']' >> ${CARGO_HOME}/config; \
    echo 'registry = "'"${CRATES_SOURCE_URL}"'"' >> ${CARGO_HOME}/config; 

WORKDIR /usr/src/rustapp

#crates index init
RUN USER=root cargo new cargo_dir && \
    cd cargo_dir && \
    echo 'anyhow = "*"' >> Cargo.toml && \
    cargo build && \
    cargo clean
