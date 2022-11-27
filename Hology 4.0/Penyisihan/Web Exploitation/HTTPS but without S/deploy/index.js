const express = require('express')
const https = require('https')
const path = require('path')
const fs = require('fs')

const app = express()

app.get('/theflaghere', (req, res, next) => {
    res.send("The flag is HOLOGY4.0{SoMe_BaSiC_S5L_mIsTAkE} <br/> P.S. Sorry for the easy and meme web challenge, thinking of quitting from Cyber Security and CTFs.")
})

app.use('/', (req, res, next) => {
    res.send("Something wrong with certificate?")
})

const sslServer = https.createServer({
    key: fs.readFileSync(path.join(__dirname, 'certis', 'key.pem')),
    cert: fs.readFileSync(path.join(__dirname, 'certis', 'cert.pem')),
}, app)

sslServer.listen(3445, () => {
    console.log("Listen to", 3445)
})