#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2024 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only

set -e

cd "$(dirname "$(readlink -f "$0")")"

if [[ -n $(git status --porcelain) ]]; then
    EVENT_DATA=$(cat $GITHUB_EVENT_PATH)
    PR_NUMBER=$(echo "$EVENT_DATA" | jq -r '.pull_request.number')
    PR_URL=$(echo "$EVENT_DATA" | jq -r '.pull_request.html_url')

    git checkout -B "update/$PR_NUMBER"
    git add .
    git commit -m "Reference images from ${PR_URL}"
    git push --set-upstream origin "update/$PR_NUMBER" --force
    UPDATE_URL=$(gh pr create -B main -H "update/$PR_NUMBER" -t "Update reference images for PR #$PR_NUMBER" -b "Update reference images for ${PR_URL}" | grep https)

    cd ../../ # Back to KDDockWidgets repo
    gh pr comment $PR_NUMBER -b "Reference images update PR created: ${UPDATE_URL}. Review carefully, merge or discard it."
fi
