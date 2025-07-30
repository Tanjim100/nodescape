# 1️⃣ Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

# 2️⃣ Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Copy only what is needed
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/app ./app
COPY --from=builder /app/styles ./styles

EXPOSE 3000

CMD ["npm", "start"]
