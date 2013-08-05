FROM ubuntu:precise
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu precise main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise-updates main restricted universe" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu precise-updates main restricted universe" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu precise-security main restricted universe" >> /etc/apt/sources.list
RUN echo "deb-src http://security.ubuntu.com/ubuntu precise-security main restricted universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install libssl-dev git-core build-essential nginx psmisc -y
RUN (git clone https://github.com/wg/wrk && cd wrk && make && cp wrk /usr/local/bin)
ADD nginx.conf /etc/nginx/
