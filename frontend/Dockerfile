FROM node:20-slim

ENV NODE_ENV production

WORKDIR /app

COPY package.json /app
COPY package-lock.json /app

RUN npm install
COPY . /app

CMD ["sh", "-c", "npm run build && npm run start"]