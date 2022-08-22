FROM renovate/renovate:32.159.4

# Overwrite default entrypoint file and add our common functions
COPY bin/ /usr/local/bin/
COPY config.js .

# Create base directory for renovate so we have somewhere to store the SSH_AUTH_SOCK
RUN mkdir -p /home/ubuntu/renovate/cache && chown 1000:1000 /home/ubuntu/renovate/cache

# Set platform and base directory
ENV RENOVATE_PLATFORM="bitbucket"
ENV RENOVATE_BASE_DIR="/home/ubuntu/renovate"

# Ensure SSH_AUTH_SOCK is shared with compoers, npm, etc
ENV SSH_AUTH_SOCK=$RENOVATE_BASE_DIR/cache/ssh.sock
ENV RENOVATE_CUSTOM_ENV_VARIABLES: '{"SSH_AUTH_SOCK":"$RENOVATE_BASE_DIR/cache/ssh.sock"}'