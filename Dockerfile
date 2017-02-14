FROM amazonlinux:latest

MAINTAINER Tavis <tai@klaviscorp.com>

# timezone:Tokyo
RUN cp /etc/localtime /etc/localtime.org \
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo -e "ZONE=\"Asia/Tokyo\"\nUTC=false" > /etc/sysconfig/clock

RUN yum install -y curl \
                   httpd24 \
                   httpd24-devel \
                   ipa-*font* \
                   libcurl \
                   mod24_ssl \
                   mysql \
                   mysql-* \
                   openssl \
		   php7-pear \
                   php70 \
                   php70-* \
		   gcc \
                   sendmail \
                   sudo \
                   unzip \
                   wget \
                   zip \
 && yum remove -y php70-pecl-imagick-devel

# Install supervisor and modify it to use python2.6 (not AmazonLinux default python2.7)
RUN wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
 && rpm -ivh epel-release-6-8.noarch.rpm \
 && yum update -y epel-release \
 && yum --enablerepo=epel install -y supervisor \
 && sed -i -E 's/(^#!\/usr\/bin\/python$)/#!\/usr\/bin\/python26/g' /usr/bin/supervisor*

# wkhtmltopdf and fluentd
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz \
 && tar xvf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz \
 && mv wkhtmltox/bin/wkhtmltopdf /usr/local/bin && ln -sb /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf \
 && rm -rf wkhtmltox* \
 && curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh \
 && chkconfig httpd on && chkconfig --add td-agent \
 && mkdir /var/log/fluentd/ && chmod 777 /var/log/fluentd/

# add the MongoDB yum repo
RUN echo $'[mongodb-org-3.2]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc' | tee -a /etc/yum.repos.d/mongodb-org-3.2.repo

# update
RUN yum update -y

# Install mongo DB
RUN yum install -y mongodb-org-server \
                   mongodb-org-shell \
                   mongodb-org-tools

RUN mkdir /var/lib/mongo/data && chown mongod:mongod /var/lib/mongo/data
RUN mkdir /var/lib/mongo/log && chown mongod:mongod /var/lib/mongo/log
RUN mkdir /var/lib/mongo/journal && chown mongod:mongod /var/lib/mongo/journal

RUN chkconfig mongod on

# Install mongo for php
RUN pecl7 install mongodb

# Set locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# conf files
COPY docker_build_files/httpd/httpd.conf /etc/httpd/conf/
COPY docker_build_files/php.ini /etc/php.ini

# our application
RUN mkdir /root/git && chown -R apache /root/git

COPY docker_build_files/script/start.sh /home/
COPY docker_build_files/script/setupmongo.js /home/
RUN chmod +x /home/start.sh
