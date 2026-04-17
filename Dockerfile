FROM alpine:3.19

RUN apk add --no-cache \
    msmtp \
    ca-certificates \
    curl \
    postfix \
    jq

RUN mkdir -p /etc/msmtp \
    && mkdir -p /var/log/msmtp

COPY msmtprc /etc/msmtprc
COPY msmtp/ /etc/msmtp/
COPY entrypoint.sh /entrypoint.sh

COPY postfix/master.cf /etc/postfix/master.cf
COPY postfix/main.cf /etc/postfix/main.cf

RUN chown -R mail:mail /etc/msmtprc /etc/msmtp /var/log/msmtp \
    && chmod 640 /etc/msmtprc \
    && chmod 750 /etc/msmtp \
    && chmod 755 /etc/msmtp/oauth2_token \
    && chmod 755 /etc/msmtp/msmtp-wrapper.sh \
    && chmod 770 /var/log/msmtp \
    && chmod 755 /entrypoint.sh

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postfix", "start-fg"]
