FROM ubuntu:xenial

MAINTAINER benjamin <bejamin@b8tabox.comm>

ENV VER_LIBTORRENT 0.13.6
ENV VER_RTORRENT 0.9.6
USER benjamin

WORKDIR /usr/local/src

# Dependencies to save time and capacity
RUN build_deps="automake build-essential ca-certificates libc-ares-dev libcppunit-dev libtool"; \
    build_deps="${build_deps} libssl-dev libxml2-dev libncurses5-dev pkg-config subversion wget"; \
    set -x && \
    apt-get update && apt-get install -q -y --no-install-recommends ${build_deps} && \
    wget http://curl.haxx.se/download/curl-7.53.0.tar.gz && \
    tar xzvfp curl-7.53.0.tar.gz && \
    cd curl-7.53.0 && \
    ./configure --enable-ares --enable-tls-srp --enable-gnu-tls --with-zlib --with-ssl && \
    make && \
    make install && \
    cd .. && \
    rm -rf curl-* && \
    ldconfig && \
    svn --trust-server-cert checkout https://svn.code.sf.net/p/xmlrpc-c/code/stable/ xmlrpc-c && \
    cd xmlrpc-c && \
    ./configure --enable-libxml2-backend --disable-abyss-server --disable-cgi-server && \
    make && \
    make install && \
    cd .. && \
    rm -rf xmlrpc-c && \
    ldconfig && \
    wget -O libtorrent-$VER_LIBTORRENT.tar.gz https://github.com/rakshasa/libtorrent/archive/$VER_LIBTORRENT.tar.gz && \
    tar xzf libtorrent-$VER_LIBTORRENT.tar.gz && \
    cd libtorrent-$VER_LIBTORRENT && \
    ./autogen.sh && \
    ./configure --with-posix-fallocate && \
    make && \
    make install && \
    cd .. && \
    rm -rf libtorrent-* && \
    ldconfig && \
    wget -O rtorrent-$VER_RTORRENT.tar.gz https://github.com/rakshasa/rtorrent/archive/$VER_RTORRENT.tar.gz && \
    tar xzf rtorrent-$VER_RTORRENT.tar.gz && \
    cd rtorrent-$VER_RTORRENT && \
    ./autogen.sh && \
    ./configure --with-xmlrpc-c --with-ncurses && \
    make && \
    make install && \
    cd .. && \
    rm -rf rtorrent-* && \
    ldconfig && \

# Install global web interface packages
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    apache2-utils \
    libc-ares2 \
    nginx \
    php5-cli \
    php5-fpm \
    mediainfo \
    unrar-free \
    unzip

# Run the wrapper script first
ENTRYPOINT ["/usr/local/bin/docktorrent"]

# Declare ports to expose
EXPOSE 80 

# Declare volumes
VOLUME ["/home/$USER", "/var/log"]
