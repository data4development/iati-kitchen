FROM openjdk:8-jdk-slim

LABEL maintainer="Rolf Kleef <rolf@data4development.nl>" \
  description="IATI/Pentaho Data Refresher" \
  repository="https://github.com/data4development/..."

# To be adapted in the cluster or runtime config:
# - the file .kettle/kettle.properties is injected in the container
#   via cluster/deploy/properties/kettle.properties
#   deployment-specific configuration should be updated there
# ----------

# To build the container
ENV \
    PDI_MAIN=8.0 \
    PDI_VERSION=8.0.0.0-28 \
    HOME=/home \
    KETTLE_HOME=/home

WORKDIR $HOME

RUN apt-get update && \
  apt-get -y install --no-install-recommends wget unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# get Pentaho Data Integration
# speed up and reduce footprint https://blog.twineworks.com/improving-startup-time-of-pentaho-data-integration-78d0803c559b
# via https://hub.docker.com/r/enricomariam42/pentaho-di/~/dockerfile/

RUN wget -q https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PDI_MAIN}/client-tools/pdi-ce-${PDI_VERSION}.zip && \
    unzip pdi-ce-${PDI_VERSION}.zip && \
    rm pdi-ce-${PDI_VERSION}.zip && \
    cd data-integration && \
    rm -rf \
      classes/kettle-lifecycle-listeners.xml \
      classes/kettle-registry-extensions.xml \
      lib/pdi-engine-api-*.jar \
      lib/pdi-engine-spark-*.jar \
      lib/pdi-osgi-bridge-core-*.jar \
      lib/pdi-spark-driver-*.jar \
      lib/pentaho-capability-manager-*.jar \
      lib/pentaho-connections-*.jar \
      lib/pentaho-cwm-*.jar \
      lib/pentaho-database-model-*.jar \
      lib/pentaho-hadoop-shims-api-*.jar \
      lib/pentaho-metaverse-api-*.jar \
      lib/pentaho-osgi-utils-api-*.jar \
      lib/pentaho-platform-api-*.jar \
      lib/pentaho-platform-core-*.jar \
      lib/pentaho-platform-extensions-*.jar \
      lib/pentaho-platform-repository-*.jar \
      lib/pentaho-service-coordinator-*.jar \
      plugins/kettle5-log4j-plugin \
      # plugins/*-xml-plugin \
      plugins/pentaho-big-data-plugin \
      samples \
      system/karaf \
      system/mondrian \
      system/osgi && \
    cd ..

COPY . ./

ENTRYPOINT ["./data-integration/kitchen.sh"]
