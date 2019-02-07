# Dockerfile
# using node:alpine for its smaller size
FROM node:8.4.0-alpine

# Create an environment variable to store the application's deployment location
ENV APP_DIR /usr/local/app

RUN mkdir -p /usr/local/app
WORKDIR ${APP_DIR}

COPY . .

# Install only production dependencies and no dev dependencies.
RUN npm i --production

# Expose the port
EXPOSE 5000

CMD ["npm", "start"]
