# Install
sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf binutils-arm-linux-gnueabihf-dbg

# Compile
arm-linux-gnueabihf-gcc -static -fno-stack-protector -std=c99 chall.c -o chall-arm

# Run 
ncat -vc ./chall -kl $ip $port
