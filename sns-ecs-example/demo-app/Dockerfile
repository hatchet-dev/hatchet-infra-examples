FROM node:18
WORKDIR /app

RUN npm install -g pnpm typescript

COPY package.json pnpm-lock.yaml* ./
RUN pnpm install
COPY index.ts .

RUN npx tsc index.ts

CMD ["node", "index.js"]