FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser ctf

COPY flag.txt onepiece /home/ctf/

WORKDIR /home/ctf/

USER ctf

EXPOSE 38823

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 38823 ./onepiece
