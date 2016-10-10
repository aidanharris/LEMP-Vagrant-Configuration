#!/bin/sh
# Starts services on-boot after the shared folder has been mounted
systemctl start mysql
systemctl start nginx
