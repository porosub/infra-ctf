FROM ubuntu:bionic
RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp
RUN adduser ctf
COPY c.txt e.txt  l.txt  marathon_soal  n.txt  p.txt  s.txt  tersesat.txt /home/ctf/
WORKDIR /home/ctf/
EXPOSE 36998
USER ctf
CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 36998 ./marathon_soal

