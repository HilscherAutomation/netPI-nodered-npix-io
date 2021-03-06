#use armv7hf compatible OS
FROM balenalib/armv7hf-debian:buster-20191223

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \ 
      version="V1.1.0" \
      description="Node-RED with dio nodes to communicate with NIOT-E-NPIX-4DI4DO extension module"

#version
ENV HILSCHERNETPI_NODERED_NPIX_IO_VERSION 1.1.0

#copy files
COPY "./init.d/*" /etc/init.d/ 
COPY "./node-red-contrib-npix-io/*" /tmp/

#do installation
RUN apt-get update  \
    && apt-get install curl build-essential python-dev \
#install node.js
    && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red@1.0.3 \
#install node
    && mkdir /usr/lib/node_modules/node-red-contrib-npix-io \
    && mv /tmp/npixio.js /tmp/npixio.html /tmp/package.json -t /usr/lib/node_modules/node-red-contrib-npix-io \
    && cd /usr/lib/node_modules/node-red-contrib-npix-io \
    && npm install \
#clean up
    && rm -rf /tmp/* \
    && apt-get remove curl \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#Node-RED Port
EXPOSE 1880

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
