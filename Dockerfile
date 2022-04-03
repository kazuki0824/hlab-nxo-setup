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
    apt install -y --no-install-recommends git python-catkin-tools

COPY ./overlay_ws/ /tmp/overlay_ws/
WORKDIR /tmp/overlay_ws
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    bash ./setup_rtmros_ws.sh

WORKDIR /
RUN rm -r /tmp/overlay_ws
COPY ./rtm_entrypoint.sh /
COPY --from=javabuild /tmp/externals/eclipse /hlab-nxo-setup/externals/
COPY --from=javabuild /tmp/externals/hironx-interface /hlab-nxo-setup/externals/
COPY ./setup_choreonoid.sh /hlab-nxo-setup/

# It is not intended to use rtm_entrypoint outside the Docker img, so allow execution only in Docker
RUN chmod +x /rtm_entrypoint.sh
ENTRYPOINT [ "/rtm_entrypoint.sh" ]
CMD [ "bash" ]


