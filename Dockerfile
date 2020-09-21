##
#docker build . -t rustapp
#docker build . -t rustapp --build-arg name=appserver
#docker run --rm -it rustapp
#docker run --rm -it rustapp ldd /home/rustapp/app_exe/appserver

#dev
FROM rust_musl AS builder

# Cargo.toml package name
ARG name=appserver 

#add build time depends 
#RUN apk  add --no-cache  packagename 

#build dep
WORKDIR /usr/src/rustapp/cargo_dir
COPY Cargo.toml Cargo.toml
RUN cargo build --release --target x86_64-unknown-linux-musl
RUN rm -f target/x86_64-unknown-linux-musl/release/deps/"${name}"*

#build app
COPY src src
RUN cargo build --release --target x86_64-unknown-linux-musl

#rust app deploy
FROM alpine:latest

# Cargo.toml package name
ARG name=appserver 

RUN addgroup -g 1000 rustapp
RUN adduser -D -s /bin/sh -u 1000 -G rustapp rustapp

WORKDIR /home/rustapp/app_exe

#add runtime depends  
#RUN apk  add --no-cache  packagename 

#copy bin and resources
COPY --from=builder /usr/src/rustapp/cargo_dir/target/x86_64-unknown-linux-musl/release/"${name}" ./appexe

RUN chown  -R rustapp:rustapp . 

USER rustapp

CMD ["./appexe"]