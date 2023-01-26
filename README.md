# Verible integration with Gerrit

Copyright (c) 2023 [Antmicro](https://www.antmicro.com>)

This project allows to create a docker container that runs Gerrit and automatically posts Verible warnings from example
repository as comments in Gerrit Change.

# Container manual

To create and run the container, the following commands can be used:
```
docker build -t <container-name> .
docker run <container-name>
```

It will start the Gerrit server, and when it's ready it will create a project. Then it will run the Verible linter to create warnings
about code style violations and will send those warning as comments into the Gerrit Change created earlier.

The guide below shows how to manually recreate the steps done by the container above

# Create and configure a Gerrit project
1. Create a container with Gerrit server\
It can be done with the following command:\
`docker run -ti -p 8080:8080 -p 29418:29418 gerritcodereview/gerrit`\
You can find more information about this process [here](https://hub.docker.com/r/gerritcodereview/gerrit).
2. Create a repository.\
Open http://localhost:8080 in your webbrowser. Skip the intro and create a new repository by clicking:\
BROWSE (on the menu on top of the page) -> Repositories -> CREATE NEW (in the top right corner)

       Note: On the project page there are some commands provided. They had URLs that seems to be random. When using them,
       you should replace random part with `localhost:8080`.

3. Clone the repository and add a hook\
The hook adds a ChangeId field to commit messages, which is required by Gerrit. It can be done with the following command:

       git clone "http://localhost:8080/my_project" && (cd "my_project" && mkdir -p .git/hooks && curl -Lo `git rev-parse --git-dir`/hooks/commit-msg http://localhost:8080/tools/hooks/commit-msg; chmod +x `git rev-parse --git-dir`/hooks/commit-msg)

4. Create a commit and open a Change (steps 1 - 5 can be done by running `make_change.sh` script):
   1. git checkout -b add-code
   2. echo "module t; endmodule" > code.v
   3. git add code.v
   4. git commit -m "Add code"
   5. git push origin HEAD:refs/for/master
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
It can be done on your native system, this part does not need to be dockerized.
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
It can be done by running the `source set_env.sh` script. Please check the script to see if any adjustments are needed on your machine.

# Usage
The following steps assume that you have already created a Change in Gerrit.\
1. Go to the project directory
1. Checkout a commit that is related to the Change.
2. Run `verible_script.sh <change-id>`
`change-id` is a field that is added to the commit description. You can check the change-id by running `git show`.\
Verible will be run on the `*.v` and `*.sv` files from this directory. Warnings from the lines that
are untouched in the Change are skipped.\
You can now go to the Change on the porject page and see the comment with Verible warning posted by reviewdog account.

