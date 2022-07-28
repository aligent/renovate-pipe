#!/bin/bash

# Begin Standard 'imports' from https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/
set -e
set -o pipefail


gray="\\e[37m"
blue="\\e[36m"
red="\\e[31m"
green="\\e[32m"
yellow="\\e[33m"
reset="\\e[0m"

#######################################
# echoes a message in blue
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
info() { echo -e "${blue}INFO: $*${reset}"; }

#######################################
# echoes a message in red
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
error() { echo -e "${red}ERROR: $*${reset}"; }

#######################################
# echoes a message in grey. Only if debug mode is enabled
# Globals:
#   DEBUG
# Arguments:
#   Message
# Returns:
#   None
#######################################
debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    echo -e "${gray}DEBUG: $*${reset}";
  fi
}

#######################################
# echoes a message in yellow
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
warning() { echo -e "${yellow}âœ” $*${reset}"; }

#######################################
# echoes a message in green
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
success() { echo -e "${green}âœ” $*${reset}"; }

#######################################
# echoes a message in red and terminates the programm
# Globals:
#   None
# Arguments:
#   Message
# Returns:
#   None
#######################################
fail() { echo -e "${red}âœ– $*${reset}"; exit 1; }

## Enable debug mode.
enable_debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    info "Enabling debug mode."
    set -x
  fi
}

#######################################
# echoes a message in blue
# Globals:
#   status: Exit status of the command that was executed.
#   output_file: Local path with captured output generated from the command.
# Arguments:
#   command: command to run
# Returns:
#   None
#######################################
run() {
  output_file="/var/tmp/pipe-$(date +%s)-$RANDOM"

  echo "$@"
  set +e
  "$@" | tee "$output_file"
  status=$?
  set -e
}

#######################################
# Initialize array variable with the specified name
# https://confluence.atlassian.com/bitbucket/advanced-techniques-for-writing-pipes-969511009.html
# Arguments:
#   array_var: the name of the variable
# Returns:
#   None
#######################################
init_array_var() {
  local array_var=${1}
  local count_var=${array_var}_COUNT
  for (( i = 0; i < ${!count_var:=0}; i++ ))
  do
    eval "${array_var}"[$i]='$'"${array_var}"_${i}
  done
}

#######################################
# Check if a newer version is available and show a warning message
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Message
#######################################
check_for_newer_version() {
  set +e
  if [[ -f "/pipe.yml" ]]; then
    local pipe_name
    local pipe_repository
    local pipe_current_version
    local pipe_latest_version
    local wget_debug_level="--quiet"

    pipe_name=$(awk -F ": " '$1=="name" {print $NF;exit;}' /pipe.yml)
    pipe_repository=$(awk '/repository/ {print $NF}' /pipe.yml)
    pipe_current_version=$(awk -F ":" '/image/ {print $NF}' /pipe.yml)

    if [[ "${DEBUG}" == "true" ]]; then
      warning "Starting check for the new version of the pipe..."
      wget_debug_level="--verbose"
    fi
    pipe_latest_version=$(wget "${wget_debug_level}" -O - "${pipe_repository}"/raw/master/pipe.yml | awk -F ":" '/image/ {print $NF}')

    if [[ "${pipe_current_version}" != "${pipe_latest_version}" ]]; then
      warning "New version available: ${pipe_name} ${pipe_current_version} to ${pipe_latest_version}"
    fi
  fi
  set -e
}

# End standard 'imports'


# Custom functions for pipeline
setup_ssh_creds() {
     # Setup pipeline SSH 
     INJECTED_SSH_CONFIG_DIR="/opt/atlassian/pipelines/agent/ssh"
     IDENTITY_FILE="${INJECTED_SSH_CONFIG_DIR}/id_rsa_tmp"
     KNOWN_SERVERS_FILE="${INJECTED_SSH_CONFIG_DIR}/known_hosts"
     if [ ! -f ${IDENTITY_FILE} ]; then
          info "No default SSH key configured in Pipelines.\n These are required to install internal composer packages. \n These should be generated in bitbucket settings at Pipelines > SSH Keys."
          return
     fi
     mkdir -p ~/.ssh
     touch ~/.ssh/authorized_keys
     cp ${IDENTITY_FILE} ~/.ssh/pipelines_id

     if [ ! -f ${KNOWN_SERVERS_FILE} ]; then
          fail "No SSH known_hosts configured in Pipelines."
     fi
     cat ${KNOWN_SERVERS_FILE} >> ~/.ssh/known_hosts
     if [ -f ~/.ssh/config ]; then
          debug "Appending to existing ~/.ssh/config file"
     fi
     echo "IdentityFile ~/.ssh/pipelines_id" >> ~/.ssh/config
     chmod -R go-rwx ~/.ssh/
}

configure() {    
    REPO_PATH="/opt/atlassian/pipelines/agent/build"

    if [ -z "${CONFIG_FILE}" ]; then
        CONFIG_FILE='config.js'
        info "No custom config file set, checking for default $CONFIG_FILE"
    fi

    if [ -f "$REPO_PATH/$CONFIG_FILE" ]; then
        info "$CONFIG_FILE found!"
        export RENOVATE_CONFIG_FILE="$REPO_PATH/$CONFIG_FILE"
    else
        info "$CONFIG_FILE does not exist in repository, falling back to default configuration."
        export RENOVATE_CONFIG_FILE="/usr/src/app/config.js"
    fi

    export RENOVATE_REPOSITORIES=$BITBUCKET_REPO_FULL_NAME
}