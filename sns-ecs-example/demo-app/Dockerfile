FROM node:18
WORKDIR /app

# Install pnpm and TypeScript globally
RUN npm install -g pnpm typescript

# Copy configuration and dependency files
COPY package.json pnpm-lock.yaml* tsconfig.json ./

# Install dependencies
RUN pnpm install

# Copy the rest of the source code
COPY . .

# Run TypeScript compiler explicitly specifying the config file
RUN npx tsc --project tsconfig.json

# Start the application
CMD ["node", "index.js"]