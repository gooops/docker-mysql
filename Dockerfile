# FROM: 依赖的镜像
FROM gcc_boost_cmake

# MAINTAINER: 个人信息
MAINTAINER ghostman "wang_yongjing@163.com"

# RUN: 执行命令
RUN curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
RUN yum -y install  glibc glibc-devel tar gcc-c++ supervisor ncurses-devel libtool bison bison-devel pwgen bzip2-devel python-devel which wget bzip2 openssh-server

RUN mkdir -p /var/log/supervisor

# ADD: 添加本地文件到容器中，如果是压缩包会在目标目录进行自动解压，如果只想添加文件可以使用 COPY命令
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./mysql-5.7.9.tar.gz /root/tools/
ADD ./install_mysql-5.7.9.sh /root/tools/

# WORKDIR: 当前的工作目录
WORKDIR /root/tools/

RUN sh install_mysql-5.7.9.sh

ADD ./my.cnf /usr/local/mysql/etc/my.cnf
ADD ./supervisord.sh /usr/bin/supervisord.sh

RUN chmod +x /usr/bin/supervisord.sh && rm -rf /root/tools/

# EXPOSE: 公开的端口，会暴露在外的端口
EXPOSE 22 3306

# CMD: 容器启动执行的命令 一个dockerfile只有一个cmd生效。
CMD ["/usr/bin/supervisord.sh"]
