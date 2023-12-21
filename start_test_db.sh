#!/bin/bash
mysql_ready() {
    mysql -e "select 1" > /dev/null 2>&1
}

echo "starting tmpfs mysql server, creating test database"
mkdir /dev/shm/mysql/
cp -R /var/lib/mysql/* /dev/shm/mysql/
chown mysql:mysql -R /dev/shm/mysql/
mkdir -p /run/mysqld && chmod a+w /run/mysqld -R

nohup /usr/sbin/mysqld --user=mysql > /dev/null &
if [ $? -ne 0 ]; then
    echo "db start failed"
    cat /var/log/mysql/error.log
fi

start_time="$(date -u +%s)"
while !(mysql_ready)
do
    sleep 0.2
    end_time="$(date -u +%s)"
    elapsed="$(($end_time-$start_time))"
    if (( $elapsed > 10 )); then
      echo "test db start failed - exiting"
      cat /var/log/mysql/error.log
      exit
    fi

    echo "waiting for mysql ... $elapsed seconds"
done

mysql -e "CREATE DATABASE test"
#for some reason the config entry is ignored, workaround
mysql -e 'set global sql_mode=NO_ENGINE_SUBSTITUTION'
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''";
mysql -e "flush privileges"
/etc/init.d/redis-server start
