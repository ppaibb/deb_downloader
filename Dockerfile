ARG ubuntu_version=22.04

FROM ubuntu:$ubuntu_version

RUN rm -f /etc/apt/apt.conf.d/docker-clean && apt-get update
