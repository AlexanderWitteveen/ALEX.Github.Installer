FROM alpine:3.15

COPY entrypoint.sh /entrypoint.sh
COPY basescript.sh /basescript.sh
COPY basescript.ps1 /basescript.ps1

RUN apk add bash zip

ENTRYPOINT ["/entrypoint.sh"]
