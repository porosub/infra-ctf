# pwnclub (100 Pts)

## Deskripsi
pwn and win the flag

Author : **rockwell**

## Hint
- 

## Proof of Concept


## Deployment

```
docker build -t chalarm .
socat TCP4-LISTEN:8000,reuseaddr,fork,su=ctf EXEC:'./pwnpwnclub.o'
crontab /path/to/crontab
```

## Flag
<details>
<summary>Tekan untuk melihat flag</summary>

    hology4{pwn3rs_P4wNeRZ_cluB3z}

</details>
