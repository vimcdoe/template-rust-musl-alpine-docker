#
#docker build . -t rust_musl -f rust_musl.dockerfile 
FROM alpine:latest AS rust_musl

#switch apk sources
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache \
    ca-certificates \
    gcc \
    git

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.46.0 \
    RUSTUP_VERSION=1.22.1 \
    RUSTUP_SHA256SUM=cee31c6f72b953c6293fd5d40142c7d61aa85db2a5ea81b3519fe1b492148dc9

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-musl/rustup-init"; \
    wget "$url"; \
    echo "${RUSTUP_SHA256SUM} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host x86_64-unknown-linux-musl; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

#switch crates index
RUN echo '[source.crates-io]' > ${CARGO_HOME}/config; \
    echo 'replace-with = "tuna"' >> ${CARGO_HOME}/config; \
    echo '' >> ${CARGO_HOME}/config; \
    echo '[source.tuna]' >> ${CARGO_HOME}/config; \
    echo 'registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"' >> ${CARGO_HOME}/config; 

WORKDIR /usr/src/rustapp

#crates index init
RUN USER=root cargo new cargo_dir && \
    cd cargo_dir && \
    echo 'spin = "0.5.2"' >> Cargo.toml && \
    cargo build && \
    cargo clean
