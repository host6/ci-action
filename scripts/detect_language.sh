#!/usr/bin/env bash
# Copyright (c) 2020-present unTill Pro, Ltd. and Contributors
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

set -Eeuo pipefail

auth_header=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
    auth_header=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
elif [ -n "${TOKEN:-}" ]; then
    auth_header=(-H "Authorization: Bearer ${TOKEN}")
fi

commit_url="https://api.github.com/repos/$GITHUB_REPOSITORY/commits/$GITHUB_SHA"
commit_json=$(curl -sS "${auth_header[@]}" -H "Accept: application/vnd.github+json" "$commit_url" || true)
tree_sha=$(echo "$commit_json" | jq -r '.commit.tree.sha // empty')

language="unknown"

if [ -n "$tree_sha" ]; then
    tree_url="https://api.github.com/repos/$GITHUB_REPOSITORY/git/trees/$tree_sha?recursive=1"
    tree_json=$(curl -sS "${auth_header[@]}" -H "Accept: application/vnd.github+json" "$tree_url" || true)

    if [ -n "$tree_json" ]; then
        language=$(echo "$tree_json" | jq -r '
            if any(.tree[]?; .path == "go.mod") then
            "go"
            elif any(.tree[]?; (.path | (endswith(".js") or endswith(".jsx") or endswith(".ts") or endswith(".tsx"))
                                    and (contains("/.") | not)
                                    and (contains("/node_modules/") | not))) then
            "node_js"
            else
            "unknown"
            end
        ')
    fi
fi

echo $language
