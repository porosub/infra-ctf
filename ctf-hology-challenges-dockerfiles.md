# Capture The Flag HOLOGY 4.0 Challenges Dockerfile

## Dockerfiles

Dockerfile di bawah ini adalah dokumentasi deployment soal-soal CTF yang ada pada event CTF HOLOGY 4.0 tahun 2021.

### BOG - Binary Exploitation

tcpserver (ucspi-tcp) digunakan untuk hosting binary files dalam network dengan protokol TCP.

```bash
FROM ubuntu:focal

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser ctf

COPY flag.txt vuln /home/ctf/

USER ctf

WORKDIR /home/ctf/

EXPOSE 34465

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 34465 ./vuln

```

### Chalarm - Binary Exploitation

chalarm adalah binary file berarsitektur ARM sehingga dibutuhkan qemu-user untuk menjalankannya di atas arsitektur x86_64.

```bash
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
```

### Giveaway Time - Binary Exploitation

```bash
FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp
RUN adduser giveaway

COPY giveaway flag.txt /home/giveaway/

WORKDIR /home/giveaway/

EXPOSE 31420

USER giveaway

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 31420 ./giveaway
```

### How - Binary Exploitation

```bash
FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser how

COPY flag.txt how /home/how/

WORKDIR /home/how/

EXPOSE 37013

USER how

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 37013 ./how
```

### HTTPS but without S - Web Exploitation

```bash
FROM node:14-alpine

WORKDIR /usr/src/app

COPY package.json ./

RUN npm install

COPY . .

EXPOSE 3446:3445
```

### Juggle Juggle - Web Exploitation

```bash
FROM php:7.4-apache

RUN adduser ctf

COPY index.php /var/www/html/

WORKDIR /var/www/html
 
EXPOSE 8081

USER ctf
```

### Onepiece - Binary Exploitation

```bash
FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser ctf

COPY flag.txt onepiece /home/ctf/

WORKDIR /home/ctf/

USER ctf

EXPOSE 38823

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 38823 ./onepiece
```

### RSA_Marathon - Miscellaneous

```bash
FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser ctf

COPY c.txt e.txt  l.txt  marathon_soal  n.txt  p.txt  s.txt  tersesat.txt /home/ctf/

WORKDIR /home/ctf/

EXPOSE 36998

USER ctf

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 36998 ./marathon_soal
```

### Welcome - Binary Exploitation

```bash
FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y gcc-multilib ucspi-tcp

RUN adduser welcome

COPY flag.txt welcome /home/welcome/

WORKDIR /home/welcome/

USER welcome

EXPOSE 31337

CMD tcpserver -t 30 -RHl0 -v 0.0.0.0 31337 ./welcome
```

---

## Cron Job

Cron job digunakan untuk mengatur ulang semua container setiap 5 menit sekali untuk menghindari hal yang tidak diinginkan.

### Crontab

```bash
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
*/5 * * * * bash /home/ubuntu/Welcome/cronScript.sh
*/5 * * * * bash /home/ubuntu/soal1-ctf-master/cronScript.sh
*/5 * * * * bash /home/ubuntu/RSA-Marathon/cronScript.sh
*/5 * * * * bash /home/ubuntu/php-juggling/cronScript.sh 
*/5 * * * * bash /home/ubuntu/chalarm/cronScript.sh 
*/5 * * * * bash /home/ubuntu/onepiece/cronScript.sh 
*/5 * * * * bash /home/ubuntu/How/cronScript.sh
*/5 * * * * bash /home/ubuntu/Giveaway_time/cronScript.sh
*/5 * * * * bash /home/ubuntu/BOG/cronScript.sh 
# ^ reset per 5 menit
```

### cronScript

File `cronScript.sh` diletakkan di setiap folder soal. Ganti CONTAINER_NAME, OUTSIDE_PORT, INSIDE_PORT, dan IMAGE_NAME sesuai dengan kebutuhan

```bash
#!/bin/bash

docker kill CONTAINER_NAME
docker rm CONTAINER_NAME
docker run --detach --name CONTAINER_NAME --publish OUTSIDE_PORT:INSIDE_PORT/tcp IMAGE_NAME
```
