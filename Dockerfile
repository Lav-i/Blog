FROM node:12.18-alpine

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm config set registry http://registry.npm.taobao.org/ && npm install hexo-cli -g && npm install

COPY . .
EXPOSE 4000

CMD [ "hexo", "server" ]