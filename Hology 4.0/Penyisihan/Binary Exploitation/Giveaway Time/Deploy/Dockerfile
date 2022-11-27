FROM ubuntu:bionic
RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp
RUN adduser giveaway
COPY giveaway flag.txt /home/giveaway/
WORKDIR /home/giveaway/
EXPOSE 31420
user giveaway
CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 31420 ./giveaway  
