#!/bin/bash

diff_cmd="git diff FECH_HEAD"

export GERRIT_CHANGE_ID=I6a527454d740b2dc7a34b15f777ef993150dcafe
export GERRIT_REVISION_ID=current
export GERRIT_BRANCH=master
export GERRIT_ADDRESS=http://localhost:8080
export GERRIT_USERNAME=reviewdog
export GERRIT_PASSWORD=rev_pass

action.py --log-file verible.log $1
rdf_gen.py --efm-file verible.log > verible_output.rdf
${REVIEWDOG_BIN} -f=rdjson -reporter=gerrit-change-review -diff="$diff_cmd" < verible_output.rdf
