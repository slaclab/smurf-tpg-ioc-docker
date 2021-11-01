# SLAC's TPG IOC Docker image for the SMuRF project

## Description

This repository can build the smurf-tpg-ioc docker image. This image runs SLAC's TPG IOC modified for SMuRF. This image depends on the smurf-epics-slac image, which runs Centos 6, and contains all the SLAC's packages, EPICS base, and EPICS modules needed to build this IOC. The name of the IOC used in this project is sioc-smrf-ts01.

## Source code

The IOC source code was taken from SLAC's version, hosted in an internal git repository. The code was manually checkout from AFS-based git (tagged version **R1.7.3-1.3.0**), cleaned (removed SLAC's IOCs and some empty or not relevant files), and copied into this repository.

## Build the image

```
docker build
```

There is currently no automated deploy process for this image. 

## Setup the host

The host must be setup before running the IOC. The IOC uses autosave and iocAdmin which persists its PV values. To do this, the host /data directory is mapped to /data inside the container. More specifically, the IOC data is located at the following path. The host will not start without autosave files (see https://github.com/slaclab/smurf-tpg-ioc-docker/issues/2) in the directory

```
/data/epics/ioc/data/sioc-smrf-ts01
```

Open TCP UDP ports 5064 and 5065 on the docker container to access the IOC PVs from outside the host. No change is necessary to access the IOC PVs from within the same host, from for example pysmurf on the same host. 

## Run using Docker

Run in the foreground.

```
docker run -ti --rm --name smurf-tpg-ioc \
-v <LOCAL_DATA_PATH>:/data \
-p 5064:5064 -p 5065:5065 -p 5064:5064/udp -p 5065:5065/udp \
tidair/smurf-tpg-ioc:<VERSION>
```

Run in the background.

```
docker run -tid --rm --name smurf-tpg-ioc \
-v <LOCAL_DATA_PATH>:/data \
-p 5064:5064 -p 5065:5065 -p 5064:5064/udp -p 5065:5065/udp \
tidair/smurf-tpg-ioc:<VERSION>
```

Where:
- **LOCAL_DATA_PATH**: is the absolute path of the root of the IOC data directory in the host local disk. For example, if in the host this directory is `/data/epics/ioc/data/sioc-smrf-ts01`, then **LOCAL_DATA_PATH** = **/data**
By default the container will start the IOC.
- **VERSION**: is the tagged version of the container your want to run.

### Interact with the Docker container

Confirm that the container is running.

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
163326dec993        smurf-tpg-ioc       "./st.cmd"          31 seconds ago      Up 30 seconds                           awesome_raman
```

You can attach to the container with the command `docker attach smurf-tpg-ioc`. Detatch with `CRTL+p` followed by `CRTL+q`. You can stop the container with the command `docker stop smurf-tpg-ioc`.

## Run using start_ioc.sh

This IOC can also run outside Docker assuming the host was setup appropriately.

```
start_ioc.sh [-S|--shelfmanager <shelfmanager_name> -N|--slot <slot_number>]
             [-a|--addr <fpga_ip>] [-p|--prefix <epics_prefix>] [-h|--help]

    -S|--shelfmanager <shelfmanager_name> : ATCA shelfmanager node name or IP address. Must be used with -N.
    -N|--slot         <slot_number>       : ATCA crate slot number. Must be used with -S.
    -a|--addr         <fpga_ip>           : FPGA IP address. If defined, -S and -N are ignored.
    -p|--prefix       <epics_prefix>      : PV name prefix. Defaults to 'TPG:SMRF:1'
    -h|--help                             : Show this message.
```

If -a if not defined, then -S and -N must both be defined, and the FPGA IP address will be automatically calculated from the crate ID and slot number. If -a if defined, -S and -N are ignored. By default, the docker image is started setting the shelfmanager to `shm-smrf-sp01`, and the slot number to `2`, as defined in the `ENTRYPOINT` section in the `Dockerfile`.
