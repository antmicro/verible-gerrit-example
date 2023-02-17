FROM gerritcodereview/gerrit:3.7.0

COPY scripts /scripts/

USER root

RUN yum -y install expect \
    wget \
    python39 \
    patch
RUN pip3 install click \
    unidiff
RUN patch < /scripts/entrypoint.patch

EXPOSE 29418 8080
