FROM renovate/renovate:32.131.1

# Overwrite default entrypoint file and add our common functions
COPY bin/ /usr/local/bin/

COPY config.js .

ENV RENOVATE_PLATFORM="bitbucket"