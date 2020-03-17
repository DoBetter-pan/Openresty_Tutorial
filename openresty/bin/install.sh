#! /bin/bash

workdir="/opt/openresty/services"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi

if [ ! -d ${workdir}/logs ]; then
    mkdir -p ${workdir}/logs
fi

cp conf /opt/openresty/services -fr
cp src /opt/openresty/services -fr
cp bin /opt/openresty/services -fr

