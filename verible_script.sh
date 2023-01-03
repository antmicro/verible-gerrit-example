#!/bin/bash

diff_cmd="git diff FECH_HEAD"
export GERRIT_CHANGE_ID=$1

action.py --log-file verible.log .
rdf_gen.py --efm-file verible.log > verible_output.rdf
${REVIEWDOG_BIN} -f=rdjson -reporter=gerrit-change-review -diff="$diff_cmd" < verible_output.rdf
