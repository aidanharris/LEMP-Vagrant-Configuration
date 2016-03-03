#!/bin/sh
# Starts services on-boot after the shared folder has been mounted
/etc/init.d/mysql start
/etc/init.d/nginx start
