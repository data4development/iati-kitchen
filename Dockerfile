FROM openjdk:8-jdk-slim

LABEL maintainer="Rolf Kleef <rolf@drostan.org>" \
  description="IATI/Pentaho Data Refresher" \
  repository="https://github.com/data4development/..."

ENV PDI_MAIN       8.0
ENV PDI_VERSION    8.0.0.0-28
ENV HOME /home

WORKDIR $HOME

RUN apt-get update && \
  apt-get -y install --no-install-recommends wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN wget -q https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PDI_MAIN}/client-tools/pdi-ce-${PDI_VERSION}.zip && \
    unzip pdi-ce-${PDI_VERSION}.zip && \
    rm pdi-ce-${PDI_VERSION}.zip

COPY . ./

ENV KETTLE_HOME $HOME

ENTRYPOINT ["./data-integration/kitchen.sh"]
