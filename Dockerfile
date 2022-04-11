ARG DISTRIBUTION=melodic


FROM openjdk:8-jdk-slim AS javabuild
WORKDIR /tmp/externals
COPY ./externals/ /tmp/externals/
RUN apt update && apt install bash git ant unzip zip curl --no-install-recommends -y
RUN bash ./install_RTP.sh


FROM ros:${DISTRIBUTION}
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt update && \
    apt install -y --no-install-recommends -q git python-catkin-tools wget

COPY ./overlay_ws/ /tmp/overlay_ws/
WORKDIR /tmp/overlay_ws
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    bash ./setup_rtmros_ws.sh

WORKDIR /
RUN rm -r /tmp/overlay_ws
COPY ./rtm_entrypoint.sh /
COPY ./eclipse-workspace /root/eclipse-workspace/
COPY ./eclipse-workspace /hlab-nxo-setup/eclipse-workspace/
COPY --from=javabuild /tmp/externals/eclipse /hlab-nxo-setup/externals/eclipse/
COPY --from=javabuild /tmp/externals/hironx-interface /hlab-nxo-setup/externals/hironx-interface/
COPY ./setup_choreonoid.sh /hlab-nxo-setup/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt install software-properties-common --no-install-recommends -y && \
    add-apt-repository ppa:openjdk-r/ppa -y && \
    apt update && \
    apt install openjdk-8-jre -q -y --no-install-recommends && \
    apt purge software-properties-common --auto-remove -y && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64
    
RUN apt install -q -y --no-install-recommends cmake-qt-gui gnome-terminal dbus-x11


# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# It is not intended to use rtm_entrypoint outside the Docker img, so allow execution only in Docker
RUN chmod +x /rtm_entrypoint.sh
ENTRYPOINT [ "/rtm_entrypoint.sh" ]
CMD [ "bash" ]


