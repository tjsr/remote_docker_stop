FROM docker:stable

LABEL author="Tim Rowe <tim@tjsr.id.au>"

RUN apk --no-cache add openssh-client

COPY /docker-stop-entrypoint.sh /docker-stop-entrypoint.sh
RUN chmod +x /docker-stop-entrypoint.sh

ENTRYPOINT ["/docker-stop-entrypoint.sh"]