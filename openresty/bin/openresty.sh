#! /bin/bash

workdir="/opt/openresty/services"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi

if [ ! -d ${workdir}/logs ]; then
    mkdir -p ${workdir}/logs
fi

cd ${workdir}

if [ "$1"x = "start"x ] 
then
    echo starting...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf
fi

if [ "$1"x = "reload"x ] 
then
    echo reloading...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf -s reload
fi

if [ "$1"x = "stop"x ] 
then
    echo stopping...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf -s stop
fi
