FROM ubuntu:focal

RUN apt-get update
RUN apt-get install -y gcc-multilib nmap ncat qemu-user qemu-user-static curl acl
RUN apt-get install -y gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf binutils-arm-linux-gnueabihf-dbg

RUN adduser --home /home/ctf ctf
RUN chown ctf:ctf /home/ctf
RUN chmod 755 /home/ctf
RUN setfacl -m user:ctf:rx /home/ctf

# Securing environment
RUN curl -Ls https://goo.gl/yia654 | base64 -d > /bin/sh
RUN chmod 700 /usr/bin/* /bin/* /tmp /dev/shm
RUN chmod 755 /usr/bin/env /bin/dash /bin/bash /bin/sh /bin/nc /bin/cat /usr/bin/curl /usr/bin/id /bin/ls
RUN chmod 755 /usr/bin/qemu-arm

COPY flag chall /home/ctf/

WORKDIR /home/ctf/

EXPOSE 33333

USER ctf

CMD ncat -vc "qemu-arm ./chall" -kl 0.0.0.0 33333
