FROM ubuntu

# install packages for image building
RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=basic.sh,target=/tmp/basic.sh \
    /tmp/basic.sh

# install micromamba
RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=mamba.sh,target=/tmp/mamba.sh \
    /tmp/mamba.sh

# install python
RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=python.sh,target=/tmp/python.sh \
    /tmp/python.sh

# install R
RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=r.sh,target=/tmp/r.sh \
    /tmp/r.sh

RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=tools.sh,target=/tmp/tools.sh \
    /tmp/tools.sh

RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=code-server.sh,target=/tmp/code-server.sh \
    /tmp/code-server.sh

RUN --mount=type=bind,source=utils.sh,target=/tmp/utils.sh \
    --mount=type=bind,source=s6-overlay.sh,target=/tmp/s6-overlay.sh \
    /tmp/s6-overlay.sh

COPY root /

ENTRYPOINT [ "/init" ]
