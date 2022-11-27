# HTTPS but without S (100 Pts)

## Deskripsi
Hmmm kok ada yang dicoret ya

Author : **Arceister**

## Hint 

## Proof of Concept

Endpoint flag didapat dengan cek sertifikat SSLnya

## Referensi
Tidak ada

## Deployment

```
docker build -t tag .
docker run -p 3446:3445 --detach tag
crontab /path/to/crontab
```

## Flag
<details>
<summary>Tekan untuk melihat flag</summary>

    HOLOGY4.0{SoMe_BaSiC_S5L_mIsTAkE}

</details>