---
layout: post
title: "Using Pinpoint with Docker"
date: 2015-05-05 12:12:07 +0900
categories:
    - Technology
description: How to use Pinpoint with Docker.
keywords: pinpoint, docker
redirect_from: /p/20150505/
twitter_card:
    image: http://yous.be/images/2015/05/05/logo.png
facebook:
    image: http://yous.be/images/2015/05/05/logo.png
---

![Pinpoint](/images/2015/05/05/logo.min.png)

> [**Pinpoint**](https://github.com/pinpoint-apm/pinpoint) is an open source APM
(Application Performance Management) tool for large-scale distributed systems
written in Java.

## Preliminary

In this post, our goal is to run a sample Pinpoint 1.6.x instance with
QuickStart scripts. You can find them on [GitHub](https://github.com/pinpoint-apm/pinpoint/tree/1.6.x/quickstart).
Also note that we're going to use [Docker](https://www.docker.com/).

## Requirements

First things first, install Docker.

``` sh
wget -qO- https://get.docker.com/ | sh
```

You can verify `docker` is installed correctly.

``` sh
sudo docker run hello-world
```

For more details, see the [installation guides](https://docs.docker.com/installation/#installation)
of Docker.

## Look into the Dockerfile

In fact, I already made a Dockerfile for Pinpoint. You can see on
[yous/pinpoint-docker](https://github.com/yous/pinpoint-docker). From now on,
I'll describe the Dockerfile line by line.

<!-- more -->

``` dockerfile
FROM debian
```

[`FROM`](https://docs.docker.com/reference/builder/#from) instruction sets the
base image of the Docker. We use lateste debian image.

``` dockerfile
RUN echo 'deb http://http.debian.net/debian/ wheezy contrib' >> /etc/apt/sources.list
RUN apt-get update
```

[`RUN`](https://docs.docker.com/reference/builder/#run) instruction executes
commands in Docker. We add `http://http.debian.net/debian/ wheezy contrib` to
the `/etc/apt/sources.list` for `java-package` package, and then run
`apt-get update`.

``` dockerfile
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git wget curl procps net-tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y java-package fakeroot
```

In this section, we install basic tools like `git`, `wget`, `curl`. Also
`procps` contains `ps`, `net-tools` contains `netstat` which is used by
QuickStart scripts later.

Note the `DEBIAN_FRONTEND=noninteractive`, this is only for the
`apt-get install` while building a Docker image, and this suppresses warning
messages of `apt-get install`. Also we can set `DEBIAN_FRONTEND` with:

``` dockerfile
ENV DEBIAN_FRONTEND noninteractive
```

But we won't add this line because when `ENV` sets, it will remain even after it
finished the build. This is bad when we run the Docker image by
`docker run -i -t ... bash`, the Docker is interactive, but the
`DEBIAN_FRONTEND` is set wrong. So we'll only set it inline. You can see the
information on [docker/docker#4032](https://github.com/docker/docker/issues/4032).

``` dockerfile
RUN useradd pinpoint -m
```

As [installation guide of Pinpoint](https://github.com/pinpoint-apm/pinpoint/blob/1.6.x/doc/installation.md)
indicates, we need to install JDK 6 and JDK 7+. To install Java, we need a
non-root user. So we add a user `pinpoint` and create its home directory by
passing `-m`. Adding a user is needed to install Java.

``` dockerfile
WORKDIR /home/pinpoint
```

[`WORKDIR`](https://docs.docker.com/reference/builder/#workdir) instruction sets
the working directory for Docker. After this line, any `RUN` instructions are
runned in this working directory.

``` dockerfile
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin
RUN chown pinpoint jdk-6u45-linux-x64.bin
RUN su pinpoint -c 'yes | fakeroot make-jpkg jdk-6u45-linux-x64.bin'
RUN rm jdk-6u45-linux-x64.bin
RUN dpkg -i oracle-j2sdk1.6_1.6.0+update45_amd64.deb
RUN rm oracle-j2sdk1.6_1.6.0+update45_amd64.deb

RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
RUN chown pinpoint jdk-7u79-linux-x64.tar.gz
RUN su pinpoint -c 'yes | fakeroot make-jpkg jdk-7u79-linux-x64.tar.gz'
RUN rm jdk-7u79-linux-x64.tar.gz
RUN dpkg -i oracle-j2sdk1.7_1.7.0+update79_amd64.deb
RUN rm oracle-j2sdk1.7_1.7.0+update79_amd64.deb
```

Now we install Java SE 6 and then Java SE 7 on the Docker. The `wget` script is
from ["How to automate download and installation of Java JDK on Linux?"](http://stackoverflow.com/a/10959815/3108885).
Running `fakeroot make-jpkg ...` and `dpkg -i ...` installs Java.

``` dockerfile
ENV JAVA_6_HOME /usr/lib/jvm/j2sdk1.6-oracle
ENV JAVA_7_HOME /usr/lib/jvm/j2sdk1.7-oracle
ENV JAVA_HOME /usr/lib/jvm/j2sdk1.7-oracle
```

For the requirements of Pinpoint, we set `JAVA_6_HOME`, `JAVA_7_HOME` and
`JAVA_HOME` environment variables.

``` dockerfile
WORKDIR /usr/local/apache-maven
```

Now we're going to install Maven.

``` dockerfile
ADD http://mirror.apache-kr.org/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz ./
ADD http://www.apache.org/dist//maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz.md5 ./
ADD http://www.apache.org/dist//maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz.asc ./
```

[`ADD`](https://docs.docker.com/reference/builder/#add) instructions copies new
files, directories, or remote file from URL to the specified path. Above lines
just download Maven files from Apache mirror.

``` dockerfile
RUN [ $(md5sum apache-maven-3.2.5-bin.tar.gz | grep --only-matching -m 1 '^[0-9a-f]*') = $(cat apache-maven-3.2.5-bin.tar.gz.md5) ]
```

This matches MD5 hash checksum of `apache-maven-3.2.5-bin.tar.gz` with
`apache-maven-3.2.5-bin-tar.gz.md5`.


``` dockerfile
RUN gpg --keyserver pgp.mit.edu --recv-key BB617866
RUN gpg --verify apache-maven-3.2.5-bin.tar.gz.asc apache-maven-3.2.5-bin.tar.gz
```

This verifies signature for `apache-maven-3.2.5-bin.tar.gz` with
`apache-maven-3.2.5-bin.tar.gz.asc`.

``` dockerfile
RUN tar -xf apache-maven-3.2.5-bin.tar.gz
ENV PATH $PATH:/usr/local/apache-maven/apache-maven-3.2.5/bin
RUN rm apache-maven-3.2.5-bin.tar.gz apache-maven-3.2.5-bin.tar.gz.md5 apache-maven-3.2.5-bin.tar.gz.asc
```

Now we install Maven 3.2.5 on the Docker. Note that we have to add the path of
Maven to the `PATH`.

``` dockerfile
RUN git clone -b 1.6.x https://github.com/pinpoint-apm/pinpoint.git /pinpoint
WORKDIR /pinpoint
RUN mvn install -Dmaven.test.skip=true
```

All requirements are installed, so we clone Pinpoint to the `/pinpoint` and
install it.

``` dockerfile
WORKDIR quickstart/hbase
ADD http://archive.apache.org/dist/hbase/hbase-0.94.25/hbase-0.94.25.tar.gz ./
RUN tar -xf hbase-0.94.25.tar.gz
RUN rm hbase-0.94.25.tar.gz
RUN ln -s hbase-0.94.25 hbase
RUN cp ../conf/hbase/hbase-site.xml hbase-0.94.25/conf/
RUN chmod +x hbase-0.94.25/bin/start-hbase.sh
```

After installation of Pinpoint, we install HBase 0.94.25 as
[`quickstart/bin/start-hbase.sh`](https://github.com/pinpoint-apm/pinpoint/blob/1.6.x/quickstart/bin/start-hbase.sh)
of Pinpoint does it.

## Running Docker

You can pull the Docker image:

``` sh
docker pull yous/pinpoint
```

Then run the image:

``` sh
docker run -i -t yous/pinpoint bash
```

Also if you want to remove the container after Docker exits, use:

``` sh
docker run -i -t --rm yous/pinpoint bash
```

This makes you can check some requirements like `which java`, but you can't run
QuickStart scripts successfully. Since the scripts check the program name in the
result of `netstat`, we should pass some option. See [docker/docker#7276](https://github.com/docker/docker/issues/7276)
for details.

``` sh
docker run -i -t --cap-add SYS_PTRACE yous/pinpoint bash
```

Also, note that we are going to use port 28080, 28081 and 28082 in QuickStart.
So binding a container's port to a specific port is needed. `-p` flag will do
it. See [Linking Containers Together](https://docs.docker.com/userguide/dockerlinks/)
for details.

``` sh
docker run -i -t -p 28080:28080 -p 28081:28081 -p 28082:28082 \
  --cap-add SYS_PTRACE yous/pinpoint bash
```

## QuickStart

We built a Docker image for Pinpoint, so now we can run QuickStart scripts. As
mentioned in [QuickStart](https://github.com/pinpoint-apm/pinpoint/blob/1.6.x/quickstart/README.md)
of Pinpoint, we run several scripts.

### Install & Start HBase

- Download & Start: `quickstart/bin/start-hbase.sh`
- Initialize Tables: `quickstart/bin/init-hbase.sh`

### Start Pinpoint Daemons

- Collector: `quickstart/bin/start-collector.sh`

  ![Running start-collector.sh](/images/2015/05/05/quickstart-start-collector.min.png)
- Web UI: `quickstart/bin/start-web.sh`

  ![Running start-web.sh](/images/2015/05/05/quickstart-start-web.min.png)
- TestApp: `quickstart/bin/start-testapp.sh`

  ![Running start-testapp.sh](/images/2015/05/05/quickstart-start-testapp.min.png)

Once HBase and the 3 daemons are running, visit the following addresses to test
out your Pinpoint instance.

- Web UI: <http://localhost:28080>

  ![Screenshot of Web UI](/images/2015/05/05/quickstart-web-ui.min.png)
- TestApp: <http://localhost:28081>

  ![Screenshot of TestApp](/images/2015/05/05/quickstart-testapp.min.png)

### Stopping

- HBase: `quickstart/bin/stop-hbase.sh`
- Collector: `quickstart/bin/stop-collector.sh`
- Web UI: `quickstart/bin/stop-web.sh`
- TestApp: `quickstart/bin/stop-testapp.sh`

## Summary

You can run Pinpoint on Docker by:

``` sh
docker pull yous/pinpoint
docker run -i -t -p 28080:28080 -p 28081:28081 -p 28082:28082 \
  --cap-add SYS_PTRACE yous/pinpoint bash
```

Inside the Docker, run:

``` sh
quickstart/bin/start-hbase.sh
quickstart/bin/init-hbase.sh
quickstart/bin/start-collector.sh
quickstart/bin/start-web.sh
quickstart/bin/start-testapp.sh
```

Then you can access <http://localhost:28080> for Web UI and
<http://localhost:28081> for TestApp.

Note again, you can see my Dockerfile on [yous/pinpoint-docker](https://github.com/yous/pinpoint-docker).
Any issues and pull requests are welcome!
