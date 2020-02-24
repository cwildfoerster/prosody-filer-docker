FROM alpine:latest

LABEL maintainer "Constantin Wildförster <constantin@wildfoerster.org>"

ENV PROSODY_FILER_VERSION 1.0.1

ENV SECRET ""
ENV HTTP_UPLOAD_SUB_DIR "upload/"

RUN mkdir -p /prosody-filer/uploads

COPY config.toml /prosody-filer/config.toml
COPY docker-entrypoint.sh /docker-entrypoint.sh

ADD https://github.com/ThomasLeister/prosody-filer/releases/download/v${PROSODY_FILER_VERSION}/prosody-filer /prosody-filer/prosody-filer

RUN chmod +x /docker-entrypoint.sh && chmod +x /prosody-filer/prosody-filer

WORKDIR /prosody-filer
VOLUME [ "/prosody-filer/uploads" ]

EXPOSE 5050

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ "/prosody-filer/prosody-filer", "-config", "/prosody-filer/config.toml" ]
