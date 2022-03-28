FROM ros:melodic

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
RUN chmod +x /rtm_entrypoint.sh
ENTRYPOINT [ "/rtm_entrypoint.sh" ]
CMD [ "bash" ]


