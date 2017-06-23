FROM buildpack-deps:scm AS scm

WORKDIR /data
RUN git clone https://github.com/ethereum/go-ethereum

FROM alpine:3.5 AS build

COPY --from=scm /data/go-ethereum /go-ethereum
RUN \
  apk add --update git go make gcc musl-dev linux-headers && \
  (cd go-ethereum && make all)

FROM bash

COPY --from=build /go-ethereum/build/bin/* /usr/local/bin/
