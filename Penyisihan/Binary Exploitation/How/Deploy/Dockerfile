FROM ubuntu:bionic
RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp
RUN adduser how
COPY flag.txt how /home/how/
WORKDIR /home/how/
EXPOSE 37013
USER how
CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 37013 ./how
