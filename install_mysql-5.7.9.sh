#!/bin/bash
set -x
source /etc/profile
grep "^mysql:" /etc/passwd &> /dev/null || groupadd mysql && useradd -g mysql -s /sbin/nologin mysql

echo -e '/usr/local/gcc/lib\n/usr/local/gcc/lib64' > /etc/ld.so.conf.d/gcc4.9.conf && ldconfig
yum install openssh-server

if [ ! -d mysql-5.7.9 ];then
 tar xzf mysql-5.7.9.tar.gz
fi
cd mysql-5.7.9
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.7.9 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=/data/mysql/data \
-DSYSCONFDIR=/usr/local/mysql/etc/ \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_EXTRA_CHARSETS=complex \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_unicode_ci \
-DWITH_DEBUG=0
#CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
#if [ $CPU_NUM -gt 1 ];then
# make -j$CPU_NUM
#else
 make
#fi
make install

echo "PATH=\$PATH:/usr/local/mysql/bin" >> /etc/profile && . /etc/profile
ln -sf /usr/local/mysql-5.7.9 /usr/local/mysql
rm -rf /etc/my.cnf

mkdir -p /usr/local/mysql/etc/
mkdir -p /data/mysql/data
mkdir -p /data/mysql/logs

chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /data/mysql/data
chown -R mysql:mysql /data/mysql/log
\cp -f /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/usr/local/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/data/mysql/data#' /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld
/usr/local/mysql/bin/mysqld --initialize-insecure --datadir=/data/mysql/data --basedir=/usr/local/mysql --user=mysql
