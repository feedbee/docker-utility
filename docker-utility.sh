#!/bin/bash

LABEL="managed-by=docker-utility"

usage() {
  echo "Usage: $0 [--debug] {create|list|restart|update|remove|args} [options]"
  echo "  --debug           # Print traced docker commands before execution"
  echo "  create  <name> <image> [docker run args...]"
  echo "  list"
  echo "  args    <name>    # Show original docker run args for container"
  echo "  restart <name>"
  echo "  update  <name>"
  echo "  remove  <name>"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

# Print an error message in red
error_echo() {
  echo -e "\033[1;31m$*\033[0m" >&2
}
# Print a success message in green
success_echo() {
  echo -e "\033[1;32m$*\033[0m"
}
# Print a message based on exit code: green for success, red for error and exit
run_status() {
  CODE=$1
  SUCCESS_MSG="$2"
  ERROR_MSG="$3"
  if [ $CODE -eq 0 ]; then
    if [ -n "$SUCCESS_MSG" ]; then
      success_echo "$SUCCESS_MSG"
    fi
  else
    error_echo "$ERROR_MSG (exit code $CODE)."
    exit 1
  fi
}
# Print traced docker command if debug is enabled
debug_echo() {
  if [ "$DEBUG" -eq 1 ]; then
    # Print in cyan
    echo -e "\033[1;36m+ $*\033[0m"
  fi
}

# Handle --debug flag
DEBUG=0
if [ "$1" = "--debug" ]; then
  DEBUG=1
  shift
fi

CMD="$1"
shift

case "$CMD" in
  create)
    NAME="$1"
    IMAGE="$2"
    if [ -z "$NAME" ] || [ -z "$IMAGE" ]; then
      echo "Usage: $0 create <name> <image> [docker run args...]"
      exit 1
    fi
    shift 2
    # Encode the run options for storage in a label
    OPTIONS_ENCODED=$(printf '%s' "$*" | base64)
    debug_echo docker run -d --restart=always --label $LABEL --label docker-utility-options=$OPTIONS_ENCODED --name $NAME $* $IMAGE
    docker run -d --restart=always --label "$LABEL" --label "docker-utility-options=$OPTIONS_ENCODED" --name "$NAME" "$@" "$IMAGE"
    CODE=$?
    run_status $CODE "Container $NAME created with image $IMAGE." "Failed to create container $NAME"
    ;;
  list)
    debug_echo docker ps --filter label=$LABEL
    docker ps --filter "label=$LABEL"
    ;;
  args)
    NAME="$1"
    if [ -z "$NAME" ]; then
      echo "Usage: $0 args <name>"
      exit 1
    fi
    OPTIONS_ENCODED=$(docker inspect --format='{{ index .Config.Labels "docker-utility-options"}}' "$NAME")
    if [ -z "$OPTIONS_ENCODED" ]; then
      echo "No options label found for container $NAME."
      exit 1
    fi
    OPTIONS=$(echo "$OPTIONS_ENCODED" | base64 --decode)
    echo "Original docker run arguments for $NAME:"
    echo "$OPTIONS"
    ;;
  restart)
    NAME="$1"
    if [ -z "$NAME" ]; then
      echo "Usage: $0 restart <name>"
      exit 1
    fi
    debug_echo docker restart $NAME
    docker restart "$NAME"
    CODE=$?
    run_status $CODE "Container $NAME restarted." "Failed to restart container $NAME"
    ;;
  update)
    NAME="$1"
    if [ -z "$NAME" ]; then
      echo "Usage: $0 update <name>"
      exit 1
    fi
    shift 1
    # Extract the image name from the existing container
    IMAGE=$(docker inspect --format='{{.Config.Image}}' "$NAME")
    if [ -z "$IMAGE" ]; then
      echo "Error: Could not find image for container $NAME."
      exit 1
    fi
    # Extract the original run options from the label
    OPTIONS_ENCODED=$(docker inspect --format='{{ index .Config.Labels "docker-utility-options"}}' "$NAME")
    if [ -z "$OPTIONS_ENCODED" ]; then
      echo "Error: No options label found for container $NAME. Cannot recreate container."
      exit 1
    fi
    OPTIONS=$(echo "$OPTIONS_ENCODED" | base64 --decode)
    debug_echo docker pull $IMAGE
    docker pull "$IMAGE"
    CODE=$?
    run_status $CODE "" "Failed to pull image $IMAGE"
    debug_echo docker stop $NAME
    docker stop "$NAME"
    CODE=$?
    run_status $CODE "" "Failed to stop container $NAME"
    debug_echo docker rm $NAME
    docker rm "$NAME"
    CODE=$?
    run_status $CODE "" "Failed to remove container $NAME"
    debug_echo docker run -d --restart=always --label $LABEL --label docker-utility-options=$OPTIONS_ENCODED --name $NAME $OPTIONS $IMAGE
    # shellcheck disable=SC2086
    docker run -d --restart=always --label "$LABEL" --label "docker-utility-options=$OPTIONS_ENCODED" --name "$NAME" $OPTIONS "$IMAGE"
    CODE=$?
    run_status $CODE "Container $NAME updated with image $IMAGE." "Failed to update container $NAME"
    ;;
  remove)
    NAME="$1"
    if [ -z "$NAME" ]; then
      echo "Usage: $0 remove <name>"
      exit 1
    fi
    debug_echo docker stop $NAME
    docker stop "$NAME"
    debug_echo docker rm $NAME
    docker rm "$NAME"
  CODE=$?
  run_status $CODE "Container $NAME removed." "Failed to remove container $NAME"
    ;;
  *)
    usage
    ;;
esac
