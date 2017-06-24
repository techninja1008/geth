FROM buildpack-deps:scm AS scm

WORKDIR /data
RUN git clone https://github.com/ethereum/go-ethereum

FROM alpine:3.5

COPY --from=scm /data/go-ethereum /go-ethereum
RUN \
  apk add --update git go make gcc musl-dev linux-headers bash && \
  (cd go-ethereum && make all)                                 && \
  cp go-ethereum/build/bin/* /usr/local/bin/                   && \
  apk del git go make gcc musl-dev linux-headers               && \
  rm -rf /go-ethereum && rm -rf /var/cache/apk/*

EXPOSE 8545
EXPOSE 30303
EXPOSE 30303/udp

CMD ["/bin/bash"]
