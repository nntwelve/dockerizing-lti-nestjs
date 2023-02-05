FROM node:18.12.1-bullseye-slim as development

# Create app directory
WORKDIR /app

# node:18.12.1-bullseye-slim throw `ps: not found` if using nestjs watch mode, so install this stuff will help us resolve this error 
RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install the dependencies
RUN npm ci

# Copy the rest of the project files
COPY . .

RUN npm run build

FROM node:18.12.1-bullseye-slim as builder

WORKDIR /app

COPY front-end ./

RUN npm ci

RUN npm run build

FROM node:18.12.1-bullseye-slim as production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

# node:18.12.1-bullseye-slim throw `ps: not found` if using nestjs watch mode, so install this stuff will help us resolve this error 
RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm ci

COPY . .

COPY --from=development /app/dist ./dist

COPY --from=builder /app/build ./public

CMD [ "node", "dist/main" ]
