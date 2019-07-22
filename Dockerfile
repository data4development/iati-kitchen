FROM openjdk:8-jdk-slim

LABEL maintainer="Rolf Kleef <rolf@data4development.nl>" \
  description="IATI/Pentaho Data Refresher" \
  repository="https://github.com/data4development/..."

# To be adapted in the cluster or runtime config
ENV KETTLE_JOBENTRY_LOG_DB=dwb_staging
ENV KETTLE_JOB_LOG_DB=dwb_staging
ENV KETTLE_STEP_LOG_DB=dwb_staging
ENV KETTLE_TRANS_LOG_DB=dwb_staging

# Postgresql database
ENV DWB_DB_HOST=127.0.0.1
ENV DWB_DB_PORT=5432
ENV DWB_DB_NAME=dataworkbench
ENV DWB_DB_USERNAME=postgres
ENV DWB_DB_PASSWORD=password_here
# ----------

ENV PDI_MAIN       8.0
ENV PDI_VERSION    8.0.0.0-28
ENV HOME /home

WORKDIR $HOME

RUN apt-get update && \
  apt-get -y install --no-install-recommends wget && \
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
# overwrite the local properties with the cluster version
COPY .kettle/cluster-kettle.properties .kettle/kettle.properties

ENV KETTLE_HOME $HOME

ENTRYPOINT ["./data-integration/kitchen.sh"]
