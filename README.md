# Verible integration with Gerrit

The script allows to automatically push Verible warnings as comments in Gerrit`s Changes.

The script has to be run in a project directory on which Verible has to be used.
1st script argument is a path to a directory. Verible will be run on the `*.v` and
`*.sv` files from this directory.
`GERRIT_CHANGE_ID` is used to point a Change to which the comments have to be added.
Warnings from the lines that are untouched in the Change are skipped.

It uses scripts from https://github.com/chipsalliance/verible-linter-action and
reviewdog: https://github.com/reviewdog/reviewdog. \
rdf_gen.diff has to be applied to verible-linter-action. It can be done by the command:\
`git apply <path to diff file>` in verible-linter-action directory.\
It requires to have a path to `verible-linter-action` directory in the `PATH` variable and a
path to reviewdog executable in `REVIEWDOG_BIN` variable.
