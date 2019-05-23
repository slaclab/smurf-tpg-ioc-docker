# Application top directory
ARG APP_TOP=/root/Tpg

# Create the builder image
FROM jesusvasquez333/smurf-epics-slac:R1.0.0 as builder
ARG APP_TOP
# Add ipmitool to the image
RUN yum -y update && yum install -y ipmitool && yum clean all -y
# Set some EPICS env vars
ENV BASE_MODULE_VERSION R3.15.5-1.0
# Prepare the build directory
RUN mkdir -p ${APP_TOP}
WORKDIR ${APP_TOP}
# Copy the source code
ADD Tpg .
ADD start_ioc.sh .
# Copy the configuration files
ADD config .

# Build the application
RUN make distclean && make

# Create the final image
FROM centos:6.10
ARG APP_TOP
## EPICS CONFIGURATIONS (should come from builder)
ENV EPICS_CA_REPEATER_PORT 5065
ENV EPICS_CA_AUTO_ADDR_LIST YES
ENV EPICS_CA_SERVER_PORT 5064
ENV IOC_DATA /data/epics/ioc/data
# Name if the IOC were are running in the container
# (defaults to sioc-smrf-ts01, cab be changed using --build-arg)
ARG IOC_NAME=sioc-smrf-ts01
# Copy the IOC produced during the building stage
COPY --from=builder ${APP_TOP} ${APP_TOP}
# Copy the ipmitool binary
COPY --from=builder /usr/bin/ipmitool /usr/bin/ipmitool
# Go to the application top level
WORKDIR ${APP_TOP}
# Start the IOC using the default shelfmanager name and slot number
ENTRYPOINT ["./start_ioc.sh","-S", "shm-smrf-sp01", "-N", "2"]
