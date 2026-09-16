FROM node:20-alpine

WORKDIR /app

# Copy package files first (better caching)
COPY app/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app source
COPY app/ .

EXPOSE 3000

CMD ["node", "server.js"]
