# This is forked image based on the original project:
# https://github.com/gcavalcante8808/docker-krb5-server

# BUILD COMMAND
# docker build --no-cache --rm -t vpms3.azurecr.io/auth/kerberos-demo .
# 
# RUN JUST THIS CONTAINER FROM ROOT (folder with .sln file):
# docker build --no-cache --rm -f Demo/Misc/Kerberos/Dockerfile -t vpms3.azurecr.io/auth/kerberos-demo:latest .
#
# RUN COMMAND
# docker network create --subnet=172.20.0.0/16 contoso.com
# docker run --name kerberos_authservice --rm --net contoso.com -d -p 88:88 -p 464:464 -p 749:749 vpms3.azurecr.io/auth/kerberos-demo:latest
FROM alpine
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="gcavalcante8808 <https://github.com/gcavalcante8808>"
LABEL maintainer="Alex Soh <alex.soh@bertelsmann.de>"
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Kerberos - Alpine" \
    org.label-schema.description="Provides a Docker image for Kerberos DC on Alpine Linux." \
    org.label-schema.license=MIT \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/gcavalcante8808/docker-krb5-server \
    org.label-schema.schema-version="1.0"

ENV NETBIOS_NAME="krb5" \
    KRB5_REALM="KRB5.CONTOSO.COM" \
    KRB5_KDC="localhost" \
    KRB5_PASS="Password!234" \
    KRB5_TZ="UTC"

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --no-cache upgrade && \
    apk add --update --no-cache vim krb5-server krb5 \
    bind bind-libs bind-tools supervisor tzdata tini
RUN ln -sf /proc/1/fd/1 /var/log/krb5kdc.log && \
    ln -sf /proc/1/fd/1 /var/log/kadmin.log && \
    ln -sf /proc/1/fd/1 /var/log/krb5lib.log
ADD supervisord.conf /etc/supervisord.conf
ADD entrypoint.sh /

VOLUME /var/lib/krb5kdc
EXPOSE 749 464 88
ENTRYPOINT ["/sbin/tini", "-v", "/entrypoint.sh"]
