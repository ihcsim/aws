FROM golang:1.10.0-alpine3.7
MAINTAINER ivan.sim@cloudreach.com

WORKDIR /go/src/games-agent

ARG AWS_QUEUE_NAME
ENV AWS_QUEUE_NAME ${AWS_QUEUE_NAME}

ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="games-agent" \
      org.label-schema.description="Games agent of the Bionic Kumquat gaming platform" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url="https://bitbucket.org/cloudreach/isim-agileops-training" \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0"

COPY apps/games-agent ./
RUN go install && rm -rf /go/src/games-agent
ENTRYPOINT ["games-agent"]
