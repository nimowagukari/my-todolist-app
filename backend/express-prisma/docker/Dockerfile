FROM node:20.9.0-alpine as builder

USER node
COPY --chown=node:node ./backend/express-prisma /home/node/workspace
WORKDIR /home/node/workspace

RUN npm install
RUN npx tsc



FROM node:20.9.0-alpine as app

USER node
COPY --from=builder /home/node/workspace /home/node/workspace
WORKDIR /home/node/workspace

EXPOSE 3000
CMD ["./dist/index.js"]
