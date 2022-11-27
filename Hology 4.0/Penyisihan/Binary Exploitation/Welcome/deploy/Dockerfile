FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser welcome

COPY flag.txt welcome /home/welcome/

WORKDIR /home/welcome/

USER welcome

EXPOSE 31337

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 31337 ./welcome
