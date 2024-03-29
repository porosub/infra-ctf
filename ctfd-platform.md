# CTF HOLOGY Platform with CTFd

Dokumentasi infrastruktur Capture the Flag HOLOGY.

Langkah-langkah instalasi [CTFd](https://ctfd.io/) sebagai platform event Capture the Flag HOLOGY.

## Catatan Penting

1. Ubah ctf.porosub.org dengan domain ctf yang akan digunakan.

2. Semua command di setiap langkah dapat di copy & paste secara bulk. Setiap line akan tekeksekusi sendiri.

## Langkah-Langkah

### Pembuatan Server

1. Buat Virtual Private Server (Preferable OS Ubuntu 20.04 LTS) di Cloud Provider kesayangan

2. Izinkan akses masuk untuk port HTTP (80/TCP) dan HTTPS (443/TCP) pada VPS

### Persiapan Server

1. Perbaruan sistem

```bash
sudo apt update;\
sudo apt upgrade -y
```

(Wajib) Restart VPS jika ada kernel upgrade

2. Pengubahan timezone dan sync

```bash
sudo timedatectl set-timezone Asia/Jakarta;\
sudo timedatectl set-ntp true
```

3. Pengubahan hostname dan hosts file

```bash
sudo hostnamectl set-hostname ctf.porosub.org;\
sudo nano /etc/hosts
```

Konten file:

```conf
...
127.0.0.1 localhost
1.2.3.4 ctf.porosub.org # Ganti 1.2.3.4 dengan Public IP server
...
```

### Instalasi Docker dan Docker Compose

1. Instalasi Docker

```bash
sudo apt remove docker docker.io containerd runc;\
sudo apt update;\
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release;\
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg;\
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;\
sudo apt-get update;\
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

2. Instalasi Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;\
sudo chmod +x /usr/local/bin/docker-compose
```

3. Aktifkan Docker pada saat booting

```bash
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service
```

4. Penggunaan Docker tanpa root user

```bash
sudo groupadd docker;\
sudo usermod -aG docker $USER
```

        Reboot sistem setelah menambahkan user ke grup docker.

### Instalasi CTFd

1. Clone Github repository [CTFd](https://github.com/CTFd/CTFd)

```bash
git clone https://github.com/CTFd/CTFd.git
```

2. Penyuntingan file docker-compose.yml

```bash
cd CTFd;\
nano docker-compose.yml
```

Konten file:

```conf
...
environment:
   - SECRET_KEY=JLycvJbVBbb5v1SC8ZMBUn8X1jNH
   - UPLOAD_FOLDER=/var/uploads
   - DATABASE_URL=mysql+pymysql://ctfd:ctfd@db/ctfd
   - REDIS_URL=redis://cache:6379
   - WORKERS=4
   - LOG_FOLDER=/var/log/CTFd
   - ACCESS_LOG=-
   - ERROR_LOG=-
   - REVERSE_PROXY=true
...
```

        Hapus service nginx karena kita akan menggunakan reverse proxy Nginx pada host machine, bukan melalui Docker

        Biarkan baris lainnya sebagaimana mestinya

3. Eksekusi file docker-compose.yml

```bash
docker-compose up -d
```

### Konfigurasi Firewall UFW

1. Perbolehkan traffic ke semua IP dan semua port (Hanya akan membuka didalam instance, tetap tidak akan bisa diakses dari luar jika telah diblokir dari tingkat service provider, namun mempermudah administrasi instance)

```bash
sudo ufw allow from any
```

2. Edit file /etc/ufw/before.rules

```bash
sudo nano /etc/ufw/before.rules
```

Masukkan teks berikut di atas *filter

```bash
*nat
:PREROUTING ACCEPT [0:0]
-A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8000
-A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8000

COMMIT
```

3. Aktifkan Firewall

```bash
sudo systemctl enable --now ufw;\
sudo ufw enable;\
sudo ufw reload
```

Setelah proses pengaktifan firewall selesai, platform CTFd dapat diakses secara langsung dari IP Public Server <http://IP_PUBLIC_SERVER>.

### Konfigurasi Reverse Proxy Nginx

1. Instalasi Nginx

```bash
sudo apt install nginx
```

2. Penyuntingan Nginx server block (Virtual Hosts)

```bash
sudo nano /etc/nginx/sites-available/ctf.porosub.org
```

Konten file:

```bash
limit_req_zone  $binary_remote_addr zone=mylimit:10m rate=10r/s;
limit_conn_zone $binary_remote_addr zone=addr:10m;
server {
    server_name ctf.porosub.org;
    limit_req zone=mylimit burst=15;
    limit_conn addr 10;
    limit_req_status 429;
    client_max_body_size 8M;
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        #Forward real IP to docker
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;

    }
}
```

3. Membuat symbolic link untuk Virtual Hosts

```bash
sudo ln -s /etc/nginx/sites-available/ctf.porosub.org /etc/nginx/sites-enabled/ctf.porosub.org
```

4. Reload file konfigurasi Nginx

```bash
sudo nginx -s reload
```

5. Aktifkan Nginx pada saat sistem boot

```bash
sudo systemctl enable --now nginx.service
```

### Konfigurasi HTTPS dengan Let's Encrypt

1. Instalasi certbot

```bash
sudo add-apt-repository universe;\
sudo apt-get update;\
sudo apt-get install software-properties-common;\
sudo apt-get install certbot python3-certbot-nginx
```

2. Eksekusi certbot dengan Nginx

```bash
sudo certbot --nginx
```

Berikan email address, domain/subdomain address, dan pilih opsi untuk selalu redirect koneksi http ke https

---

## OPSIONAL

### Konfigurasi Firewall dengan UFW

Beberapa Cloud Provider tidak memberikan firewall service semacam AWS Security Group sehingga Anda harus mengatur sendiri firewall yang digunakan, salah satu firewall yang populer digunakan adalah UFW. Pastikan untuk mengizinkan akses OpenSSH dan Nginx dalam UFW.

```bash
sudo apt install ufw;\
sudo ufw allow "Nginx Full";\
sudo ufw allow "OpenSSH";\
sudo ufw reload
```

### Workaround tambahan untuk pengguna Cloudflare

Jika kita menggunakan Cloudflare untuk mengelola domain kita dan memilih untuk menggunakan fitur Cloudflare proxy, kita perlu sedikit mengubah konfigurasi Nginx.

1. Penyuntingan file Virtual Hosts Nginx

$binary_remote_addr diganti menjadi $http_cf_connecting_ip agar Nginx dapat membatasi request dari IP pengguna asli, bukan IP dari Cloudflare proxy.

```bash
sudo nano /etc/nginx/sites-available/ctf.porosub.org
```

Konten File:

```conf
limit_req_zone  $http_cf_connecting_ip zone=mylimit:10m rate=10r/s;
limit_conn_zone $http_cf_connecting_ip zone=addr:10m;
server {
    server_name ctf.porosub.org;
    limit_req zone=mylimit burst=15;
    limit_conn addr 10;
    limit_req_status 429;
    client_max_body_size 8M;
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

2. Penyuntingan file konfigurasi default Nginx

```bash
sudo nano /etc/nginx/nginx.conf
```

Konten file:

```conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    # multi_accept on;
}

http {

    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    ##
    # Logging Settings
    ##

log_format main '$http_cf_connecting_ip - $remote_user [$time_local] '
'"$request" $status $body_bytes_sent "$http_referer" '
'"$http_user_agent"' ;
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;

    # gzip_vary on;
    # gzip_proxied any;
    # gzip_comp_level 6;
    # gzip_buffers 16 8k;
    # gzip_http_version 1.1;
    # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

3. Restart service Nginx

```bash
sudo systemctl restart nginx
```

4. Kembali menjalankan certbot

```bash
sudo certbot --nginx
```

Berikan email address, domain/subdomain address, dan pilih opsi untuk selalu redirect koneksi http ke https

---

Sekarang kita seharusnya sudah bisa mengakses platform CTFd dengan https melalui <https://ctf.porosub.org>. Setelah ini, kita bisa mulai mengatur event CTF seperti menambah user, team, challenges, dll.

## Deployment

Untuk deploy soal-soal yang perlu dihost di server seperti soal web, pwn, dan lain-lain dapat melihat contoh pada dokumentasi.

## Troubleshooting Deployment 

**mohon ditambah isi dari bagian ini apabila terdapat kendala dan kemudian menemukan solusinya, guna apabila terjadi masalah yang sama kedepannya dapat melihat dokumentasi ini kembali untuk memperbaikinya.**

#### 1. Arsitektur pada challenge
Contoh dari permasalahan ini adalah soal chalarm yang menggunakan arsitektur ARM, sehingga jika dideploy dengan cara deploy pwn biasa tidak akan berjalan. Maka diharapkan problem setter memberi tahu arsitektur apa yang digunakan apabila ada challenge kedepannya yang bukan menggunakan arsitektur amd64. Sehingga dari maintainer dapat menambahkan library-library yang akan digunakan pada container di challenge tersebut

#### 2. Challenge tidak berjalan
Trouble ini mungkin sering terjadi, ketika sudah melakukan deployment dan kemudian mencoba mengaksesnya seperti menjalankan perintah `nc localhost xxxxx` namun tidak menghasilkan apa-apa. Maka untuk solusi dari permasalahan ini kita bisa mengubah hak akses dari challenge tersebut melalui Dockerfilenya dengan menambahkan peintah `RUN chmod 755 chall`.

#### 3. Challenge tidak berjalan dan penyebab bukan masalah hak akses/tidak diketahui
Trouble ini kurang lebih sama seperti nomor sebelumnya, hanya saja ketika telah mengubah hak akses dari chall tersebut masih tetap tidak bisa diakses. Untuk itu kita perlu menginvestigasi lebih dalam apa permasalahan dari challenge tersebut kenapa tidak diakses. Kita dapat menemukan inti permasalahannya dengan masuk ke dalam container dari chall tersebut dengan menggunakan perintah `docker exec -it <ID CONTAINER> bash`. Setelah menjalankan perintah tersebut maka kita akan berada di dalam environment container, kemudian coba eksekusi file challengenya dan kemudian respon pun akan ditampilkan. Misalnya muncul penyebab masalahnya itu adalah perbedaan versi glibc dimana dari probset menggunakan versi 3.24 sedangkan dari image ubuntu versi latest hanya menyediakan sampai versi 3.21, sehingga kita bisa menyampaikannya kepada probset untuk memberbaiki challengenya.

#### 4. Soal pwn tidak muncul teksnya
Untuk permasalahan seperti teks pada soal pwn tidak muncul dahulu dimana yang muncul pertama kali justru baris kosong saja, kemudian ketika ditekan enter baru teks bisa diprint pada terminal, namun hal ini menyebabkan peserta tidak bisa menginputkan jawabannya. Solusi dari permasalahan ini adalah probset bisa memperbaiki soalnya kembali dengan cara menambahkan buffer pada kodenya karena soal seperti ini khususnya program yang berbasis pada bahasa C biasanya probset lupa menambahkan buffer pada kodenya.

#### 4.dst (mohon ditambah apabila menemukan trouble baru)

---

### Referensi

- <https://docs.ctfd.io/docs/deployment/installation>
- <https://medium.com/csictf/self-hosting-a-ctf-platform-ctfd-90f3f1611587>
