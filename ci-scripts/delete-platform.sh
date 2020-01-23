#!/usr/bin/env bash
set -e

# Config.
if [ -z "$PF_PROJECT_ID" ]; then
  echo "PF_PROJECT_ID is required"
  exit 1
fi

if [ -z "$CI_COMMIT_REF_SLUG" ]; then
  echo "Branch name (CI_COMMIT_REF_SLUG) not defined."
  exit 1
fi

BRANCH=$CI_COMMIT_REF_SLUG

# Delete the branch.
platform environment:delete --yes --no-wait --project="$PF_PROJECT_ID" --environment="$BRANCH"

# Clean up inactive environments.
platform environment:delete --project="$PF_PROJECT_ID" --inactive --exclude=master --yes --delete-branch --no-wait || true
