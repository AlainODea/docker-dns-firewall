FROM alpine:latest

MAINTAINER Alain O'Dea <alain.odea@gmail.com>

RUN apk --update add bind

EXPOSE 53

CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
