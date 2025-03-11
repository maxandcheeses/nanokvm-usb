#!/bin/sh

# Check if SSL certificates exist; if not, generate them.
if [ ! -f /app/NanoKVM-USB/cert.pem ] || [ ! -f /app/NanoKVM-USB/key.pem ]; then
  echo 'Generating SSL certificates...'
  openssl req -x509 -newkey rsa:4096 \
    -keyout /app/NanoKVM-USB/key.pem \
    -out /app/NanoKVM-USB/cert.pem \
    -days 365 -nodes \
    -subj '/CN=localhost'
fi

# If NO_AUDIO is true or 1, remove ",audio:!0}" from any index*.js files in the assests directory
if [ "$NO_AUDIO" = "true" ] || [ "$NO_AUDIO" = "1" ]; then
  echo "NO_AUDIO is set. Removing audio configuration from assests/index*.js files..."
  for file in ./assets/index*.js; do
    if [ -f "$file" ]; then
      sed -i 's/,\?audio:!0//g' "$file"
    fi
  done
fi

# Start the http-server with SSL options.
http-server -p 8080 -S -C /app/NanoKVM-USB/cert.pem -K /app/NanoKVM-USB/key.pem
