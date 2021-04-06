FROM node:12.18-alpine

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm config set registry http://registry.npm.taobao.org/
RUN npm install hexo-cli -g
RUN npm install

COPY . .
EXPOSE 4000

ENTRYPOINT [ "hexo" ]
CMD [ "server "]