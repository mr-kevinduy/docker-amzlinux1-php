FROM amazonlinux:1

MAINTAINER KevinDuy <mr.kevinduy@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Install packages
COPY ./serve.sh /install/serve.sh
COPY ./72.sh /install/72.sh

RUN chmod +x /install/*.sh

RUN /bin/bash /install/72.sh

WORKDIR /var/www/app

EXPOSE 80 443 9000
