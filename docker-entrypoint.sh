#!/bin/bash

# dump env for cronjobs
printenv | grep -v "no_proxy" >> /etc/environment

# launch all services through supervisor
/usr/bin/supervisord
