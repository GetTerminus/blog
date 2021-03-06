#!/bin/bash

git config --global user.email "chue.her@terminus.com"
git config --global user.name "chueher"

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "Create CNAME"
cd public && touch CNAME && echo 'forge.terminus.com' >> CNAME

echo "Updating gh-pages branch"
git add --all && git commit -m "Publishing to gh-pages (publish.sh)" && cd ..

echo "Pushing commit"
git push origin gh-pages --force
