# Verible integration with Gerrit

The script allows to automatically push Verible warnings as comments in Gerrit`s Changes.\
The manual below provides steps to setup Gerrit on docker container and automatically post Verible warnings
as comments in Gerrit's Change.

# Create and configure a Gerrit project
1. Create a container\
It can be done by the command:\
`docker run -ti -p 8080:8080 -p 29418:29418 gerritcodereview/gerrit`\
You can find more information [here](https://hub.docker.com/r/gerritcodereview/gerrit).
2. Create a repository.\
Go to page http://localhost:8080. Skip the intro and create repository by clicking:\
BROWSE (on the menu on top of the page) -> Repositories -> CREATE NEW (in the top right corner)

       Note: On the project page there are some commands provided. They had URLs that seems to be random. When using them,
       you should replace random part with `localhost:8080`.

3. Clone a repository and add a hook\
The hook adds a ChangeId field to commit messages, which is required by Gerrit. It can be done by the command:

       git clone "http://localhost:8080/my_project" && (cd "my_project" && mkdir -p .git/hooks && curl -Lo `git rev-parse --git-dir`/hooks/commit-msg http://localhost:8080/tools/hooks/commit-msg; chmod +x `git rev-parse --git-dir`/hooks/commit-msg)

4. Create a commit and open a Change:
   1. git checkout -b add-code
   2. echo "module t; endmodule" > code.v
   3. git add code.v
   4. git commit -m "Add code"
   5. git push origin HEAD:refs/for/master\
   6. You need the account credentials. The username is `admin`, the password can be generated in account settings.
Then you can go to project page, click `VIEW CHANGES` (just under a project name) and see the change that was created.
6. Create reviewdog user:
   1. Log into the container on which Gerrit runs:\
   `docker exec -u 0 -it <container name> /bin/bash`\
   You can check the container name by running `docker ps`
   3. Generate ssh keys by command `ssh-keygen`
   4. Add generated public key to the account:\
   go to `SSH keys` section of account setting and paste there content of `/root/.ssh/id_rsa.pub`
   5. Finally run the command to create a user:\
   `ssh -p 29418 admin@localhost gerrit create-account --group "'Service Users'" --http-password rev_pass reviewdog`

# Prepare tools
It may be done on your native system, not the docker container
## At first use only
1. Clone this repository.
2. Install [reviewodog](https://github.com/reviewdog/reviewdog#installation).
3. Install [Verible](https://github.com/chipsalliance/verible/releases).
4. Clone repository [verible-linter-action](https://github.com/chipsalliance/verible-linter-action).
5. Apply diff to verible-linter-action:\
`git apply <path to rdf_gen.diff>`

## In each new terminal session
1. Add paths to `verible-linter-action` and `verible` directories in the `PATH` variable
2. Add path to reviewdog executable in `REVIEWDOG_BIN` variable.
3. Set environment variables required by Gerrit.
It can be done by running `source set_env.sh` command. However, you may want to change some of them.

# Usage
The following steps assume that you have already created Change in Gerrit.\
1. Go to the project directory
1. Checkout a commit that is related to the Change.
2. Run `verible_script.sh <change-id>`
`change-id` is a field that is added to the commit description. You can check the change-id by running `git show`.\
Verible will be run on the `*.v` and `*.sv` files from this directory. Warnings from the lines that
are untouched in the Change are skipped.\
You can now go to the Change on the porject page and see the comment with Verible warning posted by reviewdog account.

