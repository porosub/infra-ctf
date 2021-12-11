# CTF HOLOGY Platform with CTFd

Dokumentasi infrastruktur Capture the Flag HOLOGY.

Langkah-langkah instalasi [CTFd](https://ctfd.io/) sebagai platform event Capture the Flag HOLOGY.

## Catatan Penting

Ubah ctf.porosub.org dengan domain ctf yang akan digunakan.

## Langkah-Langkah

### Pembuatan Server

1. Buat Virtual Private Server (Preferable OS Ubuntu 20.04 LTS) di Cloud Provider kesayangan

2. Izinkan akses masuk untuk port HTTP (80/TCP) dan HTTPS (443/TCP) pada VPS

### Persiapan Server

1. Perbaruan sistem

```bash
sudo apt update
sudo apt upgrade -y

# (Opsional) Restart VPS jika ada kernel upgrade
```

2. Pengubahan timezone

```bash
sudo timedatectl set-timezone Asia/Jakarta
```

3. Pengubahan hostname dan hosts file

```bash
sudo hostnamectl set-hostname ctf.porosub.org
sudo nano /etc/hosts

Konten file:
127.0.0.1 localhost
1.2.3.4 ctf.porosub.org # Ganti 1.2.3.4 dengan IP Public server
...
```

### Instalasi Docker dan Docker Compose

1. Instalasi Docker

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

2. Instalasi Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

3. Aktifkan Docker pada saat booting

```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

4. Penggunaan Docker tanpa root user

```bash
sudo groupadd docker
sudo usermod -aG docker $USER

# Logout & Login kembali ke dalam sistem
```

### Instalasi CTFd

1. Kloning Github repository [CTFd](https://github.com/CTFd/CTFd)

```bash
git clone https://github.com/CTFd/CTFd.git
```

2. Penyuntingan file docker-compose.yml

```bash
cd CTFd
nano docker-compose.yml

Konten file:
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

# Hapus service nginx karena kita akan menggunakan reverse proxy Nginx pada host machine, bukan melalui Docker
# Biarkan baris lainnya sebagaimana mestinya
```

3. Eksekusi file docker-compose.yml

```bash
docker-compose up -d
```

Setelah proses pembuatan container selesai, platform CTFd dapat diakses di port 8000 dari IP Public Server <http://IP_PUBLIC_SERVER:8000>.

### Konfigurasi Reverse Proxy Nginx

1. Instalasi Nginx

```bash
sudo apt install nginx
```

2. Penyuntingan Nginx server block (Virtual Hosts)

```bash
sudo nano /etc/nginx/sites-available/ctf.porosub.org

Konten file:
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
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
```

### Konfigurasi HTTPS dengan Let's Encrypt

1. Instalasi certbot

```bash
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-get install certbot python3-certbot-nginx
```

2. Eksekusi certbot dengan Nginx

```bash
sudo certbot --nginx

# Berikan email address, domain/subdomain address, dan pilih opsi untuk selalu redirect koneksi http ke https
```

---
## OPSIONAL

### Konfigurasi Firewall dengan UFW

Beberapa Cloud Provider tidak memberikan firewall service semacam AWS Security Group sehingga Anda harus mengatur sendiri firewall yang digunakan, salah satu firewall yang populer digunakan adalah UFW. Pastikan untuk mengizinkan akses OpenSSH dan Nginx dalam UFW.

```bash
sudo apt install ufw
sudo ufw allow "Nginx Full"
sudo ufw allow "OpenSSH"
sudo ufw enable
```

### Workaround tambahan untuk pengguna Cloudflare

Jika kita menggunakan Cloudflare untuk mengelola domain kita dan memilih untuk menggunakan fitur Cloudflare proxy, kita perlu sedikit mengubah konfigurasi Nginx.

1. Penyuntingan file Virtual Hosts Nginx

$binary_remote_addr diganti menjadi $http_cf_connecting_ip agar Nginx dapat membatasi request dari IP pengguna asli, bukan IP dari Cloudflare proxy.

```bash
sudo nano /etc/nginx/sites-available/ctf.porosub.org

Konten File:
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

Konten file:
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

# Berikan email address, domain/subdomain address, dan pilih opsi untuk selalu redirect koneksi http ke https 
```

---

Sekarang kita seharusnya sudah bisa mengakses platform CTFd dengan https melalui <https://ctf.porosub.org>. Setelah ini, kita bisa mulai mengatur event CTF seperti menambah user, team, challenges, dll.

### Referensi

- <https://docs.ctfd.io/docs/deployment/installation>
- <https://medium.com/csictf/self-hosting-a-ctf-platform-ctfd-90f3f1611587>
