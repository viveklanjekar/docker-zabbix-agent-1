FROM centos:centos7
MAINTAINER Przemyslaw Ozgo linux@ozgo.info

ENV ZABBIX_VERSION=3.0.1 \
    ZABBIX_SERVER=127.0.0.1 \
    HOSTNAME=zabbix.agent \
    HOST_METADATA=zabbix.agent \
    CONFIG_FILE=/usr/local/etc/zabbix_agentd.conf

RUN \
  yum clean all && yum makecache && \
  yum install --nogpgcheck -y svn automake gcc make iproute && \
  svn co svn://svn.zabbix.com/tags/${ZABBIX_VERSION} /usr/local/src/zabbix && \
  cd /usr/local/src/zabbix && \
  ./bootstrap.sh && \
  ./configure --enable-agent && \
  make install && \
  rpm -e --nodeps make gcc && \
  useradd -G wheel zabbix && \
  rm -rf  /usr/local/src/zabbix && \
  yum install -y sudo nc curl && \
  curl -kLs http://stedolan.github.io/jq/download/linux64/jq -o /usr/bin/jq && \
  chmod +x /usr/bin/jq && \
  echo "zabbix ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  yum remove -y svn automake && \
  yum clean all

COPY container-files /

RUN chown -R zabbix:wheel /usr/local/etc/

USER zabbix

EXPOSE 10050

ENTRYPOINT ["/bootstrap.sh"]
