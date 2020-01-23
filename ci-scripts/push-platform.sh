#!/usr/bin/env bash
set -e -o pipefail

# Config.
if [ -z "$PF_PROJECT_ID" ]; then
  echo "PF_PROJECT_ID is required"
  exit 1
fi

PF_PARENT_ENV=${PF_PARENT_ENV:-master}
ALLOW_MASTER=${ALLOW_MASTER:-0}
ALWAYS_SYNC_DATA=${ALWAYS_SYNC_DATA:-0}

export PLATFORMSH_CLI_NO_INTERACTION=1

if [ -z "$CI_COMMIT_REF_SLUG" ]; then
  echo "Source branch (CI_COMMIT_REF_SLUG) not defined."
  exit 1
fi

BRANCH=$CI_COMMIT_REF_SLUG

# This script is not for production deployments.
if [ "$BRANCH" = "master" ] && [ "$ALLOW_MASTER" != 1 ]; then
  echo "Not pushing master branch."
  exit
fi

# Set the project for further CLI commands.
platform project:set-remote "$PF_PROJECT_ID"

# Get a URL to the web UI for this environment, before pushing.
pf_ui=$(platform web --environment="$BRANCH" --pipe)
echo ""
echo "Web UI: ${pf_ui}"
echo ""

# Build the push command.
push_command="platform push --force --target=${BRANCH}"
if [ "$PF_PARENT_ENV" != "$BRANCH" ]; then
  push_command="$push_command --activate --parent=${PF_PARENT_ENV}"
fi

# Run the push command.
$push_command

# Sync data on every push. This resets the current branch to the same as master's.
if [ "$PF_ALWAYS_SYNC" = 1 ] && [ "$BRANCH" != master ]; then
  platform sync data --environment "$BRANCH" --yes
fi

# Clean up already merged and inactive environments.
platform environment:delete --inactive --merged --environment="$PF_PARENT_ENV" --exclude=master --exclude="$BRANCH" --yes --delete-branch --no-wait || true
