#!/bin/bash
echo "stopping  mysql server"
killall mysqld
/etc/init.d/redis-server stop
