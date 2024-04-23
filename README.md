# remote_docker_stop
Github action to stop a running docker container on a remote daemon.  It is  to stop deployments on that docker daemons context.

## remote_docker suite
This action is part of the remote-context docker command suite intended to control a remote docker daemon accessed via SSH using a private key.  These commands take the following common parameters:

- remote_docker_host  
  + required: true
  > description: The hostname or IP address of the remote docker host
- ssh_private_key
  + required: true
  > description: The private key configured on the remote host to allow SSH access
- remote_docker_user
  + required: true
  > description: The username to use when connecting to the remote host
- ssh_port
  + required: false
  > description: The port to use when connecting to the remote host
    default: 22

