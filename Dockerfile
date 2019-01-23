# Application top directory
ARG APP_TOP=/root/Tpg

# Create the builder image
FROM jesusvasquez333/smurf-epics-slac:R1.0.0 as builder
ARG APP_TOP
# Prepare the build directory
RUN mkdir -p ${APP_TOP}
WORKDIR ${APP_TOP}
# Copy the source code
ADD . .
# Path the configuration files for the container environment
RUN sed -i -e 's|^PACKAGE_AREA=.*|PACKAGE_AREA=${PACKAGE_SITE_TOP}|g' configure/CONFIG_SITE.Common.rhel6-x86_64
RUN sed -i -e 's|^CROSS_COMPILER_TARGET_ARCHS\s*=.*|CROSS_COMPILER_TARGET_ARCHS=|g' configure/CONFIG_SITE
RUN rm -rf rm configure/CONFIG_SITE.Common.linuxRT-x86_64
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
# Go to the IOC top level
WORKDIR ${APP_TOP}/iocBoot/${IOC_NAME}
# Start the IOC by default
CMD ["./st.cmd"]
