FROM alpine:3.6
LABEL maintainer="Roman Volosatovs <rvolosatovs@riseup.net>"

ARG PROTOBUF_VERSION=3.3.1
ARG SWIFT_GRPC_VERSION=0.1.13

ADD resources/ld_library_path.patch /

RUN apk add --no-cache build-base curl automake autoconf libtool && \
    curl -L https://github.com/rvolosatovs/docker-alpine-swift-protobuf/releases/download/${SWIFT_GRPC_VERSION}/export-lib-${SWIFT_GRPC_VERSION}.tar | tar xv -C / && \
    curl -L https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz && \
    cd /protobuf-${PROTOBUF_VERSION} && \
        autoreconf -f -i -Wall,no-obsolete && \
        (cd ./src/google/protobuf/compiler/ && patch < /ld_library_path.patch) && \
        rm -rf autom4te.cache config.h.in~ && \
        ./configure --prefix=/usr --enable-static=no && \
        make -j8 && make install && \
        rm -rf `pwd` && cd / && \
    apk del build-base curl automake autoconf libtool && \
    find /usr/lib -name "*.a" -or -name "*.la" -delete && \
    apk add --no-cache libstdc++ && \
    rm /ld_library_path.patch

ENTRYPOINT ["/usr/bin/protoc"]
