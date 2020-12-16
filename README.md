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

* Insert `export PATH=${PWD}/grav_bin:${PATH}` into your .bashrc script
* Install at least docker-ce 20.10
  (See https://docs.docker.com/engine/install/)
* Install latest docker buildx plugin
  (See https://docs.docker.com/buildx/working-with-buildx/)

## Project structure

```bash
<PROJECT_ROOT>
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

> NOTE: The files or directory content marked with `[*]` are not uploaded to Git. They must be build with the appropriate `(<PROJECT_ROOT>/grav_mk*)` script.

> NOTE: To initialize the project, execute `./grav_bin/grav_mkinit.sh init` first.

## Project features

This project includes the following features:

* Use local context key/value files for project configuration settings `(<PROJECT_ROOT>/.context.*)`
* Use local cache directory for injecting files at buildtime `(<PROJECT_ROOT>/rootfs/*)`
* Use some bash shell scripts for build, runtime and configuration `(<PROJECT_ROOT>/grav_*.sh)`
* Use docker buildx builder for external docker image storage `(--cache-from, --cache-to)` in a local directory `(<PROJECT_ROOT>/grav_cache/.ccache)`
* Use docker buildx builder for specific platform builds, here `(linux/amd64)`
* Create a named user `(grav)` with SSH keys for vscode development over remote SSH
* Inject a user password for SSH login securely
* Inject the SSH keys for automatic logins and cache retrieval from local or remote host securely
* Use external cache volume with ccache, rsync for faster php compilation `(<PROJECT_ROOT>/grav_cache/.ccache)`
* Mount docker named volume to a specific host directory `(<PROJECT_ROOT>/grav_data)`
* <PROJECT_ROOT>/rootfs repository for caching grav packages (packages, themes, skeletons, plugins)
* Use a local bash shared library `(libgrav)` for all local bash scripts

## Work in progress

* (WIP) Install PHP xdebug for vscode debugging over remote xdebug port
* (WIP) Run docker container services as non root user `(www-data)`
* (TBD) Create a multistage dockerfile with base, compile and release stage
* (TBD) Implement multiarch images wit QEMU static support
* (TBD) Create an alpine container for smaller footprint
* (TBD) Use buildx with docker composer file

## Using local key/value files for configuration

To persist some project configuration data a couple of key/value files are created in this local directory. This `(<PROJECT_ROOT>/.context.*)` files are identified by a key and a corresponding value. E.g.

```bash
GRAV_USER=grav
```

> NOTE: This files can be changed manually or by a local bash scripts that starts with `(<PROJECT__ROOT>./grav_mk*.sh)`

## Using docker multiarch environment

Using the extended docker build features of `(buildx)` this project is prepared for multiarch images. That means it uses one name for different target architectures `(linux/amd64, linux/arm64, linux/armv7, ...)`. Currently only the `(linux/amd64)` architecture is supported.

## Using local docker cache repository

In addition to the build and compile cache environment, there is another local directory `(./<PROJECT_ROOT>/rootfs/*)` that holds cached artefacts. This directory can be used to store for example the grav zip files to avoid a lengthy download time from the internet.

In this case store the `(grav-admin.zip)` file under `(./<PROJECT_ROOT>/grav_rootfs/tmp)`. If the name is correct the file will be inserted into the docker buildtime context and used instead of downloading the file from the internet.

## Handling user password and SSH secrets

The extended docker build features of `(buildx)` allows to inject sensitive data without history trace. The user password is generated externally with `(SHA512)` using a provided bash script `<PROJECT_ROOT>/mkssh.sh)` stored under `(<PROJECT_DIR>/grav_keys/grav_pass.key)` and injected into the container at buildtime.

The same thing occures for the SSH private and public key. The key are stored under `(<PROJECT_DIR/grav_keys/grav_rsa)` and `(<PROJECT_DIR/grav_keys/grav_rsa.pub)`respectively.

> NOTE: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host. Otherwise the user autologin over SSH and cache synchronization over github, rsync does not work.

## Caching docker buildtime

The extended docker build features of `(buildx)` allows to store the docker buildtime cache into a local project directory `(<PROJECT_ROOT>/grav_cache/.dcache)`. This can be of course changed to push/pull from a private registry if needed.

## Running services as non-root user

To increase the overall security the required services (SSH, Cron and Apache) are running under a non root user (www-data) context.

## Persisting build cache using ccache and rsync

`CCache` and `rsync` are used to speedup the building of PHP extensions. At buildtime and before the PHP compilation is started, the external cache directory `(<PROJECT_ROOT>/grav_cache/.ccache)` is read with `rsync` into the docker container `(/tmp/.ccache)`. CCache will reroute the compiler call to this specific directory for faster compilation. Before all build artefacts are removed the cache directory `(/tmp/.ccache)` is exported with `rsync` using incremental backup to preserve the compiled data for a next build  `(<PROJECT_ROOT>/grav_cache/.ccache)`.

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

To be able to build or run a container some information is needed in advance:

* `Grav production core version, e.g. GRAV_PROD=1.6.1`
* `Grav development core version, e.g. GRAV_DEV=1.7.0-rc.19`
* `Grav cache directory path, e.g. GRAV_CACHE=<PROJECT_ROOT>/grav_cache`
* `Grav volume directory path, e.g. GRAV_VOL=<PROJECT_ROOT>/grav_data`
* `Grav password path, e.g. GRAV_PASS=<PROJECT_ROOT>/grav_pass.key`
* `SSH key directory path, e.g. GRAV_SSH=>PROJECT_ROOT>/grav_rsa`
* `Username, e.g. GRAV_USER=grav`

This information is stored into local project context files that begins with `<PROJECT_ROOT>/.*`. To insert this data locally some local bash scripts are used `grav_mk*`. Feel free to include your own values if needed.

* `<PROJECT_ROOT>/mkpass.sh)` = Configures the named container user and password
* `<PROJECT_ROOT>/mkssh.sh)` = Configures the SSH private and public files for rsync, git, ...
* `<PROJECT_ROOT>/mkcore.sh)` = Configures the grav production/development core version string
* `<PROJECT_ROOT>/getcore.sh)`= Download the corresponding production/development core file into `(<PROJECT_ROOT>/rootfs)` directory
* `<PROJECT_ROOT>/mkdata.sh)` = Configures the local data volume path `(<PROJECT_ROOT>/grav_data)`
* `<PROJECT_ROOT>/mkcache.sh)` = Configures the local cache volume path `(<PROJECT_ROOT>/grav_cache/*)`

> NOTE: Please consult the usage information of each local bash script by executing the command without arguments.

## Downloading files to be cached into the rootfs directory

To be able to create the project in offline situation or minimize the download time from the internet, two tasks must be executed:

* Define wich grav version is needed to be installed from the grav download site using a local script `(<PROJECT_ROOT>/grav_mkcore.sh)`.  Insert as first argument `(prod)` or `(dev)`. To download a specific version use `(<PROJECT_ROOT/grav_getcore.sh)`. Use the same arguments like `(<PROJECT_ROOT>/grav_mkcore.sh)`

E.g. to download a specific version of grav-admin core `(1.6.0)` enter:

```bash
./grav_getcore.sh 1.6.0 grav-admin
```

> NOTE: The files are stored into the `(<PROJECT_ROOT>/rootfs/tmp)`

## Persisting data into an external storage

To save the Grav site data to the host file system (so that it persists even after the container has been removed), simply map the container's `/var/www/html` directory to a named Docker volume `(grav_data)`. This named docker volume `grav_data)` is mapped into the project directory on the host `(<PROJECT_ROOT>/grav_data)`.

> NOTE: If the mapped directory or named volume is empty, it will be automatically populated with a fresh install of Grav the first time that the container starts. However, once the directory/volume has been populated, the data will persist and will not be overwritten the next time the container starts.

## Building the image from Dockerfile

To build the image from the command line a local bash script `(<PROJECT__ROOT>/grav_build.sh)` is needed.

This script as a lot of presetted arguments. The first argument is mandatory if not set, the script emits a usage string.

Here an example, how to create a user `(grav)` and build the latest grav+admin development package.

```bash
<PROJECT__ROOT>./grav_build.sh grav grav-admin testing
```

Here an example how to create a user `(grav)` and build the latest grav+admin production package. Observe that the last two arguments are omitted while presetted.

```bash
<PROJECT__ROOT>./grav_build.sh grav
```

Here the complete usage string of `(<PROJECT__ROOT>/grav_build.sh)` script:

```bash
$ <PROJECT__ROOT>./grav_build.sh 
FAIL: Arguments are not provided!

ARGS: grav_build.sh grav_user [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]
NOTE: (*) are default values, (#) are recommended values

ARG1:     [grav_user]: any|(#)         - (#=grav)
ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)
ARG3:  [grav_tagname]: latest|testing  - (*=latest)
ARG4: [grav_passfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_pass.key)
ARG5: [grav_privfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_rsa)
ARG6:  [grav_pubfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_rsa.pub)

INFO: grav_build.sh grav grav-admin latest /home/grav/Workspace/docker-grav/grav_keys/grav_pass.key /home/grav/Workspace/docker-grav/grav_keys/grav_rsa /home/grav/Workspace/docker-grav/grav_keys/grav_rsa.pub
```

The docker image has the following scheme:

* <grav-user=grav>/<grav-name=<grav|grav-admin>:<grav-tag=latest|testing>

E.g. `grav/grav:latest` for production images or `(grav/grav-admin:testing)` for development images.

## Running the image from Dockerfile

To run the image from the command line a local bash script `(<PROJECT__ROOT>/grav_run.sh)` is needed.
This script as a lot of presetted arguments. The first argument is mandatory if not set the script emits a usage string.

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` development package.

```bash
<PROJECT__ROOT>./grav_run.sh grav grav-admin testing
```

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` production package. Observe that the last two arguments are omitted while presetted.

```bash
<PROJECT__ROOT>./grav_run.sh grav grav-admin
```

Here the complete usage string of `(<PROJECT__ROOT>/grav_run.sh)` script:

```bash
$ <PROJECT__ROOT>./grav_run.sh
FAIL: Arguments are not provided!

ARGS: grav_run.sh grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_voldata=grav_data]
NOTE: (*) are default values, (#) are recommended values

ARG1:      grav_user: any|(#) - (#=grav)
ARG2: [grav_imgname|: any|(*) - (*=grav)
ARG3:  [grav_imgtag|: any|(*) - (*=latest)
ARG4: [grav_voldata]: any|(*) - (*=grav_data)

INFO: grav_run.sh grav grav latest grav_data
```

IF you installed the `(grav-admin)` package the point the browser to `http://localhost:8000/admin` and create a user account, otherwise point the browser to `http://localhost:8000/` directly.

> NOTE: The following ports are exposed: 

* `(2222)`: for SSH secondary access using the named user
* `(8080)`: for HTTP secondary access
* `(8443)`: for HTTPS secondary access (WIP)
