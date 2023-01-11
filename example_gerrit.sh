#!/bin/bash

# The first API call is ignored in gerrit, until the issue is fixed the dummy call is needed.
curl http://localhost:8080/projects

# Create repository
HTTP_TOKEN=$(/scripts/get_gerrit_token.exp | tail -1 | sed 's/^[^"]*"\([^"]*\)".*/\1/')
echo \'$HTTP_TOKEN\'
curl -X PUT -d '{"create_empty_commit": true}' --header 'Content-Type: application/json; charset=UTF-8' --user admin:$HTTP_TOKEN http://localhost:8080/a/projects/new-project

# Add ssh-key
ssh-keygen -t rsa -q -f "/root/.ssh/id_rsa" -N ""
curl -X POST --user admin:$HTTP_TOKEN -d@/root/.ssh/id_rsa.pub --header "Content-Type: text/plain" http://localhost:8080/a/accounts/1000000/sshkeys
echo "StrictHostKeyChecking no" > /root/.ssh/config

# create new Change
git clone "ssh://admin@localhost:29418/new-project" && scp -p -P 29418 admin@localhost:hooks/commit-msg "new-project/.git/hooks/"
cd new-project
git config --global user.email admin@example.com
git config --global user.name Administrator
/scripts/make_change.sh

# Add reviewdog user
ssh -p 29418 admin@localhost gerrit create-account --group "'Service Users'" --http-password rev_pass reviewdog

# Installation of necessary dependencies
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s
wget https://github.com/chipsalliance/verible/releases/download/v0.0-2548-g5e00342c/verible-v0.0-2548-g5e00342c-CentOS-7.9.2009-Core-x86_64.tar.gz
tar -xf verible-v0.0-2548-g5e00342c-CentOS-7.9.2009-Core-x86_64.tar.gz
git clone https://github.com/chipsalliance/verible-linter-action.git

# Setup enviroment
cd verible-linter-action && git apply /scripts/rdf_gen.diff && cd ..
export PATH=$(pwd)/verible-v0.0-2548-g5e00342c/bin:$(pwd)/verible-linter-action:$PATH
export REVIEWDOG_BIN=$(pwd)/bin/reviewdog
source /scripts/set_env.sh

# # Run reviewdog integration script
CHANGE_ID=$(git show | grep Change-Id: | sed 's/^.*: \(.*\)$/\1/')
echo \'$CHANGE_ID\'
/scripts/verible_script.sh $CHANGE_ID
