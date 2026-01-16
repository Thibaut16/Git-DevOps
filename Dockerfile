# moderne Node LTS Version
FROM node:18-alpine

LABEL maintainer="kengnejordi@yahoo.fr"

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production

COPY . .

EXPOSE 8000

HEALTHCHECK --interval=5s --timeout=5s \
  CMD wget -qO- http://127.0.0.1:8000 || exit 1

CMD ["npm", "start"]

