FROM ubuntu:focal

#FROM golang:1.16-alphine

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser ctf

COPY flag.txt vuln /home/ctf/

USER ctf

WORKDIR /home/ctf/

EXPOSE 34465

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 34465 ./vuln


