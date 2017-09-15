#!/bin/bash

if [ -n "${VNC_PASSWORD}" ]; then
    echo -n "${VNC_PASSWORD}" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
fi

nginx -c /etc/nginx/nginx.conf
exec /bin/tini -- /usr/bin/supervisord -n
