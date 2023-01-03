# Verible integration with Gerrit

The script allows to automatically push Verible warnings as comments in Gerrit`s Changes.

# Setup
## At first use only
1. Clone this repository.
2. Install [reviewodog](https://github.com/reviewdog/reviewdog#installation).
3. Install [Verible](https://github.com/chipsalliance/verible/releases).
4. Clone repository [verible-linter-action](https://github.com/chipsalliance/verible-linter-action).
5. Apply diff to verible-linter-action:\
`git apply <path to rdf_gen.diff>`
6. Create reviewdog user:\
`ssh -p 29418 admin@localhost gerrit create-account --group "'Service Users'" reviewdog`

## In each new terminal session
1. Add paths to `verible-linter-action` and `verible` directories in the `PATH` variable
2. Add path to reviewdog executable in `REVIEWDOG_BIN` variable.
3. Set environment variables required by Gerrit.
It can be done by running `source set_env.sh` command. However, you may want to change some of them.

# Usage
First push commit and create Change in Gerrit.\
Then just run `verible_script.sh <change-id>` in a directory with project you want to use Verible on.
`change-id` is a field that is added to the commit description.\
Verible will be run on the `*.v` and `*.sv` files from this directory. Warnings from the lines that
are untouched in the Change are skipped.

