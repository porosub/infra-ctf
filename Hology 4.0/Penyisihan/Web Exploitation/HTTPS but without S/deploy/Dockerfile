FROM node:14-alpine

WORKDIR /usr/src/app
COPY package.json ./
RUN npm install

COPY . .

EXPOSE 3446:3445
CMD ["node", "index.js"]