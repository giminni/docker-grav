# Docker Image for Grav (in development)

TL;DR

This project is forked from the official docker image for grav. If you want work with me on this project, feel free to download it from `(https://github.com/giminni/docker-grav)`

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

This Dockerfile needs the following prerequisites:

* Insert `export PATH=${PWD}/grav_bin:${PATH}` into your `.bashrc` script or execute it from the command line
* Install at least docker-ce 20.10
  (See https://docs.docker.com/engine/install/)
* Install latest docker buildx plugin
  (See https://docs.docker.com/buildx/working-with-buildx/)
* Install a newer version of openssl not older than 1.1.1
* Install uuid, jq, git, tree, vim or vscode for development

## Project structure

The project consists of different directories, each one has a specific role:

```bash
<PROJECT_HOME>
|-- [ ]  grav_bin        |-- (Directory for bash scripts)
|-- [*]  grav_cache      |-- (Directory for cache files) 
|-- [*]  grav_cfg        |-- (Directory for config files) 
|-- [*]  grav_data       |-- (Directory for data files)  
|-- [ ]  grav_docker     |-- (Directory for docker files)
|-- [*]  grav_key        |-- (Directory for SSH & user keys)
|-- [ ]  grav_lib        |-- (Library for shell scripts)
|-- [ ]  grav_rootfs     |-- (Repository for packages and files)
|-- [ ]  .dockerignore
|-- [ ]  .gitignore
|-- [ ]  Dockerfile -> ./grav_docker/Dockerfile
`-- [ ]  README.md
```

> NOTE: The files or directory content marked with `[*]` are not uploaded to Git. They must be build with the appropriate `(<PROJECT_HOME>/grav_bin/grav_mk*)` script.

> NOTE: To initialize the project, execute `./grav_bin/grav_mkinit.sh init` first from the `(<PROJECT_HOME>)` directory.

## Project features

This project includes the following features:

* Use local context key/value files for project configuration settings `(<PROJECT_HOME>/.context.*)`
* Use local cache directory for injecting files at buildtime `(<PROJECT_HOME>/grav_rootfs/*)`
* Use some sophisticated bash shell scripts for build, runtime and configuration `(<PROJECT_HOME>/grav_bin/grav_*.sh)`
* Use the latest docker buildx builder for external docker image storage `(--cache-from, --cache-to)` in a local directory `(<PROJECT_HOME>/grav_cache/.ccache)`
* Use the latest docker buildx builder for specific platform builds, here `(linux/amd64)`
* Ability to create a named user `(grav)` with SSH keys for vscode development over remote SSH over port 2222
* Ability to create a user password for SSH login securely
* Ability to create and add the SSH keys for automatic logins and cache retrieval from local or remote host securely
* Use external cache volume with ccache, rsync for faster php compilation `(<PROJECT_HOME>/grav_cache/.ccache)`
* Mount a docker named volume `(grav_data)` to a specific host directory `(<PROJECT_HOME>/grav_data)`
* Create a repository `(<PROJECT_HOME>/rootfs)` for caching grav packages (packages, themes, skeletons, plugins)
* Use a local bash shared library `(libgrav)` for all local bash scripts

## Work in progress

* (WIP) Install PHP xdebug for vscode debugging over remote xdebug port
* (WIP) Run docker container services as non root user `(www-data)`
* (TBD) Create a multistage dockerfile with base, compile and release stage
* (TBD) Implement multiarch images wit QEMU static support
* (TBD) Create an alpine container for smaller footprint
* (TBD) Use buildx with docker composer file
* (TBD) Ability to install grav skeletons and plugins

## Installation procedure

* Install the prerequisite software (See [Prerequisites](#-prerequisites)
* Download the project with git `git clone https://github.com/giminni/docker-grav`
* Change into the current project directory with `cd docker-grav`
* Initialize the project with `${PWD}/grav_bin/grav_mkinit.sh init`
* Reload bash shell with `source ${HOME}/.bashrc`
* Set the current grav core production and development package version with `grav_setcore.sh all`, older grav core packages version can be set manually, for example with `grav_setcore.sh 1.6.0` for production package version or `grav_setcore.sh 1.7.0-rc.19` for development package version.
* Download the grav core production packages with `grav_getcore all grav` or the core development packages with `grav_getcore all grav-admin`, older grav core packages can be set manually, for example with `grav_getcore.sh 1.6.0 grav` for production package version or `grav_getcore.sh 1.7.0-rc.19 grav-admin` for development package version.
* Create the encrypted password for user `grav` with `grav_mkpass.sh <user-password> grav`, the password must contain at least 11 characters
* Create new or use your own SSH private and public key with `grav_mkssh.sh <email-address>` by answering with `1` for create new SSH key or `2` for use own SSH key. The latter case will copy the key from your `${HOME}/.ssh` directory.
* Create the cache directory with `grav_mkcache.sh grav_cache`
* Build the docker image with `grav_build grav grav-admin testing` for the development version or `grav_build.sh grav` for the production version.
* Create the data directory with `grav_mkdata.sh grav_data`
* Run the docker image with `grav_run grav grav-admin testing` for the development version or `grab_run.sh grav` for the production version.
* Enter the command line of the running grav image, with `grav_shell.sh bash grav-admin` for the development version or `grav_shell.sh bash grav` for the production version.

## Installation checklist

* Check if scripts are available by entering `grav_` and pressing the TAB-key
* Check if the `.context` file is created in the project directory with `cat ${PWD}/.context`
* Check if the configuration directory `grav_cfg` is populated with `.config.*` files with `ls -las ${PWD}/grav_cfg`
* Check `grav_pass.key` file under the key directory `grav_key` with `cat ${PWD}/grav_key/grav_pass.key`
* Check if the SSH keys exists with `ls -las ${PWD}/grav_key/grav_rsa*` if you are using the `rsa` algorithm. Other algorithm that can be used are `dsa` and `ecdsa`.
* Check if the grav core file was downloaded correctly into the `grav_rootfs` directory, with `ls -las ${PWD}/grav_rootfs/tmp`.
* Check if the cache directory exists with `ls -las ${PWD}/grav_cache`. A subdirectory `.ccache` must exists, otherwise the `grav-build.sh` script throw an error.
* Check if the docker grav image exists, with `sudo docker images`
* Check if the docker grav image is running, with `sudo docker ps -a`

## Using local key/value files for configuration

To persist some project configuration data a couple of key/value files are created in the `(<PROJECT_HOME>/grav_cfg)` directory. A `(<PROJECT_HOME>/.context)` file will be generated with `(<PROJECT_HOME/grav_bin/grav_mkinit.sh init)` at init time holding the configuration directory where all configuration files are stored. 

E.g. `.context` file in `(<PROJECT_HOME>/)` directory:

```bash
GRAV_CTX="<PROJECT_HOME>/grav_cfg"
```

E.g. `.config.bin` file in `(<PROJECT_HOME>/grav_cfg)` directory:

```bash
GRAV_BIN="<PROJECT_HOME>/grav_bin"
```

> NOTE: Every configuration files can be changed manually by expert user or use the handy local bash scripts that starts with `(<PROJECT_HOME>/grav_bin/grav_mk*.sh)` for novice user.

## Using docker multiarch environment

Using the extended docker build features of `(buildx)` this project is prepared for multiarch images. That means it uses one name for different target architectures `(linux/amd64, linux/arm64, linux/armv7, ...)`. Currently only the `(linux/amd64)` architecture is supported.

## Using local docker cache repository

In addition to the build and compile cache environment, there is another local directory `(./<PROJECT_HOME>/grav_rootfs/*)` that holds cached artefacts. This directory can be used to store for example the grav core zip files to reduce bandwith and avoid a lengthy download time from the internet.

In this case store the `(grav-admin.zip)` file under `(<PROJECT_HOME>/grav_rootfs/tmp)`. If the name is correct the file will be inserted into the docker buildtime context and used instead of downloading the file from the internet.

## Handling user password and SSH secrets

The extended docker build features of `(buildx)` allows injecting sensitive data without leaving any history trace. The user password is generated externally with openssl `(SHA512)` encryption by a provided bash script `<PROJECT_HOME>/grav_bin/mkssh.sh)`. The encrypted password is then stored under `(<PROJECT_DIR>/grav_key/grav_pass.key)` and injected into the container at buildtime.

The same thing occures for the SSH private and public key. The key are stored under `(<PROJECT_DIR/grav_key/grav_rsa)` and `(<PROJECT_DIR/grav_key/grav_rsa.pub)` respectively.

> NOTE: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host. Otherwise the user autologin over SSH and cache synchronization over github, rsync does not work.

## Caching docker buildtime

The extended docker build features of `(buildx)` allows to store the docker buildtime cache into a local project directory `(<PROJECT_HOME>/grav_cache/.dcache)`. This can be of course changed to push/pull from a pubic/private registry if needed.

## Running services as non-root user

To increase the overall security the required services (SSH, Cron and Apache) are running under a non root user (www-data) context.

## Persisting build cache using ccache and rsync

`CCache` and `rsync` are used to speedup the building of PHP extensions. At buildtime and before the PHP compilation is started, the external cache directory `(<PROJECT_HOME>/grav_cache/.ccache)` is read with `rsync` into the docker container `(/tmp/.ccache)`. CCache will reroute the compiler call to this specific directory for faster compilation. Before all build artefacts are removed the cache directory `(/tmp/.ccache)` is exported with `rsync` using incremental backup to preserve the compiled data for a next build  `(<PROJECT_HOME>/grav_cache/.ccache)`.

> NOTE: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host.

## Working with vscode locally or remotely

To avoid direct access to the docker container a SSH user is fully provided and configured. The SSH server is listening on port `(2222)` to avoid collision with other primary SSH server.
Point your vscode remote-SSH plugin to the localhost host or to the designated IP address and port `(2222)` to access the docker image for development.

## Managing a container from the command line

There are a couple of local bash scripts to create, run and delete a container:

* `grav_build.sh` is used for building a container
* `grav_run.sh` is used for running a container
* `grav_shell.sh` is used for accessing the command line inside a container
* `grav_purge.sh` is used for deleting all cached data, container and image artefacts.

## Configuring a container from the command line

The following data is needed to be able to build or run a container:

* Grav binary directory path `(.config.bin)`, e.g. `GRAV_BIN=<PROJECT_HOME>/grav_bin"`
* Grav cache directory path `(.config.cache)`, e.g. `GRAV_CACHE="<PROJECT_HOME>/grav_cache"`
* Grav config directory path `(.config.cfg)`, e.g. `GRAV_CFG=<PROJECT_HOME>/grav_cfg"`
* Grav data volume directory path `(.config.data)`, e.g. `GRAV_DATA="<PROJECT_HOME>/grav_data"`
* Grav development core version `(.config.dev)`, e.g. `GRAV_DEV=1.7.0-rc.20`
* Grav docker directory path `(.config.docker)`, e.g. `GRAV_DOCK=<PROJECT_HOME>/grav_docker"`
* Grav home directory path `(.config.home)`, e.g. `GRAV_HOME=<PROJECT_HOME>"`
* Grav key directory path `(.config.key)`, e.g. `GRAV_KEY="<PROJECT_HOME>/grav_key"`
* Grav library directory path `(.config.lib)`, e.g. `GRAV_LIB="<PROJECT_HOME>/grav_lib"`
* Grav password file `(.config.pass)`, e.g. `GRAV_PASS="<PROJECT_HOME>/grav_key/grav_pass.key"`
* Grav production core version `(.config.prod)`, e.g. `GRAV_PROD=1.6.1`
* Grav rootfs directory path `(.config.root)`, e.g. `GRAV_ROOT="<PROJECT_HOME>/grav_rootfs"`
* Grav SSH key directory path `(.config.ssh)`, e.g. `GRAV_SSH=<PROJECT_HOME>/grav_key/grav_rsa"`
* Grav username `(.config.user)`, e.g. `GRAV_USER=grav`

This information is stored into local project connfig files that begins with `(<PROJECT_HOME>/grav_cfg/.*)`. To insert this data locally some local bash scripts are used `grav_mk*`. Every file is filled with a default value, however feel free to change it to suite your needs.

* `(<PROJECT_HOME>/grav_bin/grav_build.sh)` = Build the grav docker image from the specified values
* `(<PROJECT_HOME>/grav_bin/grav_getcore.sh)`= Download the corresponding production/development core file into `(<PROJECT_HOME>/rootfs)` directory
* `(<PROJECT_HOME>/grav_bin/grav_mkcache.sh)` = Configures the local cache volume path `(<PROJECT_HOME>/grav_cache/*)`
* `(<PROJECT_HOME>/grav_bin/grav_mkdata.sh)` = Configures the local data volume path `(<PROJECT_HOME>/grav_data)`
* `(<PROJECT_HOME>/grav_bin/grav_mkinit.sh)` = Initialize project, must run first. (See [Installation procecure](#-installation-procedure))
* `(<PROJECT_HOME>/grav_bin/grav_mkpass.sh)` = Configures the named container user and password
* `(<PROJECT_HOME>/grav_bin/grav_mkssh.sh)` = Configures the SSH private and public files for rsync, git, ...
* `(<PROJECT_HOME>/grav_bin/grav_purge.sh)` = Remove all grav artefacts, build cache, container and images
* `(<PROJECT_HOME>/grav_bin/grav_run.sh)` = Run the grav docker container from the specified values
* `(<PROJECT_HOME>/grav_bin/grav_setcore.sh)` = Configures the grav production/development core version string
* `(<PROJECT_HOME>/grav_bin/grav_shell.sh)` = Access the container over SSH on port `2222` using the provided SSH keys

> NOTE: Please consult the usage information of each local bash script by executing the command without arguments.

## Downloading files to be cached into the rootfs directory

To be able to create the project in offline situation or minimize the download time from the internet, two tasks must be executed:

* Define wich grav version is needed to be installed from the grav download site using a local script `(<PROJECT_HOME>/grav_bin/grav_mkcore.sh)`.  Insert as first argument `(prod)` or `(dev)`. To download a specific version use `(<PROJECT_HOME/grav_bin/grav_getcore.sh)`. Use the same arguments like `(<PROJECT_HOME>/grav_bin/grav_mkcore.sh)`

E.g. to download a specific version of grav-admin core `(1.6.0)` enter:

```bash
<PROJECT_HOME>/grav_bin/grav_getcore.sh 1.6.0 grav-admin
```

> NOTE: The files are stored into the `(<PROJECT_HOME>/grav_rootfs/tmp)`. To reduce the container size, remove all superfluous artefacts before starting the build.

## Persisting data into an external storage

To save the Grav site data to the host file system (so that it persists even after the container has been removed), simply map the container's `/var/www/html` directory to a named Docker volume `(grav_data)`. This named docker volume `(grav_data)` is mapped into the project directory on the host `(<PROJECT_HOME>/grav_data)`.

> NOTE: If the mapped directory or named volume is empty, it will be automatically populated with a fresh install of Grav the first time that the container starts. However, once the directory/volume has been populated, the data will persist and will not be overwritten the next time the container starts.

## Building the image from Dockerfile

To build the image from the command line a local bash script `(<PROJECT_HOME>/grav_bin/grav_build.sh)` is used.

This script as a lot of presetted arguments. The first argument is mandatory if not set, the script emits a usage string.

Here an example, how to create a user `(grav)` and build the latest grav+admin development package.

```bash
<PROJECT_HOME>/grav_bin/grav_build.sh grav grav-admin testing
```

Here an example how to create a user `(grav)` and build the latest grav+admin production package. Observe that the last two arguments are omitted while presetted.

```bash
<PROJECT_HOME>/grav_bin/grav_build.sh grav
```

Here the complete usage string of `(<PROJECT_HOME>/grav_bin/grav_build.sh)` script:

```bash
<PROJECT_HOME> $ ./grav_bin/grav_build.sh 
FAIL: Arguments are not provided!

ARGS: grav_build.sh grav_user [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]
NOTE: (*) are default values, (#) are recommended values

ARG1:       grav_user: any|(#)         - (#=grav)
ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)
ARG3:  [grav_tagname]: latest|testing  - (*=latest)
ARG4: [grav_passfile]: any|(*)         - (*=<PROJECT_HOME>/grav_keys/grav_pass.key)
ARG5: [grav_privfile]: any|(*)         - (*=<PROJECT_HOME>/grav_keys/grav_rsa)
ARG6:  [grav_pubfile]: any|(*)         - (*=<PROJECT_HOME>/grav_keys/grav_rsa.pub)

INFO: grav_build.sh grav grav-admin latest /home/rpiadmin/Workspace/docker-grav/grav_key/grav_pass.key /home/rpiadmin/Workspace/docker-grav/grav_key/grav_rsa /home/rpiadmin/Workspace/docker-grav/grav_key/grav_rsa.pub

HELP: grav_build.sh: Builds the docker file from some entered arguments. (See NOTE, INFO and ARGS)
```

## Running the image from Dockerfile

To run the image from the command line a local bash script `(<PROJECT_HOME>/grav_bin/grav_run.sh)` is needed.
This script as a lot of presetted arguments. The first argument is mandatory if not set the script emits a usage string.

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` development package.

```bash
<PROJECT_HOME>/grav_bin/grav_run.sh grav grav-admin testing
```

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` production package. Observe that the last two arguments are omitted while presetted.

```bash
<PROJECT_HOME>/grav_bin/grav_run.sh grav grav-admin
```

Here the complete usage string of `(<PROJECT_HOME>/grav_bin/grav_run.sh)` script:

```bash
<PROJECT_HOME> $ ./grab_bin/grav_run.sh
FAIL: Arguments are not provided!

ARGS: grav_run.sh grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_voldata=grav_data]
NOTE: (*) are default values, (#) are recommended values

ARG1:      grav_user: any|(#) - (#=grav)
ARG2: [grav_imgname|: any|(*) - (*=grav-admin)
ARG3:  [grav_imgtag|: any|(*) - (*=latest)
ARG4: [grav_voldata]: any|(*) - (*=grav_data)

INFO: grav_run.sh grav grav-admin latest grav_data

HELP: grav_run.sh: Instantiate a docker container depending from some entered arguments. (See NOTE, INFO and ARGS)
```

IF you installed the `(grav-admin)` package the point the browser to `http://localhost:8000/admin` and create a user account, otherwise point the browser to `http://localhost:8000/` directly.

> NOTE: The following ports are exposed: 

* `(2222)`: for SSH secondary access using the named user
* `(8080)`: for HTTP secondary access
* `(8443)`: for HTTPS secondary access (WIP)

The docker image has the following scheme:

* <grav-user=grav>/<grav-name=<grav|grav-admin>:<grav-tag=latest|testing>

E.g. `grav/grav:latest` for production images or `(grav/grav-admin:testing)` for development images.
