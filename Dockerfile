FROM alpine:3.13

LABEL maintainer="kagbe.leviy@gmail.com"

EXPOSE 80 443

# Install some tools in the container and generate self-signed SSL certificates.
# Packages are listed in alphabetical order, for ease of readability and ease of maintenance.
RUN     apk update \
    &&  apk add apache2-utils bash bind-tools busybox-extras curl ethtool git \
                iperf3 iproute2 iputils jq yq lftp mtr mysql-client \
                netcat-openbsd net-tools nginx nmap nmap-scripts nmap-ncat \
                openssh-client openssl perl-net-telnet postgresql-client procps \
                rsync socat tcpdump tshark wget kafkacat fping drill \
    &&  mkdir /data \
    &&  chmod 777 /data \
    &&  mkdir /certs \
    &&  chmod 700 /certs \
    &&  openssl req \
        -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout /certs/server.key -out /certs/server.crt -subj '/CN=localhost'

COPY index.html /data/

# Copy a custom nginx.conf with log files redirected to stderr and stdout
COPY nginx.conf /etc/nginx/nginx.conf

COPY docker-entrypoint.sh /


# Run the startup script as ENTRYPOINT, which does few things and then starts nginx.
ENTRYPOINT ["/docker-entrypoint.sh"]


# Start nginx in foreground:
CMD ["nginx", "-g", "daemon off;"]
