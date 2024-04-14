#!/bin/sh
set -eu

if [ -z "$INPUT_REMOTE_DOCKER_USER" ]; then
  echo "Input REMOTE_DOCKER_USER is required!"
  exit 1
fi

if [ -z "$INPUT_REMOTE_DOCKER_HOST" ]; then
  echo "Input REMOTE_DOCKER_HOST is required!"
  exit 1
fi

if [ -z "$INPUT_SSH_PRIVATE_KEY" ]; then
  echo "Input SSH_PRIVATE_KEY is required!"
  exit 1
fi

if [ -z "$INPUT_CONTAINER_NAME" ]; then
  echo "Input CONTAINER_NAME is required!"
  exit 1
fi

INPUT_REMOTE_DOCKER_PORT="${INPUT_REMOTE_DOCKER_PORT:=22}"

INPUT_REMOVE_CONTAINER="${INPUT_REMOVE_CONTAINER:=false}"
INPUT_REMOVE_IMAGE="${INPUT_REMOVE_IMAGE:=false}"
INPUT_FAIL_IF_NOT_RUNNING="${INPUT_FAIL_IF_NOT_RUNNING:=false}"

mkdir -p ~/.ssh

echo "$INPUT_SSH_PRIVATE_KEY" >~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

ssh-keyscan -p $INPUT_REMOTE_DOCKER_PORT "$INPUT_REMOTE_DOCKER_HOST" >>~/.ssh/known_hosts 2>/dev/null
ssh-keyscan -p $INPUT_REMOTE_DOCKER_PORT "$INPUT_REMOTE_DOCKER_HOST" >>/etc/ssh/ssh_known_hosts 2>/dev/null

eval $(ssh-agent) 2>&1 >/dev/null
ssh-add ~/.ssh/id_rsa 2>/dev/null

DOCKER_COMMAND="docker --host=ssh://ec2-user@$INPUT_REMOTE_DOCKER_HOST:$INPUT_REMOTE_DOCKER_PORT"

CONTAINER_ID=$(${DOCKER_COMMAND} ps -q -f name=${INPUT_CONTAINER_NAME})

if [ "${INPUT_FAIL_IF_NOT_RUNNING}" = "true" ] && [ ! -z "${CONTAINER_ID}"]; then
  echo "No container for name ${INPUT_CONTAINER_NAME} found, exiting"
  exit 1
fi

if [ "${INPUT_REMOVE_IMAGE}" = "true" ]; then
  PREVIOUS_IMAGE_ID=$(${DOCKER_COMMAND} inspect ${INPUT_CONTAINER_NAME} -f "{{ .Config.Image }}")
fi

if [ -z "${CONTAINER_ID}" ]; then
  echo "No container for name ${INPUT_CONTAINER_NAME} found to stop"
else
  REMOVED_CONTAINER_NAME=$(${DOCKER_COMMAND} stop ${CONTAINER_ID})
  echo Stopped container ${INPUT_CONTAINER_NAME} (${REMOVED_CONTAINER_NAME})
fi

if [ "${INPUT_REMOVE_CONTAINER-}" = "true" ]; then
  echo Removing container ${INPUT_CONTAINER_NAME}
  ${DOCKER_COMMAND} rm ${INPUT_CONTAINER_NAME}
fi

EXISTING_IMAGE_COUNT=$(${DOCKER_COMMAND} images -q ${PREVIOUS_IMAGE_ID} | wc -l)

if [ [ "${INPUT_REMOVE_IMAGE}" = "true" ] && [ ${EXISTING_IMAGE_COUNT} -ne 0 ] ]; then
  echo Removing previously used image ${PREVIOUS_IMAGE_ID}
  ${DOCKER_COMMAND} rmi ${PREVIOUS_IMAGE_ID}
fi
