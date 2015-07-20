FROM ubuntu:14.04
MAINTAINER IBM

RUN apt-get update \
	&& apt-get install -y wget \
    && apt-get install -y curl supervisor openssh-server \	
    && rm -rf /var/lib/apt/lists/*

# Install JRE
ADD dependencies/ibm-java-jre-7.1-2.10-x86_64-archive.bin /tmp/java.bin
RUN chmod +x /tmp/java.bin
RUN /tmp/java.bin -i silent -DUSER_INSTALL_DIR=/opt/ibm/java \
  	&& rm /tmp/java.bin
ENV JAVA_HOME /opt/ibm/java
ENV PATH $JAVA_HOME/jre/bin:$PATH
COPY dependencies/license-check /opt/ibm/docker/

# Install WebSphere Liberty
ADD dependencies/wlp-runtime-8.5.5.5.jar /tmp/wlp-runtime.jar
RUN /opt/ibm/java/jre/bin/java -jar /tmp/wlp-runtime.jar --acceptLicense /opt/ibm \
    && rm /tmp/wlp-runtime.jar
ENV PATH /opt/ibm/wlp/bin:$PATH

# SSH
RUN mkdir -p /var/run/sshd &&\
    mkdir -p /root/.ssh/ &&\
    mkdir -p /root/sshkey/ &&\
    touch /root/.ssh/authorized_keys &&\
    sed -i 's/session \+required \+pam_loginuid\.so/session optional pam_loginuid.so/' /etc/pam.d/sshd &&\
    sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config &&\
    sed -i 's/.*ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config

# Create 'worklight' profile
RUN /opt/ibm/wlp/bin/server create worklight \
    && rm -rf /opt/ibm/wlp/usr/servers/.classCache \
    && rm -rf /opt/ibm/wlp/usr/servers/worklight/apps/*
COPY mfpf-libs/analytics.ear /opt/ibm/wlp/usr/servers/worklight/apps/
COPY server/env /opt/ibm/wlp/usr/servers/worklight/
COPY server/config/logs/50-default.conf /etc/rsyslog.d/
COPY server/config/logs/rsyslog.conf /etc/supervisor/conf.d/
COPY server/bin/liberty-run /opt/ibm/wlp/bin/
COPY server/bin/mfp-init /opt/ibm/wlp/bin/
COPY server/bin/wlpropsparser.py /opt/ibm/wlp/bin/
COPY server/bin/liberty.conf /etc/supervisor/conf.d/
COPY server/bin/sshd.conf /etc/supervisor/conf.d/
COPY server/bin/run_supervisord /root/bin/
COPY server/bin/supervisord.conf /etc/supervisor/

COPY usr/security /opt/ibm/wlp/usr/servers/worklight/resources/security/
COPY usr/env /opt/ibm/wlp/usr/servers/worklight/
COPY usr/ssh /root/sshkey/

RUN chmod u+x /opt/ibm/docker/license-check \
	&& chmod u+x /opt/ibm/wlp/bin/liberty-run \
    && chmod u+x /opt/ibm/wlp/bin/mfp-init \	
	&& chmod +x /root/bin/run_supervisord \
	&& mkdir /var/log/rsyslog \
    && chown syslog /var/log/rsyslog

ENTRYPOINT ["/bin/sh", "-c" ]
CMD ["/root/bin/run_supervisord"]

COPY usr/config/*.xml /opt/ibm/wlp/usr/servers/worklight/configDropins/overrides/

ENV LICENSE accept
