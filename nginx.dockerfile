FROM node:12.6.0 as intermediate

COPY ./ ./
RUN /bin/sh ./files/prebuild/write-version.sh
RUN /bin/sh ./files/prebuild/build-frontend.sh


FROM staticfloat/nginx-certbot@sha256:113300163d871119a261738964d7d8f24a478a605d56888a82e9f45fb353698d

EXPOSE 80
EXPOSE 443

VOLUME [ "/etc/dh", "/etc/selfsign", "/etc/nginx/conf.d" ]
ENTRYPOINT [ "/bin/bash", "/scripts/odk-setup.sh" ]

RUN apt-get update; apt-get install -y openssl netcat nginx-extras lua-zlib

RUN mkdir -p /etc/selfsign/live/local
COPY files/nginx/odk-setup.sh /scripts

COPY files/local/customssl/*.pem /etc/customssl/live/local/

COPY files/nginx/default /etc/nginx/sites-enabled/
COPY files/nginx/inflate_body.lua /usr/share/nginx
COPY files/nginx/odk.conf.template /usr/share/nginx
COPY files/nginx/run_certbot.sh /scripts/
COPY --from=intermediate client/dist/ /usr/share/nginx/html
COPY --from=intermediate /tmp/version.txt /usr/share/nginx/html/

