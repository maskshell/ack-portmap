FROM alpine AS downloader

ARG TARGETOS=linux
ARG TARGETARCH
ARG VERSION=1.3.0

RUN apk add --no-cache wget

RUN wget https://github.com/containernetworking/plugins/releases/download/v${VERSION}/cni-plugins-${TARGETOS}-${TARGETARCH}-v${VERSION}.tgz \
         -O /cni-plugins.tgz && \
    tar -xzf /cni-plugins.tgz ./portmap -C /

FROM busybox

COPY --from=downloader /portmap /
