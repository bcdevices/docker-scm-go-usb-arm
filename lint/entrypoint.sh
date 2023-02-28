#!/bin/sh

cd "$GITHUB_WORKSPACE"

REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
export REVIEWDOG_GITHUB_API_TOKEN

golangci-lint run --out-format line-number ${INPUT_GOLANGCI_LINT_FLAGS} \
  | reviewdog -f=golangci-lint -name="${INPUT_TOOL_NAME}" -reporter=github-pr-check -level="${INPUT_LEVEL}"
