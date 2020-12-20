# Docker Image for Grav (in development)

TL;DR

This project is forked from the official docker image for grav. If you want work with me, feel free to download it from `https://github.com/giminni/docker-grav`

It contains the original files:

* apache-2.4.38
* GD library
* Unzip library
* php7.4
* php7.4-opcache
* php7.4-acpu
* php7.4-yaml
* cron
* vim editor

In addition other packages are included:

* php7.4_pdo
* php7.4_pdo_mysql
* php7.4_pdo_pqsql
* php7.4-pgsql
* php7.4_xdebug
* ca-certificates
* ccache
* iputils-ping
* jq
* net-tools
* openssh-server
* openssl
* rsync
* sudo
* tree
* wget 

## Prerequisites

This project needs the following prerequisites:

* Install at least jq >= 1.5
* Install at least openssl >= 1.1.1
* Install at least docker-ce >= 20.10
  (See https://docs.docker.com/engine/install/)
* Install at least docker buildx plugin >= 0.5.0
  (See https://docs.docker.com/buildx/working-with-buildx/)
* Install jq, openssl, uuid, git, tree, vim or vscode for development

This prerequisites are checked automatically with `mkinit.sh init`.
Execute it with `${GRAV_HOME}/bin/mkinit.sh init`. After that
reload your shell with `source ${HOME}/.bashrc`, now the home path
variable is `${GRAV_HOME}`.

## Project structure

The project consists of different directories, each one has a specific role:

```bash
${GRAV_HOME}
|-- [ ]  bin            |-- (Directory for bash scripts)
|-- [*]  cache          |-- (Directory for cache files) 
|-- [*]  cfg            |-- (Directory for config files) 
|-- [*]  data           |-- (Directory for data files)  
|-- [ ]  docker         |-- (Directory for docker files)
|-- [*]  key            |-- (Directory for SSH & user keys)
|-- [ ]  lib            |-- (Library for shell scripts)
|-- [ ]  rootfs         |-- (Repository for packages and files)
|-- [ ]  .dockerignore
|-- [ ]  .gitignore
|-- [ ]  Dockerfile -> ./docker/Dockerfile
`-- [ ]  README.md
```

>  Note: The files or directory content marked with `[*]` are not uploaded to Git. They must be build with the appropriate `<PROJECT_ROOT>/bin/grav-mk*` script.

>  Note: To initialize the project, execute `./bin/grav-mkinit.sh init` first from the `${GRAV_HOME}` directory.

## Project features

This project includes the following features:

* Use local context key/value files for project configuration settings `${GRAV_HOME}/.context.*`
* Use local cache directory for injecting files at buildtime `${GRAV_HOME}/rootfs/*`
* Use some sophisticated bash shell scripts for build, runtime and configuration `${GRAV_HOME}/bin/grav-*.sh`
* Use the latest docker buildx builder for external docker image storage `--cache-from, --cache-to` in a local directory `${GRAV_HOME}/cache/.ccache`
* Use the latest docker buildx builder for specific platform builds, here `linux/amd64`
* Ability to create a named user `grav` with SSH keys for vscode development over remote SSH over port 2222
* Ability to create a user password for SSH login securely
* Ability to create and add the SSH keys for automatic logins and cache retrieval from local or remote host securely
* Use external cache volume with ccache, rsync for faster php compilation `${GRAV_HOME}/cache/.ccache`
* Mount a docker named volume `data` to a specific host directory `${GRAV_HOME}/data`
* Create a repository `${GRAV_HOME}/rootfs` for caching grav packages (packages, themes, skeletons, plugins)
* Use local bash shared library `libgrav*` for all local bash scripts

## Work in progress

* (WIP) Install PHP xdebug for vscode debugging over remote xdebug port
* (WIP) Run docker container services as non root user `www-data`
* (TBD) Create a multistage dockerfile with base, compile and release stage
* (TBD) Implement multiarch images wit QEMU static support
* (TBD) Create an alpine container for smaller footprint
* (TBD) Use buildx with docker composer file
* (TBD) Ability to install grav skeletons and plugins

## Installation procedure

* Install the prerequisite software (See [Prerequisites](#-prerequisites)
* Download the project with git `git clone https://github.com/giminni/docker-grav`
* Change into the current project directory with `cd docker-grav`
* Initialize the project with `${PWD}/bin/grav-mkinit.sh init`
* Reload bash shell with `source ${HOME}/.bashrc`
* Set the current grav core production and development package version with `grav-setcore.sh all`, older grav core packages version can be set manually, for example with `grav-setcore.sh 1.6.0` for production package version or `grav-setcore.sh 1.7.0-rc.19` for development package version.
* Download the grav core production packages with `grav_getcore all grav` or the core development packages with `grav_getcore all grav-admin`, older grav core packages can be set manually, for example with `grav-getcore.sh 1.6.0 grav` for production package version or `grav-getcore.sh 1.7.0-rc.19 grav-admin` for development package version.
* Create the encrypted password for user `grav` with `grav-mkpass.sh <user-password> grav`, the password must contain at least 11 characters
* Create new or use your own SSH private and public key with `grav-mkssh.sh <email-address>` by answering with `1` for create new SSH key or `2` for use own SSH key. The latter case will copy the key from your `${HOME}/.ssh` directory.
* Create the cache directory with `grav-mkcache.sh cache`
* Build the docker image with `grav_build grav grav-admin testing` for the development version or `grav-build.sh grav` for the production version.
* Create the data directory with `grav-mkdata.sh data`
* Run the docker image with `grav_run grav grav-admin testing` for the development version or `grab_run.sh grav` for the production version.
* Enter the command line of the running grav image, with `grav-shell.sh grav-admin` for the development version or `grav-shell.sh grav` for the production version.

## Installation checklist

* Check if scripts are available by entering `grav-` and pressing the TAB-key
* Check if the `.context` file is created in the project directory with `cat ${PWD}/.context`
* Check if the configuration directory `cfg` is populated with `.config.*` files with `ls -las ${PWD}/cfg`
* Check `grav_pass.key` file under the key directory `key` with `cat ${PWD}/key/grav_pass.key`
* Check if the SSH keys exists with `ls -las ${PWD}/key/grav_rsa*` if you are using the `rsa` algorithm. Other algorithm that can be used are `dsa` and `ecdsa`.
* Check if the grav core file was downloaded correctly into the `grav_rootfs` directory, with `ls -las ${PWD}/rootfs/tmp/grav/core`.
* Check if the cache directories exists with `ls -las ${PWD}/cache`. A subdirectory `.ccache` and `.phpcache` must exists, otherwise the `grav-build.sh` script does not start.
* Check if the docker grav image exists, with `sudo docker images`
* Check if the docker grav image is running, with `sudo docker ps -a`

## Using local key/value files for configuration

To persist some project configuration data a couple of key/value files are created in the `${GRAV_HOME}/cfg` directory. A `${GRAV_HOME}/.context` file will be generated with `<PROJECT_HOME/bin/grav-mkinit.sh init` at init time holding the configuration directory where all configuration files are stored. 

E.g. `.context` file in `${GRAV_HOME}/` directory:

```bash
GRAV_CTX="${GRAV_HOME}/cfg"
```

E.g. `.config.bin` file in `${GRAV_HOME}/cfg` directory:

```bash
GRAV_BIN="${GRAV_HOME}/bin"
```

>  Note: Every configuration files can be changed manually by expert user or use the handy local bash scripts that starts with `${GRAV_HOME}/bin/grav_mk*.sh` for novice user.

## Using docker multiarch environment

Using the extended docker build features of `buildx` this project is prepared for multiarch images. That means it uses one name for different target architectures `linux/amd64, linux/arm64, linux/armv7, ...`. Currently only the `linux/amd64` architecture is supported.

## Using local docker cache repository

In addition to the build and compile cache environment, there is another local directory `./${GRAV_HOME}/grav_rootfs/*` that holds cached artefacts. This directory can be used to store for example the grav core zip files to reduce bandwith and avoid a lengthy download time from the internet.

In this case store the `grav-admin.zip` file under `${GRAV_HOME}/rootfs/tmp`. If the name is correct the file will be inserted into the docker buildtime context and used instead of downloading the file from the internet.

## Handling user password and SSH secrets

The extended docker build features of `buildx` allows injecting sensitive data without leaving any history trace. The user password is generated externally with openssl `SHA512` encryption by a provided bash script `${GRAV_HOME}/bin/mkssh.sh`. The encrypted password is then stored under `${GRAV_HOME}/key/grav_pass.key` and injected into the container at buildtime.

The same thing occures for the SSH private and public key. The key are stored under `${GRAV_HOME}/key/grav_rsa` and `${GRAV_HOME}/key/grav_rsa.pub` respectively.

>  Note: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host. Otherwise the user autologin over SSH and cache synchronization over github, rsync does not work.

## Caching docker buildtime

The extended docker build features of `buildx` allows to store the docker buildtime cache into a local project directory `${GRAV_HOME}/cache/.dcache`. This can be of course changed to push/pull from a pubic/private registry if needed.

## Running services as non-root user

To increase the overall security the required services (SSH, Cron and Apache) are running under a non root user (www-data) context.

## Persisting build cache using ccache and rsync

`CCache` and `rsync` are used to speedup the building of PHP extensions. At buildtime and before the PHP compilation is started, the external cache directory `${GRAV_HOME}/cache/.ccache` is read with `rsync` into the docker container `<CONTAINER_ROOT>/tmp/.ccache`. CCache will reroute the compiler call to this specific directory for faster compilation. Before all build artefacts are removed the cache directory `<CONTAINER_ROOT>/tmp/.ccache` is exported with `rsync` using incremental backup to preserve the compiled data for a next build  `${GRAV_HOME}/cache/.ccache`.

>  Note: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host.

## Working with vscode locally or remotely

To avoid direct access to the docker container a SSH user is fully provided and configured. The SSH server is listening on port `2222` to avoid collision with other primary SSH server.
Point your vscode remote-SSH plugin to the localhost host or to the designated IP address and port `2222` to access the docker image for development.

## Managing a container from the command line

There are a couple of local bash scripts to create, run and delete a container:

* `grav-build.sh` is used for building a container
* `grav-run.sh` is used for running a container
* `grav-shell.sh` is used for accessing the command line inside a container
* `grav-purge.sh` is used for deleting all cached data, container and image artefacts.

## Configuring a container from the command line

The following data is needed to be able to build or run a container:

* Grav binary directory path `.config.bin`, e.g. `GRAV_BIN=${GRAV_HOME}/bin"`
* Grav cache directory path `.config.cache`, e.g. `GRAV_CACHE="${GRAV_HOME}/cache"`
* Grav config directory path `.config.cfg`, e.g. `GRAV_CFG=${GRAV_HOME}/cfg"`
* Grav data volume directory path `.config.data`, e.g. `GRAV_DATA="${GRAV_HOME}/data"`
* Grav development core version `.config.dev`, e.g. `GRAV_DEV=1.7.0-rc.20`
* Grav docker directory path `.config.docker`, e.g. `GRAV_DOCK=${GRAV_HOME}/docker"`
* Grav home directory path `.config.home`, e.g. `GRAV_HOME=${GRAV_HOME}"`
* Grav key directory path `.config.key`, e.g. `GRAV_KEY="${GRAV_HOME}/key"`
* Grav library directory path `.config.lib`, e.g. `GRAV_LIB="${GRAV_HOME}/lib"`
* Grav password file `.config.pass`, e.g. `GRAV_PASS="${GRAV_HOME}/key/grav_pass.key"`
* Grav production core version `.config.prod`, e.g. `GRAV_PROD=1.6.1`
* Grav rootfs directory path `.config.root`, e.g. `GRAV_ROOT="${GRAV_HOME}/rootfs"`
* Grav SSH key directory path `.config.ssh`, e.g. `GRAV_SSH=${GRAV_HOME}/key/grav_rsa"`
* Grav username `.config.user`, e.g. `GRAV_USER=grav`

This information is stored into local project connfig files that begins with `${GRAV_HOME}/cfg/.*`. To insert this data locally some local bash scripts are used `grav-mk*`. Every file is filled with a default value, however feel free to change it to suite your needs.

* `${GRAV_HOME}/bin/grav-build.sh` = Build the grav docker image from the specified values
* `${GRAV_HOME}/bin/grav-getcore.sh`= Download the corresponding production/development core file into `${GRAV_HOME}/rootfs` directory
* `${GRAV_HOME}/bin/grav-mkcache.sh` = Configures the local cache volume path `${GRAV_HOME}/cache/*`
* `${GRAV_HOME}/bin/grav-mkdata.sh` = Configures the local data volume path `${GRAV_HOME}/data`
* `${GRAV_HOME}/bin/grav-mkinit.sh` = Initialize project, must run first. (See [Installation procecure](#-installation-procedure))
* `${GRAV_HOME}/bin/grav-mkpass.sh` = Configures the named container user and password
* `${GRAV_HOME}/bin/grav-mkssh.sh` = Configures the SSH private and public files for rsync, git, ...
* `${GRAV_HOME}/bin/grav-purge.sh` = Remove all grav artefacts, build cache, container and images
* `${GRAV_HOME}/bin/grav-run.sh` = Run the grav docker container from the specified values
* `${GRAV_HOME}/bin/grav-setcore.sh` = Configures the grav production/development core version string
* `${GRAV_HOME}/bin/grav-shell.sh` = Access the container locally by opening a shell

>  Note: Please consult the usage information of each local bash script by executing the command without arguments.

## Downloading files to be cached into the rootfs directory

To be able to create the project in offline situation or minimize the download time from the internet, two tasks must be executed:

* Define wich grav version is needed to be installed from the grav download site using a local script `${GRAV_HOME}/bin/grav-setcore.sh`.  Insert as first argument `prod` or `dev`. To download a specific version use `<PROJECT_HOME/bin/grav-getcore.sh`. Use the same arguments like `${GRAV_HOME}/bin/grav-setcore.sh`

E.g. to download a specific version of grav-admin core `1.6.0` enter:

```bash
${GRAV_HOME}/bin/grav-getcore.sh 1.6.0 grav-admin
```

>  Note: The files are stored into the `${GRAV_HOME}/grav_rootfs/tmp`. To reduce the container size, remove all superfluous artefacts before starting the build.

## Persisting data into an external storage

To save the Grav site data to the host file system (so that it persists even after the container has been removed), simply map the container's `/var/www/html` directory to a named Docker volume `data`. This named docker volume `data` is mapped into the project directory on the host `${GRAV_HOME}/data`.

>  Note: If the mapped directory or named volume is empty, it will be automatically populated with a fresh install of Grav the first time that the container starts. However, once the directory/volume has been populated, the data will persist and will not be overwritten the next time the container starts.

## Building the image from Dockerfile

To build the image from the command line a local bash script `${GRAV_HOME}/bin/grav-build.sh` is used.

This script as a lot of presetted arguments. The first argument is mandatory if not set, the script emits a usage string.

Here an example, how to create a user `grav` and build the latest grav+admin development package.

```bash
${GRAV_HOME}/bin/grav-build.sh grav grav-admin testing
```

Here an example how to create a user `grav` and build the latest grav+admin production package. Observe that the last two arguments are omitted while presetted.

```bash
${GRAV_HOME}/bin/grav-build.sh grav
```

Here the complete usage string of `${GRAV_HOME}/bin/grav-build.sh` script:

```bash
${GRAV_HOME} $ ./bin/grav-build.sh 
Error: Arguments are not provided!

 Args: grav-build.sh grav_user [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]
 Note: (*) are default values, (#) are recommended values

 Arg1:       grav_user: any|(#)         - (#=grav)
 Arg2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)
 Arg3:  [grav_tagname]: latest|testing  - (*=latest)
 Arg4: [grav_passfile]: any|(*)         - (*=${GRAV_HOME}/key/grav_pass.key)
 Arg5: [grav_privfile]: any|(*)         - (*=${GRAV_HOME}/key/grav_rsa)
 Arg6:  [grav_pubfile]: any|(*)         - (*=${GRAV_HOME}/key/grav_rsa.pub)

 Info: grav-build.sh grav grav-admin latest /home/rpiadmin/Workspace/docker-grav/key/grav_pass.key /home/rpiadmin/Workspace/docker-grav/key/grav_rsa /home/rpiadmin/Workspace/docker-grav/key/grav_rsa.pub

 Help: grav-build.sh: Builds the docker file from some entered arguments. (See Note, Info and Args)
```

## Running the image from Dockerfile

To run the image from the command line a local bash script `${GRAV_HOME}/bin/grav-run.sh` is needed.
This script as a lot of presetted arguments. The first argument is mandatory if not set the script emits a usage string.

Here an example how to run as user `grav` and use the latest `grav-admin` development package.

```bash
${GRAV_HOME}/bin/grav-run.sh grav grav-admin testing
```

Here an example how to run as user `grav` and use the **latest** `grav-admin` production package. Observe that the last two arguments are omitted while presetted.

```bash
${GRAV_HOME}/bin/grav-run.sh grav grav-admin latest
```

Here the complete usage string of `${GRAV_HOME}/bin/grav-run.sh` script:

```bash
${GRAV_HOME} $ ./grab_bin/grav-run.sh
Error: Arguments are not provided!

 Args: grav-run.sh grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_voldata=data]
 Note: (*) are default values, (#) are recommended values

 Arg1:      grav_user: any|(#) - (#=grav)
 Arg2: [grav_imgname|: any|(*) - (*=grav-admin)
 Arg3:  [grav_imgtag|: any|(*) - (*=latest)
 Arg4: [grav_voldata]: any|(*) - (*=data)

 Info: grav-run.sh grav grav-admin latest data

 Help: grav-run.sh: Instantiate a docker container depending from some entered arguments. (See Note, Info and Args)
```

IF you installed the `grav-admin` package the point the browser to `http://localhost:8000/admin` and create a user account, otherwise point the browser to `http://localhost:8000/` directly.

>  Note: The following ports are exposed: 

* `2222`: for SSH secondary access using the named user
* `8080`: for HTTP secondary access
* `8443`: for HTTPS secondary access (WIP)

The docker image has the following scheme:

* <grav-user=grav>/<grav-name=<grav|grav-admin>:<grav-tag=latest|testing>

E.g. `grav/grav:latest` for production images or `grav/grav-admin:testing` for development images.

## References

* (Working with buildx)[https://docs.docker.com/buildx/working-with-buildx/]