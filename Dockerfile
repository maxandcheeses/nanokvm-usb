# Start with a Node.js base image (Alpine for smaller size)
FROM node:alpine

# Install OpenSSL and other dependencies (including unzip for ZIP file extraction)
RUN apk update && \
    apk add --no-cache \
    openssl \
    bash \
    wget \
    unzip

# Install http-server globally
RUN npm install -g http-server

# Set working directory where the ZIP will be extracted
WORKDIR /app

# Copy the NanoKVM-USB.zip file into the container
COPY NanoKVM-USB.zip /app/

# Extract the ZIP file
RUN unzip /app/NanoKVM-USB.zip -d /app && \
    rm /app/NanoKVM-USB.zip

# Set the working directory to the extracted folder (NanoKVM-USB)
WORKDIR /app/NanoKVM-USB

# Expose port 8080 (the port where the server will run)
EXPOSE 8080

# Entrypoint script to generate certificates and start http-server
ENTRYPOINT ["sh", "-c", "if [ ! -f /app/NanoKVM-USB/cert.pem ] || [ ! -f /app/NanoKVM-USB/key.pem ]; then \
    echo 'Generating SSL certificates...'; \
    openssl req -x509 -newkey rsa:4096 -keyout /app/NanoKVM-USB/key.pem -out /app/NanoKVM-USB/cert.pem -days 365 -nodes -subj '/CN=localhost'; \
fi && \
http-server -p 8080 -S -C /app/NanoKVM-USB/cert.pem -K /app/NanoKVM-USB/key.pem"]

