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

* Install at least docker-ce 20.10
  (See https://docs.docker.com/engine/install/)
* Install latest docker buildx plugin
  (See https://docs.docker.com/buildx/working-with-buildx/)

## Project features

This project includes the following features:

* Use local context key/value files for project configuration settings `(.context.*)`
* Use local cache directory for injecting files at buildtime `(rootfs/*)`
* Use some bash shell scripts for build-, runtime and configuration `(grav_*.sh)`
* Use docker buildx builder for external docker image storage `(--cache-from, --cache-to)` in a local directory `(.volumes/grav_cache/.ccache)`
* Use docker buildx builder for specific platform builds, here `(linux/amd64)`
* Create a named user `(grav)` with SSH keys for vscode development over remote SSH
* Inject a user password for SSH login securely
* Inject the SSH keys for automatic logins and cache retrieval securely
* Use external cache volume created with ccache, rsync for faster php compilation `(.volumes/grav_cache/.ccache)`
* Mount docker named volume to a specific host directory `(.volumes/grav_data)`
* Rootfs repository for caching grav packages (packages, themes, skeletons, plugins)
* Use a local bash shared library `(libgrav)`

## Work in progress

* (WIP) Install PHP xdebug for vscode debugging over remote xdebug port
* (WIP) Run docker container services as non root user `(www-data)`
* (TBD) Create a multistage dockerfile with base, compile and release stage
* (TBD) Implement multiarch images wit QEMU static support
* (TBD) Create an alpine container for smaller footprint
* (TBD) Use buildx with docker composer file

## Using local key/value files for configuration

To persist some configuration data a couple of key/value files are created in this local directory. This `(.context.*)` files are identified by a key and a corresponding value.

```bash
GRAV_USER=grav
```

> NOTE: This files can be changed manually or by a local bash scripts that starts with `(./grav_mk*.sh)`

## Using docker multiarch environment

Using the extended docker build features of `(buildx)` this project is prepared for multiarch images. That means it uses one name for different target architectures `(linux/amd64, linux/arm64, ...)`. Currently only the linux/amd64 architecture is supported.

## Using local docker cache repository

In addition to the buildtime and compile cache environment there is another local directory `(./rootfs/*)` that can be used to store for example the grav zip files to avoid a lengthy download and compilation time.

In this case store the grav-admin.zip file under `(./rootfs/tmp)`. If the name is correct the file will be inserted into the docker buildtime context and used instead of downloading the file from the internet.

## Handling user password and SSH secrets

Using the extended docker build features of `(buildx)` the user password is encrypted externally `(SHA512)` using a provided bash script `(grav_mkssh.sh)` and injected into the build time container without traces.
The same thing occures for the SSH private and public key.

> NOTE: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host.

## Caching docker buildtime

Using the extended docker build features of `(buildx)` the docker buildtime cache is stored in a local project directory `(.volumes/grav_cache/.dcache)`. This can be of course changed to push/pull from a private registry if needed.

## Running services as non-root user

To increase the overall security the required services (SSH, Cron and Apache) are running under a non root user (www-data) context.

## Persisting build cache using ccache and rsync

`CCache` and `rsync` are used to speedup the building of PHP extensions. At buildtime and before the PHP compilation is started, the external cache directory `(.volumes/grav_cache/.ccache)` is read with `rsync` into the docker container `(/tmp/.ccache)`. CCache will reroute the compiler call to this specific directory for faster compilation. Before all build artefacts are removed the cache directory `(/tmp/.ccache)` is exported with `rsync` using incremental backup to preserve the compiled data for a next build  `(.volumes/grav_cache/.ccache)`.

> NOTE: Ensure that the SSH keys and user match the SSH keys of an external user on the local or remote host.

## Working with vscode locally or remotely

To avoid direct access to the docker container a SSH user is fully provided and configured. The SSH server is listening on port `(2222)` to avoid collision with other primary SSH server.
Point your vscode remote-SSH plugin to the localhost host or to the designated IP address and port `(2222)` to access the docker image for development.

## Managing a container from the command line

There are a couple of local bash scripts to create, run and delete a container:

* `grav_build.sh` is used for building a container
* `grav_run.sh` is used for running a container
* `grav_shell.sh` is used for accessing the command line inside a container

## Configuring a container from the command line

To be able to build or run a container some information is needed in advance:

* `Grav production version`
* `Grav development version`
* `Grav cache directory path`
* `Grav volume directory path`
* `Encrypted user password`
* `SSH private key`
* `SSH public key`
* `Username`

This information is stored into local project context files that begins with `.context.*`. To insert this data locally some local bash scripts are used `grav_mk*`. Feel free to include your own values if needed.

* `(grav_mkpass.sh)` = Configures the named container user and password
* `(grav_mkssh.sh)` = Configures the SSH private and public files for rsync, git, ...
* `(grav_ver.sh)` = Configures the grav production and version string information
* `(grav_data.sh)` = Configures the local data volume path `(.volumes/grav_data)`
* `(grav_cache.sh)` = Configures the local cache volume path `(.volumes/grav_cache/...)`

> NOTE: Please consult the usage information of each local bash script, executing the command without arguments.

## Persisting data into an external storage

To save the Grav site data to the host file system (so that it persists even after the container has been removed), simply map the container's `/var/www/html` directory to a named Docker volume (grav_data). This named docker volume (grav_data) is mapped into the project directory on the host (.volumes/grav_data).

> If the mapped directory or named volume is empty, it will be automatically populated with a fresh install of Grav the first time that the container starts. However, once the directory/volume has been populated, the data will persist and will not be overwritten the next time the container starts.

## Building the image from Dockerfile

To build the image from the command line a local bash script `(./grav_build.sh)` is needed.
This script as a lot of presetted arguments. The first argument is mandatory if not set the script emits a usage string.

Here an example how to create a user `(grav)` and build the latest grav+admin development package.

```bash
./grav_build.sh grav grav-admin testing
```

Here an example how to create a user `(grav)` and build the latest grav+admin production package. Observe that the last two arguments are omitted while presetted.

```bash
./grav_build.sh grav
```

Here the complete usage string of `(./grav_build.sh)` script:

```bash
$ ./grav_build.sh 
FAIL: Arguments are not provided!

ARGS: grav_build.sh grav_user [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]
NOTE: (*) are default values, (#) are recommended values

ARG1:     [grav_user]: any|(#)         - (#=grav)
ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)
ARG3:  [grav_tagname]: latest|testing  - (*=latest)
ARG4: [grav_passfile]: any|(*)         - (*=<current-dir>/grav_pass.key)
ARG5: [grav_privfile]: any|(*)         - (*=<current-dir>/grav_rsa)
ARG6:  [grav_pubfile]: any|(*)         - (*=<current-dir>/grav_rsa.pub)

INFO: grav_build.sh grav grav-admin latest /home/rpiadmin/Workspace/docker-grav/grav_pass.key /home/rpiadmin/Workspace/docker-grav/grav_rsa /home/rpiadmin/Workspace/docker-grav/grav_rsa.pub
```

The docker image has the following scheme:

* <grav-user=grav>/<grav-name=<grav|grav-admin>:<grav-tag=latest|testing>

e.g. `grav/grav:latest` or `(grav/grav-admin:testing)`

## Running the image from Dockerfile

To run the image from the command line a local bash script `(./grav_run.sh)` is needed.
This script as a lot of presetted arguments. The first argument is mandatory if not set the script emits a usage string.

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` development package.

```bash
./grav_run.sh grav grav-admin testing
```

Here an example how to run as user `(grav)` and use the latest `(grav-admin)` production package. Observe that the last two arguments are omitted while presetted.

```bash
./grav_run.sh grav grav-admin
```

Here the complete usage string of `(./grav_run.sh)` script:

```bash
$ ./grav_run.sh
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
