#!/bin/bash

echo -e "\033[0;32mDeploying rebuilt site to GitHub...\033[0m"

cd public

if [ -n "$GITHUB_AUTH_SECRET" ]
then
    touch ~/.git-credentials
    chmod 0600 ~/.git-credentials
    echo $GITHUB_AUTH_SECRET > ~/.git-credentials

    git config credential.helper store
    git config user.email "asongtoruin@users.noreply.github.com"
    git config user.name "asongtoruin"
fi

git add .
git commit -m "Rebuild site"
git push --force origin HEAD:master
