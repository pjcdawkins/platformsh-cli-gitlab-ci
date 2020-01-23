#!/usr/bin/env bash
set -e

# Set up SSH credentials for pushing to external Git repositories, via GitLab CI
# environment variables.
if [ -n "$SSH_KEY" ]; then
  mkdir -p $HOME/.ssh
  echo "$SSH_KEY" > $HOME/.ssh/id_rsa
  echo "$SSH_KEY_PUB" > $HOME/.ssh/id_rsa.pub

  # Some vague semblance of security for the private key.
  chmod go-r $HOME/.ssh/id_rsa
  unset SSH_KEY

  echo "Created SSH key: .ssh/id_rsa"
fi

# Set up SSH known hosts file.
if [ -n "$SSH_KNOWN_HOSTS" ]; then
  mkdir -p $HOME/.ssh
  echo "$SSH_KNOWN_HOSTS" > $HOME/.ssh/known_hosts
fi
