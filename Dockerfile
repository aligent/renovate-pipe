FROM renovate/renovate:35.115.2

# Overwrite default entrypoint file and add our common functions
COPY bin/ /usr/local/bin/
COPY config.js .

# Create base directory for renovate so we have somewhere to store the sockets
RUN mkdir -p /home/ubuntu/renovate/sockets && chown 1000:1000 /home/ubuntu/renovate/sockets

# Set platform and base directory
ENV RENOVATE_PLATFORM="bitbucket"
ENV RENOVATE_BASE_DIR="/home/ubuntu/renovate"

# Ensure SSH_AUTH_SOCK is shared with compoers, npm, etc
ENV SSH_AUTH_SOCK=$RENOVATE_BASE_DIR/sockets/ssh.sock
ENV RENOVATE_CUSTOM_ENV_VARIABLES="{\"SSH_AUTH_SOCK\":\"$RENOVATE_BASE_DIR/sockets/ssh.sock\"}"