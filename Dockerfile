FROM node:10.15-alpine
ENV NODE_ENV=development
EXPOSE 8080
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . ./
RUN npm run build

FROM node:10.15-alpine
ENV NODE_ENV=production
ENV HOME=/usr/src/app
EXPOSE 8080
WORKDIR /usr/src/app
COPY --from=0 $HOME/package.json /$HOME/package-lock.json ./
COPY --from=0 $HOME/dist ./dist/
RUN npm install
CMD ["npm", "start"]