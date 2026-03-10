FROM node:24-alpine AS build

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN node ace build

# ---

FROM node:24-alpine

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3333
ENV LOG_LEVEL=info
ENV APP_KEY=changeme-generate-a-real-key
ENV APP_URL=http://localhost:3333
ENV SESSION_DRIVER=cookie

WORKDIR /app

COPY --from=build /app/build .

RUN apk add --no-cache python3 make g++ \
    && npm ci --omit=dev \
    && apk del python3 make g++

RUN mkdir -p /app/storage

EXPOSE 3333

CMD ["node", "bin/server.js"]
